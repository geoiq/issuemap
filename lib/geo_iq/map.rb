require 'geo_iq/base'

module GeoIQ
  class Map < GeoIQ::Base
    class << self
      # Create a new GeoIQ::Map instance directly (rather than through provided methods
      # on the GeoIQ module)
      def create(attributes = {})
        new(post('/maps.json', {:query => attributes}))
      end

      # Returns an instantiated GeoIQ::Map based on the ID passed in. Raises a GeoIQ::Exception
      # if the Map doesn't exist.
      def find(id)
        new(GeoIQ.get("/maps/#{id}.json"))
      end
    end

    # Instantiates a layer on this map and returns the response from the POST.
    # TODO: Return the fully instantiated Layer (with all of its attributes and more fun).
    def create_layer(attributes = {})
      query = {:query => attributes}
      GeoIQ.post("#{path}/layers.json", query)
      # GeoIQ::Layer.new(GeoIQ.post("#{path}/layers.json", query).parsed_response.merge('map_id' => id))
    end

    # Deletes a layer with a given ID
    def delete_layer(id)
      if layer = layers.find {|layer| layer.id == id}
        layer.destroy
      end
    end

    # Returns an array of GeoIQ::Layer instances for this particular map
    def layers
      @layers ||= GeoIQ.get("#{path}/layers.json")#.parsed_response#.map {|layer| GeoIQ::Layer.new(layer.merge('map_id' => id)) }
    end

    def path #:nodoc:
      "/maps/#{id}"
    end
  end
end
