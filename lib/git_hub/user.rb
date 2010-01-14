require 'time'

module GitHub
  class User < Base

    set_resource 'http://github.com/api/v2/yaml/user', 'user', 'users'

    attr_accessor :name, :company, :location, :created, :public_repo_count, :public_gist_count,
                  :id, :homepage, :followers_count, :following_count, :login, :email,
                  # additional attributes for authenticated user:
                  :plan, :collaborators, :disk_usage, :private_gist_count,
                  :owned_private_repo_count, :total_private_repo_count,
                  # additional attributes from search:
                  :language, :fullname, :type, :pushed, :score

    aliases_for :homepage => :blog, :name => [:user, :username], :created => :created_at

    def initialize(opts)
      @public_repo_count = opts.delete('repos')  # TODO: find better way without modifying opts?
      @followers_count = opts.delete('followers')
      super
      if @login #need to correct attributes generated by /show/:user
        @name, @fullname = @login, @name
        @id = "user-#{@id}"
      end
      raise "Unable to initialize #{self.class} without name for #{opts}" unless @name
      @created = Time.parse(@created) unless @created.is_a?(Time)
      @pushed = Time.parse(@pushed) if @pushed && !@pushed.is_a?(Time)
      @type ||= "user"
    end

    def url; "http://github.com/#{@name}" end

    class << self

      # Find github user, accepts Hash with keys:
      # :user/:username:: Github user name
      # :repo/:repository/:project/:name:: Repo name
      # :query/:search:: Array of search terms as Strings or Symbols
      def find(opts)
        user, query = extract opts, :user, :query
        path = if query
          "/search/#{query.map(&:to_s).join('+')}"
        elsif user
          "/show/#{user}"
        else
          raise "Unable to find #{self.class}(s) for #{opts}"
        end
        instantiate get(path)
      end
    end

    def followers
      res = get("/show/#{@name}/followers")
      res['users'].map {|user| User.find(:user => user )}
    end

    def following
      get("/show/#{@name}/following")['users'].map {|user| User.find(:user => user )}
    end

    def follow user
      post("/follow/#{user}")['users'].map {|user| User.find(:user => user )}
    end

    def unfollow user # api /user/unfollow/:user is not working properly atm, using http
      res = get 'http://github.com/users/follow', 'target' => user
      raise "User Not Found #{user}" unless res.code == 302.to_s
      following
    end
  end
end