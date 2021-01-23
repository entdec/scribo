# frozen_string_literal: true

require 'test_helper'

module Scribo
  class SiteFindServiceTest < ActiveSupport::TestCase
    test 'finds site with baseurl / by path being /' do
      Account.first.current!
      subject = Scribo::Site.create!(scribable: Account.current)
      config = subject.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/"')
      result = Scribo::SiteFindService.new({ path: '/' }).call
      assert_equal subject, result
    end

    test 'finds site with baseurl / by path being /index.html' do
      Account.first.current!
      subject = Scribo::Site.create!(scribable: Account.current)
      config = subject.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/"')
      result = Scribo::SiteFindService.new({ path: '/index.html' }).call
      assert_equal subject, result
    end

    test 'finds site with baseurl /help by path being /help/' do
      Account.first.current!
      subject = Scribo::Site.create!(scribable: Account.current)
      config = subject.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/help"')
      result = Scribo::SiteFindService.new({ path: '/help/index.html' }).call
      assert_equal subject, result
    end

    test 'finds site with baseurl /help by path being /help' do
      Account.first.current!
      subject = Scribo::Site.create!(scribable: Account.current)
      config = subject.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/help"')
      result = Scribo::SiteFindService.new({ path: '/help' }).call
      assert_equal subject, result
    end

    test 'finds site with baseurl /help by path being /help with underlying site (with baseurl /)' do
      Account.first.current!
      underlying_site = Scribo::Site.create!(scribable: Account.current)
      underlying_site_config = underlying_site.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/"')

      subject = Scribo::Site.create!(scribable: Account.current)
      config = subject.contents.create!(kind: 'text', path: '_config.yml', data: 'baseurl: "/help"')
      result = Scribo::SiteFindService.new({ path: '/help' }).call
      assert_equal subject.reload, result
    end
  end
end
