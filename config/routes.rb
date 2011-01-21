ActionController::Routing::Routes.draw do |map|
  map.resources :maps, :new => { :preprocess => :post }, :collection => { :review => :any }

  map.geoiq_proxy "/proxy/*path.:format", :controller => "proxy", :action => "proxy", :format => :format

  map.page "/pages/:action", :controller => "pages"
  map.root :controller => "pages", :action => "home"
end
