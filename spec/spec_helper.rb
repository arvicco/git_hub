require 'spec'
require 'cgi'
require 'fakeweb'
require 'fakeweb_matcher'
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
  TEST_FAKE_WEB = true # turning this flag on routes all Net calls to local stubs

  # Checks that given block does not raise any errors
  def use
    lambda {yield}.should_not raise_error
  end

  # Extract response from file
  def response_from_file(file_path, uri_path='')
    filename = File.join(File.dirname(__FILE__), 'stubs', file_path + '.res')
    unless File.exists?(filename) && !File.directory?(filename)
      raise "No stub file #{filename}. To obtain it use:\n#{curl_string(uri_path, filename)}"
    end
    filename
  end

  def curl_string(uri_path, filename)
    if api.authenticated?
      "curl -i -d \"login=#{api.auth['login']}&token=#{api.auth['token']}\" #{uri_path} > #{filename}"
    else
      "curl -i #{github_yaml}#{path} > #{filename}"
    end
  end

  # Converts path to uri, registers it with FakeWeb with stub file at stubs/(http)/path as a response
  # If extensions given (possibly as an Array), looks for stub files with extensions, responds in sequence
  # If block is given, yields to block and checks that registered uri was hit during block execution
  def expect(method, path, extensions = nil)
    if TEST_FAKE_WEB
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
        FakeWeb.register_uri(method, uri_path, :response=>response_from_file(file_path, uri_path))
      end
      if block_given?
        yield
        FakeWeb.should have_requested(method, uri_path)
      end
    else
      yield if block_given?
    end
  end

  # Authenticate as joe
  def authenticate_as_joe 
    api.auth = joe_auth
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

  def api
    GitHub::Api.instance
  end

  def wait
    sleep 1 unless TEST_FAKE_WEB # cache is sticky on real github
  end

  # specific expectations used in more than one spec file
  def should_be_commit commit, type
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
