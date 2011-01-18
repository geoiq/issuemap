class MapsController < ApplicationController
  before_filter :find_map, :only => [:edit, :show, :update]
  before_filter :build_map, :only => [:create, :new, :review]
  before_filter :check_location_type, :only => [:create, :update]

  def preprocess
    import = DatasetPreprocessor.new(params[:upload] || params[:paste])
    render :text => import.to_json
  end

  def create
    if @map.save!
      # flash[:notice] = "'#{@map.title}' was successfully created!"
      redirect_to map_path(@map.linkable_id)
    else
      flash.now[:error] = "Your map could not be saved! Please try again"
      render :review
    end
  rescue
      flash.now[:error] = "Your map could not be saved! Please try again"
      render :review
  end

  def new
  end

  def show
    @show_progress = false

    respond_to do |format|
      format.html {}
      # format.png { send_file(@map.to_png(params.merge(:text => map_url(@map, :only_path => false))), :filename => "#{@map.title}.png", :type => "image/png", :disposition => "inline") }
      format.png {    render :text => @map.to_png(params.merge(:text => url_for(:controller => "maps", :action => "show", :id => @map.linkable_id, :only_path => false))), :layout => false, :status => :ok }
    end
  rescue
    flash[:error] = "There was a problem loading your map. Please try again."
    render :new
  end

  def update
    if @map.update_attributes(params[:map])
      # flash[:notice] = "#{@map.title} was successfully updated!"
      redirect_to map_path(@map.linkable_id)
    else
      flash.now[:error] = "Your map could not be saved! Please try again"
      render :edit
    end
  rescue
    render_parsing_error
  end

  def review
    @map.dataset.save_upload if @map.dataset.upload.file?
    unless @map.dataset.previous_upload.nil?
      @map.title ||= File.basename(@map.dataset.previous_upload, File.extname(@map.dataset.previous_upload))
    end
    if @map.dataset.hashed_data(true).blank?
      render_parsing_error
    end
    @default_numerical_data_column = @map.dataset.default_data_columns.empty? ? nil : @map.dataset.default_data_columns.to_a[0][0]
  rescue
    flash[:error] = "There was a problem creating the dataset for this map.  Please try again."
    redirect_to :back
  end

  protected
  def build_map
    @map = Map.new(params[:map])
    @map.build_dataset if @map.dataset.nil?
  end

  def check_location_type
    if params[:map][:dataset_attributes][:location_column_types].first.blank?
      flash.now[:error] = "We need to know the type of the location column you've chosen."
      render :template => "maps/review"
    end
  end

  def find_map
    return if params[:id].blank?
    @map = Map.find_by_linkable_id(params[:id])
    @map = Map.find(params[:id]) if @map.nil?
  end

  def render_dataset_error
    session[:map] = params[:map]

    flash[:error] = "There was a problem creating the dataset for this map.  Please try again."
    redirect_to :back
  end

  def render_parsing_error
    flash[:error] = "Sorry, there was a problem parsing the supplied data."
    redirect_to new_map_path
  end
end
