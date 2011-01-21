class Map < ActiveRecord::Base
  validates_presence_of :title, :original_csv_data
  validates_presence_of :location_column_name, :location_column_type
  validates_presence_of :data_column_name, :data_column_type

  before_create :set_token

  # Returns a PNG version of the map from GeoIQ
  #
  # options - A Hash used to refind the query (default: {})
  #           :text   - A String to overlay on the image (optional;
  #                     default: `token`)
  #           :size   - A String representing an images size (optional;
  #                     values: s, m, or l; default: l)
  #           :extend - A String representing the bounding extents (optional;
  #                     default: map bounds)
  def to_png(options = {})
    options = options.reverse_merge(:size => "l", :text => token).merge(:format => "png")
    response = GeoIQ.get("/maps/#{self.geoiq_map_xid}", :query => options)
    response.body
  end

  def provider
    "OpenStreetMap (Road)" # "Yahoo Road", "Google Hybrid", "Google Terrain"
  end

  def to_param
    slug = title.gsub(/\W/, " ").strip.gsub(/\s+/, "-").downcase if title
    [token, slug].compact.join("-")
  end

  def dom_token
    ["map", (token || "new")].join("_")
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
