require 'test_helper'

class CrawlControllerTest < ActionDispatch::IntegrationTest
  test "should get get_page" do
    get crawl_get_page_url
    assert_response :success
  end

end
