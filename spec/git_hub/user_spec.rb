require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))
module GitHubTest
  def should_be_user(user, name = :joe007, type = :show)
    user.name.should == name.to_s
    user.username.should == name.to_s
    user.type.should == 'user'
    user.url.should == "http://github.com/#{name}"
    case name.to_sym
      when :joe007
        user.fullname.should == 'Joe Honne'
        user.id.should == 'user-173668'
        user.created.should == Time.parse('2009-12-29T15:33:44Z')
        case type.to_sym
          when :search
            # attributes differs between /show and /search
            user.public_repo_count.should == 4
            user.followers_count.should == 0
            user.location.should == ''
            user.public_gist_count.should == nil
            user.following_count.should == nil
            user.blog.should == nil
            # additonal attributes from /search
            user.language.should == ''
            user.pushed.should == Time.parse('2009-12-30T14:15:16.972Z')
            user.score.should be_close 4.18, 0.2
          when :show, :show_auth
            # attributes differs between /show and /search
            user.public_repo_count.should == 3
            user.followers_count.should == 1
            user.location.should == 'Germany'
            user.language.should == nil
            user.pushed.should == nil
            user.score.should == nil
            # additonal attributes from /show
            user.company.should == 'Joerific'
            user.following_count.should == 1
            user.public_gist_count.should == 0
            user.blog.should == 'http://www.joe007.org'
            if type == :show_auth
              # additional attributes for athenticated user
              user.plan.should == {'name' => 'free', 'collaborators' => 0, 'space' => 307200, 'private_repos' => 0}
              user.collaborators.should == 0
              user.disk_usage.should == 76
              user.private_gist_count.should == 0
              user.owned_private_repo_count.should == 0
              user.total_private_repo_count.should == 0
            end
        end
      when :arvicco
        user.id.should == 'user-39557'
        user.followers_count.should == 1
        user.following_count.should == 1
        user.public_repo_count.should be_close 11.76, 0.8
        user.created.should == Time.parse('2008-12-10 05:56:19 -08:00')
    end
  end

  describe GitHub::User do
    before(:all) do
      FakeWeb.allow_net_connect = false if TEST_FAKE_WEB
    end
    after(:each) do
      FakeWeb.clean_registry if TEST_FAKE_WEB
      api.auth.clear
      wait
    end

    context '.find as /show/:user' do
      it 'finds valid github user' do
        expect(:get, "#{github_yaml}/user/show/joe007") do
          user = GitHub::User.find(:user=>'joe007')
          should_be_user user, :joe007
        end
      end

      it 'finds authenticated github user with additional attributes set' do
        expect(:get, "#{github_yaml}/user/show/joe007", :auth) do
          api.auth = joe_auth
          user = GitHub::User.find(:user=>'joe007')
          should_be_user user, :joe007, :show_auth
        end
      end

      it 'fails to find invalid github user' do
        expect(:get, "#{github_yaml}/user/show/joe_is_not_github_user") do
          res = GitHub::User.find(:user=>'joe_is_not_github_user')
          res.code.should == 404.to_s
          res.message.should == 'Not Found'
        end
      end
    end

    context '.find as /search/:search+:terms' do
      it 'finds github user by name' do
        expect(:get, "#{github_yaml}/user/search/joe+007") do
          user = GitHub::User.find(:query=>['joe', '007']).first
          should_be_user user, :joe007, :search
        end
      end
    end

    context 'following' do
      context 'collections' do
        it 'retrieves followers of this user' do
          expect(:get, "#{github_yaml}/user/show/joe007/followers") do
            expect(:get, "#{github_yaml}/user/show/arvicco") do
              followers = joe.followers
              followers.should be_kind_of Array
              followers.should have(1).user
              followers.each {|user| user.should be_a GitHub::User}
              should_be_user followers.first, :arvicco
            end
          end
        end

        it 'retrieves users that are followed by this user' do
          expect(:get, "#{github_yaml}/user/show/joe007/following") do
            expect(:get, "#{github_yaml}/user/show/arvicco") do
              following = joe.following
              following.should be_kind_of Array
              following.should have(1).user
              following.each {|user| user.should be_a GitHub::User}
              should_be_user following.first, :arvicco
            end
          end
        end
      end

      context 'actions' do
        before(:each) do
          expect(:get, "http://github.com/users/follow")
          expect(:get, "#{github_yaml}/user/show/arvicco")
          authenticate_as_joe
        end
        after(:each) do
          # after - normal state is for joe to follow arvicco
          authenticate_as_joe
          expect(:post, "#{github_yaml}/user/follow/arvicco")
          joe.follow! :arvicco
          wait
        end

        it 'stops following previously followed user (if authenticated)' do
          expect(:get, "http://github.com/users/follow") do
            expect(:get, "#{github_yaml}/user/show/joe007/following", :empty)
            following = joe.unfollow! :arvicco
            following.should be_kind_of Array
            following.should be_empty
          end
        end

        it 'starts following new user (if authenticated)' do
          # before - normal state is for joe to follow arvicco
          expect(:get, "#{github_yaml}/user/show/joe007/following")
          joe.unfollow! :arvicco
          wait

          expect(:post, "#{github_yaml}/user/follow/arvicco") do
            following = joe.follow! :arvicco
            following.should be_kind_of Array
            following.should have(1).user
            following.each {|user| user.should be_a GitHub::User}
            should_be_user following.first, :arvicco
          end
        end
      end
    end
  end
end
