# frozen_string_literal: true

require_relative "lib/git_steering/version"

Gem::Specification.new do |spec|
  spec.name = "git_steering"
  spec.version = GitSteering::VERSION
  spec.authors = ["Magnetic Market Actual Skill"]
  spec.email = ["info@example.com"]

  spec.summary = "Manage steering file symlinks from vendor gems and submodules"
  spec.description = "GitSteering automatically manages symlinks for .kiro/steering/*.md files from vendor gems and submodules into the parent project, allowing gems to provide context and guidelines for AI assistants."
  spec.homepage = "https://github.com/magenticmarketactualskill/git_steering"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/magenticmarketactualskill/git_steering"
  spec.metadata["changelog_uri"] = "https://github.com/magenticmarketactualskill/git_steering/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    bin/*
    README.md
    LICENSE.txt
    CHANGELOG.md
  ]).reject { |f| File.directory?(f) }

  spec.bindir = "bin"
  spec.executables = ["git_steering"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "rainbow", "~> 3.0"
  spec.add_dependency "thor", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "cucumber", "~> 9.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop", "~> 1.50"
end
