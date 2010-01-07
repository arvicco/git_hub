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

    base_uri 'http://github.com/api/v2/yaml/repos'

    attr_accessor :name, :owner, :description, :url, :homepage, :open_issues, :watchers, :forks, :fork, :private,
                  # additional attributes from search:
                  :id, :type, :size, :language, :created, :pushed, :score #?

    def initialize options
      super
      raise "Unable to initialize #{self.class} without name" unless @name
      @url ||= "http://github.com/#{@owner}/#{@name}"
      @type ||= "repo"
    end

    alias followers= watchers=
    alias followers watchers
    alias username= owner=
    alias username owner

    def fork?;
      !!self.fork
    end

    def private?;
      !!self.private
    end

    def clone_url
      url = private? || api.auth['login'] == self.owner ? "git@github.com:" : "git://github.com/"
      url += "#{self.owner}/#{self.name}.git"
    end

    class << self # Repo class methods

      # Find repo(s) of a (valid) github user.
      # Accepts Hash with keys:
      # :owner/:user/:username:: Github user name
      # :repo/:repository/:project/:name:: Repo name
      # :query:: Array of search terms as Strings or Symbols
      def find(opts={})
        if opts[:query]
          query = opts[:query].map(&:to_s).join('+')
          path = "/search/#{query}"
        else
          owner = opts[:owner] || opts[:user] || opts[:username] || opts[:login] || api.auth['login'] || ''
          repo = opts[:repo] || opts[:repository] || opts[:name] || opts[:project]
          path = repo ? "/show/#{owner}/#{repo}" : "/show/#{owner}"
        end
        convert_to_repo get(path)
      end

      alias show find
      alias search find

      # Create new github repo, accepts Hash with :repo, :description, :homepage, :public/:private
      # or repo name as a single parameter
      def create(*params)
        if params.size == 1 && params.first.is_a?(Hash)
          opts = params.first
          repo = opts[:repo] || opts[:repository] || opts[:name] || opts[:project]
          description = opts[:description] || opts[:descr] || opts[:desc]
          homepage = opts[:homepage]
          public = opts[:public] || !opts[:private] # default to true
        else # repo name as a single parameter
          repo = params.first.to_s
          description = nil
          homepage = nil
          public = false
        end
        raise("Unable to create #{self.class} without authorization") unless api.authenticated?
        convert_to_repo post("/create", 'name' => repo, 'description' => description,
                                        'homepage' => homepage, 'public' => (public ? 1 : 0))
      end

      private
      # TODO: generalize and move to Base?
      def convert_to_repo result
        if result['repository']
          new result['repository']
        elsif result['repositories']
          result['repositories'].map {|r| new r}
        else
          result
        end
      end
    end

    # Delete github repo
    def delete
      result = post("/delete/#{@name}")
      if result['delete_token']
        post("/delete/#{@name}", 'delete_token' => result['delete_token'])
      else
        result
      end
    end

    def add_service
    end

    def remove_service
    end

    def add_collaborator
    end

    def remove_collaborator
    end

    # repos/show/:user/:repo/tags
    # repos/show/:user/:repo/branches
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