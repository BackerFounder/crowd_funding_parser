# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'crowd_funding_parser/version'

Gem::Specification.new do |spec|
  spec.name          = "crowd_funding_parser"
  spec.version       = CrowdFundingParser::VERSION
  spec.authors       = ["BackerFounder"]
  spec.email         = ["hello@backer-founder.com"]
  spec.summary       = %q{A crowd-funding platform parser}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency "parallel", "~> 1.3"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
end
