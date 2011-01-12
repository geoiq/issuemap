require 'test_helper'

class MapTest < ActiveSupport::TestCase
  should have_one :dataset
  should validate_presence_of :dataset
  should validate_presence_of :title
end
