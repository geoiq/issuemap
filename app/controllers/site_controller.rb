class SiteController < ApplicationController
  caches_page :show, :cache_path => Proc.new { |cache| cache.params }

  def index
  end
  
  def show
    method_missing(params[:id])
  end
  
  def method_missing(m)
    logger.debug "Site method missing! #{m}"
    params[:action] = m
    @show_progress = false
    (render :text => "Page not found.", :status => 404; return) unless File.exists?("#{RAILS_ROOT}/app/views/site/#{params[:action]}.html.erb")
    respond_to do |format|
      format.html { render :template  => "site/#{params[:action]}.html.erb" }
     end
  end
    
end