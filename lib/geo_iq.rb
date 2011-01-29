require 'httparty'
require 'ostruct'

require 'geo_iq/layer'
require 'geo_iq/map'
require 'geo_iq/dataset'

module GeoIQ
  include HTTParty
  # base_uri 'http://localhost:9292/'
  default_timeout 30

  class << self
    # Use this to configure how you connect to GeoIQ. Since GeoIQ is based on HTTParty, you can
    # also just call the following:
    # 
    #   GeoIQ.basic_auth(username, password)
    def connect(username, password)
      @username, @password = username, password
      basic_auth(@username, @password)
      self
    end

    # Use create_dataset to upload data to GeoIQ. If you're passing in a CSV, pass it in the
    # attributes hash as :data, e.g.:
    # 
    #   GeoIQ.create_dataset(:title => "My Data", :data => File.read("/path/to/my.csv"))
    # 
    # This will return a GeoIQ::Dataset with the correct ID value set.
    def create_dataset(attributes = {})
      request = {}
      if data = attributes.delete(:data) || attributes.delete('data')
        data, boundary = upload('dataset[csv]', data)
        request.merge!(:body => data.to_s, :headers => {'Content-Type' => "multipart/form-data; boundary=#{boundary}"}, 
          :query => { "#{attributes[:join_param]}"=> "#{attributes[:join_value]}"})
      end
      response = post('/datasets.json', request)
      Rails.logger.error "Create Dataset: #{response.inspect}"
      redirect = response.headers['location'] || response.headers['Location']
      
      id = File.basename(redirect, File.extname(redirect))
      GeoIQ::Dataset.new('id' => id.to_i)
    end
    
    def get_dataset(id)
      request = {}
      response = get("/datasets/#{id}.json?include_features=0", request)
      response
    end
    # def create_dataset(attributes = {})
    #   request = {}
    #   if data = attributes.delete(:data) || attributes.delete('data')
    #     # data, boundary = upload('dataset[csv]', data)
    #     request.merge!(:body => data, :headers => {'Content-Type' => "text/csv"})
    #   end
    #   # request.merge!(:query => attributes, :no_follow => true)
    #   response = post('/datasets.json', request)
    #   redirect = response.headers['location'] || response.headers['Location']
    #   id = File.basename(redirect, File.extname(redirect))
    #   GeoIQ::Dataset.new('id' => id.to_i)
    # end

    # Creates a map with a hash of attributes and returns a GeoIQ::Map instance.
    # 
    #   GeoIQ.create_map(:title => "My Map", :description => "A nice little Saturday")
    def create_map(attributes)
      query = {:query => attributes}
      GeoIQ::Map.new(post('/maps.json', query).parsed_response)
    end

    # Turns on debugging. Use in your initializer if you'd like to see a clearer dump
    # of what's going on w/the POSTs and whatnot going to GeoIQ. Especially useful for
    # debugging issues w/the API.
    def debug(really = true)
      if really
        debug_output
      else
        debug_output(nil)
      end
    end

    def delete(path, options = {}) #:nodoc:
      respond_to_action(super(path, options))
    end

    def get(path, options = {}) #:nodoc:
      respond_to_action(super(path, options))
    end

    def post(path, options = {}) #:nodoc:
      respond_to_action(super(path, options))
    end

    def put(path, options = {}) #:nodoc:
      respond_to_action(super(path, options))
    end

    # Session will return a Hash with the cookie key and value. Usefull for
    # embedding maps that need an authenticated session to work, like so:
    # 
    #   var map = new F1.Maker.Map({
    #     dom_id: 'map_wrapper',
    #     map_id: 321,
    #     '<%= GeoIQ.session.key %>': '<%= GeoIQ.session.value %>'
    #   });
    def session
      return @session if defined?(@session)
      session_cookie = cookies.select {|k,v| k.starts_with?("_")}.first
      @session = OpenStruct.new(:key => session_cookie.first, :value => session_cookie.last)
    end

    private #:nodoc:
    def cookies #:nodoc:
      return @auth_cookies if defined? @auth_cookies
      request = get('/search.json', :headers_only => true)
      cookies = {}
      request.headers['set-cookie'].split(/\;/).map {|v| v.split(/\=/)}.each do |k, v|
        cookies[k] = v if v
      end
      @auth_cookies = cookies
    end

    def respond_to_action(response) #:nodoc:
      unless %w(200 201).include? response.headers['status']
        # raise Exception.new(response)
      end
      response
    end

    def upload(name, content) #:nodoc:
      boundary = '----------------------------d6a0d93b3643'
      body = []
      body << %(--#{boundary})
      body << %(Content-Disposition: form-data; name=#{name.inspect}; filename="upload.csv")
      body << %(Content-Type: application/octet-stream)
      body << ''
      body << content
      body << ''
      body << %(--#{boundary}--)
      [body.join("\r\n"), boundary]
    end
  end

  class Exception < ::Exception #:nodoc:
    attr_accessor :status, :headers, :body

    def initialize(response)
      self.body    = response.body
      self.headers = response.headers
      self.status  = response.headers['status'].to_i

      message = ["#{response.headers['status']}\n"]

      if response.headers['json']
        message << 'Errors:'
        message << JSON.parse(response.headers['json']).reject(&:nil?).map{|error| "  - #{error}"}
      else
        message << response.parsed_response || request.headers.inspect
      end
      super(message.flatten.join("\n"))
    end
  end
end
