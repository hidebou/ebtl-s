class CrawlController < ApplicationController
  def get_page
=begin  
   if http?(params[:url]) && params[:url] =~ /www\.amazon\./
      log.info("in carwl. params= #{params.to_s}")
      shop_crawl = ShopCrawler.new
      result = shop_crawl.crawl_page_js(params[:url])
    else
      result = ""
      log.error("in carwl. url error = #{params[:url]}")
    end
=end
    # test 
    result = "get_page test!"
    render json: result
  end
  
end
