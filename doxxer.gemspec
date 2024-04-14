# frozen_string_literal: true

require_relative "lib/doxxer/version"

Gem::Specification.new do |spec|
  spec.name = "doxxer"
  spec.version = Doxxer::VERSION
  spec.authors = ["Roger Garcia (roginn)"]
  spec.email = ["roginn@gmail.com"]

  spec.summary = "Expose dynamic interactions and dependencies between your classes"
  spec.description = "Expose dynamic interactions and dependencies between your classes"
  spec.homepage = "https://github.com/roginn/doxxer"
  spec.required_ruby_version = ">= 3.2.2"

  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/roginn/doxxer"
  spec.metadata["changelog_uri"] = "https://github.com/roginn/doxxer/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "debug_inspector", "~> 1.2.0"
end
