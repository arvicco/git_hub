module GitHub
  class Repo < Base
    GITHUB_SERVICES = {
#[github]
#	user = user
#	token = token
#	:donate => {:path => '/edit/donate',  :inputs => ['paypal']}
#	homepage = homepage_url
#	webhooks => {:path => '/edit/postreceive_urls', :fields => []
#http://rdoc.info/projects/update, http://runcoderun.com/github, http://api.devver.net/github
#	basecamp = url, username, password, project, category
#	cia = true
#	campfire = subdomain, username, password, room, ssl, play_sound
#	email = arvitallian@gmail.com
#	fogbugz = cvssubmit_url, fb_version, fb_repoid
#	friendfeed = nickname, remotekey
#	irc = server, port, room, password, nick, ssl
#	jabber = user
#	lighthouse = subdomain, project_id, token, private
#	presently = subdomain, group_name, username, password
#	rubyforge = username, password, grupid
#	runcoderun = true
#	trac = url, token
#	twitter = username, password, digest
    }

    set_resource 'http://github.com/api/v2/yaml/repos', 'repository', 'repositories'

    attr_accessor :name, :user, :description, :url, :homepage, :open_issues, :followers, :forks, :fork, :private,
                  # additional attributes from search:
                  :id, :type, :size, :language, :created, :pushed, :score #?

    aliases_for :followers => :watchers, :user => [:username, :owner]

    def initialize(opts)
      super
      raise "Unable to initialize #{self.class} without user and name" unless @user && @name
      @url ||= "http://github.com/#{@user}/#{@name}"
      @type ||= "repo"
      @created = Time.parse(@created) unless !@created || @created.is_a?(Time)
      @pushed = Time.parse(@pushed) unless !@pushed ||@pushed.is_a?(Time)
    end

    def fork?;
      !!fork
    end

    def private?;
      !!self.private
    end

    def clone_url
      url = private? || API.auth['login'] == user ? "git@github.com:" : "git://github.com/"
      url += "#{@user}/#{@name}.git"
    end

    def tags
      hash_of_commits(:tags)
    end

    def branches
      hash_of_commits(:branches)
    end

    # Returns commits for this repo, accepts options:
    # :branch:: Only commits for specific branch - default 'master'
    # :path:: Only commits for specific path
    # :sha/:id:: Only one commit with specific id (sha)
    def commits opts = {}
       Commit.find opts.merge(:user => @user, :repo => @name)
    end

    class << self # Repo class methods

      # Find repo(s) of a (valid) github user, accepts Hash with keys:
      # :owner/:user/:username:: Github user name
      # :repo/:repository/:project/:name:: Repo name
      # :query/:search:: Array of search terms as Strings or Symbols
      def find(opts)
        user, repo, query = extract opts, :user, :repo, :query
        path = if query
          "/search/#{query.map(&:to_s).join('+')}"
        elsif user && repo
          "/show/#{user}/#{repo}"
        elsif user
          "/show/#{user}"
        else
          raise "Unable to find #{self.class}(s) for #{opts}"
        end
        instantiate get(path)
      end

      alias show find
      alias search find

      # Create new github repo, accepts Hash with :repo, :description, :homepage, :public/:private
      def create!(opts)
        repo, desc, homepage, public = extract opts, :repo, :desc, :homepage, :public
        API.ensure_auth opts
        instantiate post("/create", 'name' => repo, 'description' => desc,
                         'homepage' => homepage, 'public' => (public ? 1 : 0))
      end
    end 

    # Delete github repo, accepts optional Hash with authentication
    def delete!(opts = {})
      API.ensure_auth opts
      result = post("/delete/#{@name}")
      if token = result['delete_token']
        post("/delete/#{@name}", 'delete_token' => token)
      else
        result
      end
    end 

    def add_service
    end

    def remove_service
    end

    def collaborators
      'repos/show/:user/:repo/collaborators'
    end

    def add_collaborator
    end

    def remove_collaborator
    end

    private

    def hash_of_commits(resource)
      result = get "/show/#{@user}/#{@name}/#{resource}"
      if tagged_shas = result[resource.to_s]
        tagged_commits = tagged_shas.map do |tag,sha|
          [tag, Commit.find(:user=>@user, :repo=>@name, :sha=>sha)]
        end
        Hash[*tagged_commits.flatten]
      else
        result
      end
    end

    # repos/show/:user/:repo/languages
    # repos/show/:user/:repo/network
    #
    # repos/show/:user/:repo/collaborators
    # POST repos/collaborators/:repo/add/:user
    # POST repos/collaborators/:repo/remove/:user
    #
    # repos/keys/:repo
    # POST repos/key/:repo/remove
    # POST repos/key/:repo/add {title => title of the key, key => public key data}

    # POST repos/set/public/:repo
    # POST repos/set/private/:repo

    # ? repos/fork/:user/:repo
    # repos/unwatch/:user/:repo
    # repos/watch/:user/:repo
    # repos/show/:user/:repo ? new?

  end
end