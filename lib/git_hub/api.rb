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

    #TODO: need to fix it in terms of options and add tests
    def ensure_auth opts ={}
      return if authenticated?
      login = opts[:login]
      token = opts[:token]
      raise("Authentication failed") unless login && token
      @auth = {'login'=>login, 'token'=>token}
    end

    def request verb, url, data = {}
      method = ('Net::HTTP::' + verb.to_s.capitalize).to_class
      uri = URI.parse url
      server = Net::HTTP.new(uri.host, uri.port)
      server.use_ssl = (uri.scheme == 'https')
      server.verify_mode = OpenSSL::SSL::VERIFY_NONE if server.use_ssl?
      server.start do |http|
        req = method.new(uri.path)
        req.form_data = data.merge(auth)
        http.request(req)
      end
    end
  end
end