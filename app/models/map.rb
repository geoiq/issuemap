class Map < ActiveRecord::Base
  include Attempt
  include MapStyles
  before_create :create_in_geoiq
  before_create :create_linkable_id
  before_update :update_geoiq

  has_one :dataset, :dependent => :destroy
  validates_presence_of :dataset, :title
  accepts_nested_attributes_for :dataset

  MAP_PROVIDERS = ["OpenStreetMap (Road)", "Yahoo Road", "Google Hybrid", "Google Terrain"]

  def remote_map
    @remote_map ||= GeoIQ::Map.find(geoiq_id)
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
      resp = GeoIQ.send("get", "/maps/#{self.maker_id}", :query => query_options)
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
          self.maker_id = remote_map.id
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
  
  def create_linkable_id
    token = Digest::MD5.hexdigest(Time.now.to_s + self.title)[0..5]
    self.linkable_id = token
  end
  
  def update_geoiq
    remote_map.update(:title => title, 
      :extent => [-180,-90,180,90], 
      :basemap => self.map_provider)
  end
  
   
end
