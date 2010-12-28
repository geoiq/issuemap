require 'spec_helper'

describe Map do
  it { should have_one(:dataset) }
  it { should validate_presence_of(:dataset) }

end
