require 'test_helper'

class DatasetPreprocessorTest < ActiveSupport::TestCase
  context "#column_names" do
    EXPECTED_COLUMN_NAMES = ["State Name", "State Abbreviation", "Count"]

    should "return an array of column names for valid comma delimited data" do
      assert_equal EXPECTED_COLUMN_NAMES, comma_import.column_names
    end

    should "return an array of column names for valid comma delimited data with two line headers" do
      assert_equal EXPECTED_COLUMN_NAMES, comma_multiline_header_import.column_names
    end

    should "return an array of column names for valid comma delimited file" do
      assert_equal EXPECTED_COLUMN_NAMES, comma_file_import.column_names
    end

    should "return an array of column names for valid excel file" do
      assert_equal EXPECTED_COLUMN_NAMES, excel_file_import.column_names
    end

    should "return an array of column names for valid excelx file" do
      assert_equal EXPECTED_COLUMN_NAMES, excelx_file_import.column_names
    end

    should "return an array of column names for valid openoffice file" do
      assert_equal EXPECTED_COLUMN_NAMES, openoffice_file_import.column_names
    end

    should "return an array of column names for valid tab delimited data" do
      assert_equal EXPECTED_COLUMN_NAMES, tab_import.column_names
    end

    should "return an empty array of column names for blank data" do
      assert_equal [], blank_import.column_names
    end
  end

  context "#to_csv" do
    should "return a similar csv file for valid comma delimited data" do
      expected_csv = COMMA_DELIMITED.gsub("\r", "")
      assert_equal expected_csv, comma_import.to_csv
    end

    should "return a similar csv file for valid tab delimited data" do
      expected_csv = TAB_DELIMITED.gsub("\r", "").gsub("\t", ",")
      assert_equal expected_csv, tab_import.to_csv
    end

    should "return an empty csv for blank data" do
      assert_equal "\n", blank_import.to_csv
    end
  end

  context "#values_for" do
    should "return an array of column values for valid comma delimited data" do
      assert_equal ["AL", "AK", "AS", "AZ"], comma_import.values_for("State Abbreviation")
    end

    should "return an empty array for blank data" do
      assert_equal [], blank_import.values_for("Unknown")
    end
  end

  context "#values_at" do
    should "return an array of arrays of column values for valid comma delimited data" do
      assert_equal [["AL"], ["AK"], ["AS"], ["AZ"]], comma_import.values_at("State Abbreviation")
      assert_equal [["AL", "1"], ["AK", "2"], ["AS", "3"], ["AZ", "4"]], comma_import.values_at("State Abbreviation", "Count")
    end

    should "return an empty array for blank data" do
      assert_equal [], blank_import.values_at("Unknown")
    end
  end

  context "#column_details" do
    EXPECTED_COLUMN_DETAILS = {
      "State Name"         => { :guessed_type => nil, :samples => ["ALABAMA", "ALASKA", "AMERICAN SAMOA"] },
      "State Abbreviation" => { :guessed_type => nil, :samples => ["AL", "AK", "AS"] },
      "Count"              => { :guessed_type => nil, :samples => ["1", "2", "3"] },
    }

    should "return a populated hash for valid comma delimited data" do
      assert_equal EXPECTED_COLUMN_DETAILS, comma_import.column_details
    end

    should "return a populated hash for valid comma delimited data with two line headers" do
      assert_equal EXPECTED_COLUMN_DETAILS, comma_multiline_header_import.column_details
    end

    should "return an empty hash for blank data" do
      assert_equal Hash.new, blank_import.column_details
    end
  end

  context "#guessed_location_column" do
    should "return the first good location guess for valid comma delimited data" do
      assert_equal "State Name", comma_import.guessed_location_column
    end

    should "return nil for blank data" do
      assert_nil blank_import.guessed_location_column
    end
  end

  context "#guessed_data_column" do
    should "return the first good data guess for valid comma delimited data" do
      assert_equal "Count", comma_import.guessed_data_column
    end

    should "return nil for blank data" do
      assert_nil blank_import.guessed_data_column
    end
  end

  private

  def comma_import
    DatasetPreprocessor.new(COMMA_DELIMITED)
  end

  def comma_multiline_header_import
    DatasetPreprocessor.new(COMMA_DELIMITED_WITH_MULTILINE_HEADERS)
  end

  def comma_file_import
    DatasetPreprocessor.new(fixture_file("commas.csv", "text/csv"))
  end

  def excel_file_import
    DatasetPreprocessor.new(fixture_file("excel.xls", "application/octet-stream"))
  end

  def excelx_file_import
    DatasetPreprocessor.new(fixture_file("excelx.xlsx", "application/octet-stream"))
  end

  def openoffice_file_import
    DatasetPreprocessor.new(fixture_file("openoffice.ods", "application/octet-stream"))
  end

  def tab_import
    DatasetPreprocessor.new(TAB_DELIMITED)
  end

  def blank_import
    DatasetPreprocessor.new("")
  end

  COMMA_DELIMITED = <<-EOF
State Name,State Abbreviation,Count
ALABAMA,AL,1
ALASKA,AK,2
AMERICAN SAMOA,AS,3
ARIZONA,AZ,4
EOF

  COMMA_DELIMITED_WITH_MULTILINE_HEADERS = <<-EOF
"State\nName","State\nAbbreviation","Count", ,"\n\n"
ALABAMA,AL,1,,
ALASKA,AK,2,,
AMERICAN SAMOA,AS,3,,
ARIZONA,AZ,4,,
EOF

  TAB_DELIMITED = <<-EOF
State Name	State Abbreviation	Count
ALABAMA	AL	1
ALASKA	AK	2
AMERICAN SAMOA	AS	3
ARIZONA	AZ	4
EOF
end
