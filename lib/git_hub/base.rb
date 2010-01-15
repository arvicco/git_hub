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
      def request verb, uri, data = {}
        full_uri = uri[0] == '/' ? base_uri+uri : uri
        res = API.request verb, full_uri, data
        if res.respond_to?(:content_type, :body) && res.content_type =~ /application\/x-yaml/
          YAML::load(res.body)
        else
          res
        end
      end

      def get uri, data = {}
        request :get, uri, data
      end

      def post uri, data = {}
        request :post, uri, data
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

      # matches arguments supplied by args Array to parameters specified by *params Array
      # TODO: replace opts[:name] with class-specific opts[:@singular]?
      def extract(args, *params)
        args, opts = args.args_and_opts
        params.map do |param|                # for every symbol in params Array:
          arg = args.next rescue nil         #   try to assign sequential argument from args
          arg ||= extract_value opts, param  #   try to assign named argument from opts
          arg || case param                  #   assign defaults if no other value found
            when :user
              API.auth['login']
            when :branch
              'master'
            when :public
              !opts[:private] unless arg == false
            else
              nil                             #   no default found, parameter is nil
          end
        end
      end

      NICKNAMES = { :user => [:owner, :username, :login],
                    :repo => [:repository, :project],
                    :sha => [:id, :object_id, :hash],
                    :desc => [:description, :descr],
                    :query => :search }

      # extracts from opts value indexed by param or any of its nicknames
      def extract_value opts, param
        nicks = [param, NICKNAMES[param]].flatten.compact
        opts.values_at(*nicks+nicks.map(&:to_s)).compact.first
      end

      # Creates single instance or Array of instances for a given Hash of
      # attribute Hash(es), returns original Hash if unsuccessful
      def instantiate hash, extra_attributes={}
        return hash unless hash.kind_of? Hash
        init = hash.values_at(*@singulars).compact.first
        inits = hash.values_at(*@plurals).compact.first
        if init
          new init.merge extra_attributes
        elsif inits
          inits.map {|each| new each.merge extra_attributes}
        else
          hash
        end
      end
    end

    def get uri, data = {}
      self.class.get uri, data
    end

    def post uri, data = {}
      self.class.post uri, data
    end

    def to_s
      name
    end

  end
end