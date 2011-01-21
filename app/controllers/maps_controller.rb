class MapsController < ApplicationController
  before_filter :find_map, :only => [:show, :update]
  before_filter :ensure_correct_slug, :only   => :show

  def preprocess
    import = DatasetPreprocessor.new(params[:data])
    import.check_validity!
    render :text => import.to_json
  rescue StandardError => e
    logger.error(error_message_and_backtrace(e))
    render :text => { :error => error_message(e) }.to_json, :status => :internal_server_error
  end

  def create
    @map = Map.new(params[:map])
    if @map.save
      redirect_to @map
    else
      render :new
    end
  rescue StandardError => e
    logger.error(error_message_and_backtrace(e))
    flash.now[:error] = "Your map could not be saved! Please try again"
    render :new
  end

  def new
    @map = Map.new(params[:map])
  end

  def show
    respond_to do |format|
      format.html {}
      format.png do
        png = @map.to_png(:text => map_url(@map.token))
        send_data(png, :type => "image/png", :filename => "#{@map.to_param}.png", :disposition => "inline")
      end
    end
  end

  protected

  def find_map
    token = params[:id].split("-").first if params[:id]
    @map = Map.find_by_token(token)
    raise ActiveRecord::RecordNotFound, "No Maps matches that token" unless @map
  end

  def ensure_correct_slug
    if params[:format].blank? || params[:format].to_s == "html"
      redirect_to(@map, :status => :moved_permanently) unless params[:id] == @map.to_param
    end
  end
end
