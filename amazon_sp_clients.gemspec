require_relative 'lib/amazon_sp_clients/version'

Gem::Specification.new do |spec|
  spec.name          = 'amazon_sp_clients'
  spec.version       = AmazonSpClients::VERSION
  spec.authors       = ['Dropstream']
  spec.email         = ['351015+nina-saule@users.noreply.github.com']

  spec.summary       = 'Amazon Selling Partner APIs'
  spec.description   = 'Collection of SwaggerCodegen gems wrapped into one gem'
  spec.homepage      = 'https://github.com/dropstream/amazon_sp_clients'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.3')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|amzn-models)/|^lib/generator})
    end
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
end
