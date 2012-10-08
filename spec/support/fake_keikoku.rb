class FakeKeikoku
  def initialize
    @publishers = []
    @notifications = []
  end

  def register_publisher(opts)
    @publishers << opts
  end

  def publisher_by_api_key(api_key)
    @publishers.detect { |p| p[:api_key] == api_key }
  end

  def call(env)
    with_rack_env(env) do
      if request_path == '/api/v1/notifications' && request_verb == 'POST'
        if publisher_by_api_key(request_api_key)
          notification = Notification.new({id: next_id}.merge(request_body))
          @notifications << notification
          [200, { }, [Yajl::Encoder.encode({id: notification.id})]]
        else
          [401, { }, ["Not authorized"]]
        end
      end
    end
  end

private
  def rack_env
    @rack_env
  end

  def with_rack_env(rack_env)
    @rack_env = rack_env
    response = yield
  ensure
    @rack_env = nil
    response
  end

  def request_path
    rack_env['PATH_INFO']
  end

  def request_verb
    rack_env['REQUEST_METHOD']
  end

  def request_body
    raw_body = rack_env["rack.input"].read
    rack_env["rack.input"].rewind
    Yajl::Parser.parse(raw_body)
  end

  def request_api_key
    rack_env["HTTP_X_KEIKOKU_AUTH"]
  end

  def next_id
    @@sequence ||= 0
    @@sequence += 1
  end

  class Notification
    def initialize(opts)
      @opts = opts
      opts.each do |key, value|
        self.class.send :define_method, key do
          value
        end
      end
    end
  end
end
