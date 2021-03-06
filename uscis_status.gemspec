# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'uscis_status/version'

Gem::Specification.new do |spec|
  spec.name          = "uscis_status"
  spec.version       = USCISStatus::VERSION
  spec.authors       = ["Guillermo Guerini"]
  spec.email         = ["guillermo@gguerini.com"]
  spec.description   = "USCIS Status Checker"
  spec.summary       = "Easy way to check multiple application statuses from USCIS website."
  spec.homepage      = "https://github.com/gguerini/uscis_status"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "mechanize", ">= 2.6.0"
end
