require 'test_helper'

class DatasetTest < ActiveSupport::TestCase
  should belong_to :map
  should have_attached_file :upload

  should "parse a csv based paste" do
    dataset = Dataset.new(:data => "")
    file = File.open(File.join(RAILS_ROOT, "lib", "examples", "example.csv"))
    file.each_line {|line| dataset.data += line }

    assert_not_nil dataset.hashed_data
    assert_equal 5, dataset.hashed_data.keys.size
  end

  should "respond with the number of data points" do
    dataset = Dataset.new
    assert_equal 0, dataset.data_points

    dataset = Dataset.new(:data => "X\r\n1")
    assert_equal 1, dataset.data_points

    dataset = Dataset.new(:data => "X, Y, Z\r\n1, 2, 3")
    assert_equal 3, dataset.data_points

    dataset = Dataset.new(:data => "X, Y, Z\r\n1, 2, 3\r\na, b, c\r\na, b, c")
    assert_equal 9, dataset.data_points
  end

  should "only allow a certain number of data points" do
    dataset = Dataset.new
    dataset.expects(:data_points).returns(60001)

    assert !dataset.valid?
    assert dataset.errors.on(:data_points)
  end
end
