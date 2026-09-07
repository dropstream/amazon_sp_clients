# frozen_string_literal: true

# The gem is published to rubygems.org by the tag workflow. These
# examples pin the push host and its MFA rule, and keep development
# files out of the built gem.
RSpec.describe 'sp_api_clients.gemspec' do
  subject(:gemspec) do
    Gem::Specification.load(File.expand_path('../sp_api_clients.gemspec', __dir__))
  end

  let(:dev_file) do
    %r{
      ^(spec|gemfiles|bin|lib/generator|\.github)/ |
      ^\. |
      ^(Gemfile|Gemfile\.lock|Rakefile|CLAUDE\.md)$
    }x
  end

  # The name carries no vendor mark; the namespace and require paths
  # keep the old name, so consumers change only their Gemfile.
  it 'is named sp_api_clients' do
    expect(gemspec.name).to eq('sp_api_clients')
  end

  it 'allows pushes only to rubygems.org' do
    expect(gemspec.metadata['allowed_push_host']).to eq('https://rubygems.org')
  end

  it 'requires MFA of its owners on rubygems.org' do
    expect(gemspec.metadata['rubygems_mfa_required']).to eq('true')
  end

  it 'ships the library, the generated clients and the top-level docs' do
    expect(gemspec.files).to include(
      'README.md', 'CHANGELOG.md', 'LICENSE', 'sp_api_clients.gemspec',
      'lib/sp_api_clients.rb', 'lib/amazon_sp_clients.rb', 'lib/amazon_sp_clients/v2.rb',
      'lib/amazon_sp_clients/v2/apis/orders_v0.rb', 'vendor/orders_v0/lib/sp_orders_v0.rb'
    )
  end

  it 'ships no development files' do
    expect(gemspec.files).not_to include(a_string_matching(dev_file))
  end
end
