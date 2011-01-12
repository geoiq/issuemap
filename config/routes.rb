ActionController::Routing::Routes.draw do |map|
  map.geocommons_proxy "/proxy/*path.:format", :controller => "proxy", :action => "proxy", :format => :format

  map.tos "/tos", :controller => "site", :action => "show", :id => "tos"
  map.privacy "/privacy", :controller => "site", :action => "show", :id => "privacy"

  map.resources :maps, :collection => { :review => :any }

  map.root :controller => "site"
end
