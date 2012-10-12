# Public: Encapsulates a keikoku notification
#
# This is the entry point for dealing with notifications
#
# Examples
#
#   notification = Keikokuc::Notification.new(message: 'hello',
#                                             severity: 'info',
#                                             target_name: 'sunny-skies-42'
#                                             producer_api_key: 'abcd')
#   if notification.publish
#     # persist notification
#   else
#     # handle error
#   end
#
class Keikokuc::Notification
  ATTRS = %w[message url severity
             target_name account_email
             producer_api_key remote_id
             errors read_at account_sequence].freeze

  attr_accessor *ATTRS

  # Public: Initialize a notification
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
    @client = opts[:client]
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

  # Public: marks this notification as read on keikoku
  #
  # Marks the notification as read, after which it will
  # no longer be displayed to any consumer for this user
  #
  # Returns a boolean set to true if marking as read succeeded
  def read
    response, error = client.read_notification(remote_id)
    if error.nil?
      self.read_at = response[:read_at]
    end
    error.nil?
  end

  # Public: whether this notification is marked as read by this user
  #
  # Returns true if the user has marked this notification as read
  def read?
    !!@read_at
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

  def client # :nodoc:
    @client ||= Keikokuc::Client.new(producer_api_key: producer_api_key)
  end
end
