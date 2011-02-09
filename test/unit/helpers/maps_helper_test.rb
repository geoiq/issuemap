require 'test_helper'

class MapsHelperTest < ActionView::TestCase
  context "#map_admin?" do
    setup { @map = Factory(:map) }

    should "return false for a user who doesn't administer a map" do
      session[:owned_maps] = nil
      assert !map_admin?(@map)
    end

    should "return true for a user who does administer a map" do
      session[:owned_maps] = [999, @map.id, 998]
      assert map_admin?(@map)
    end
  end

  context "#map_admin_section" do
    setup { @map = Factory(:map) }

    should "yield nothing for a user who doesn't administer a map" do
      session[:owned_maps] = nil
      content = map_admin_section(@map) { "some content" }
      assert !content
    end

    should "return yield the block for a user who does administer a map" do
      session[:owned_maps] = [999, @map.id, 998]
      content = map_admin_section(@map) { "some content" }
      assert_equal "some content", content
    end
  end
end
