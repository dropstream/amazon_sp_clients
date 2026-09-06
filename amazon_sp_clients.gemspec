require_relative 'lib/amazon_sp_clients/version'

Gem::Specification.new do |spec|
  spec.name          = 'amazon_sp_clients'
  spec.version       = AmazonSpClients::VERSION
  spec.authors       = ['Dropstream']
  spec.email         = ['351015+nina-saule@users.noreply.github.com']

  spec.summary       = 'Amazon Selling Partner APIs'
  spec.description   = 'Ruby clients for the Amazon Selling Partner API (SP-API)'
  spec.homepage      = 'https://github.com/dropstream/amazon_sp_clients'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3')

  # Releases go to the Dropstream registry on GitHub Packages, never to
  # rubygems.org. `github_repo` ties the package to this repository.
  spec.metadata['allowed_push_host'] = 'https://rubygems.pkg.github.com/dropstream'
  spec.metadata['github_repo'] = 'ssh://github.com/dropstream/amazon_sp_clients'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Only lib/, vendor/, the gemspec and the top-level docs ship. Tests,
  # the generator, CI config, dotfiles and the dev tooling stay behind.
  dev_files = %r{
    ^(test|spec|features|amzn-models|gemfiles|bin)/ |
    ^lib/generator |
    ^\. |
    ^(Gemfile(\.lock)?|Rakefile|CLAUDE\.md|codegen-config\.yml|selling-partner-api-models\.sha)$
  }x
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(dev_files) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 1.10', '< 3'
  spec.add_dependency 'faraday-httpclient', '>= 1.0', '< 3'
  spec.add_dependency 'faraday-retry', '>= 1.0', '< 3'
  spec.add_dependency 'httpclient'
  spec.add_dependency 'multi_xml'

  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop', '~> 1.86'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'yard'
end
