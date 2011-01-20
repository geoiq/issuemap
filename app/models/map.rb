class Map < ActiveRecord::Base
  include Attempt
  include MapStyles
  # before_create :create_in_geoiq
  before_create :set_token

  validates_presence_of :title, :original_csv_data
  validates_presence_of :location_column_name, :location_column_type
  validates_presence_of :data_column_name, :data_column_type

  def map_provider
    "OpenStreetMap (Road)" # "Yahoo Road", "Google Hybrid", "Google Terrain"
  end

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

  protected

  def create_in_geoiq
    dataset.map = self
    begin
      if remote_dataset = dataset.create_in_geoiq
        ds = attempt { GeoIQ.get_dataset(remote_dataset.id) }
        RAILS_DEFAULT_LOGGER.debug "Creating a map!! #{ds.inspect} --  #{ds['extent']}"
        if remote_map = attempt { GeoIQ.create_map(:title => title, :basemap => self.map_provider, :tags => "issuemap", :extent => ds["extent"].join(",")) }
          self.geoiq_map_xid = remote_map.id.to_s
          # assumes 1 selected data column: {:attribute_name => {"include"=>"1", "type"=>"integer"}}
          selected_attribute = self.dataset.data_columns.to_a.flatten.first
          styles = @@map_styles.choice
          styles['fill']['selectedAttribute'] = selected_attribute
          # dataset.location_columns.keys.each do |layer_name|
            layer_hash = {
              :title => title,#layer_name.titleize,
              :subtitle => '',
              :visible => true,
              :opacity => 1.0,
              :source => "finder:#{remote_dataset.id}",
              :styles => styles
            }
            attempt { remote_map.create_layer(layer_hash) }
          # end
        end
      end
      remote_map
    rescue GeoIQ::Exception => e
      Rails.logger.warn("GeoIQ request failed: #{e.status}\n\n#{e.message}")
      self.errors.add(:map, "could not be created!")
      return false
    end
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
end
