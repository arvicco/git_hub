module GitHub
  class Commit < Base

    set_resource 'http://github.com/api/v2/yaml/commits', 'commit', ['commits', 'tags', 'branches']

    attr_accessor :id, :author, :committer, :parents, :url, :committed_date, :authored_date, :message, :tree,
                  #  :user, :name, :sha, :repo,
                  # retrieving commit for a specific sha - "/show/#{opts[:user]}/#{opts[:repo]}/#{opts[:sha]}"
                  :added, :modified, :removed
    
    def initialize opts
      super
      raise "Unable to initialize #{self.class} without id(sha)" unless sha
    end

    alias name id
    alias name= id=
    alias sha id
    alias sha= id=

    class << self
      # Find commits, accepts Hash with keys:
      # :user/:owner/:username:: Github user name
      # :repo/:repository/:project:: Repo name
      # :branch:: Repo branch - default 'master'
      # :path:: For specific path
      # :sha/:hash/:id:: Unique commit id (sha)
      def find(opts)
        normalize opts
        raise "Unable to find Commits for #{opts}" unless opts[:user] && opts[:repo]
        path = if opts[:sha]
          "/show/#{opts[:user]}/#{opts[:repo]}/#{opts[:sha]}"
        elsif opts[:path]
          "/list/#{opts[:user]}/#{opts[:repo]}/#{opts[:branch]}/#{opts[:path]}"
        else
          "/list/#{opts[:user]}/#{opts[:repo]}/#{opts[:branch]}"
        end
        instantiate get(path)
      end

      #alias show find
    end
  end

end