require 'httparty'
require 'json'

module Kipalog
  class APIClient
    BASE_URI = 'kipalog.com/api/v1'.freeze
    X_KIPALOG_TOKEN = 'X-Kipalog-Token'.freeze
    ACCEPT_CHARSET = 'Accept-Charset'
    DEFAULT_CHARSET = 'application/json'

    def initialize(config = Kipalog.config)
      @config = config
    end

    def get(path)
      send_request(:get, path)
    end

    def post(path, request_body)
      send_request(:post, path, request_body)
    end

    def send_request(method, path, body_hash = {})
      _make_request(method, path, body_hash) do |result|
        response = Kipalog::Response.new(
          result.code,
          result.headers,
          result.parsed_response
        )

        if response.ok?
          response
        else
          raise RequestError, response.body
        end
      end
    end

    private

    attr_reader :config

    def _make_request(method, path, body_hash)
      yield(HTTParty.send(method, path, _request_options(body_hash)))
    rescue HTTParty::Error => e
      raise RequestError, e.message
    end

    def _request_options(body_hash)
      {
        base_uri: BASE_URI,
        body: body_hash.to_json,
        headers: _headers
      }
    end

    def _headers
      {
        X_KIPALOG_TOKEN => config.token,
        ACCEPT_CHARSET => DEFAULT_CHARSET
      }
    end
  end
end

