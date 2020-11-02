# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentFindServiceTest < ActiveSupport::TestCase
    test 'finds content by path being /' do
      @site = Scribo::Site.create!
      subject = @site.contents.create!(kind: 'text', path: 'index.html', data: 'something')
      result = Scribo::ContentFindService.new(@site, { path: '/' }).call
      assert_equal subject, result
    end

    test 'finds content by path being /index' do
      @site = Scribo::Site.create!
      subject = @site.contents.create!(kind: 'text', path: 'index.html', data: 'something')

      result = Scribo::ContentFindService.new(@site, { path: '/index' }).call
      assert_equal subject, result
    end

    test 'finds content by permalink' do
      @site = Scribo::Site.create!
      subject = @site.contents.create!(kind: 'text', path: 'index.html', data: 'something', properties: { permalink: '/smurrefluts' })

      result = Scribo::ContentFindService.new(@site, { path: '/smurrefluts' }).call
      assert_equal subject, result
    end

    test 'finds post by global permalink' do
      @site = Scribo::Site.create!
      folder = @site.contents.create!(kind: 'folder', path: '_posts')
      subject = @site.contents.create!(parent: folder, kind: 'text', path: '2020-11-01-nice.md', data: '# something')

      result = Scribo::ContentFindService.new(@site, { path: '/2020/11/01/nice.html' }).call
      assert_equal subject, result
    end
  end
end
