module HandlesTimeout
  def self.included(base)
    base.extend ClassMethods
  end

  RequestTimeout = Class.new

  module ClassMethods
    def handle_timeout(method_name)
      alias_method "#{method_name}_without_timeout", method_name
      define_method method_name do |args|
        begin
          Timeout::timeout(5) { send("#{method_name}_without_timeout", args) }
        rescue Timeout::Error
          [nil, RequestTimeout]
        end
      end
    end
  end
end
