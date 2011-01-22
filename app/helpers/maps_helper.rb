module MapsHelper
  def compact_embed_code(map, locals = {})
    embed_code = render :partial => "maps/embed", :locals => locals.merge(:map => map)
    embed_code = embed_code.lines.map(&:strip).join
  end

  def location_type_options
    options_for_select([["Please select a location type...", nil]] + AppConfig[:boundaries])
  end

  def data_type_options
    options_for_select([["Please select a data type...", nil]] + DATA_TYPES)
  end

  DATA_TYPES = [['Plain text', 'string'],
                ['Whole numbers', 'integer'],
                ['Decimals', 'decimal'],
                ['Time or Date', 'datetime']]
end
