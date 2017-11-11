# frozen_string_literal: true

require 'test_helper'

module Scribo
  class Admin::ContentsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test 'should get new' do
      get new_admin_content_url
      assert_response :success
    end
  end
end
