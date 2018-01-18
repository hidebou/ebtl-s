class CrawlController < ApplicationController
  def get_page
   url = params[:url]
   if valid_url?(url) && url =~ /www\.amazon\./
      logger.info("in carwl. params= #{params.to_s}")
      shop_crawl = ShopCrawler.new
      result = shop_crawl.crawl_page_js(url)
    else
      result = ""
      logger.error("in carwl. url error. param = #{params.to_s}")
    end
    render json: result
  end

  def valid_url?(str)
    begin
      uri = URI.parse(str)
    rescue URI::InvalidURIError
      return false
    end
    return uri.scheme == 'http' || uri.scheme == 'https'
  end

end
