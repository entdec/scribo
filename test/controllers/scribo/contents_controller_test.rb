require 'test_helper'

module Scribo
  class ContentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get show" do
      get contents_show_url
      assert_response :success
    end

  end
end
