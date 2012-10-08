require 'rest-client'
require 'yajl'
require 'timeout'

# Internal: Handles HTTP requests/responses to the keikoku API
#
# This class is meant to be used internally by Keikokuc
class Keikokuc::Client
  include HandlesTimeout

  InvalidNotification = Class.new

  # Internal: posts a new notification to keikoku
  #
  # attributes - a hash containing notification attributes
  #
  # Examples
  #
  #   client = Keikokuc::Client.new
  #   response, error = client.post_notification(message: 'hello')
  #
  # Returns
  #
  # two objects:
  #   The response as a hash
  #   The error if any (nil if no error)
  #
  # Possible errors include:
  #
  # * `Client::Timeout` if the request takes longer than 5 seconds
  # * `Client::InvalidNotification` if the response indicates
  #   invalid notification attributes
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
  def notifications_api # :nodoc:
    @notifications_api ||= RestClient::Resource.new(api_url)
  end

  def api_url # :nodoc:
    "https://keikoku.herokuapp.com/api/v1/notifications"
  end

  def encode_json(hash) # :nodoc:
    Yajl::Encoder.encode(hash)
  end

  def parse_json(data) # :nodoc:
    symbolize_keys(Yajl::Parser.parse(data)) if data
  end

  def symbolize_keys(hash) # :nodoc:
    hash.inject({}) do |result, (k, v)|
      result[k.to_sym] = v
      result
    end
  end
end
