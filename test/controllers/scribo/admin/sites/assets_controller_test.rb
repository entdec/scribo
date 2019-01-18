# frozen_string_literal: true

require 'test_helper'

module Scribo
  module Admin
    class Buckets::AssetsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      test 'should get new' do
        get new_admin_bucket_asset_url(bucket_id: scribo_buckets(:main))
        assert_response :success
      end
    end
  end
end
