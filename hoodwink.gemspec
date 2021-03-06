$:.push File.expand_path("../lib", __FILE__)
require "hoodwink/version"

Gem::Specification.new do |s|
  s.name        = "hoodwink"
  s.version     = Hoodwink::VERSION
  s.authors     = ["Ian Duggan"]
  s.email       = ["ian@ianduggan.net"]
  s.homepage    = ""
  s.summary     = %q{Web request intereception and mocking for development and testing}
  s.description = %q{Web request intereception and mocking for development and testing}

  s.rubyforge_project = "hoodwink"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "wrong"
  s.add_development_dependency "guard-rspec"

  s.add_runtime_dependency "activesupport", "> 3.0.0"
  s.add_runtime_dependency "activeresource"
  s.add_runtime_dependency "addressable"
  s.add_runtime_dependency "webmock"

  # TODO: fix supermodel dependency on activemodel ~> 3.0.0 so we can move this to gemspec
  #s.add_runtime_dependency "supermodel", "~> 0.1.6"
end
