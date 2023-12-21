# frozen_string_literal: true

RSpec.describe Paraday do
  it 'has a version number' do
    expect(Paraday::VERSION).not_to be nil
  end

  context 'proxies to default_connection' do
    let(:mock_connection) { double('Connection') }
    before do
      Paraday.default_connection = mock_connection
    end

    it 'proxies methods that exist on the default_connection' do
      expect(mock_connection).to receive(:this_should_be_proxied)

      Paraday.this_should_be_proxied
    end

    it 'uses method_missing on Paraday if there is no proxyable method' do
      expected_message =
        if RUBY_VERSION >= '3.3'
          "undefined method `this_method_does_not_exist' for module Paraday"
        else
          "undefined method `this_method_does_not_exist' for Paraday:Module"
        end

      expect { Paraday.this_method_does_not_exist }.to raise_error(NoMethodError, expected_message)
    end

    it 'proxied methods can be accessed' do
      allow(mock_connection).to receive(:this_should_be_proxied)

      expect(Paraday.method(:this_should_be_proxied)).to be_a(Method)
    end

    after do
      Paraday.default_connection = nil
    end
  end
end
