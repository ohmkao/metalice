$:.push File.expand_path("../lib", __FILE__)

require "metalice/version"

Gem::Specification.new do |s|
  s.name        = "metalice"
  s.version     = Metalice::VERSION
  s.authors     = ["ohm kao"]
  s.email       = ["ohm.kao@gmail.com"]
  s.homepage    = "https://github.com/ohmkao/metalice"
  s.summary     = ""
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0"
  s.add_dependency "meta-tags", "~> 2.0"

  s.add_development_dependency 'sqlite3'
end
