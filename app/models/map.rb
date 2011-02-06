class Map < ActiveRecord::Base
  validates_presence_of :title, :original_csv_data
  validates_presence_of :location_column_name, :location_column_type
  validates_presence_of :data_column_name, :data_column_type

  before_create :set_token, :set_admin_token

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

  def to_png(text_overlay = token, size = nil)
    query = { :size => (size || "l"), :format => "png", :text => text_overlay }
    GeoIQ.get("/maps/#{self.geoiq_map_xid}", :query => query).body
  end

  def to_csv
    to_dataset_format("csv")
  end

  def to_kml
    to_dataset_format("kml")
  end

  protected

  def to_dataset_format(format)
    GeoIQ.get("/datasets/#{self.geoiq_dataset_xid}.#{format}").body
  end

  def generate_token(size = 12)
    begin
      token = ActiveSupport::SecureRandom.hex(size).first(size)
    end while self.class.find_by_token(token)
    token
  end

  def set_token
    self.token = generate_token(6)
  end

  def set_admin_token
    self.admin_token = generate_token(12)
  end
end
