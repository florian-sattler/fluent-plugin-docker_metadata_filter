# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-docker_metadata_elastic_filter"
  gem.version       = "0.2.0"
  gem.authors       = ["Jimmi Dyson","Hiroshi Hatake","Zsolt Fekete"]
  gem.email         = ["zsoltf@me.com"]
  gem.description   = %q{Filter plugin to add Docker metadata for use with Elasticsearch}
  gem.summary       = %q{Filter plugin to add Docker metadata for use with Elasticsearch}
  gem.homepage      = "https://github.com/zsoltf/fluent-plugin-docker_metadata_elastic_filter"
  gem.license       = "Apache-2.0"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.has_rdoc      = false

  gem.required_ruby_version = '>= 2.1.0'

  gem.add_runtime_dependency "fluentd", [">= 0.14.0", "< 2"]
  gem.add_runtime_dependency "docker-api"
  gem.add_runtime_dependency "lru_redux"

  gem.add_development_dependency "bundler", "~> 1.3"
  gem.add_development_dependency "rake"
  gem.add_development_dependency "minitest", "~> 4.0"
  gem.add_development_dependency "test-unit", "~> 3.0.2"
  gem.add_development_dependency "test-unit-rr", "~> 1.0.3"
  gem.add_development_dependency "copyright-header"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "bump"
end
