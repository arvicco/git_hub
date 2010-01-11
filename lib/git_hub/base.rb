require 'yaml'

module GitHub
  class Base

    def initialize(attributes={})
      update_attributes attributes
    end

    def update_attributes attributes
      attributes.each do |key, value|
        raise "No attr_accessor for #{key} on #{self.class}" unless respond_to?("#{key}=")
        self.send("#{key.to_s}=", value)
      end
    end

    class << self
      def request verb, uri, params = {}
        path = uri[0] == '/' ? base_uri+uri : uri
        #p "request: #{verb} #{path} #{params}"
        res = api.request verb, path, params
        YAML::load(res.body) if res.respond_to?(:body)
        #p "response: #{res}: #{res.code}: #{res.http_version}: #{res.message}", res.body
      end

      def get uri, params ={}
        request :get, uri, params
      end

      def post uri, params = {}
        request :post, uri, params
      end

      def api
        @@api ||= Api.instance
      end

      def set_resource base_uri, singulars, plurals
        @base_uri = base_uri
        @singulars = [singulars].flatten
        @plurals = [plurals].flatten
      end

      def base_uri
        @base_uri || ""
      end

      private

      def normalize opts
        opts[:user] ||= opts[:owner] || opts[:username] || opts[:login] || api.auth['login']
        opts[:repo] ||= opts[:repository] || opts[:name] || opts[:project]
        opts[:sha] ||= opts[:hash] || opts[:object_id] || opts[:id]
        opts[:description] ||= opts[:descr] || opts[:desc]
        opts[:query] ||= opts[:search]
        opts[:branch] ||= 'master'
        opts[:public] ||= !opts[:private] unless opts[:public] = false # defaults to true
      end

      def instantiate hash
        if res = contains(hash, @singulars)
          new res
        elsif res = contains(hash, @plurals)
          res.map {|r| new r}
        else
          hash
        end
      end

      def contains hash, keys
        keys.inject(nil) {|memo, key| memo ||= hash[key.to_s]}
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

    def to_s
      name
    end

  end
end