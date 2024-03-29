# frozen_string_literal: true

require 'test_helper'

module Scribo
  class SiteImportServiceTest < ActiveSupport::TestCase
    test 'import zip with folder entries' do
      f = ZipFileGenerator.new('test/files/site_imported').write
      subject = Scribo::SiteImportService.new(f.path).call

      assert subject
      assert_equal 5, subject.contents.count
      assert_equal 'text', subject.contents.located('/_config.yml', restricted: false).first.kind
      assert_equal 'text', subject.contents.located('/index.html').first.kind
      assert_equal "test\n", subject.contents.located('/index.html').first.data
      assert_equal 'folder', subject.contents.located('/folder1').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
      assert_equal subject.contents.located('/folder1').first, subject.contents.located('/folder1/test.png').first.parent
      assert_equal 'asset', subject.contents.located('/test.png').first.kind
    end

    test 'import zip with folder entries, zip in one containing folder' do
      f = ZipFileGenerator.new('test/files/site_imported', containing_folder: true).write
      subject = Scribo::SiteImportService.new(f.path).call

      assert subject
      assert_equal 5, subject.contents.count
      assert_equal 'text', subject.contents.located('/_config.yml', restricted: false).first.kind
      assert_equal 'text', subject.contents.located('/index.html').first.kind
      assert_equal "test\n", subject.contents.located('/index.html').first.data
      assert_equal 'folder', subject.contents.located('/folder1').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
      assert_equal subject.contents.located('/folder1').first, subject.contents.located('/folder1/test.png').first.parent
      assert_equal 'asset', subject.contents.located('/test.png').first.kind
    end

    test 'import zip without folder entries' do
      f = ZipFileGenerator.new('test/files/site_imported', folder_entries: false).write
      subject = Scribo::SiteImportService.new(f.path).call

      assert subject
      assert_equal 5, subject.contents.count
      assert_equal 'text', subject.contents.located('/_config.yml', restricted: false).first.kind
      assert_equal 'text', subject.contents.located('/index.html').first.kind
      assert_equal "test\n", subject.contents.located('/index.html').first.data
      assert_equal 'folder', subject.contents.located('/folder1').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
      assert_equal subject.contents.located('/folder1').first, subject.contents.located('/folder1/test.png').first.parent
      assert_equal 'asset', subject.contents.located('/test.png').first.kind
    end

    test 'import zip without contents in _config.yml' do
      f = ZipFileGenerator.new('test/files/site_imported2', folder_entries: false).write
      subject = Scribo::SiteImportService.new(f.path).call

      assert subject
      assert_equal 5, subject.contents.count
      assert_equal 'text', subject.contents.located('/_config.yml', restricted: false).first.kind
      assert_equal 'text', subject.contents.located('/index.html').first.kind
      assert_equal "test\n", subject.contents.located('/index.html').first.data
      assert_equal 'folder', subject.contents.located('/folder1').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
      assert_equal subject.contents.located('/folder1').first, subject.contents.located('/folder1/test.png').first.parent
      assert_equal 'asset', subject.contents.located('/test.png').first.kind
    end

    test 'import zip without _config.yml' do
      f = ZipFileGenerator.new('test/files/site_imported3', folder_entries: false).write
      subject = Scribo::SiteImportService.new(f.path).call

      assert subject
      assert_equal 6, subject.contents.count
      assert_equal 'text', subject.contents.located('/index.html').first.kind
      assert_equal "test\n", subject.contents.located('/index.html').first.data
      assert_equal({ 'published' => true }, subject.contents.located('/index.html').first.properties)
      assert_equal 'folder', subject.contents.located('/folder1').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
      assert_equal 'asset', subject.contents.located('/test.png').first.kind
      assert_equal 'asset', subject.contents.located('/folder1/fontello.woff2').first.kind
      assert_equal '', subject.contents.located('/test.md').first.data
      assert_equal({ 'layout' => 'home' }, subject.contents.located('/test.md').first.properties)
    end
  end
end
