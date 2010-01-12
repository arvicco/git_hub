require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest
  describe GitHub::User do
    after(:each) do
      api.auth.clear
    end

    context '.find as /show/:user/:repo' do
      it 'finds repo of a (valid) github user' do
      end
    end
  end
end
