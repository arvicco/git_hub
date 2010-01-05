require 'net/https'
require 'singleton'

module GitHub
  class Api
    include Singleton

    attr_writer :auth

    def auth
      @auth || {}
    end

    def authenticated?
      auth != {}
    end

    # Turns string into appropriate class constant, returns nil if class not found
    def classify name
      klass = name.split("::").inject(Kernel) {|klass, const_name| klass.const_get const_name }
      klass.is_a?(Class) ? klass : nil
    rescue NameError
      nil
    end

    def request verb, url, params = {}
      method = classify('Net::HTTP::' + verb.to_s.capitalize)
      uri = URI.parse url
      server = Net::HTTP.new(uri.host, uri.port)
      server.use_ssl = (uri.scheme == 'https')
      server.verify_mode = OpenSSL::SSL::VERIFY_NONE if server.use_ssl?
      server.start do |http|
        req = method.new(uri.path)
        req.form_data = params.merge(auth)
        http.request(req)
      end
    end
  end
end