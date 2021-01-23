# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentsControllerTest < ::ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @png_data = Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==')
      Account.first.current!
      @site = Scribo::Site.create!(scribable: Account.current)
      assert_equal Account.current, @site.scribable
      @site.contents.create!(kind: 'text', path: 'index.html', data: 'Hello')
      @site.contents.create!(kind: 'text', path: 'test.link', data: '/index')
      @site.contents.create!(kind: 'asset', path: 'asset.png', data: @png_data)
      @site.contents.create!(kind: 'text', path: 'some filename with spaces.html', data: 'Spaces?')
    end

    test 'should show content' do
      get '/', headers: { 'X-ACCOUNT': Account.current.id }
      assert_response :success
      assert_equal 'Hello', @response.body
      assert_equal 'text/html', @response.media_type
    end

    test 'should get redirected' do
      get '/test', headers: { 'X-ACCOUNT': Account.current.id }
      assert_redirected_to '/index'
    end

    test 'should get asset' do
      get '/asset.png', headers: { 'X-ACCOUNT': Account.current.id }
      assert_equal @png_data, @response.body
      assert_equal 'image/png', @response.media_type
      assert @response.headers['Etag']
    end

    test 'should get filename with spaces' do
      get '/some%20filename%20with%20spaces.html', headers: { 'X-ACCOUNT': Account.current.id }
      assert_equal 'Spaces?', @response.body
      assert_equal 'text/html', @response.media_type
    end
  end
end
