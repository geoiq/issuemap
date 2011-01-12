ActionController::Routing::Routes.draw do |map|
  map.resources :maps, :collection => { :review => :any }

  map.geocommons_proxy "/proxy/*path.:format", :controller => "proxy", :action => "proxy", :format => :format

  map.page "/pages/:action", :controller => "pages"
  map.root :controller => "pages", :action => "home"
end
