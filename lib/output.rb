# Use this to test requests, since the API doesn't always work as expected. So,
# find a cURL request from the API docs that actually works, then rackup this guy
# (cd RAILS_ROOT && rackup lib/output/config.ru). Point the functional cURL requests
# at this guy, then point GeoIQ at this guy (http://localhost:9292/) and then compare
# the headers that come back.

class Output
  def call(env)
    @response = nil
    request = Rack::Request.new(env)
    puts "Form data? #{request.form_data?}"
    puts "Request body: #{request.body.read}"
    env.keys.sort.each do |key|
      puts "#{key}: #{env[key].inspect}"
    end
    [200, {'Content-Type' => 'text/plain'}, [response.join("\n\n")]]
  end

  def puts(string)
    response.push string
    super string
  end

  def response
    @response ||= []
  end
end
