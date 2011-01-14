class ActionController::TestCase
  [:get, :post, :put, :delete].each do |method|
    class_eval <<-RUBY
      def self.on_#{method}(action, options = {}, &block)
        on_http_method(#{method.inspect}, action, options, &block)
      end

      def self.should_404_on_#{method}(action, options = {}, &block)
        should_404_on_http_method(#{method.inspect}, action, options, &block)
      end
    RUBY
  end

  private

  def self.on_http_method(method, action, options = {}, &block)
    description = on_http_method_description(method, action, options)
    context description do
      setup do
        send_http_method(method, action, options)
      end
      merge_block(&block)
    end
  end

  def self.should_404_on_http_method(method, action, options = {}, &block)
    description = on_http_method_description(method, action, options)
    should "return 404 #{description}" do
      assert_raise(Mongoid::Errors::DocumentNotFound) do
        send_http_method(method, action, options)
      end
    end
  end

  def self.on_http_method_description(method, action, options = {})
    "on #{method.to_s.upcase} to #{action.inspect} with #{options.inspect}"
  end

  def send_http_method(method, action, options = {})
    opts = options.is_a?(Proc) ?
           options.bind(self).call :
           convert_hash_values_to_instance_variable_params(options)
    send(method, action, opts)
  end

  def convert_hash_values_to_instance_variable_params(hash)
    converted = {}
    hash.each do |k, v|
      if v.is_a?(Hash)
        v = convert_hash_values_to_instance_variable_params(v)
      elsif v.to_s.starts_with?("@")
        v = instance_eval(v.to_s)
      end
      converted[k] = v
    end
    converted
  end
end
