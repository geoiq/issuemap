class MapsController < ApplicationController
  before_filter :find_map, :only => [:show, :update]

  def preprocess
    import = DatasetPreprocessor.new(params[:upload] || params[:paste])
    render :text => import.to_json
  rescue StandardError => e
    logger.error e
    logger.error e.backtrace.join("\n")
    render :text => { :error => e.message }.to_json, :status => :internal_server_error
  end

  def create
    @map = Map.new(params[:map])
    if @map.save
      redirect_to map_path(@map.token)
    else
      flash.now[:error] = "Your map could not be saved! Please try again"
      render :new
    end
  rescue
    flash.now[:error] = "Your map could not be saved! Please try again"
    render :new
  end

  def new
    @map = Map.new(params[:map])
  end

  def show
    respond_to do |format|
      format.html {}
      # format.png { send_file(@map.to_png(params.merge(:text => map_url(@map, :only_path => false))), :filename => "#{@map.title}.png", :type => "image/png", :disposition => "inline") }
      format.png {    render :text => @map.to_png(params.merge(:text => url_for(:controller => "maps", :action => "show", :id => @map.token, :only_path => false))), :layout => false, :status => :ok }
    end
  rescue
    flash[:error] = "There was a problem loading your map. Please try again."
    render :new
  end

  protected

  def find_map
    return if params[:id].blank?
    @map = Map.find_by_token(params[:id])
    @map = Map.find(params[:id]) if @map.nil?
  end

  def render_dataset_error
    session[:map] = params[:map]

    flash[:error] = "There was a problem creating the dataset for this map.  Please try again."
    redirect_to :back
  end
end
