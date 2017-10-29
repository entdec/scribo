# frozen_string_literal: true

require 'test_helper'

module Scribo
  class Admin::AssetsControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    test 'should get new' do
      get admin_assets_new_url
      assert_response :success
    end
  end
end
