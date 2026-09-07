# frozen_string_literal: true

require 'date'
require_relative '../tasks/release'

RSpec.describe Release do
  let(:date) { Date.new(2026, 9, 7) }

  describe '.check_version!' do
    it 'accepts X.Y.Z' do
      expect { described_class.check_version!('2.0.1') }.not_to raise_error
    end

    it 'rejects anything else' do
      ['2.0', 'v2.0.1', '2.0.1.pre', '', nil].each do |bad|
        expect { described_class.check_version!(bad) }
          .to raise_error(Release::Error, /X\.Y\.Z/), bad.inspect
      end
    end
  end

  describe '.stamp_changelog' do
    let(:changelog) do
      <<~MD
        # Changelog

        ## [2.0.1]

        ### Fixed

        - Something.

        ## [2.0.0] - 2026-09-03
      MD
    end

    it 'adds the date to the undated heading' do
      out = described_class.stamp_changelog(changelog, '2.0.1', date)

      expect(out).to include("## [2.0.1] - 2026-09-07\n")
      expect(out).to include("## [2.0.0] - 2026-09-03\n")
    end

    it 'keeps a heading that already has a date' do
      dated = changelog.sub('## [2.0.1]', '## [2.0.1] - 2026-09-01')

      expect(described_class.stamp_changelog(dated, '2.0.1', date)).to eq(dated)
    end

    it 'raises when the version has no entry' do
      expect { described_class.stamp_changelog(changelog, '2.0.2', date) }
        .to raise_error(Release::Error, /no '## \[2\.0\.2\]' entry/)
    end
  end

  describe '.bump_version_file' do
    let(:source) { "module AmazonSpClients\n  VERSION = '2.0.0'.freeze\nend\n" }

    it 'replaces the constant and nothing else' do
      expect(described_class.bump_version_file(source, '2.0.1'))
        .to eq("module AmazonSpClients\n  VERSION = '2.0.1'.freeze\nend\n")
    end

    it 'raises when the constant is missing' do
      expect { described_class.bump_version_file("module X\nend\n", '2.0.1') }
        .to raise_error(Release::Error, /VERSION/)
    end
  end
end
