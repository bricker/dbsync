# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dbsync/version"

Gem::Specification.new do |s|
  s.name        = "dbsync"
  s.version     = Dbsync::VERSION
  s.authors     = ["Bryan Ricker"]
  s.email       = ["bricker88@gmail.com"]
  s.homepage    = "http://github.com/bricker88/dbsync"
  s.summary     = %q{Easy syncing from remote to development database in Rails.}
  s.description = %q{A set of rake tasks to help you sync your remote production data with your local database for development.}

  s.rubyforge_project = "dbsync"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib/tasks"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "activesupport", ">= 3.2.8"
  s.add_runtime_dependency "activerecord", "=> 3.2.8"
  s.add_runtime_dependency "railties", "=> 3.2.8"
end
