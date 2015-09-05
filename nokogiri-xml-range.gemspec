# -*- encoding: utf-8 -*-

require File.expand_path('../lib/nokogiri/xml/range/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "nokogiri-xml-range"
  gem.version       = Nokogiri::XML::Range::VERSION
  gem.summary       = %q{DOM Range implementation on Nokogiri}
  gem.description   = %q{Nokogiri DOM Range Implementatin based on DOM Standard specification.}
  gem.license       = "LGPL"
  gem.authors       = ["KITAITI Makoto"]
  gem.email         = "KitaitiMakoto@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/nokogiri-xml-range"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'nokogiri'

  gem.add_development_dependency 'test-unit', '~> 3'
  gem.add_development_dependency 'test-unit-notify'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.8'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'coveralls'
end
