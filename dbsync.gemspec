$:.push File.expand_path("../lib", __FILE__)
require "dbsync/version"

Gem::Specification.new do |s|
  s.name        = "dbsync"
  s.version     = Dbsync::VERSION
  s.authors     = ["Bryan Ricker"]
  s.email       = ["bricker88@gmail.com"]
  s.homepage    = "https://github.com/bricker/dbsync"
  s.license     = 'MIT'
  s.description = "A set of rake tasks to help you sync your remote " \
                  "production data with your local database for development."
  s.summary     = "Easy syncing from remote to development database in Rails."

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "lib/tasks"]

  s.add_dependency "activerecord", [">= 3.2.8", "< 5"]
  s.add_dependency "railties", [">= 3.2.8", "< 5"]
  s.add_dependency "cocaine", "~> 0.5.3"

  s.add_development_dependency "rspec"
end
