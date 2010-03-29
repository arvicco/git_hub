require 'spec'
require File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib git_hub]))

# Module that extends RSpec with my own extensions/macros
module SpecMacros

  # Wrapper for *it* method that extracts description from example source code, such as:
  # spec{ use{  result =  function(arg1 = 4, arg2 = 'string')  }}
  def spec &block
    it description_from(*block.source_location), &block
  end

  # reads description line from source file and drops external brackets (like *spec*{}, *use*{})
  def description_from(file, line)
    File.open(file) do |f|
      f.lines.to_a[line-1].gsub( Regexp.new('(spec.*?{)|(use.*?{)|}'), '' ).strip
    end
  end
end

Spec::Runner.configure do |config|
  # Add my macros
  config.extend(SpecMacros)
end

module GitHubTest

  # Test related Constants:
  API = GitHub::Api.instance

  MOCK_WEB = :webmock   # turning this flag on routes all Net calls to local stubs

  case MOCK_WEB
    when :fakeweb
      require 'fakeweb'
      require 'fakeweb_matcher'
    when :webmock
      require 'webmock/rspec'
  end

  # Extract response from file
  def response_from_file( file_path, uri_path = '' )
    filename = File.join(File.dirname(__FILE__), 'stubs', file_path + '.res')
    unless File.exists?(filename) && !File.directory?(filename)
      raise "No stub file #{filename}. To obtain it use:\n#{curl_string(filename, uri_path)}"
    end
    filename
  end

  # Curl command to retrieve non-existent stub file
  def curl_string( filename, uri_path )
    if API.authenticated?
      "curl -i -d \"login=#{API.auth['login']}&token=#{api.auth['token']}\" #{uri_path} > #{filename}"
    else
      "curl -i #{uri_path} > #{filename}"
    end
  end

  # Converts path to uri, registers it with FakeWeb with stub file at stubs/(http)/path as a response
  # If extensions given (possibly as an Array), looks for stub files with extensions, responds in sequence
  # If block is given, yields to block and checks that registered uri was hit during block execution
  def expect( method, path, extensions = nil )
    if MOCK_WEB
      uri_path = path
      [extensions].flatten.each do |ext|
        case path
          when Regexp.new(github_yaml)
            file_path = path.sub(github_yaml, '/yaml')
          when Regexp.new(github_http)
            file_path = path.sub(github_http, '/http')
          else
            uri_path = github_yaml + path
            file_path = path
        end
        file_path += ".#{ext}" if ext
        case MOCK_WEB
          when :fakeweb
            FakeWeb.register_uri(method, uri_path, :response=>response_from_file(file_path, uri_path))
          when :webmock
            WebMock.stub_request(method, uri_path).to_return(File.new(response_from_file(file_path, uri_path)))
        end
      end
      if block_given?
        yield
        case MOCK_WEB
          when :fakeweb
            FakeWeb.should have_requested(method, uri_path)
          when :webmock
            WebMock.should have_requested(method, uri_path)
        end
      end
    else
      yield if block_given?
    end
  end

  def web_setup
    case MOCK_WEB
      when :fakeweb
        FakeWeb.allow_net_connect = false
      when :webmock
        WebMock.allow_net_connect!
    end
  end

  def web_teardown
    case MOCK_WEB
      when :fakeweb
        FakeWeb.clean_registry
        FakeWeb.allow_net_connect = true
      when :webmock
        WebMock.reset_webmock
        WebMock.disable_net_connect!
    end
  end

  # Remove authentication
  def clear_auth
    API.auth.clear
  end

  # Authenticate as joe
  def authenticate_as_joe
    API.auth = joe_auth
  end

  def joe_auth
    {'login' => 'joe007', 'token' => 'b937c8e7ea5a5b47f94eafa39b1e0462'}
  end

  def joe
    expect(:get, "#{github_yaml}/user/show/joe007")
    GitHub::User.find(:user=>'joe007')
  end

  def github_http
    'http://github.com'
  end

  def github_yaml
    'http://github.com/api/v2/yaml'
  end

  # repo name for 'new_repo' for real life tests - needed because GitHub
  # gets stuck after several attempts to create repo with the same name
  def new_repo
    @new_repo_name ||= MOCK_WEB ? 'new_repo' : "new_repo#{Time.now.strftime("%Y%m%d-%H%M%S")}"
  end

  # waits a little bit - needed because cache is sticky on real github
  def wait
    sleep 1 unless MOCK_WEB
  end

  # specific expectations used in more than one spec file
  def should_be_commit( commit, type )
    arvicco = { 'name'=> 'arvicco', 'email'=> 'arvitallian@gmail.com'}
    commit.should be_a GitHub::Commit
    commit.author.should == arvicco
    commit.committer.should == arvicco
    commit.user.should == 'joe007'
    commit.repo.should == 'fine_repo'
    case type.to_s
      when '5e61'
        commit.parents.should == [{"id"=>"f7f5dddaa37deacc83f1f56876e2b135389d03ab"}]
        commit.sha.should == '5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
        commit.url.should == 'http://github.com/joe007/fine_repo/commit/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
        commit.committed.should == Time.parse("2010-01-08T02:49:26-08:00")
        commit.authored.should == Time.parse("2010-01-08T02:49:26-08:00")
        commit.message.should == 'Version bump to 0.1.2'
        commit.tree.should == '917a288e375020ac4c0f4413dc6f23d6f06fc51b'
      when '543b'
        commit.parents.should == []
        commit.sha.should == '4f223bdbbfe6acade73f4b81d089f0705b07d75d'
        commit.url.should == 'http://github.com/joe007/fine_repo/commit/4f223bdbbfe6acade73f4b81d089f0705b07d75d'
        commit.committed.should == Time.parse("2010-01-08T01:20:55-08:00")
        commit.authored.should == Time.parse("2010-01-08T01:20:55-08:00")
        commit.message.should == 'First commit'
        commit.tree.should == '543b9bebdc6bd5c4b22136034a95dd097a57d3dd'
    end
  end
end # module GithubTest
