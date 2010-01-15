require File.expand_path(
        File.join(File.dirname(__FILE__), '..', 'spec_helper'))

module GitHubTest
  describe GitHub::Base do
    after(:each) do
      clear_auth
    end

    context 'requests' do
      it 'submits appropriate requests to api as get/post methods (both class and instance)' do
        base = described_class.new
        API.should_receive(:request).with(:get, '/blah', anything()).twice
        base.get ('/blah')
        described_class.get ('/blah')

        API.should_receive(:request).with(:post, '/blah', anything()).twice
        base.post ('/blah')
        described_class.post ('/blah')
      end

      it 'prepends get/post calls by content of @base_uri variable' do
        base = described_class.new
        described_class.class_eval { @base_uri = 'http://base1.com' }
        API.should_receive(:request).with(:get, 'http://base1.com/blah', anything()).twice
        base.get ('/blah')
        described_class.get ('/blah')

        API.should_receive(:request).with(:post, 'http://base1.com/blah', anything()).twice
        base.post ('/blah')
        described_class.post ('/blah')
      end
    end                                                
  end
end # module GitHubTest

# EOF
