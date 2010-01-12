# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{git_hub}
  s.version = "0.2.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["arvicco"]
  s.date = %q{2010-01-12}
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
     "features/support/env.rb",
     "git_hub.gemspec",
     "lib/git_hub.rb",
     "lib/git_hub/api.rb",
     "lib/git_hub/base.rb",
     "lib/git_hub/commit.rb",
     "lib/git_hub/repo.rb",
     "rdoc/classes/GitHub.html",
     "rdoc/classes/GitHub/Api.html",
     "rdoc/classes/GitHub/Base.html",
     "rdoc/classes/GitHub/Repo.html",
     "rdoc/created.rid",
     "rdoc/files/README_rdoc.html",
     "rdoc/files/lib/git_hub/api_rb.html",
     "rdoc/files/lib/git_hub/base_rb.html",
     "rdoc/files/lib/git_hub/repo_rb.html",
     "rdoc/files/lib/git_hub_rb.html",
     "rdoc/fr_class_index.html",
     "rdoc/fr_file_index.html",
     "rdoc/fr_method_index.html",
     "rdoc/index.html",
     "rdoc/rdoc-style.css",
     "spec/git_hub/api_spec.rb",
     "spec/git_hub/base_spec.rb",
     "spec/git_hub/commit_spec.rb",
     "spec/git_hub/repo_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "spec/stubs/api_route_error.res",
     "spec/stubs/commits/list/joe007/fine_repo/master.res",
     "spec/stubs/commits/list/joe007/fine_repo/master/README.res",
     "spec/stubs/commits/show/joe007/fine_repo/3a70f86293b719f193f778a8710b1f83f2f7bf38.res",
     "spec/stubs/commits/show/joe007/fine_repo/5e61f0687c40ca48214d09dc7ae2d0d0d8fbfeb8.res",
     "spec/stubs/commits/show/joe007/fine_repo/f7f5dddaa37deacc83f1f56876e2b135389d03ab.res",
     "spec/stubs/repos/create.1.res",
     "spec/stubs/repos/create.2.res",
     "spec/stubs/repos/create.3.res",
     "spec/stubs/repos/create.4.res",
     "spec/stubs/repos/delete/new_repo.1.res",
     "spec/stubs/repos/delete/new_repo.2.res",
     "spec/stubs/repos/search/joe+repo.res",
     "spec/stubs/repos/show/joe007.res",
     "spec/stubs/repos/show/joe007/err_repo.res",
     "spec/stubs/repos/show/joe007/fine_repo.res",
     "spec/stubs/repos/show/joe007/fine_repo/branches.res",
     "spec/stubs/repos/show/joe007/fine_repo/tags.res",
     "spec/stubs/repos/show/joe007/new_repo.res"
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

