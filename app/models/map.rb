class Map < ActiveRecord::Base
  validates_presence_of :title, :original_csv_data
  validates_presence_of :location_column_name, :location_column_type
  validates_presence_of :data_column_name, :data_column_type

  before_create :set_token

  # Creates a PNG image of the map in GeoIQ
  #
  # Options:
  # * size - s,m,l - for image size (optional, default: "l")
  # * extent - "west,south,east,north" bounding extents (optional, default: map bounds)
  def to_png(options)
    query_options = options.merge!({:size=> options[:size] || "l", :format => "png"})
    logger.debug("Map to_png: #{query_options.inspect}")
    begin
      resp = GeoIQ.send("get", "/maps/#{self.geoiq_map_xid}", :query => query_options)
    rescue GeoIQ::Exception => e
      raise e.headers.inspect
    end
    logger.debug "Body: #{resp.body}"
    resp.body
  end

  def provider
    "OpenStreetMap (Road)" # "Yahoo Road", "Google Hybrid", "Google Terrain"
  end

  def to_param
    slug = title.gsub(/\W/, " ").strip.gsub(/\s+/, "-").downcase if title
    [token, slug].compact.join("-")
  end

  protected

  def generate_token(size = 12)
    begin
      token = ActiveSupport::SecureRandom.hex(size).first(size)
    end while self.class.find_by_token(token)
    token
  end

  def set_token
    self.token = generate_token(6)
  end
end
