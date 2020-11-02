# frozen_string_literal: true

require 'test_helper'

module Scribo
  class ContentRenderServiceTest < ActiveSupport::TestCase
    test 'renders scss with includes' do
      content = Scribo::Content.located('/test.scss').first

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "body {\n  font-family: Arial;\n  font-size: 20px;\n  font-weight: bold;\n  color: #ff0000; }\n", subject
    end

    test 'site drop' do
      content = Scribo::Site.titled('second').contents.first

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "email@example.com,rss,github\n", subject
    end

    test 'site import and rendering' do
      Tempfile.open(['hello', '.zip']) do |f|
        ZipFileGenerator.new('test/files/mysite', folder_entries: false).write(f)
        site = Scribo::SiteImportService.new(f.path).call

        subject = Scribo::ContentFindService.new(site, path: '/assets/main.css').perform
        result = Scribo::ContentRenderService.new(subject, {}).perform

        assert_includes result, 'Reset some basic elements'
      end
    end
  end
end
