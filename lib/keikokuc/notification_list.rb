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
#
class Keikokuc::NotificationList
  include Enumerable

  attr_accessor :user, :password

  def initialize(opts)
    @user          = opts.fetch(:user)
    @password      = opts.fetch(:password)
    @client        = opts[:client]
    @notifications = []
  end

  def fetch
    result, error = client.get_notifications
    if error.nil?
      @notifications = result.map do |attributes|
        Keikokuc::Notification.new(attributes)
      end
    end

    error.nil?
  end

  def size
    @notifications.size
  end

  def each
    @notifications.each
  end

private
  def client
    @client ||= Client.new(user: user, password: password)
  end
end
