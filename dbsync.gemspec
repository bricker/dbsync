# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dbsync/version"

Gem::Specification.new do |gem|
  gem.name        = "dbsync"
  gem.version     = Dbsync::VERSION
  gem.authors     = ["Bryan Ricker"]
  gem.email       = ["bricker88@gmail.com"]
  gem.description = %q{A set of rake tasks to help you sync your remote production data with your local database for development.}
  gem.summary     = %q{Easy syncing from remote to development database in Rails.}
  gem.homepage    = "http://github.com/bricker/dbsync"

  gem.rubyforge_project = "dbsync"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib", "lib/tasks"]

  gem.add_runtime_dependency "activesupport", "~> 3.2.8"
  gem.add_runtime_dependency "activerecord", "~> 3.2.8"
  gem.add_runtime_dependency "railties", "~> 3.2.8"
end
