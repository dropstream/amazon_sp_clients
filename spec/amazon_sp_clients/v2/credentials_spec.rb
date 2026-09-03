require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::Credentials do
  v2 = AmazonSpClients::V2

  let(:now) { Time.utc(2026, 9, 3, 12, 0, 0) }

  before { Timecop.freeze(now) }

  # A stand-in for LWA: counts exchanges, records the refresh tokens it
  # was given, and can be slowed down to widen race windows.
  def fake_lwa(rotate: true, delay: 0)
    Class.new do
      attr_reader :calls, :seen_refresh_tokens

      def initialize(rotate, delay)
        @rotate = rotate
        @delay = delay
        @calls = 0
        @seen_refresh_tokens = []
        @mutex = Mutex.new
      end

      def exchange(refresh_token:)
        n = @mutex.synchronize do
          @calls += 1
          @seen_refresh_tokens << refresh_token
          @calls
        end
        sleep(@delay) if @delay.positive?

        AmazonSpClients::V2::Token.new(
          access_token: "TOKEN_#{n}", token_type: 'bearer', expires_in: 3600,
          expires_at: Time.now.utc + 3600, refresh_token: @rotate ? "RT#{n}" : nil
        )
      end
    end.new(rotate, delay)
  end

  describe v2::Credentials::Callback do
    it 'asks the block for the token on every call' do
      tokens = %w[first second]
      calls = 0
      creds = described_class.new do
        calls += 1
        tokens.shift
      end

      expect(creds.access_token).to eq('first')
      expect(creds.access_token).to eq('second')
      expect(calls).to eq(2)
    end

    it 'needs a block' do
      expect { described_class.new }.to raise_error(ArgumentError, /block/)
    end
  end

  describe v2::Credentials::RefreshToken do
    let(:lwa) { fake_lwa }
    let(:creds) { described_class.new(lwa, 'RT0') }

    it 'exchanges on first use and reuses the token while it is fresh' do
      expect(creds.access_token).to eq('TOKEN_1')
      expect(creds.access_token).to eq('TOKEN_1')
      expect(lwa.calls).to eq(1)
    end

    it 'exchanges again once the token counts as expired' do
      creds.access_token
      Timecop.freeze(now + 3600 - 60)

      expect(creds.access_token).to eq('TOKEN_2')
      expect(lwa.calls).to eq(2)
    end

    it 'exchanges once when many threads hit an expired token' do
      slow_lwa = fake_lwa(delay: 0.02)
      creds = described_class.new(slow_lwa, 'RT0')

      tokens = Array.new(8) { Thread.new { creds.access_token } }.map(&:value)

      expect(slow_lwa.calls).to eq(1)
      expect(tokens.uniq).to eq(['TOKEN_1'])
    end

    it 'sends the rotated refresh token on the next exchange' do
      creds.access_token
      Timecop.freeze(now + 3600)
      creds.access_token

      expect(lwa.seen_refresh_tokens).to eq(%w[RT0 RT1])
      expect(creds.refresh_token).to eq('RT2')
    end

    it 'keeps the previous refresh token when the response omits it' do
      lwa = fake_lwa(rotate: false)
      creds = described_class.new(lwa, 'RT0')

      creds.access_token
      Timecop.freeze(now + 3600)
      creds.access_token

      expect(lwa.seen_refresh_tokens).to eq(%w[RT0 RT0])
      expect(creds.refresh_token).to eq('RT0')
    end

    it 'reports the initial refresh token before any exchange' do
      expect(creds.refresh_token).to eq('RT0')
    end
  end
end
