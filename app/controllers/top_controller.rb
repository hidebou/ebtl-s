class TopController < ApplicationController
  def index
    @msg = "This is top page!"
  end
  
  def crawl
    @msg = "This is crawl page"  
  end
end
