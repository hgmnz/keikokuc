class Keikokuc::Notification
  ATTRS = %w[message target severity url producer_api_key remote_id errors].freeze

  attr_accessor *ATTRS

  def initialize(opts = {})
    ATTRS.each do |attribute|
      send("#{attribute}=", opts[attribute]) if opts.has_key?(attribute.to_sym)
    end
  end

  def publish
    body, error = client.post_notification(to_hash)
    if error.nil?
      self.remote_id = body[:id]
      self.errors = nil
    elsif error == Keikokuc::Client::InvalidNotification
      self.errors = body[:errors]
    end
    error.nil?
  end

  def to_hash
    ATTRS.inject({}) do |h, attribute|
      h[attribute.to_sym] = send(attribute)
      h
    end
  end

private
  def client
    @client ||= Keikokuc::Client.new
  end
end
