# frozen_string_literal: true

require 'paraday/adapter/net_http'
require 'paraday/net_http/version'

module Paraday
  module NetHttp
    Paraday::Adapter.register_middleware(net_http: Paraday::Adapter::NetHttp)
  end
end
