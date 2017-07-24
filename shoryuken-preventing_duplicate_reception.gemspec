# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shoryuken/preventing_duplicate_reception/version'

Gem::Specification.new do |spec|
  spec.name          = 'shoryuken-preventing_duplicate_reception'
  spec.version       = Shoryuken::PreventingDuplicateReception::VERSION
  spec.authors       = ['dany1468']
  spec.email         = ['dany1468@gmail.com']

  spec.summary       = %q{Shoryuken plugin for preventing duplicate message reception.}
  spec.description   = %q{Shoryuken plugin for preventing duplicate message reception.}
  spec.homepage      = 'https://github.com/dany1468/shoryuken-preventing_duplicate_reception'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'shoryuken', '~> 3.1'
  spec.add_dependency 'aws-sdk-core', '> 2'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
