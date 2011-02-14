class MapsController < ApplicationController
  before_filter :find_map, :only => [:show, :update, :cache, :update]
  before_filter :check_admin_token, :only => :show
  before_filter :ensure_admin_token, :only => :update
  before_filter :ensure_correct_slug, :only => :show
  caches_page :cache

  def new
    @map = Map.new(params[:map])
  end

  def preprocess
    import = DatasetPreprocessor.new(params[:data])
    import.check_validity!
    render :text => import.to_json
  rescue StandardError => e
    logger.error(error_message_and_backtrace(e))
    render :text => { :error => e.message }.to_json, :status => :internal_server_error
  end

  def create
    @map = Map.new(params[:map])
    if @map.save
      add_map_to_owned_map_list(@map)
      redirect_to @map
    else
      render :new
    end
  rescue StandardError => e
    logger.error(error_message_and_backtrace(e))
    flash.now[:error] = "Your map could not be saved! Please try again"
    render :new
  end

  def update
    if @map.update_attributes(params[:map])
      expire_page :action => :cache, :id => @map.token, :format => "png"
    end
    redirect_to @map
  end

  def show
    respond_to do |format|
      format.html {}
      format.csv { send_map_data(@map.to_csv, :csv, "csv") }
      format.kml { send_map_data(@map.to_kml, :kml, "kml") }
      format.png { send_map_data(@map.to_png(:text => map_url(@map.token), :size => params[:size]), :png, "png") }
    end
  end

  def cache
    # we can only cache one png size unless we make custom routes
    params[:size] = "m"
    show
  end

  protected

  def add_map_to_owned_map_list(map)
    map_ids = session[:owned_maps] || []
    map_ids.push(map.id)
    map_ids.shift([0, map_ids.length - 10].max)
    session[:owned_maps] = map_ids
  end

  def send_map_data(bytes, type, format)
    send_data(bytes, :type => type, :filename => "#{@map.to_param}.#{format}", :disposition => "inline")
  end

  def find_map
    token = params[:id].split("-").first if params[:id]
    @map = Map.find_by_token(token)
    raise ActiveRecord::RecordNotFound, "No Maps matches that token" unless @map
  end

  def check_admin_token
    admin_token = params.delete(:admin_token)
    return unless admin_token && format_html?
    add_map_to_owned_map_list(@map) if admin_token == @map.admin_token
    redirect_to params
  end

  def ensure_admin_token
    unless map_admin?(@map)
      render :text => "Unauthorized.", :status => :unauthorized
    end
  end

  def ensure_correct_slug
    return unless format_html?
    redirect_to(@map, :status => :moved_permanently) unless params[:id] == @map.to_param
  end

  def format_html?
    params[:format].blank? || params[:format].to_s == "html"
  end

  def map_admin?(map)
    session[:owned_maps].include?(map.id) if session[:owned_maps]
  end
end
