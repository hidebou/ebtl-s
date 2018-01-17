module Api
  class CrawlController < ApplicationController
    def index
      msg = "api carwl index."
      render json: msg
    end
    
    def get_page
      if params[:url] =~ /www\.amazon\./
        logger.info("in carwl. params= #{params.to_s}")
        shop_crawl = ShopCrawler.new
        result = shop_crawl.crawl_page_js(params[:url])
      else
        result = ""
        log.error("in carwl. url error = #{params[:url]}")
      end
      
      render json: result
    end

    def http?(str)
      begin
        uri = URI.parse(str)
      rescue URI::InvalidURIError
        return false
      end
      return uri.scheme == 'http'
    end
    
  end
end