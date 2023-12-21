# frozen_string_literal: true

RSpec.describe Paraday::Response::RaiseError do
  let(:conn) do
    Paraday.new do |b|
      b.response :raise_error
      b.adapter :test do |stub|
        stub.get('ok') { [200, { 'Content-Type' => 'text/html' }, '<body></body>'] }
        stub.get('bad-request') { [400, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('unauthorized') { [401, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('forbidden') { [403, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('not-found') { [404, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('proxy-error') { [407, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('request-timeout') { [408, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('conflict') { [409, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('unprocessable-entity') { [422, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('too-many-requests') { [429, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('4xx') { [499, { 'X-Reason' => 'because' }, 'keep looking'] }
        stub.get('nil-status') { [nil, { 'X-Reason' => 'nil' }, 'fail'] }
        stub.get('server-error') { [500, { 'X-Error' => 'bailout' }, 'fail'] }
      end
    end
  end

  it 'raises no exception for 200 responses' do
    expect { conn.get('ok') }.not_to raise_error
  end

  it 'raises Paraday::BadRequestError for 400 responses' do
    expect { conn.get('bad-request') }.to raise_error(Paraday::BadRequestError) do |ex|
      expect(ex.message).to eq('the server responded with status 400')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(400)
      expect(ex.response_status).to eq(400)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::UnauthorizedError for 401 responses' do
    expect { conn.get('unauthorized') }.to raise_error(Paraday::UnauthorizedError) do |ex|
      expect(ex.message).to eq('the server responded with status 401')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(401)
      expect(ex.response_status).to eq(401)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::ForbiddenError for 403 responses' do
    expect { conn.get('forbidden') }.to raise_error(Paraday::ForbiddenError) do |ex|
      expect(ex.message).to eq('the server responded with status 403')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(403)
      expect(ex.response_status).to eq(403)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::ResourceNotFound for 404 responses' do
    expect { conn.get('not-found') }.to raise_error(Paraday::ResourceNotFound) do |ex|
      expect(ex.message).to eq('the server responded with status 404')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(404)
      expect(ex.response_status).to eq(404)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::ProxyAuthError for 407 responses' do
    expect { conn.get('proxy-error') }.to raise_error(Paraday::ProxyAuthError) do |ex|
      expect(ex.message).to eq('407 "Proxy Authentication Required"')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(407)
      expect(ex.response_status).to eq(407)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::RequestTimeoutError for 408 responses' do
    expect { conn.get('request-timeout') }.to raise_error(Paraday::RequestTimeoutError) do |ex|
      expect(ex.message).to eq('the server responded with status 408')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(408)
      expect(ex.response_status).to eq(408)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::ConflictError for 409 responses' do
    expect { conn.get('conflict') }.to raise_error(Paraday::ConflictError) do |ex|
      expect(ex.message).to eq('the server responded with status 409')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(409)
      expect(ex.response_status).to eq(409)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::UnprocessableEntityError for 422 responses' do
    expect { conn.get('unprocessable-entity') }.to raise_error(Paraday::UnprocessableEntityError) do |ex|
      expect(ex.message).to eq('the server responded with status 422')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(422)
      expect(ex.response_status).to eq(422)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::TooManyRequestsError for 429 responses' do
    expect { conn.get('too-many-requests') }.to raise_error(Paraday::TooManyRequestsError) do |ex|
      expect(ex.message).to eq('the server responded with status 429')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(429)
      expect(ex.response_status).to eq(429)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::NilStatusError for nil status in response' do
    expect { conn.get('nil-status') }.to raise_error(Paraday::NilStatusError) do |ex|
      expect(ex.message).to eq('http status could not be derived from the server response')
      expect(ex.response[:headers]['X-Reason']).to eq('nil')
      expect(ex.response[:status]).to be_nil
      expect(ex.response_status).to be_nil
      expect(ex.response_body).to eq('fail')
      expect(ex.response_headers['X-Reason']).to eq('nil')
    end
  end

  it 'raises Paraday::ClientError for other 4xx responses' do
    expect { conn.get('4xx') }.to raise_error(Paraday::ClientError) do |ex|
      expect(ex.message).to eq('the server responded with status 499')
      expect(ex.response[:headers]['X-Reason']).to eq('because')
      expect(ex.response[:status]).to eq(499)
      expect(ex.response_status).to eq(499)
      expect(ex.response_body).to eq('keep looking')
      expect(ex.response_headers['X-Reason']).to eq('because')
    end
  end

  it 'raises Paraday::ServerError for 500 responses' do
    expect { conn.get('server-error') }.to raise_error(Paraday::ServerError) do |ex|
      expect(ex.message).to eq('the server responded with status 500')
      expect(ex.response[:headers]['X-Error']).to eq('bailout')
      expect(ex.response[:status]).to eq(500)
      expect(ex.response_status).to eq(500)
      expect(ex.response_body).to eq('fail')
      expect(ex.response_headers['X-Error']).to eq('bailout')
    end
  end

  describe 'request info' do
    let(:conn) do
      Paraday.new do |b|
        b.response :raise_error, **middleware_options
        b.adapter :test do |stub|
          stub.post(url, request_body, request_headers) do
            [400, { 'X-Reason' => 'because' }, 'keep looking']
          end
        end
      end
    end
    let(:middleware_options) { {} }
    let(:request_body) { JSON.generate({ 'item' => 'sth' }) }
    let(:request_headers) { { 'Authorization' => 'Basic 123' } }
    let(:url_path) { 'request' }
    let(:query_params) { 'full=true' }
    let(:url) { "#{url_path}?#{query_params}" }

    subject(:perform_request) do
      conn.post url do |req|
        req.headers['Authorization'] = 'Basic 123'
        req.body = request_body
      end
    end

    it 'returns the request info in the exception' do
      expect { perform_request }.to raise_error(Paraday::BadRequestError) do |ex|
        expect(ex.response[:request][:method]).to eq(:post)
        expect(ex.response[:request][:url]).to eq(URI("http:/#{url}"))
        expect(ex.response[:request][:url_path]).to eq("/#{url_path}")
        expect(ex.response[:request][:params]).to eq({ 'full' => 'true' })
        expect(ex.response[:request][:headers]).to match(a_hash_including(request_headers))
        expect(ex.response[:request][:body]).to eq(request_body)
      end
    end

    context 'when the include_request option is set to false' do
      let(:middleware_options) { { include_request: false } }

      it 'does not include request info in the exception' do
        expect { perform_request }.to raise_error(Paraday::BadRequestError) do |ex|
          expect(ex.response.keys).to contain_exactly(
            :status,
            :headers,
            :body
          )
        end
      end
    end
  end
end
