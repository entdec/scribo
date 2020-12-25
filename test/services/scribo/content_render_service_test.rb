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

    test 'renders scss with includes which start with a _' do
      site = scribo_sites(:main)
      content = site.contents.create!(path: 'smurrefluts.scss', data: "@import '_scss_include'; body { @include large-text; }", kind: 'text')

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "body {\n  font-family: Arial;\n  font-size: 20px;\n  font-weight: bold;\n  color: #ff0000; }\n", subject
    end

    test 'renders scss with includes from a subfolder which start with a _' do
      site = scribo_sites(:main)

      sass_folder = scribo_contents(:sass_folder)
      sub_folder = site.contents.create!(path: '_smurrefluts', parent: sass_folder)

      smalltext = site.contents.create!(path: '_small.scss', parent: sub_folder, data: '@mixin small-text { font: { family: Arial; size: 2px; weight: bold; } color: #ff0000;}', kind: 'text')

      assert_equal '/_sass/_smurrefluts/_small.scss', smalltext.full_path

      content = site.contents.create!(path: 'blah.scss', parent: sub_folder, data: "@import '_smurrefluts/_small'; body { @include small-text; }", kind: 'text')

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "body {\n  font-family: Arial;\n  font-size: 2px;\n  font-weight: bold;\n  color: #ff0000; }\n", subject
    end

    test 'renders scss with relative include from a subfolder' do
      site = scribo_sites(:main)

      sass_folder = scribo_contents(:sass_folder)
      sub_folder = site.contents.create!(path: '_smurrefluts', parent: sass_folder)

      smalltext = site.contents.create!(path: '_small.scss', parent: sub_folder, data: "@import 'small_mixin';", kind: 'text')
      smalltext_mixin = site.contents.create!(path: '_small_mixin.scss', parent: sub_folder, data: '@mixin small-text { font: { family: Arial; size: 2px; weight: bold; } color: #ff0000;}', kind: 'text')

      assert_equal '/_sass/_smurrefluts/_small_mixin.scss', smalltext_mixin.full_path

      content = site.contents.create!(path: 'blah.scss', parent: sub_folder, data: "@import '_smurrefluts/_small'; body { @include small-text; }", kind: 'text')

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "body {\n  font-family: Arial;\n  font-size: 2px;\n  font-weight: bold;\n  color: #ff0000; }\n", subject
    end

    test 'site drop' do
      content = Scribo::Site.titled('second').contents.first

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal "email@example.com,rss,github\n", subject
    end

    test 'site import and rendering' do
      f = ZipFileGenerator.new('test/files/mysite', folder_entries: false).write
      site = Scribo::SiteImportService.new(f.path).call

      subject = Scribo::ContentFindService.new(site, path: '/assets/main.css').perform
      result = Scribo::ContentRenderService.new(subject, {}).perform

      assert_includes result, 'Reset some basic elements'
    end

    test 'multiple levels of layout should preserve liquid inside raw' do
      site = scribo_sites(:main)
      layout2 = site.contents.create!(path: 'layout2.html', data: '2{{content}}2', kind: 'text', parent: scribo_contents(:layout_folder))
      layout1 = site.contents.create!(path: 'layout1.html', properties: { layout: 'layout2' }, data: '1{{content}}1', kind: 'text', parent: scribo_contents(:layout_folder))
      content = site.contents.create!(properties: { title: 'Hello', layout: 'layout1' }, path: 'test.txt', data: '{%raw%}{{title}}{%endraw%}', kind: 'text')

      assert content
      subject = Scribo::ContentRenderService.new(content, {}).call

      assert_equal '21{{title}}12', subject
    end
  end
end
