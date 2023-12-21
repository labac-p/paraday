# frozen_string_literal: true

# Requires Ruby with rspec and paraday gems.
# rspec client_spec.rb

require 'paraday'
require 'json'

# Example API client
class Client
  def initialize(conn)
    @conn = conn
  end

  def httpbingo(jname, params: {})
    res = @conn.get("/#{jname}", params)
    data = JSON.parse(res.body)
    data['origin']
  end

  def foo(params)
    res = @conn.post('/foo', JSON.dump(params))
    res.status
  end
end

RSpec.describe Client do
  let(:stubs)  { Paraday::Adapter::Test::Stubs.new }
  let(:conn)   { Paraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { Client.new(conn) }

  it 'parses origin' do
    stubs.get('/ip') do |env|
      # optional: you can inspect the Paraday::Env
      expect(env.url.path).to eq('/ip')
      [
        200,
        { 'Content-Type': 'application/javascript' },
        '{"origin": "127.0.0.1"}'
      ]
    end

    # uncomment to trigger stubs.verify_stubbed_calls failure
    # stubs.get('/unused') { [404, {}, ''] }

    expect(client.httpbingo('ip')).to eq('127.0.0.1')
    stubs.verify_stubbed_calls
  end

  it 'handles 404' do
    stubs.get('/api') do
      [
        404,
        { 'Content-Type': 'application/javascript' },
        '{}'
      ]
    end
    expect(client.httpbingo('api')).to be_nil
    stubs.verify_stubbed_calls
  end

  it 'handles exception' do
    stubs.get('/api') do
      raise Paraday::ConnectionFailed
    end

    expect { client.httpbingo('api') }.to raise_error(Paraday::ConnectionFailed)
    stubs.verify_stubbed_calls
  end

  context 'When the test stub is run in strict_mode' do
    let(:stubs) { Paraday::Adapter::Test::Stubs.new(strict_mode: true) }

    it 'verifies the all parameter values are identical' do
      stubs.get('/api?abc=123') do
        [
          200,
          { 'Content-Type': 'application/javascript' },
          '{"origin": "127.0.0.1"}'
        ]
      end

      # uncomment to raise Stubs::NotFound
      # expect(client.httpbingo('api', params: { abc: 123, foo: 'Kappa' })).to eq('127.0.0.1')
      expect(client.httpbingo('api', params: { abc: 123 })).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end
  end

  context 'When the Paraday connection is configured with FlatParamsEncoder' do
    let(:conn) { Paraday.new(request: { params_encoder: Paraday::FlatParamsEncoder }) { |b| b.adapter(:test, stubs) } }

    it 'handles the same multiple URL parameters' do
      stubs.get('/api?a=x&a=y&a=z') { [200, { 'Content-Type' => 'application/json' }, '{"origin": "127.0.0.1"}'] }

      # uncomment to raise Stubs::NotFound
      # expect(client.httpbingo('api', params: { a: %w[x y] })).to eq('127.0.0.1')
      expect(client.httpbingo('api', params: { a: %w[x y z] })).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end
  end

  context 'When you want to test the body, you can use a proc as well as string' do
    it 'tests with a string' do
      stubs.post('/foo', '{"name":"YK"}') { [200, {}, ''] }

      expect(client.foo(name: 'YK')).to eq 200
      stubs.verify_stubbed_calls
    end

    it 'tests with a proc' do
      check = ->(request_body) { JSON.parse(request_body).slice('name') == { 'name' => 'YK' } }
      stubs.post('/foo', check) { [200, {}, ''] }

      expect(client.foo(name: 'YK', created_at: Time.now)).to eq 200
      stubs.verify_stubbed_calls
    end
  end
end
