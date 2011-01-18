module MapsHelper
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
