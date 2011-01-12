require 'test_helper'

class YearHelperTest < ActionView::TestCase
  setup do
    Timecop.freeze(Time.utc(1978, 12, 18))
  end

  teardown do
    Timecop.return
  end

  context "#current_year" do
    should "return the current year" do
      assert_equal 1978, current_year
    end
  end

  context "#year_range" do
    should "return the current year if no start_year is specified" do
      assert_equal "1978", year_range
    end

    should "return a range given a previous year as the start year" do
      assert_equal "1956-1978", year_range(1956)
    end

    should "return an ordered range given a future year as the start year" do
      assert_equal "1978-1982", year_range(1982)
    end
  end
end
