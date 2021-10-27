# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "execution/version"

Gem::Specification.new do |spec|
  spec.name          = "Effects"
  spec.version       = Effects::VERSION
  spec.authors       = ["Jahfer Husain"]
  spec.email         = ["jahfer.husain@shopify.com"]

  spec.summary       = "Internal and external control flow"

  spec.metadata["allowed_push_host"] = "Not allowed"

  spec.files = Dir['lib/**/*.rb']
  spec.require_paths = %w(lib)

  spec.add_dependency("activesupport", ">= 5.2")

  spec.add_development_dependency("bundler")
  spec.add_development_dependency("rake")
end
