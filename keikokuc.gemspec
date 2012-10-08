# -*- encoding: utf-8 -*-
require File.expand_path('../lib/keikokuc/version', __FILE__)
require 'factory_girl'

Gem::Specification.new do |gem|
  gem.authors       = ["Harold Giménez"]
  gem.email         = ["harold.gimenez@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "keikokuc"
  gem.require_paths = ["lib"]
  gem.version       = Keikokuc::VERSION

  gem.add_dependency 'rest-client'
  gem.add_dependency 'yajl-ruby'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'factory_girl'
  gem.add_development_dependency 'sham_rack'
end
