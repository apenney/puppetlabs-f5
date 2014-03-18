require 'spec_helper'
require "savon/mock/spec_helper"

describe Puppet::Type.type(:f5_user).provider(:f5_user) do
  include Savon::SpecHelper

  before(:all) {
    # All creations of provider instances seem to call this
    message = { folder: "/Common" }
    fixture = File.read("spec/fixtures/f5/management_partition/set_active_folder.xml")
    savon.expects(:set_active_folder).with(message: message).returns(fixture)
  }

  before(:each) {
    # Turn on mocking for savon
    savon.mock!

    # Fake url to initialize the device against
    allow(Facter).to receive(:value).with(:feature)
    allow(Facter).to receive(:value).with(:url).and_return("https://admin:admin@f5.puppetlabs.lan/")
  }

  after(:each)  { savon.unmock! }

  let(:f5_user) do
    Puppet::Type.type(:f5_user).new(
      :name            => 'test',
      :password        => { 'is_encrypted' => false, 'password' => 'beep' },
      :login_shell     => '/bin/bash',
      :user_permission => { '[All]' => 'USER_ROLE_ADMINISTRATOR' },
      :description     => 'beep',
      :fullname        => 'test user',
    )
  end

  let(:provider) { f5_user.provider }

  describe '#instances' do
    it do
      # Update this xml file with a real xml response
      get_list_xml = File.read("spec/fixtures/f5/management_partition/get_list.xml")
      savon.expects(:get_list).returns(get_list_xml)
      subject.class.instances
    end
  end

  describe '#create' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_user/create_response.xml')
      message = {:users=>{:item=>[{:user=>{:name=>"test", :full_name=>"test user"}, :password=>{:password=>"beep", :is_encrypted=>false}, :login_shell=>"/bin/bash", :permissions=>[{:item=>{:partition=>"[All]", :role=>"USER_ROLE_ADMINISTRATOR"}}]}]}}
      savon.expects(:create_user_3).with(message: message).returns(fixture)
      provider.create
    end
  end

  describe '#destroy' do
    it 'returns appropriate xml' do
      fixture = File.read('spec/fixtures/f5/f5_user/destroy_response.xml')
      savon.expects(:delete_user).with(message: { user_names: { item: 'test' }}).returns(fixture)
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'returns false' do
      get_list_xml = File.read("spec/fixtures/f5/management_partition/get_list.xml")
      savon.expects(:get_list).returns(get_list_xml)
      expect(provider.exists?).to be_false
    end
  end

  describe 'user_permission' do
    it 'returns appropriate XML' do
    end
  end
  describe 'user_permission=' do
  end

  describe 'password' do
  end
  describe 'password=' do
  end

  describe 'fullname' do
  end
  describe 'fullname=' do
  end

  describe 'login_shell' do
  end
  describe 'login_shell=' do
  end
end
