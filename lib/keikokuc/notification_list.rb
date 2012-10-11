# Public: collection of keikoku notifications
#
# This class encapsulates Keikoku::Notification objects
# as a collection.
#
# It includes the Enumerable module, so `map`, `detect`,
# and friends can be used.
#
# Examples
#
#   notifications = Keikokuc::NotificationList.new(user:    'user@example.com',
#                                                  api_key: 'abcd')
#   if notifications.fetch
#     notifications.each do |notification|
#       puts notification.inspect
#     end
#   else
#     # handle error
#   end
class Keikokuc::NotificationList
  include Enumerable

  attr_accessor :user, :password

  # Public: Initializes a NotificationList
  #
  # opts - options hash containing attribute values for the object
  #        being constructed accepting the following three keys:
  #  user - the heroku account's email (required)
  #  password - the heroku account's password (required)
  #  client - the client, used for DI in tests
  def initialize(opts)
    @user          = opts.fetch(:user)
    @password      = opts.fetch(:password)
    @client        = opts[:client]
    @notifications = []
  end

  # Public: fetches notifications for the provided user
  #
  # Sets notifications to a set of `Notification` objects
  # accessible via methods in Enumerable
  #
  # Returns a boolean set to true if fetching succeeded
  def fetch
    result, error = client.get_notifications
    if error.nil?
      @notifications = result.map do |attributes|
        Keikokuc::Notification.new(attributes)
      end
    end

    error.nil?
  end

  # Public: the number of notifications
  #
  # Returns an Integer set to the number of notifications
  def size
    @notifications.size
  end

  # Public: yields each Notification
  #
  # Yields every notification in this collection
  def each
    @notifications.each
  end

private
  def client # :nodoc:
    @client ||= Client.new(user: user, password: password)
  end
end
