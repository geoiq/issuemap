require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dataset do

  it { should belong_to(:map) }
  it { should have_attached_file(:upload) }  
  
  it "should parse a csv based paste" do
    dataset = Dataset.new(:data => "")
    file = File.open(File.join(RAILS_ROOT,"lib","example.csv"))
    file.each_line {|line| dataset.data += line }
    
    dataset.hashed_data.should_not be_nil
    dataset.hashed_data.keys.size.should > 3
  end

  it "should respond with the number of data points" do
    @dataset = Dataset.new
    @dataset.data_points.should == 0

    @dataset = Dataset.new(:data => "X, Y, Z\r\n1, 2, 3")
    @dataset.data_points.should == 3

    @dataset = Dataset.new(:data => "X, Y, Z, A, B, C\r\n1, 2, 3, 9, 10, 11\r\na, b, c, d, e, f\r\na, b, c, d, e, f")
    @dataset.data_points.should == 18
  end

  it "should only allow a certain number of data points" do
    @dataset = Dataset.new
    @dataset.should_receive(:data_points).at_least(:once).and_return(60001)

    @dataset.should_not be_valid
    @dataset.should have(1).errors_on(:data_points)
  end
end
