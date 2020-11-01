# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentsControllerTest < ::ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      Account.first.current!
      @site = Scribo::Site.create!(scribable: Account.current)
      assert_equal Account.current, @site.scribable
      @site.contents.create!(kind: 'text', path: 'index.html', data: 'Hello')
    end

    test 'should get show' do
      get root_url
      assert_response :success
    end
  end
end
