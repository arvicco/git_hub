
require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. lib git_hub]))

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
      f.lines.to_a[line-1].gsub( Regexp.new('(spec.*?{)|(use.*?{)|}'), '' ).lstrip.rstrip
    end
  end
end

Spec::Runner.configure do |config|
  # Add my macros
  config.extend(SpecMacros)	
  
  # Mock Framework. RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end

module GitHubTest

  # Test related Constants:
  TEST_PROJECT = 'GitHub'
  TEST_STRING = 'This is test string'

  # Checks that given block does not raise any errors
  def use
    lambda {yield}.should_not raise_error
  end

  # Returns empty block (for use in spec descriptions)
  def any_block
    lambda {|*args| args}
  end
end