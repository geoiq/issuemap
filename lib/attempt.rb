# Mix the attempt module in when working with the GeoIQ API if it's acting a bit
# spiky - this should help smooth some of the 500's out.
# 
# Please note that attempt(5) { block! } will still raise exceptions if it consistently
# fails to do whatever it is you need it to do. Just a heads up, dude.
module Attempt
  def attempt(times = 2)
    exception = nil
    times.times do
      begin
        result = yield
        return result
      rescue Exception => e
        exception = e
      end
    end
    raise exception
  end
end
