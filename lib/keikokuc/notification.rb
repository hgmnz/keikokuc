# Public: Encapsulates a keikoku notification
#
# This is the entry point for dealing with notifications
#
# Examples
#
#   notification = Keikokuc::Notification.new(message: 'hello',
#                                             severity: 'info',
#                                             target: 'sunny-skies-42'
#                                             producer_api_key: 'abcd')
#   if notificaiton.publish
#     # persist notification
#   else
#     # handle error
#   end
#
class Keikokuc::Notification
  ATTRS = %w[message url severity
             target_name account_email
             producer_api_key remote_id errors].freeze

  attr_accessor *ATTRS

  # Public: class constructor
  #
  # opts - a hash of attributes to be set on constructed object
  #
  # Examples
  #
  #   notification = Keikokuc::Notification.new(message: 'hello')
  #
  # All keys on matching ATTRS will be set
  def initialize(opts = {})
    ATTRS.each do |attribute|
      if opts.has_key?(attribute.to_sym)
        send("#{attribute}=", opts[attribute.to_sym])
      end
    end
  end

  # Public: publishes this notification to keikoku
  #
  # This method sets the `remote_id` attribute if it succeeds.
  # If it fails, the `errors` hash will be populated.
  #
  # Returns a boolean set to true if publishing succeeded
  def publish
    response, error = client.post_notification(to_hash)
    if error.nil?
      self.remote_id = response[:id]
      self.errors = nil
    elsif error == Keikokuc::Client::InvalidNotification
      self.errors = response[:errors]
    end
    error.nil?
  end

  # Internal: coerces this notification to a hash
  #
  # Returns this notification's attributes as a hash
  def to_hash
    ATTRS.inject({}) do |h, attribute|
      h[attribute.to_sym] = send(attribute)
      h
    end
  end

private
  def client # :nodoc:
    @client ||= Keikokuc::Client.new(producer_api_key: producer_api_key)
  end
end
