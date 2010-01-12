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
  TEST_PROJECT = 'GitHub'
  TEST_STRING = 'This is test string'

  # Checks that given block does not raise any errors
  def use
    lambda {yield}.should_not raise_error
  end

  # Extract response from file
  def response_from_file(path)
    filename = File.join(File.dirname(__FILE__), 'stubs', path + '.res')
    unless File.exists?(filename) && !File.directory?(filename)
      raise "No stub file #{filename}. To obtain it use:\n#{curl_string(path, filename)}"
    end
    filename
  end

  # Extract response body from file
  def body_from_file(path)
    File.read(response_from_file(path)).gsub(/.*\n\n/m, '')
  end

  def curl_string(path, filename)
    if api.authenticated?
      "curl -i -d \"login=#{api.auth['login']}&token=#{api.auth['token']}\" #{github_yaml}#{path} > #{filename}"
    else
      "curl -i #{github_yaml}#{path} > #{filename}"
    end
  end

  # Stubs github server, with options:
  # :host:: Host name - default 'github.com'
  # :port:: Port - default 80
  def stub_server(options={})
    server = Net::HTTP.new(options[:host] ||'github.com', options[:port] || 80)
    Net::HTTP.stub!(:new).and_return(server)
    server
  end

  # Stubs http request, with options:
  # :path:: Request path - default '/api/v2/yaml/repos/create'
  # :get:: Indicates that request is get, otherwise post
  def stub_req(options={})
    path = options[:path] || '/api/v2/yaml/repos/create'
    options[:get] ? Net::HTTP::Get.new(path) : Net::HTTP::Post.new(path)
  end

  def stub_server_and_req(options = {})
    [stub_server(options), stub_req(options)]
  end

  # Turns string into appropriate class constant, returns nil if class not found
  def classify name
    klass = name.split("::").inject(Kernel) {|klass, const_name| klass.const_get const_name }
    klass.is_a?(Class) ? klass : nil
  rescue NameError
    nil
  end

  # Builds fake HTTP response from a given options Hash. Accepts options:
  # :klass:: Response class, default - Net::HTTPOK
  # :http_version:: HTTP version - default 1.1
  # :code:: Response return code - default 200
  # :message:: Response message - default 'OK'
  # :status:: [code, message] pair as one option
  # :body:: Response body - default ''
  # TODO: make it more lifelike using StringIO, instead of just stubbing :body
  def build_response(options={})
    code = options[:status] ? options[:status].first : options[:code] || 200
    message = options[:status] ? options[:status].last : options[:message] || 'OK'
    version = options[:http_version] || 1.1
    resp = (options[:klass] || Net::HTTPOK).new(code, version, message)
    resp.stub!(:body).and_return(options[:body] || '')
    resp
  end

  # Expects request of certain method(:get, :post, ... :any) to specific uri (given as a String, URI or Regexp),
  # (optionally) matches expected query keys with actuals and handles request and response according to options.
  # In addition to build_response options (:klass, :http_version, :code, :message, :status, :body), it supports:
  # :expected_keys:: Hash of expected query keys(if value is not important, :key => :any)
  # :response:: Use this ready-made response object instead of building response
  # :exception:: Raise this Exception object instead of response
  # If you expect multiple requests to the same uri, options may also be an Array containing a list of the
  # above-described Hashes - requests will be expected in the same order they appear in the Array
  def expects(method, uri, options={})
    @github ||= stub_server
    opts = options.is_a?(Array) ? options.shift : options # may be a single options Hash or Array of Hashes
    @github.should_receive(:request) do |req|
      case method # match expected request method to actual
        when :any
          Net::HTTPRequest
        when Class
          method
        when Symbol, String
          classify('Net::HTTP::' + method.to_s.capitalize)
      end.should === req
      case uri # match expected uri to actual
        when URI::HTTP, URI::HTTPS
          uri.path
        when String
          URI.parse(uri).path
        when Regexp
          uri
      end.should === req.path
      if opts[:expected_keys] # match expected request query keys to actual keys
        actuals = CGI::parse(req.body)
        opts[:expected_keys].each do |key, val|
          actuals.should have_key key.to_s
          actual = actuals[key.to_s]
          actual = actual.first if actual.size == 1 # if only one array element, extract it
          case val # match expected key value to actual
            when :any
            when Class, Regexp, String
              val.should === actual
            else
              val.to_s.should === actual
          end
        end
      end
      expects(method, uri, options) if options.is_a?(Array) && !options.empty? # expect next request in Array
      raise opts[:exception] if opts[:exception] && opts[:exception].kind_of?(Exception)
      opts[:response] || build_response(opts)
    end
  end

  # Extends path to uri, registers it with FakeWeb with stub file at stubs/path as a response
  # If block is given, yields to block and checks that registered uri was hit during block execution
  def expect(method, path)
    case path
      when Regexp.new(github_yaml)
        uri = path
        file = path.sub(github_yaml, '')
      else
        uri = github_yaml + path
        file = path
    end
    FakeWeb.register_uri(method, uri, :response=>response_from_file(file))
    if block_given?
      yield
      FakeWeb.should have_requested(method, uri)
    end
  end

  # Auth for joe
  def joe_auth
    {'login' => 'joe007', 'token' => 'b937c8e7ea5a5b47f94eafa39b1e0462'}
  end

  def github_yaml
    'http://github.com/api/v2/yaml'
  end

  def api
    GitHub::Api.instance
  end

  # specific expectations used in more than one spec file
  def should_be_commit_5e61 commit
    arvicco = { 'name'=> 'arvicco', 'email'=> 'arvitallian@gmail.com'}
    commit.should be_a GitHub::Commit
    commit.sha.should == '5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
    commit.url.should == 'http://github.com/joe007/fine_repo/commit/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8'
    commit.committed_date.should == "2010-01-08T02:49:26-08:00"
    commit.authored_date.should == "2010-01-08T02:49:26-08:00"
    commit.message.should == 'Version bump to 0.1.2'
    commit.tree.should == '917a288e375020ac4c0f4413dc6f23d6f06fc51b'
    commit.author.should == arvicco
    commit.committer.should == arvicco
    commit.user.should == 'joe007'
    commit.repo.should == 'fine_repo'
  end

  def should_be_commit_543b commit
    arvicco = { 'name'=> 'arvicco', 'email'=> 'arvitallian@gmail.com'}
    commit.should be_a GitHub::Commit
    commit.parents.should == []
    commit.sha.should == '4f223bdbbfe6acade73f4b81d089f0705b07d75d'
    commit.url.should == 'http://github.com/joe007/fine_repo/commit/4f223bdbbfe6acade73f4b81d089f0705b07d75d'
    commit.committed_date.should == "2010-01-08T01:20:55-08:00"
    commit.authored_date.should == "2010-01-08T01:20:55-08:00"
    commit.message.should == 'First commit'
    commit.tree.should == '543b9bebdc6bd5c4b22136034a95dd097a57d3dd'
    commit.author.should == arvicco
    commit.committer.should == arvicco
    commit.user.should == 'joe007'
    commit.repo.should == 'fine_repo'
  end


end # module GithubTest
