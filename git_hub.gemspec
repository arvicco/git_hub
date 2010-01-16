# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git_hub}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["arvicco"]
  s.date = %q{2010-01-16}
  s.default_executable = %q{git_hub}
  s.description = %q{Simple interface to github API}
  s.email = %q{arvitallian@gmail.com}
  s.executables = ["git_hub"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "bin/git_hub",
     "features/git_hub.feature",
     "features/step_definitions/git_hub_steps.rb",
     "features/support/env.rb",
     "git_hub.gemspec",
     "lib/git_hub.rb",
     "lib/git_hub/api.rb",
     "lib/git_hub/base.rb",
     "lib/git_hub/commit.rb",
     "lib/git_hub/extensions.rb",
     "lib/git_hub/repo.rb",
     "lib/git_hub/user.rb",
     "spec/git_hub/api_spec.rb",
     "spec/git_hub/base_spec.rb",
     "spec/git_hub/commit_spec.rb",
     "spec/git_hub/extensions_spec.rb",
     "spec/git_hub/repo_spec.rb",
     "spec/git_hub/user_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/stubs/http/users/follow.res",
     "spec/stubs/yaml/api_route_error.res",
     "spec/stubs/yaml/commits/list/joe007/fine_repo/master.res",
     "spec/stubs/yaml/commits/list/joe007/fine_repo/master/README.res",
     "spec/stubs/yaml/commits/show/joe007/fine_repo/3a70f86293b719f193f778a8710b1f83f2f7bf38.res",
     "spec/stubs/yaml/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8.res",
     "spec/stubs/yaml/commits/show/joe007/fine_repo/f7f5dddaa37deacc83f1f56876e2b135389d03ab.res",
     "spec/stubs/yaml/repos/create.1.res",
     "spec/stubs/yaml/repos/create.2.res",
     "spec/stubs/yaml/repos/create.3.res",
     "spec/stubs/yaml/repos/create.4.res",
     "spec/stubs/yaml/repos/delete/new_repo.1.res",
     "spec/stubs/yaml/repos/delete/new_repo.2.res",
     "spec/stubs/yaml/repos/delete/new_repo.res",
     "spec/stubs/yaml/repos/search/fine+repo.res",
     "spec/stubs/yaml/repos/search/joe+repo.res",
     "spec/stubs/yaml/repos/show/invalid_github_user/err_repo.res",
     "spec/stubs/yaml/repos/show/joe007.res",
     "spec/stubs/yaml/repos/show/joe007/err_repo.res",
     "spec/stubs/yaml/repos/show/joe007/fine_repo.res",
     "spec/stubs/yaml/repos/show/joe007/fine_repo/branches.res",
     "spec/stubs/yaml/repos/show/joe007/fine_repo/tags.res",
     "spec/stubs/yaml/repos/show/joe007/new_repo.res",
     "spec/stubs/yaml/user/follow/arvicco.res",
     "spec/stubs/yaml/user/search/joe+007.res",
     "spec/stubs/yaml/user/show/arvicco.res",
     "spec/stubs/yaml/user/show/invalid_github_user.res",
     "spec/stubs/yaml/user/show/joe007.auth.res",
     "spec/stubs/yaml/user/show/joe007.res",
     "spec/stubs/yaml/user/show/joe007/followers.res",
     "spec/stubs/yaml/user/show/joe007/following.empty.res",
     "spec/stubs/yaml/user/show/joe007/following.res"
  ]
  s.homepage = %q{http://github.com/arvicco/git_hub}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Simple interface to github API}
  s.test_files = [
    "spec/git_hub/api_spec.rb",
     "spec/git_hub/base_spec.rb",
     "spec/git_hub/commit_spec.rb",
     "spec/git_hub/extensions_spec.rb",
     "spec/git_hub/repo_spec.rb",
     "spec/git_hub/user_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<cucumber>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<cucumber>, [">= 0"])
  end
end

