require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::Token do
  let(:now) { Time.utc(2026, 9, 3, 12, 0, 0) }

  before { Timecop.freeze(now) }

  def token(expires_at)
    described_class.new(
      access_token: 'Atza|x', token_type: 'bearer', expires_in: 3600,
      expires_at: expires_at, refresh_token: nil
    )
  end

  it 'is fresh well before expiry' do
    expect(token(now + 3600)).not_to be_expired
  end

  it 'counts as expired 60 seconds early' do
    expect(token(now + 60)).to be_expired
    expect(token(now + 61)).not_to be_expired
  end

  it 'counts a token without expiry as expired' do
    expect(token(nil)).to be_expired
  end

  it 'is frozen' do
    expect(token(now + 3600)).to be_frozen
  end

  it 'hides the token values from inspect' do
    token = described_class.new(access_token: 'Atza|SECRET-A', token_type: 'bearer',
                                expires_in: 3600, expires_at: now + 3600,
                                refresh_token: 'Atzr|SECRET-R')

    expect(token.inspect).to include('bearer').and include('[FILTERED]')
    expect(token.inspect).not_to include('SECRET-A')
    expect(token.inspect).not_to include('SECRET-R')
  end
end
