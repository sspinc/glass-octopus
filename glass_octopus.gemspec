# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'glass_octopus/version'

Gem::Specification.new do |spec|
  spec.name          = "glass_octopus"
  spec.version       = GlassOctopus::VERSION
  spec.authors       = ["Tamás Michelberger"]
  spec.email         = ["tomi@secretsaucepartners.com"]

  spec.summary       = %q{A Kafka consumer framework. Like Rack but for Kafka.}
  spec.homepage      = "https://github.com/sspinc/glass-octopus"
  spec.license       = "MIT"

  spec.description   = <<-EOF
GlassOctopus provides a minimal, modular and adaptable interface for developing
Kafka consumers in Ruby. In its philosophy it is very close to Rack.
EOF

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-color", "~> 0"
  spec.add_development_dependency "guard", "~> 2.14"
  spec.add_development_dependency "guard-minitest", "~> 2.4"
  spec.add_development_dependency "terminal-notifier-guard", "~> 1.7"
  spec.add_development_dependency "ruby-kafka", "~> 1.0"
  spec.add_development_dependency "avro_turf", "~> 1.0"
  spec.add_development_dependency "sinatra", ">= 2.2.0"
  spec.add_development_dependency "webmock", "~> 3.3.0"
end
