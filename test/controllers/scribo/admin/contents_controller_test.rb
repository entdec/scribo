require 'test_helper'

module Scribo
  class Admin::ContentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test "should get new" do
      get admin_contents_new_url
      assert_response :success
    end

  end
end
