desc 'Alias to doc:rdoc'
task :doc => 'doc:rdoc'

namespace :doc do
  require 'rake/rdoctask'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = DOC_DIR.basename.to_s
    rdoc.title = "#{NAME} #{VERSION} Documentation"
    rdoc.rdoc_files.include('README*', 'LICENCE', 'HISTORY')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
end
