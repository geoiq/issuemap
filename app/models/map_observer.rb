class MapObserver < ActiveRecord::Observer
  # TODO: This should really instead trigger a background job where the
  # Maps#show page spins and polls until everything is ready.
  def before_create(map)
    create_geoiq_map(map)
  end

  protected

  def create_geoiq_map(map)
    create_geoiq_dataset(map)
    ds = GeoIQ.get_dataset(map.geoiq_dataset_xid) # for extent

    map_details = {
      :title   => map.title,
      :basemap => map.provider,
      :tags    => "issuemap",
      :extent  => ds["extent"].join(",")
    }
    geoiq_map = GeoIQ.create_map(map_details)

    create_geoiq_layer(map, geoiq_map)

    map.geoiq_map_xid = geoiq_map.id.to_s
    geoiq_map
  end

  def create_geoiq_dataset(map)
    data = DatasetPreprocessor.new(map.original_csv_data)
    trimmed_csv = data.to_geoiq_csv(map.location_column_name, map.data_column_name)

    dataset_details = {
      :data       => trimmed_csv,
      :join_param => "column_types[#{safe(map.location_column_name)}]",
      :join_value => map.location_column_type
    }
    geoiq_dataset = GeoIQ.create_dataset(dataset_details)

    map.geoiq_dataset_xid = geoiq_dataset.id.to_s
    geoiq_dataset
  end

  def create_geoiq_layer(map, geoiq_map)
    styles = MapStyles.random_style
    styles[:fill][:selectedAttribute] = safe(map.data_column_name)
    layer_details = {
      :title    => map.title,
      :subtitle => "",
      :visible  => true,
      :opacity  => 1.0,
      :source   => "finder:#{map.geoiq_dataset_xid}",
      :styles   => styles
    }
    geoiq_map.create_layer(layer_details)
  end

  def safe(column_name)
    DatasetPreprocessor.safe_column_name(column_name)
  end
end
