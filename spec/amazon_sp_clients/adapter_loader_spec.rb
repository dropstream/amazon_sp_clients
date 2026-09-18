# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AmazonSpClients::AdapterLoader do
  describe '.require_adapter!' do
    it 'loads the adapter without error' do
      expect { described_class.require_adapter! }.not_to raise_error
    end

    context 'when the adapter cannot load under this Faraday' do
      before do
        # faraday-httpclient 1.x under Faraday 2 fails inside the require
        # with NoMethodError (Faraday 1's `dependency` DSL is gone).
        allow(described_class).to receive(:require)
          .with('faraday/httpclient')
          .and_raise(NoMethodError, "undefined method 'dependency'")
      end

      it 'raises LoadError naming the fix command' do
        expect { described_class.require_adapter! }.to raise_error(
          LoadError,
          /bundle update faraday faraday-httpclient faraday-retry/
        )
      end

      it 'names both gem versions in the message' do
        expect { described_class.require_adapter! }.to raise_error(
          LoadError, /faraday-httpclient .* under Faraday #{Faraday::VERSION}/
        )
      end
    end
  end
end
