require 'yaml'

module GitHub
  class Base
    @base_uri = ''

    def initialize(attributes={})
      attributes.each do |key, value|
        raise "No attr_accessor for #{key} on #{self.class}" unless respond_to?("#{key}=")
        self.send("#{key}=", value)
      end
    end

    def self.base_uri uri
      @base_uri = uri
    end

    class << self
      def request verb, uri, params = {}
        res = api.request verb, @base_uri+uri, params
        YAML::load(res.body) if res.respond_to?(:body) # res.kind_of?(Net::HTTPSuccess)
        #p "in show: #{res}: #{res.code}: #{res.http_version}: #{res.message}", res.body
      end

      def get uri, params ={}
        request :get, uri, params
      end

      def post uri, params = {}
        request :post, uri, params
      end

      def api
        @@api ||= GitHub::Api.instance
      end
    end

    def get uri, params ={}
      self.class.get uri, params
    end

    def post uri, params ={}
      self.class.post uri, params
    end

    def api
      self.class.api
    end
  end
end