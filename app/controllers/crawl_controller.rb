require 'anemone'
require 'capybara'
require 'capybara/poltergeist'
require 'nkf'

class CrawlController < ApplicationController

  CAPYBARA_WINDOW_HEIGHT = 768
  CAPYBARA_WINDOW_WIDTH = 1366
  CRAWL_LOG = './log/shop_crawl.txt'
  LOG_FILE_SIZE = 5*1024*1024
  DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.2987.133 Safari/537.36"  
  
  # 初期化
  def initialize(user_agent: ENV["CRAWL_USER_AGENT"], ajax_wait_time: 10)
    begin
      #@log = Logger.new('./log/shop_crawl.txt', 10, LOG_FILE_SIZE)
      logger.info('ShopCrawler initialize.')
      @max_wait_time = 1000
      @max_ajax_wait_time = ajax_wait_time
      @session = nil
      @user_agent = user_agent.present? ? user_agent : DEFAULT_USER_AGENT
      init_capybara
      init_anemone
    
    rescue => e
      msg = "Exception in initialize, exception class=#{e.class.to_s}, msg=#{e.to_s}"
      logger.error(msg)
      raise e
    end
  end


  # capybaraの初期化
  def init_capybara
    logger.info('in init_capybara.')
    @window_width = CAPYBARA_WINDOW_WIDTH 
    @window_height = CAPYBARA_WINDOW_HEIGHT

    Capybara.register_driver :poltergeist do |app|
      Capybara::Poltergeist::Driver.new(app, {:js_errors => false, :timeout => @max_wait_time, :logger => self, :phantomjs_logger => self, :debug => true, :phantomjs_options => ['--load-images=no',  '--ignore-ssl-errors=yes', '--ssl-protocol=any'], :window_size => [@window_width, @window_height], :screen_size => [@window_width, @window_height] } )
    end
    
    Capybara.default_driver = :poltergeist
    Capybara.javascript_driver = :poltergeist
    Capybara.default_selector = :xpath
  end

  # Anemoneの初期化
  def init_anemone
    logger.info('in init_anemone.')  
    @anemone_option = {
      :user_agent => @user_agent,
      :depth_limit => 0,
    }
  end

  # capybaraセッションの作成
  def create_session
    session = Capybara::Session.new(:poltergeist)    
    session.driver.headers = { 'User-Agent' => @user_agent }
    session
  end

  # ログ出力
  def puts(s)
    logger.debug(s)
  end

  
  # ログ出力
  def write(s)
    logger.debug(s)
  end


  # ページを取得する
  def crawl_page(url)
    result = nil
    begin
      @url = url
      logger.debug("in crawl_page url=#{@url}")
      Anemone.crawl(@url, @anemone_option) do |anemone|
        anemone.on_every_page do |page|
          if page != nil && page.body != nil
            result = NKF.nkf('-wxm0', page.body)
            logger.info("crawl result: url=#{@url}\r\n#{result}")
          else
            result = nil
            logger.error("in crawl_page. page is nil. url=#{@url}")
          end
        end
      end
    rescue => e
      if url.blank?
        url = ""
      end
      msg = "Exception in crawl_page url=#{url}, exception class=#{e.class.to_s}, msg=#{e.to_s}"
      logger.error(msg)
    end
    result
  end


  # JavaScritpの実行を待ってページを取得する
  def crawl_page_js(url)
    begin    
      @url = url
      logger.debug("in crawl_page_js url=#{@url}")
      @session = create_session if @session.blank?
      @session.visit @url
      
      wait_for_ajax(@session)
      result = NKF.nkf('-wxm0', @session.html)
      logger.info("crawl result: url=#{@url}\r\n#{result}")
      
      @session.driver.quit
      @session = nil
      
      return result
    rescue => e
      if url.blank?
        url = ""
      end
      msg = "Exception in crawl_page url=#{url}, exception class=#{e.class.to_s}, msg=#{e.to_s}"
      logger.error(msg)
    end
  end


  # java scriptの実行を待つ
  def wait_for_ajax(session)
    begin
      Timeout.timeout(@max_ajax_wait_time) do
        active = session.evaluate_script('jQuery.active')
        until active == 0
          sleep 0.5
          active = session.evaluate_script('jQuery.active')
        end
      end
    rescue Timeout::Error => e
      if @url.blank?
        @url = ""
      end
      msg = "Exception in wait_for_ajax. ajax wait timeout occured, url=#{@url}, msg=#{e.to_s}"
      logger.error(msg)
    rescue => e
      if @url.blank?
        @url = ""
      end
      msg = "Exception in wait_for_ajax. url=#{@url}, class=#{e.class.to_s}, msg=#{e.to_s}" 
      logger.error(msg)
    end
  end


  def get_page
   url = params[:url]
   result = ""
   if valid_url?(url) && url =~ /www\.amazon\./
      logger.info("in carwl. params= #{params.to_s}")
      
      initialize
      result = crawl_page_js(url)
      
      #shop_crawl = ShopCrawler.new
      #result = shop_crawl.crawl_page_js(url)
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

=begin
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
=end

end
