require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest

  def should_be_repo repo, name = :fine_repo, type = :show
    repo.should be_a GitHub::Repo
    repo.should_not be_fork
    repo.should_not be_private
    repo.owner.should == 'joe007'
    repo.username.should == 'joe007'
    repo.type.should == 'repo'
    repo.name.should == name.to_s
    repo.url.should == "http://github.com/joe007/#{name.to_s}"
    repo.clone_url.should == if api.authenticated?
      "git@github.com:joe007/#{name.to_s}.git"
    else
      "git://github.com/joe007/#{name.to_s}.git"
    end
    case name.to_s
      when 'fine_repo'
        repo.watchers.should == 2
        repo.followers.should == 2
        repo.description.should == 'Fine repo by joe'
        case type.to_s
          when 'show'
            repo.homepage.should == ''
            repo.open_issues.should == 0
            repo.forks.should == 0
            # unset attributes
            repo.id.should == nil
            repo.language.should == nil
            repo.size.should == nil
            repo.created.should == nil
            repo.pushed.should == nil
            repo.score.should == nil
          when 'search'
            repo.forks.should == 1
            repo.id.should == 'repo-452322'
            repo.language.should == ''
            repo.size.should == 76
            repo.created.should == Time.parse('2009-12-29T15:51:41Z')
            repo.pushed.should == Time.parse('2010-01-08T10:49:49Z')
            repo.score.should == 11.765799
            # unset attributes
            repo.homepage.should == nil
            repo.open_issues.should == nil
        end
      when 'new_repo'
        repo.watchers.should == 1
        repo.followers.should == 1
        repo.open_issues.should == 0
        repo.forks.should == 0
        case type.to_s
          when 'simple'
            repo.description.should == nil
            repo.homepage.should == nil
          when 'with_attributes'
            repo.description.should == 'New repo'
            repo.homepage.should == 'http://joe.org/new_repo'
        end
    end
  end

  describe GitHub::Repo do
    after(:each) do
      api.auth.clear
    end

    context '.find as /show/:user/:repo' do
      it 'finds repo of a (valid) github user' do
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo") do
          repo = GitHub::Repo.find(:user=>'joe007', :repo=>'fine_repo')
          should_be_repo repo
        end
      end

      it 'finds repo if user object is given instead of username' do
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo") do
          repo = GitHub::Repo.find(:user=>joe, :repo=>'fine_repo')
          should_be_repo repo
        end
      end

      it 'fails returning error object instead of non-existing repo' do
        expect(:get, "#{github_yaml}/repos/show/joe007/err_repo") do
          res = GitHub::Repo.find(:user=>'joe007', :repo=>'err_repo')
          res.should have_key 'error' # res = {"error"=>[{"error"=>"repository not found"}]}
          res['error'].should be_kind_of Array
          res['error'].first.should have_key 'error'
        end
      end
    end

    context '.find as /show/:user)' do
      it 'returns an array of repos for a valid github user' do
        expect(:get, "#{github_yaml}/repos/show/joe007") do
          repos = GitHub::Repo.find(:user=>'joe007')
          repos.should_not be_empty
          repos.should be_an Array
          repos.should have(3).repos
          repos.each {|repo| repo.should be_a GitHub::Repo}
          should_be_repo repos.first
        end
      end
    end

    context '.find as /search' do
      it 'searches github repos with specific search terms' do
        expect(:get, "#{github_yaml}/repos/search/fine+repo") do
          repos = GitHub::Repo.find(:query=>['fine', 'repo'])
          repos.should_not be_empty
          repos.should be_an Array
          repos.should have(1).repos
          repos.each {|repo| repo.should be_a GitHub::Repo}
          should_be_repo repos.first, :fine_repo, :search
        end
      end
    end

    context '.create' do
      it 'creates new repo for authenticated github user' do
        api.auth = joe_auth
        keys = {:name => 'new_repo', :public => 1}.merge joe_auth
        expects(:post, "#{github_yaml}/repos/create", :expected_keys=>keys, :body=>body_from_file('/repos/create.1'))
        repo = GitHub::Repo.create(:repo=>'new_repo')
        should_be_repo repo, 'new_repo', :simple
      end

      it 'creates new repo with extended attributes' do
        api.auth = joe_auth
        keys = {:name => 'new_repo', :description => 'New repo',
                :homepage => 'http://joe.org/new_repo', :public => 1}.merge joe_auth
        expects(:post, "#{github_yaml}/repos/create", :expected_keys=>keys, :body=>body_from_file('/repos/create.2'))
        repo = GitHub::Repo.create(:name=>'new_repo', :description => 'New repo',
                                   :homepage => 'http://joe.org/new_repo', :private => false)
        should_be_repo repo, 'new_repo', :with_attributes
      end

      it 'fails if repo with the same name already exists' do
        api.auth = joe_auth
        keys = {:name => 'fine_repo', :public => 1}.merge joe_auth
        expects(:post, "#{github_yaml}/repos/create", :expected_keys=>keys, :body=>body_from_file('/repos/create.4'))
        res = GitHub::Repo.create(:name=>'fine_repo')
        res.should have_key 'error' # res = {"error"=>[{"error"=>"repository not found"}]}
        res['error'].should be_kind_of Array
        res['error'].first.should have_key 'error'
        res['error'].first['error'].should == 'repository creation failed'
      end

    end

    context '#delete' do
      it 'deletes new repo for authenticated github user' do
        api.auth = joe_auth
        expect(:get, "#{github_yaml}/repos/show/joe007/new_repo")
        repo = GitHub::Repo.find(:repo=>'new_repo')
        post1 = { :expected_keys => joe_auth,
                  :body => body_from_file('/repos/delete/new_repo.1') }
        post2 = { :expected_keys => {:delete_token => :any}.merge(joe_auth),
                  :body => body_from_file('/repos/delete/new_repo.2') }
        expects(:post, "#{github_yaml}/repos/delete/new_repo", [post1, post2])
        res = repo.delete
        res['status'].should == 'deleted'
      end
    end

    context '#branches, tags, commits' do
      before(:each) do
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo")
        @repo = GitHub::Repo.find(:user=>'joe007', :repo=>'fine_repo')
      end

      it 'retrieves repo tags as a Hash with tag name keys and Commit values' do
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/3a70f86293b719f193f778a8710b1f83f2f7bf38")
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/f7f5dddaa37deacc83f1f56876e2b135389d03ab")
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8")
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo/tags") do
          tags = @repo.tags
          tags.should be_kind_of Hash
          tags.should have(3).tags
          tags.each {|tag, commit| commit.should be_a GitHub::Commit}
          tags.should have_key 'v0.1.2'
          should_be_commit tags['v0.1.2'], '5e61'
        end
      end

      it 'retrieves repo branches as a Hash with branch name keys and Commit values' do
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo/branches") do
          branches = @repo.branches
          branches.should be_kind_of Hash
          branches.should have(1).branches
          branches.each {|tag, commit| commit.should be_a GitHub::Commit}
          branches.should have_key 'master'
          should_be_commit branches['master'], '5e61'
        end
      end

      it 'retrieves commits for a repo branch (master by default)' do
        expect(:get, "#{github_yaml}/commits/list/joe007/fine_repo/master") do
          commits = @repo.commits
          commits.should be_kind_of Array
          commits.should have(5).commits
          commits.each {|commit| commit.should be_a GitHub::Commit}
          should_be_commit commits.first, '5e61'
        end
      end

      it 'retrieves commits with a specific id' do
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8") do
          commit = @repo.commits :sha=> '5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
          should_be_commit commit, '5e61'
        end
      end
    end

    context 'following a repository' do
      before(:each) do
        expect(:get, "#{github_yaml}/repos/show/joe007/fine_repo")
        @repo = GitHub::Repo.find(:user=>'joe007', :repo=>'fine_repo')
      end

      it 'watches a repository' do
        pending
        @repo.watch
      end
      it 'unwatches a repository' do
        pending
        @repo.watch
      end
    end

    it 'tests' do
      pending
      api.auth = joe_auth
      expect(:get, "#{github_yaml}/repos/showp/joe007/new_repo")
      repos = GitHub::Repo.show('arvicco')
      p repos
      p repos.map(&:url)
      repos.should be_an Array
      repos.should_not be_empty
      if repos.last.name == 'new_repo'
        repos.last.delete
      end
      true.should == false
    end

  end # describe GitHub::Repo
end # module GithubTest

# EOF
