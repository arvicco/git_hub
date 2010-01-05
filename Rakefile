
require 'bones' rescue abort '### Please install the "bones" gem ###'

ensure_in_path 'lib'
require 'git_hub'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  ignore_file '.gitignore'	
  name  'git_hub'
  authors  'Arvicco'
  email  'arvitallian@gmail.com'
  url  'http://github.com/arvicco/git_hub'
  version  GitHub::VERSION
  ignore_file  '.gitignore'
}

# EOF
