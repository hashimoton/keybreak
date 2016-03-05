# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keybreak/version'

Gem::Specification.new do |spec|
  spec.name          = "keybreak"
  spec.version       = Keybreak::VERSION
  spec.authors       = ["hashimoton"]
  spec.email         = ["nhashimoto01@gmail.com"]

  spec.summary       = %q{Keybreak is a utility module for key break processing in Ruby.}
  spec.description   = %q{Keybreak module may assist you to make your key break processing code simpler.}
  spec.homepage      = "https://github.com/hashimoton/keybreak"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  
  spec.required_ruby_version = ">= 1.9.3"
end
