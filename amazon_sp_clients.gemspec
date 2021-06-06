require_relative 'lib/amazon_sp_clients/version'

Gem::Specification.new do |spec|
  spec.name          = "amazon_sp_clients"
  spec.version       = AmazonSpClients::VERSION
  spec.authors       = ["Dropstream"]
  spec.email         = ["karl@getdropstream.com"]

  spec.summary       = %q{Amazon Selling Partner APIs}
  spec.description   = %q{Collection of SwaggerCodegen gems wrapped into one gem}
  spec.homepage      = "https://github.com/dropstream/amazon_sp_clients"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features|amzn-models|codegen-templates)/})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'httpclient'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'multi_xml'

  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'pry-byebug'
end
