# frozen_string_literal: true

require 'test_helper'

module Scribo
  module Admin
    class Sites::ContentsControllerTest < ::ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      test 'should get context index' do
        get admin_site_contents_url(site_id: scribo_sites(:main))
        assert_response :success
      end
    end
  end
end
