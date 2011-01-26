class PagesController < ApplicationController
  caches_all_pages

  def home
    map_tokens = AppConfig[:featured_map_tokens]
    @maps = Map.find(:all, :conditions => { :token => map_tokens })
    if @maps.size < 5
      @maps.push(*Map.find(:all, :limit => (5 - @maps.size)))
    end
  end
end
