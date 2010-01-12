module GitHub
  class Commit < Base

    set_resource 'http://github.com/api/v2/yaml/commits', 'commit', 'commits'

    attr_accessor :id, :author, :committer, :parents, :url, :committed_date, :authored_date, :message, :tree,
                  # retrieving commit for a specific sha - "/show/:user/:repo/:sha" adds:
                  :added, :modified, :removed,
                  # extra attributes:
                  :user, :repo

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
      # :branch:: Only commits for specific branch - default 'master'
      # :path:: Only commits for specific path
      # :sha/:id:: Only one commit with specific id (sha)
      def find(opts)
        user, repo, branch, sha, path = extract opts, :user, :repo, :branch, :sha, :path 
        path = if sha && user && repo
          "/show/#{user}/#{repo}/#{sha}"
        elsif path && user && repo
          "/list/#{user}/#{repo}/#{branch}/#{path}"
        elsif branch && user && repo
          "/list/#{user}/#{repo}/#{branch}"
        else
          raise "Unable to find #{self.class}(s) for #{opts}"
        end
        instantiate get(path), :user=>user, :repo=>repo
      end

      alias show find
    end
  end

end