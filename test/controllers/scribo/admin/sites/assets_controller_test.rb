# frozen_string_literal: true

require 'test_helper'

module Scribo
  module Admin
    class Sites::AssetsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      test 'should get new' do
        get new_admin_site_asset_url(site_id: scribo_sites(:main))
        assert_response :success
      end
    end
  end
end
