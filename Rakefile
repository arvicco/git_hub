require 'pathname'
NAME = 'git_hub'
BASE_DIR = Pathname.new(__FILE__).dirname
LIB_DIR =  BASE_DIR + 'lib'
PKG_DIR =  BASE_DIR + 'pkg'
DOC_DIR =  BASE_DIR + 'rdoc'

$LOAD_PATH.unshift LIB_DIR.to_s
require NAME

CLASS_NAME = GitHub
VERSION = CLASS_NAME::VERSION

begin
  require 'rake'
rescue LoadError
  require 'rubygems'
  gem 'rake', '~> 0.8.3.1'
  require 'rake'
end

# Load rakefile tasks
Dir['tasks/*.rake'].sort.each { |file| load file }

