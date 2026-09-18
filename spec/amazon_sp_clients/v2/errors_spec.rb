require 'spec_helper'
require 'amazon_sp_clients/v2'

RSpec.describe AmazonSpClients::V2::Error do
  v2 = AmazonSpClients::V2

  it 'is a StandardError carrying request context' do
    err = described_class.new(
      'boom', status: 400, request_id: 'req-1', request: { path: '/x' }, response: { body: '' }
    )

    expect(err).to be_a(StandardError)
    expect(err.message).to eq('boom')
    expect(err.status).to eq(400)
    expect(err.request_id).to eq('req-1')
    expect(err.request).to eq(path: '/x')
    expect(err.response).to eq(body: '')
  end

  it 'hangs the top-level branches off Error' do
    [v2::ConnectionError, v2::ParseError, v2::AuthError, v2::ResponseError, v2::DocumentError]
      .each { |klass| expect(klass.superclass).to be(described_class) }
  end

  it 'nests the tree as documented' do
    expect(v2::TimeoutError.superclass).to be(v2::ConnectionError)
    expect(v2::InvalidGrantError.superclass).to be(v2::AuthError)
    expect(v2::InvalidClientError.superclass).to be(v2::AuthError)
    expect(v2::ClientError.superclass).to be(v2::ResponseError)
    expect(v2::ServerError.superclass).to be(v2::ResponseError)
    [v2::BadRequestError, v2::UnauthorizedError, v2::ForbiddenError, v2::NotFoundError]
      .each { |klass| expect(klass.superclass).to be(v2::ClientError) }
  end

  # A migrated `rescue V2::ClientError` must not swallow throttling.
  it 'keeps throttling outside the client error branch' do
    expect(v2::ThrottledError.superclass).to be(v2::ResponseError)
    expect(v2::ThrottledError.ancestors).not_to include(v2::ClientError)
  end

  it 'exposes the parsed SP-API errors on response errors' do
    errors = [AmazonSpClients::ApiError::Error.new('InvalidInput', 'bad', nil)]
    err = v2::ResponseError.new('400 InvalidInput: bad', status: 400, errors: errors,
                                                         rate_limit: 0.5)

    expect(err.errors).to eq(errors)
    expect(err.code).to eq('InvalidInput')
    expect(err.rate_limit).to eq(0.5)
  end

  it 'has no code when the body carried no errors' do
    err = v2::ServerError.new('500 (no body)', status: 500)

    expect(err.errors).to eq([])
    expect(err.code).to be_nil
  end

  it 'exposes the LWA error code and description on auth errors' do
    err = v2::AuthError.new(
      '400 invalid_grant: nope', status: 400, code: 'invalid_grant', description: 'nope'
    )

    expect(err.code).to eq('invalid_grant')
    expect(err.description).to eq('nope')
  end
end
