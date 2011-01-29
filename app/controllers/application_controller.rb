class ApplicationController < ActionController::Base
  helper :all

  protect_from_forgery

  protected

  def self.caches_all_pages
    after_filter { |c| c.cache_page }
  end

  def error_message(e)
    "#{e.class} (#{e.message})"
  end

  def error_message_and_backtrace(e)
    "\n#{error_message(e)}:\n  " + clean_backtrace(e).join("\n  ") + "\n\n"
  end
end
