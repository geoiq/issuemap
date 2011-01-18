class DatasetPreprocessor
  extend ActiveSupport::Memoizable

  def initialize(data)
    if data.respond_to?(:original_filename)
      digest_spreadsheet(data)
    else
      digest_delimited(data, guess_delimiter(data))
    end
  end

  delegate :headers, :to_csv, :values_at, :to => :@table
  alias_method :column_names, :headers
  alias_method :csv, :to_csv

  def values_for(column_name)
    values_at(column_name).flatten
  end

  def column_details
    {}.tap do |types|
      column_names.each do |column_name|
        types[column_name] = { :guessed_type => nil, :samples => samples(column_name) }
      end
    end
  end

  def guessed_location_column
    possible_location_columns.first
  end

  def guessed_data_column
    (possible_data_columns - possible_location_columns).first
  end

  def as_json(options)
    {
      :csv                     => csv,
      :column_names            => column_names,
      :column_details          => column_details,
      :guessed_location_column => guessed_location_column,
      :guessed_data_column     => guessed_data_column,
    }
  end

  private

  def digest_spreadsheet(uploaded_file)
    case File.extname(uploaded_file.original_filename)
    when ".xls"
      # TODO
    when ".xlsx"
      # TODO
    else # .csv, .txt, etc
      delimiter = guess_delimiter(uploaded_file)
      uploaded_file.rewind
      digest_delimited(uploaded_file, delimiter)
    end
  end

  def digest_delimited(data_or_file, delimiter = ",")
    csv = FasterCSV.new(data_or_file, :col_sep => delimiter, :headers => true, :skip_blanks => true)
    @table = csv.read
  end

  def guess_delimiter(data_or_file)
    tabified = data_or_file.lines.all? { |line| line.include?("\t") }
    tabified ? "\t" : ","
  end

  def samples(column_name)
    values_for(column_name)[0...3]
  end

  def possible_data_columns
    column_names.select do |name|
      values_for(name).all? { |value| Float(value) rescue false }
    end
  end
  memoize :possible_data_columns

  POSSIBLE_LOCATION_SNIPPETS = %w(state country county fips district zip)
  def possible_location_columns
    column_names.select do |name|
      normalized_name = name.to_s.downcase
      POSSIBLE_LOCATION_SNIPPETS.any? { |snippet| normalized_name.include?(snippet) }
    end
  end
  memoize :possible_location_columns
end