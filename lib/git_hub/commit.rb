module GitHub
  class Commit < Base

    set_resource 'http://github.com/api/v2/yaml/commits', 'commit', 'commits'

    attr_accessor :id, :author, :committer, :parents, :url, :committed, :authored, :message, :tree,
                  # retrieving commit for a specific sha - "/show/:user/:repo/:sha" adds:
                  :added, :modified, :removed,
                  # extra attributes:
                  :user, :repo

    aliases_for :id => [:sha, :name], :committed => :committed_date, :authored => :authored_date

    def initialize(opts)
      super
      raise "Unable to initialize #{self.class} without id(sha)" unless sha
      @committed = Time.parse(@committed) unless @committed.is_a?(Time)
      @authored = Time.parse(@authored) unless @authored.is_a?(Time)
    end

    class << self
      # Find commits, accepts Hash with keys:
      # :user/:owner/:username:: Github user name
      # :repo/:repository/:project:: Repo name
      # :branch:: Only commits for specific branch - default 'master'
      # :path:: Only commits for specific path
      # :sha/:id:: Only one commit with specific id (sha)
      def find(opts)
        user, repo, branch, sha, path = extract opts, :user, :repo, :branch, :sha, :path 
        repo_given = branch && user && repo
        path = if sha && repo_given
          "/show/#{user}/#{repo}/#{sha}"
        elsif path && repo_given
          "/list/#{user}/#{repo}/#{branch}/#{path}"
        elsif repo_given 
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