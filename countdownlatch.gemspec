# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "countdownlatch/version"

Gem::Specification.new do |s|
  s.name        = "countdownlatch"
  s.version     = CountDownLatch::VERSION
  s.authors     = ["Ben Langfeld"]
  s.email       = ["ben@langfeld.me"]
  s.homepage    = "https://github.com/benlangfeld/countdownlatch"
  s.summary     = %q{3..2..1..GO!}
  s.description = %q{A synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rake'
  s.add_development_dependency 'minitest'
end
