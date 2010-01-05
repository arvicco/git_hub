require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest
  describe GitHub::Api do
    after(:each) do
      GitHub::Api.instance.auth.clear
    end

    context 'authentication' do
      it 'starts out unauthenticated' do
        api = described_class.instance
        api.should_not be_authenticated
        api.auth.should == {}
      end

      it 'authenticates with login and token' do
        api = described_class.instance
        api.auth = joe_auth
        api.should be_authenticated
        api.auth.should == joe_auth
        api.auth.clear
        api.should_not be_authenticated
        api.auth.should == {}
      end
    end

    context 'requests' do
      before :each do
        @api= described_class.instance
        @api.auth = joe_auth
        @hash = {'name' => 'name', 'description' => 'descr'}
        @hash_with_auth = @hash.merge joe_auth
      end

      context 'post' do
        it 'connects via http, submits post request' do
          server, post = stub_server_and_req()
          Net::HTTP::Post.should_receive(:new).with('/api/v2/yaml/repos/create').and_return(post)
          Net::HTTP.should_receive(:new).with('github.com', 80).and_return(server)
          server.should_receive(:request).with(post)

          @api.request(:post, "#{github_yaml}/repos/create", @hash)
        end

        it 'connects to github via https, submits post request' do
          server, post = stub_server_and_req( :port => 443)
          Net::HTTP::Post.should_receive(:new).with('/api/v2/yaml/repos/create').and_return(post)
          Net::HTTP.should_receive(:new).with('github.com', 443).and_return(server)
          server.should_receive(:request).with(post)

          @api.request(:post, 'https://github.com/api/v2/yaml/repos/create', @hash)
        end

        it 'sends form params urlencoded  with added authentication' do
          server = stub_server
          server.should_receive(:request) do |req|
            req.content_type.should == 'application/x-www-form-urlencoded'
            req.body.should == 'name=name&description=descr&login=joe007&token=b937c8e7ea5a5b47f94eafa39b1e0462'
          end

          @api.request(:post, "#{github_yaml}/repos/create", @hash)
        end
      end

      context 'get' do
        it 'connects to github via http, submits get request' do
          server, req = stub_server_and_req(:get => true)
          Net::HTTP::Get.should_receive(:new).with('/api/v2/yaml/repos/create').and_return(req)
          Net::HTTP.should_receive(:new).with('github.com', 80).and_return(server)
          server.should_receive(:request).with(req)

          @api.request(:get, "#{github_yaml}/repos/create")
        end

        it 'connects to github via https, submits get request' do
          server, req = stub_server_and_req(:get => true, :port => 443)
          Net::HTTP::Get.should_receive(:new).with('/api/v2/yaml/repos/create').and_return(req)
          Net::HTTP.should_receive(:new).with('github.com', 443).and_return(server)
          server.should_receive(:request).with(req)

          @api.request(:get, "https://github.com/api/v2/yaml/repos/create")
        end

        it 'sends get request with added authentication' do
          server = stub_server(:get => true)
          server.should_receive(:request) do |req|
            req.content_type.should == 'application/x-www-form-urlencoded'
            req.body.should == 'login=joe007&token=b937c8e7ea5a5b47f94eafa39b1e0462'
          end

          @api.request(:get, "#{github_yaml}/repos/create")
        end
      end # requests
    end
  end
end # module GitHubTest

# EOF
