desc "Alias to git:commit"
task :git => 'git:commit'

namespace :git do

  desc "Stage and commit your work [with message]"
  task :commit, [:message] do |t, args|
    puts "Staging new (unversioned) files"
    system "git add --all"
    if args.message
      puts "Committing with message: #{args.message}"
      system %Q[git commit -a -m "#{args.message}" --author arvicco]
    else
      puts "Committing"
      system %Q[git commit -a -m "No message" --author arvicco]
    end
  end

  desc "Push local changes to Github"
  task :push => :commit do
    puts "Pushing local changes to remote"
    system "git push"
  end

  desc "Create (release) tag on Github"
  task :tag => :commit do
    puts "Creating git tag: #{VERSION}"
    system %Q{git tag -a -m "Release tag #{VERSION}" #{VERSION}}
    puts "Pushing local changes to remote"
    system "git push"
  end

end