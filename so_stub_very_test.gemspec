# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'so_stub_very_test/version'

Gem::Specification.new do |spec|
  spec.name          = "so_stub_very_test"
  spec.version       = SoStubVeryTest::VERSION
  spec.authors       = ["Jonathan Clem"]
  spec.email         = ["jonathan@jclem.net"]
  spec.summary       = %q{so stub...very test...much excon...wow}
  spec.description   = %q{build sensible default Excon stubs...and then build more of them}
  spec.homepage      = "https://github.com/jclem/so_stub_very_test"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "excon", "~> 0.25", ">= 0.25.1"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
