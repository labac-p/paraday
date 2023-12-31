# frozen_string_literal: true

module Paraday
  class Response
    # RaiseError is a Paraday middleware that raises exceptions on common HTTP
    # client or server error responses.
    class RaiseError < Middleware
      # rubocop:disable Naming/ConstantName
      ClientErrorStatuses = (400...500).freeze
      ServerErrorStatuses = (500...600).freeze
      # rubocop:enable Naming/ConstantName

      def on_complete(env)
        case env[:status]
        when 400
          raise Paraday::BadRequestError, response_values(env)
        when 401
          raise Paraday::UnauthorizedError, response_values(env)
        when 403
          raise Paraday::ForbiddenError, response_values(env)
        when 404
          raise Paraday::ResourceNotFound, response_values(env)
        when 407
          # mimic the behavior that we get with proxy requests with HTTPS
          msg = %(407 "Proxy Authentication Required")
          raise Paraday::ProxyAuthError.new(msg, response_values(env))
        when 408
          raise Paraday::RequestTimeoutError, response_values(env)
        when 409
          raise Paraday::ConflictError, response_values(env)
        when 422
          raise Paraday::UnprocessableEntityError, response_values(env)
        when 429
          raise Paraday::TooManyRequestsError, response_values(env)
        when ClientErrorStatuses
          raise Paraday::ClientError, response_values(env)
        when ServerErrorStatuses
          raise Paraday::ServerError, response_values(env)
        when nil
          raise Paraday::NilStatusError, response_values(env)
        end
      end

      # Returns a hash of response data with the following keys:
      #   - status
      #   - headers
      #   - body
      #   - request
      #
      # The `request` key is omitted when the middleware is explicitly
      # configured with the option `include_request: false`.
      def response_values(env)
        response = {
          status: env.status,
          headers: env.response_headers,
          body: env.body
        }

        # Include the request data by default. If the middleware was explicitly
        # configured to _not_ include request data, then omit it.
        return response unless options.fetch(:include_request, true)

        response.merge(
          request: {
            method: env.method,
            url: env.url,
            url_path: env.url.path,
            params: query_params(env),
            headers: env.request_headers,
            body: env.request_body
          }
        )
      end

      def query_params(env)
        env.request.params_encoder ||= Paraday::Utils.default_params_encoder
        env.params_encoder.decode(env.url.query)
      end
    end
  end
end

Paraday::Response.register_middleware(raise_error: Paraday::Response::RaiseError)
