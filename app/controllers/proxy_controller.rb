class ProxyController < ApplicationController
  def proxy
    to_proxy = "/" + params[:path].join('/')
    request_params = params.dup
    [:controller, :action, :path].each {|k| request_params.delete(k)}
    begin
      resp = GeoIQ.send(request.method, to_proxy, :query => request_params)
    rescue GeoIQ::Exception => e
      raise e.headers.inspect
    end
    response.headers["Content-Type"] = resp.headers["Content-Type"]
    render :text => resp.body, :layout => false, :status => resp.code
  end
end
