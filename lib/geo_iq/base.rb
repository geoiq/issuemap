#:nodoc:

# The GeoIQ::Base class is where much of the basic stuff

module GeoIQ #:nodoc:
  class Base < OpenStruct
    attr_reader :id

    def delete
      GeoIQ.delete("#{path}.json")
    end

    def initialize(attributes = {})
      @id = attributes.delete('id')
      super(attributes)
    end

    # Subclassess override the path method to indicate where they should exist, e.g.
    # a map might provide "/maps/#{self.id}.json" as its path. Cool, eh?
    def path
      raise "You must define a path for this #{self.class.name}"
    end

    # Updates the instance with new attributes
    def update(attributes)
      self.class.new(GeoIQ.put("#{path}.json", attributes).parsed_response)
    end

    # Returns the URL for whatever GeoIQ::Base instance you're looking at should be
    def url
      @url ||= GeoIQ.base_uri + "#{path}.json"
    end
  end
end
