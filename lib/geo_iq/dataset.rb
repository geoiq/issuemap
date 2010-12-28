require 'geo_iq/base'

# The GeoIQ::Dataset class provides an interface to existing GeoIQ datasets, including
# dumps of their most important 

module GeoIQ
  class Dataset < GeoIQ::Base
    class << self
      # Create a new GeoIQ::Dataset instance directly (rather than through provided methods
      # on the GeoIQ module)
      def create(attributes = {})
        new(post('/datasets.json', {:query => attributes}))
      end

      # Returns an instantiated GeoIQ::Dataset. Raises a GeoIQ::Exception if the Dataset
      # doesn't exist.
      def find(id)
        new(GeoIQ.get("/datasets/#{id}.json"))
      end
    end
  end
end
