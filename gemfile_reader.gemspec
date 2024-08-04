# frozen_string_literal: true

require_relative "lib/gemfile_reader/version"

Gem::Specification.new do |spec|
  spec.name = "gemfile_reader"
  spec.version = GemfileReader::VERSION
  spec.licenses = ["MIT"]
  spec.authors = ["fenec"]

  spec.summary = "Reads a Gemfile and provides description for the gems in it"
  spec.homepage = "https://github.com/fenec/gemfile_reader"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage

  spec.files = Dir.glob(%w[README.md {exe,lib}/**/*]).reject { |f| File.directory?(f) }
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async", "~> 2.14.2"
  spec.add_dependency "http", "~> 5.2.0"
end
