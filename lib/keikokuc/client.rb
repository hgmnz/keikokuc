require 'rest-client'
require 'yajl'
require 'timeout'
class Keikokuc::Client
  include HandlesTimeout

  InvalidNotification = Class.new

  def post_notification(attributes)
    begin
      response = notifications_api.post(encode_json(attributes))
    rescue RestClient::UnprocessableEntity => e
      response = e.response
      error    = InvalidNotification
    end
    [parse_json(response), error]
  end
  handle_timeout :post_notification

private
  def notifications_api
    @notifications_api ||= RestClient::Resource.new(api_url)
  end

  def api_url
    "https://keikoku.herokuapp.com/api/v1/notifications"
  end

  def encode_json(hash)
    Yajl::Encoder.encode(hash)
  end

  def parse_json(data)
    symbolize_keys(Yajl::Parser.parse(data)) if data
  end

  def symbolize_keys(hash)
    hash.inject({}) do |result, (k, v)|
      result[k.to_sym] = v
      result
    end
  end
end
