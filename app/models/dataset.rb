require 'pp'
require 'faster_csv' #TODO: remove this, but Gemfile is the bonko and doesn't include it -ajturner
require 'paperclip' #again?
class Dataset < ActiveRecord::Base
  include Attempt

  belongs_to :map
  serialize :data_columns, Hash
  serialize :location_columns, ActiveSupport::OrderedHash

  GRAPH_DATA_TYPES = [
    ['Plain text', 'string'],
    ['Whole numbers', 'integer'],
    ['Decimals', 'decimal'],
    ['Time or Date', 'datetime']
  ]
  LOCATION_COLUMNS  = %w{ county state st zip zipcode zip_code district congressional_district fip fips }
  LOCATION_DATA_TYPES = YAML.load_file(File.join(RAILS_ROOT, 'config', 'boundaries.yml'))[GEOIQ_ENDPOINT] || YAML.load_file(File.join(RAILS_ROOT, 'config', 'boundaries.yml'))["default"]
  # [
  #     ['State - Full Name (e.g. Arkansas)', '14/state'],
  #     ['State - Abbreviation (e.g. AK)', '14/st'],
  #     ['State - FIPS', '14/fips'],
  #     ['Country - Full Name (e.g. France)', '16/NAME'],
  #     ['Country - 3 Letter GMI Code', '16/GMI_CNTRY'],
  #     ['Country - 2 Letter ISO Code (e.g. FR)', '16/ISO_2_CODE'],
  #     ['Country - 3 Letter ISO Code (e.g. FRA)', '16/ISO_3_CODE'],
  #     ['County - County and State (no spaces) (e.g. Springfield,MO)', '17/countysta'],
  #     ['County - State and County (no spaces)', '17/statecount'],
  #     ['County - Name Only (e.g. Arlington)', '17/b'],
  #     ['County - FIPS', '17/f'],
  #     ['Congressional District', '21/cd_1'],
  #     ['Zip - Numeric (e.g. 22201)', '17/ZIP']
  #   ]
    # ['State - Full Name', '522/state'],
    # ['State - Abbreviation', '522/st'],
    # ['State - FIPS', '522/fips'],
    # ['Country - Full Name', '527/NAME'],
    # ['Country - 3 Letter GMI Code', '527/GMI_CNTRY'],
    # ['Country - 2 Letter ISO Code', '527/ISO_2_CODE'],
    # ['Country - 3 Letter ISO Code', '527/ISO_3_CODE'],
    # ['County - County and State (no spaces)', '645/countysta'],
    # ['County - State and County (no spaces)', '645/statecount'],
    # ['County - Name Only', '645/b'],
    # ['County - FIPS', '645/f'],
    # ['Congressional District', '648/cd_1'],
    # ['Zip - Numeric', '645/ZIP']  
  COLUMN_SEPARATORS = [["Comma",","], ["Semicolon", ";"], ["Tab", "\t"]]
  MAX_DATA_POINTS   = 60000

  validate :max_data_points
  validates_size_of :data_columns, :minimum => 1
  validates_size_of :location_columns, :minimum => 1

  attr_accessor :hashed_value, :previous_upload, :location_column_type
  attr_reader :data_column_keys, :data_column_types, :location_column_keys, :location_column_types

  if Rails.env.production?
    has_attached_file :upload,
    :storage => :s3,
    :s3_credentials => 'config/amazon_s3.yml'
  else
    has_attached_file :upload
  end

  def data_points
    @data_points ||= hashed_data.values.flatten.length
  end

  def default_location_columns
    hashed_data.keys.select {|x| LOCATION_COLUMNS.include?(x.downcase.strip.underscore) }
  end

  def data_column_hash=(data_column_hash)
    data_column_hash = Hash[*data_column_hash.delete_if {|key, options| !options['include'] }.map {|key, options| [key, options['type']]}.flatten]
    self.data_columns = data_column_hash unless data_column_hash.empty?
  end

  def default_data_columns
    default_data_columns = ActiveSupport::OrderedHash.new
    hashed_data.each do |key, values|
      if values.map(&:to_s).map(&:strip).all? {|value| value.to_s.strip =~ /^-{0,1}\d+$/ }
        default_data_columns[key] = 'integer'
      elsif values.map(&:to_s).map(&:strip).reject(&:blank?).all? {|value| value.to_s.strip =~ /^-{0,1}\d*\.{0,1}\d*$/}
        default_data_columns[key] = 'decimal'
      end
    end
    default_data_columns
  end
  
  def column_types
    types = {}
    location_columns.each do |column|
      types << { "#{column[0]}" => determine_join_code(column)}
    end
  end
  
  def hashed_data(reparse = false)
    return hashed_value unless (reparse || hashed_value.nil?)
    parse_data!(self.separator)
    hashed_value
  end

  def location_column_keys=(new_location_column_keys)
    @location_column_keys = new_location_column_keys
    set_location_columns if location_column_types
  end

  def location_column_types=(new_location_column_types)
    @location_column_types = new_location_column_types
    set_location_columns if location_column_keys
  end

  def save_upload
    self.previous_upload = File.join(temp_dir, upload.original_filename)
    File.open(self.previous_upload, 'w') do |f|
      f.write(upload.queued_for_write[:original].read)
    end
    self.previous_upload
  end

  protected
  def create_in_geoiq
    # For multiple location columns.  For now, we are only allowing one.
    # ==================================================================
    # joins = {'column_types' => []}
    # location_columns.each do |key, value|
    #   joins['column_types'].push({key => value})
    # end
    # raise joins.inspect.to_s

    # Very important
    join_param = "column_types[#{location_columns.keys.first.downcase}]"
    join_value = location_columns.values.first

    # Add selected location column
    column_attributes = location_columns.map {|key, value| Hash[:name, key, :type, value]}

    # Add selected data column
    column_attributes += data_columns.map {|key, value| Hash[:name, key, :type, value]}

    # Stripped data with only location and single numeric column
    location_column_title = location_columns.map{|key, value| key}
    data_column_title     = data_columns.map{|key, value| key}
    
    trimmed_data = FasterCSV.generate do |csv|
      csv << [location_column_title, data_column_title]
      hashed_value["#{location_column_title}"].length.times do |x|
        csv << [hashed_value["#{location_column_title}"][x], hashed_value["#{data_column_title}"][x]]
      end
    end
    
    if remote_dataset = GeoIQ.create_dataset(:data => trimmed_data, :title => map.title, 
      :attributes => column_attributes, :join_param => join_param, :join_value => join_value)
      self.finder_id = remote_dataset.id
      remote_dataset
    end
  end

  def max_data_points
    errors.add(:data_points, "is too long - maximum is #{MAX_DATA_POINTS}") if data_points > MAX_DATA_POINTS
  end

  def parse_data!(separator)
    # Setup hashed_value as an ordered hash so header order is consistent
    self.hashed_value = ActiveSupport::OrderedHash.new

    # If there's an uploaded file, use the SpreadsheetReader class to produce
    # some CSV data
    if upload.file?
      self.data = SpreadsheetReader.read(upload)
    elsif data.blank?
      return
    end

    # Parse out the CSV file into our ordered hash
    FasterCSV.parse(data, :col_sep => separator, :headers => true) do |row|
      headers = row.headers.reject(&:blank?).map(&:strip).reject(&:blank?).map(&:downcase).each{|x| x.gsub!(" ","_")}.each{|x| x.gsub!(/\W/,"")}
      headers.each_with_index {|header, index| hashed_value[header] ||= [] }
      row.fields.each_with_index do |field, index|
        hashed_value[headers[index]] << field.to_s.strip.gsub(",","") if hashed_value[headers[index]]
      end
    end

    self.data_columns ||= default_data_columns
    self.location_columns ||= ActiveSupport::OrderedHash[*default_location_columns.map {|column| [column, nil] }.flatten]
  end

  def set_location_columns
    new_location_columns = ActiveSupport::OrderedHash.new
    location_column_keys.each do |key|
      new_location_columns[key] = location_column_types.shift
    end
    self.location_columns = new_location_columns
  end

  def temp_dir
    FileUtils.mkdir_p(Rails.root.join('tmp', 'uploads'))
    Rails.root.join('tmp', 'uploads')
  end
end
