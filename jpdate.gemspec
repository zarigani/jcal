# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jpdate/version'

Gem::Specification.new do |spec|
  spec.name          = "jpdate"
  spec.version       = JPDate::VERSION
  spec.authors       = ["zariganitosh"]
  spec.email         = ["XXXX@example.com"]
  spec.summary       = %q{日本の祝日を出力するJPDateクラス}
  spec.description   = %q{明治6年1月1日以降の日本の祝日を出力可能なJPDateクラス}
  spec.homepage      = "https://github.com/zarigani/jcal"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
