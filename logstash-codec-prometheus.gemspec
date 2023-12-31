Gem::Specification.new do |s|
  s.name          = 'logstash-codec-prometheus'
  s.version       = '0.1.0'
  s.licenses      = ['Apache-2.0']
  s.summary       = 'A logstash codec plugin to decode documents in prometheus exposition format.'
  s.description   = 'A logstash codec plugin to decode documents in prometheus exposition format. The encoder has not been implemented yet. The project is forked from https://github.com/yesmarket/logstash-codec-prometheus but the parser logic has been rewritten and the output format is not compatible with the original version.'
  s.homepage      = 'https://github.com/itbill/logstash-codec-prometheus'
  s.authors       = ['Bill Lam']
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "codec" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-line', "~> 3.0"
  s.add_development_dependency 'logstash-devutils', "~> 1.3"
end
