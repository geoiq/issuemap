require 'geo_iq/base'

module GeoIQ
  class Layer < GeoIQ::Base
    def path #:nodoc:
      "/maps/#{map_id}/layers/#{id}"
    end
  end
end
