class PagesController < ApplicationController
  caches_all_pages

  def home
    @maps = Map.find(:all, :limit => 5)
  end
end
