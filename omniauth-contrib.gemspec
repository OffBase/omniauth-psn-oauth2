# -*- encoding: utf-8 -*-
require File.expand_path(File.join('..', 'lib', 'omniauth', 'psn_oauth2', 'version'), __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'omniauth', '> 1.0'

  gem.authors       = ["Rob Cataneo"]
  gem.email         = ["robcataneo@gmail.com"]
  gem.description   = %q{A PSN (PlayStation Network) OAuth2 strategy for OmniAuth 1.x}
  gem.summary       = %q{A PSN (PlayStation Network) OAuth2 strategy for OmniAuth 1.x}
  gem.homepage      = ""

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.name          = "omniauth-psn-oauth2"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::PsnOauth2::VERSION

  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.1'

  gem.add_development_dependency 'rspec', '>= 2.14.0'
  gem.add_development_dependency 'rake'
end
