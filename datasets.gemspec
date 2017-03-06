# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datasets/version'

Gem::Specification.new do |spec|
  spec.name          = "datasets"
  spec.version       = Datasets::VERSION
  spec.authors       = ["Aaron Elkiss","Colin Gross", "Bryan Hockey"]
  spec.email         = ["aelkiss@umich.edu", "grosscol@umich.edu", "bhock@umich.edu"]

  spec.summary       = %q{Library to maintain the datasets provided by HathiTrust to researchers.}
  spec.homepage      = "https://github.com/hathitrust/datasets"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rpairtree"

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
