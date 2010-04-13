desc "Alias to gem:release"
task :release => 'gem:release'

desc "Alias to gem:install"
task :install => 'gem:install'

desc "Alias to gem:build"
task :gem => 'gem:build'

namespace :gem do
  gem_file = "#{NAME}-#{VERSION}.gem"

  desc "(Re-)Build gem"
  task :build do
    puts "Remove existing gem package"
    rm_rf PKG_DIR
    puts "Build new gem package"
    system "gem build #{NAME}.gemspec"
    puts "Move built gem to package dir"
    mkdir_p PKG_DIR
    mv gem_file, PKG_DIR
  end

  desc "Cleanup already installed gem(s)"
  task :cleanup do
    puts "Cleaning up installed gem(s)"
    system "gem cleanup #{NAME}"
  end

  desc "Build and install gem"
  task :install => :build do
    system "gem install #{PKG_DIR}/#{gem_file}"
  end

  desc "Build and push gem to Gemcutter"
  task :release => [:build, 'git:tag'] do
    system "gem push #{PKG_DIR}/#{gem_file}"
  end
end