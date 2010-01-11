require 'yaml'

module GitHub
  class Base

    def initialize(attributes={})
      set_attributes attributes
    end

    def set_attributes attributes
      attributes.each do |key, value|
        raise "No attr_accessor for #{key} on #{self.class}" unless respond_to?("#{key}=")
        self.send("#{key.to_s}=", value)
      end
    end

    class << self
      def request verb, uri, params = {}
        full_uri = uri[0] == '/' ? base_uri+uri : uri
        #p "request: #{verb} #{full_uri} #{params}"
        res = api.request verb, full_uri, params
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
        @base_uri || ''
      end

      private

      # retrieves arguments described by *args from an opts Hash
      def retrieve(opts, *args)
        args.map do |arg|
          opts[arg] || opts[arg.to_sym] || case arg.to_sym
            when :user
              opts[:owner] || opts[:username] || opts[:login] || api.auth['login']
            when :repo
              opts[:repository] || opts[:name] || opts[:project]
            when :sha
              opts[:hash] || opts[:object_id] || opts[:id]
            when :desc
              opts[:description] || opts[:descr]
            when :query
              opts[:search]
            when :branch
              'master'
            when :public
              !opts[:private] unless opts[:public] == false
            else
          end
        end
      end

      # tries to single instance or an Array of instances for a given Hash of
      # attributes Hash(es), returns original Hash if unsuccessful
      def instantiate hash
        if res = hash.values_at(*@singulars).compact.first
          new res
        elsif res = hash.values_at(*@plurals).compact.first
          res.map {|r| new r}
        else
          hash
        end
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