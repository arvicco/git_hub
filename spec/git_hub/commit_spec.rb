require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest
  describe GitHub::Commit do
    after(:each) do
      api.auth.clear
    end

    context '.find' do
      it 'finds all commits for a (valid) github user repo' do
        expect(:get, "#{github_yaml}/commits/list/joe007/fine_repo/master") do
          commits = GitHub::Commit.find(:user=>'joe007', :repo=>'fine_repo')
          commits.should be_an Array
          commits.should_not be_empty
          commits.should have(5).commits
          commits.each {|commit| commit.should be_a GitHub::Commit}
          should_be_5e61 commits.first
        end
      end

      it 'finds all commits for a specific id path' do
        expect(:get, "#{github_yaml}/commits/list/joe007/fine_repo/master/README") do
          commits = GitHub::Commit.find(:user=>'joe007', :repo=>'fine_repo', :path=>'README')
          commits.should be_an Array
          commits.should_not be_empty
          commits.should have(1).commit
          commits.each {|commit| commit.should be_a GitHub::Commit}
          should_be_543b commits.first
        end
      end

      it 'finds commits with a specific id(sha)' do
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8") do
          commit = GitHub::Commit.find :user=> 'joe007', :repo=>'fine_repo', :sha=> '5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
          should_be_5e61 commit
        end
      end

      it 'retrieves additional attributes for a commit specified by id(sha)' do
        expect(:get, "#{github_yaml}/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8") do
          commit = GitHub::Commit.find :user=> 'joe007', :repo=>'fine_repo', :sha=> '5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
          commit.added.should == []
          commit.modified.should == [{"diff"=>"@@ -1 +1 @@\n-0.1.1\n+0.1.2", "filename"=>"VERSION"}]
          commit.removed.should == []
        end
      end
    end
  end # describe GitHub::Commit

end # module GithubTest

# EOF
