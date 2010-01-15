require 'yaml'

module GitHub
  API = Api.instance
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
        res = API.request verb, full_uri, params
        #p "response: #{res}: #{res.code}: #{res.http_version}: #{res.message}", res.body
        if res.respond_to?(:content_type, :body) && res.content_type =~ /application\/x-yaml/
          YAML::load(res.body)
        else
          res
        end
      end

      def get uri, params ={}
        request :get, uri, params
      end

      def post uri, params = {}
        request :post, uri, params
      end

      def set_resource base_uri, singulars, plurals
        @base_uri = base_uri
        @singulars = [singulars].flatten
        @plurals = [plurals].flatten
      end

      def base_uri
        @base_uri || ''
      end

      # Meta-defines alias(es) for multiple attribute-accessors
      def aliases_for attributes
        attributes.each do |attr, nicks|
          [nicks].flatten.each do |nick|
            self.class_eval("alias #{nick} #{attr}
                             alias #{nick}= #{attr}=")
          end
        end
      end

      private

      NICKNAMES = { :user => [:owner, :username, :login],
                    :repo => [:repository, :project],
                    :sha => [:id, :object_id, :hash],
                    :desc => [:description, :descr],
                    :query => :search }

      # matches arguments supplied by args Array to parameters specified by *params
      # TODO: replace opts[:name] with class-specific opts[:@singular]?
      def extract(args, *params)
        args, opts = args.args_and_options
        params.map do |param|
          arg = args.next rescue nil
          arg ||= opts[param] || opts[param.to_sym]
          nicks = NICKNAMES[param.to_sym]
          [nicks].flatten.each {|nick| arg ||= opts[nick]} if nicks
          arg ||= case param.to_sym
            when :user then
              API.auth['login']
            when :branch then
              'master'
            when :public then
              !opts[:private] unless opts[:public] == false
          end
        end
      end

      # Creates single instance or Array of instances for a given Hash of
      # attribute Hash(es), returns original Hash if unsuccessful
      def instantiate hash, extra_attributes={}
        return hash unless hash.kind_of? Hash
        if init = hash.values_at(*@singulars).compact.first
          new init.merge extra_attributes
        elsif inits = hash.values_at(*@plurals).compact.first
          inits.map {|each| new each.merge extra_attributes}
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

    def to_s
      name
    end

  end
end