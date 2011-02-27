class MapObserver < ActiveRecord::Observer
  # TODO: This should really instead trigger a background job where the
  # Maps#show page spins and polls until everything is ready.
  def before_create(map)
    create_geoiq_map(map)
  end

  def before_update(map)
    update_geoiq_map(map)
  end

  protected

  def create_geoiq_map(map)
    create_geoiq_dataset(map)

    map.color_palette = MapStyles.random_color_palette
    GeoIQ.create_map(map_details(map)).tap do |geoiq_map|
      map.geoiq_map_xid = geoiq_map.id.to_s
    end
  end

  def create_geoiq_dataset(map)
    GeoIQ.create_dataset(dataset_details(map)).tap do |geoiq_dataset|
      map.geoiq_dataset_xid = geoiq_dataset.id.to_s
    end
  end

  def update_geoiq_map(map)
    GeoIQ.put("/maps/#{map.geoiq_map_xid}.json", :query => map_details(map))
  end

  def safe(column_name)
    DatasetPreprocessor.safe_column_name(column_name)
  end

  def dataset_details(map)
    data = DatasetPreprocessor.new(map.original_csv_data)
    trimmed_csv = data.to_geoiq_csv(map.location_column_name, map.data_column_name)
    {
      :data       => trimmed_csv,
      :join_param => "column_types[#{safe(map.location_column_name)}]",
      :join_value => map.location_column_type
    }
  end

  def map_details(map)
    map_details = {
      :title   => map.title,
      :basemap => map.provider,
      :tags    => "issuemap"
    }

    extent = map_extent(map)
    layer  = layer_details(map)
    map_details.merge!(:extent => extent) if extent.present?
    map_details.merge!(:layers => [layer]) if layer.present?
    map_details
  end

  def map_extent(map)
    extent = map.extent
    if map.new_record? && extent.blank?
      ds = GeoIQ.get_dataset(map.geoiq_dataset_xid)
      extent = ds["extent"].join(",")
    end
    extent
  end

  def layer_details(map)
    return if map.color_palette.blank?
    styles = MapStyles.choropleth(map.color_palette, map.flip_colors?)
    return if styles.nil?
    styles[:fill][:selectedAttribute] = safe(map.data_column_name)
    {
      :title    => map.title,
      :subtitle => "",
      :visible  => true,
      :opacity  => 1.0,
      :source   => "finder:#{map.geoiq_dataset_xid}",
      :styles   => styles
    }
  end
end
