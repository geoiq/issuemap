class ApplicationController < ActionController::Base
  layout 'application'
  helper :all # include all helpers, all the time

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  private

  def self.caches_all_pages
    after_filter { |c| c.cache_page }
  end
end
