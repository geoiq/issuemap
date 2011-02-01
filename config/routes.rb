IssueMap::Application.routes.draw do
  resources :maps do
    new do
      post :preprocess
    end
  end
  match "/map_cache/:id", :to => "maps#cache", :as => :map_cache

  match "/proxy/(*path)", :to => "proxy#proxy", :as => :geoiq_proxy
  match "/pages/:action", :to => "pages", :as => :page
  root :to => "pages#home"
end
