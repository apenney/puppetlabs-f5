## This code is simply the icontrol gem renamed and mashed up.
require 'openssl'
require 'savon'

module Puppet::Util::NetworkDevice::F5
  class Transport
    attr_reader :hostname, :username, :password, :directory
    attr_accessor :wsdls, :endpoint, :interfaces

    def initialize hostname, username, password, wsdls = []
      @hostname = hostname
      @username = username
      @password = password
      @wsdls = wsdls
      @endpoint = '/iControl/iControlPortal.cgi'
      @interfaces = {}
    end

    def testing?
      false
    end

    def wsdl_location(wsdl)
      if self.testing?
        directory = File.join(File.dirname(__FILE__), '..', 'wsdl')
        File.join(directory, wsdl + '.wsdl')
      else
        "https://#{@hostname}#{@endpoint}?WSDL=#{wsdl}"
      end
    end

    def get_interfaces
      @wsdls.each do |wsdl|

        namespace = 'urn:iControl:' + wsdl.gsub(/(.*)\.(.*)/, '\1/\2')
        url = 'https://' + @hostname + '/' + @endpoint
        @interfaces[wsdl] = Savon.client(wsdl: self.wsdl_location(wsdl), ssl_verify_mode: :none,
          basic_auth: [@username, @password], endpoint: url,
          namespace: namespace, convert_request_keys_to: :none,
          strip_namespaces: true, log: false)
      end

      @interfaces
    end

    def get_all_interfaces
      @wsdls = self.available_wsdls
      puts @wsdls
      self.get_interfaces
    end

    def available_interfaces
      @interfaces.keys.sort
    end

    def available_wsdls
      Dir.entries(@directory).delete_if {|file| !file.end_with? '.wsdl'}.sort
    end
  end
end
