require 'paperclip/matchers'

Spec::Runner.configure do |config|
  include Paperclip::Shoulda::Matchers
end
