class DatasetPreprocessor
  extend ActiveSupport::Memoizable

  def initialize(data)
    if data.respond_to?(:original_filename)
      digest_file(data)
    else
      digest_delimited(data, guess_delimiter(data))
    end
  end

  delegate :to_csv, :values_at, :to => :@table
  alias_method :csv, :to_csv

  def column_names
    @table.headers.reject(&:blank?)
  end
  memoize :column_names

  def values_for(column_name)
    values_at(column_name).flatten
  end

  def column_details
    {}.tap do |types|
      column_names.each do |column_name|
        types[column_name] = { :guessed_type => nil, :samples => samples(column_name, 7) }
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

  # Return CSV that only includes the specified columns, with column names that
  # conform to the naming conventions required by GeoIQ.
  def to_geoiq_csv(*column_names)
    FasterCSV.generate do |csv|
      csv << column_names.map { |n| self.class.safe_column_name(n) }
      values_at(*column_names).each do |values|
        csv << values
      end
    end
  end

  # This isn't the best way to handle validations, but this is a quick win until
  # we upgrade to Rails 3 and ActiveModel::Validations
  def check_validity!
    if column_names.length < 2
      raise ArgumentError, "Data must include at least two columns"
    end
    if @table.size < 2
      raise ArgumentError, "Data must include at least one header and one data row"
    end
  end

  def self.safe_column_name(name)
    name.
      gsub("%", " percent ").
      gsub("$", " dollars ").
      gsub("<", " less than ").
      gsub(">", " greater than ").
      strip.
      gsub(/\s+/, "_").
      gsub(/\W/, "").downcase if name
  end

  private

  def digest_file(uploaded_file)
    case File.extname(uploaded_file.original_filename.downcase)
    when ".xls"
      digest_spreadsheet(Excel, uploaded_file)
    when ".xlsx"
      digest_spreadsheet(Excelx, uploaded_file)
    when '.ods'
      digest_spreadsheet(Openoffice, uploaded_file)
    else # .csv, .txt, etc
      delimiter = guess_delimiter(uploaded_file)
      uploaded_file.rewind
      digest_delimited(uploaded_file, delimiter)
    end
  end

  def digest_spreadsheet(spreadsheet_class, uploaded_file)
    tempfile = Tempfile.new("spreadsheet")
    spreadsheet_class.new(uploaded_file.path, false, :ignore).to_csv(tempfile.path)
    digest_delimited(tempfile, ",")
  end

  def digest_delimited(data_or_file, delimiter = ",")
    csv = FasterCSV.new(data_or_file, :col_sep => delimiter, :skip_blanks => true,
                        :headers => true, :header_converters => [one_line_headers])
    @table = csv.read
  end

  # FasterCSV::Table does't seem to behave when a header has carriage returns in
  # it. This cleans header values to avoid what could be considered a bug in
  # FasterCSV.
  def one_line_headers
    lambda { |h| h.tr("\r\n", " ") if h }
  end

  def guess_delimiter(data_or_file)
    line_count = 0
    tab_line_count = 0
    data_or_file.lines.each do |line|
      line_count += 1
      tab_line_count += 1 if line.include?("\t")
    end
    tab_ratio = tab_line_count.to_f / line_count.to_f
    (tab_ratio > 0.8) ? "\t" : ","
  end

  def samples(column_name, count)
    values_for(column_name)[0...count]
  end

  def possible_data_columns
    column_names.select do |name|
      values_for(name).all? { |value| Float(value.to_s.tr(",", "")) rescue false }
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
