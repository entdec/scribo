# frozen_string_literal: true

require 'test_helper'

module Scribo
  class SiteImportServiceTest < ActiveSupport::TestCase
    test 'import zip with folder entries' do
      Tempfile.open(['hello', '.zip']) do |f|
        ZipFileGenerator.new('test/files/site_imported').write(f)
        subject = Scribo::SiteImportService.new(f.path).call

        assert subject
        assert_equal 4, subject.contents.count
        assert_equal 'text', subject.contents.located('/').first.kind
        assert_equal "test\n", subject.contents.located('/').first.data
        assert_equal 'folder', subject.contents.located('/folder1').first.kind
        assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
        assert_equal 'asset', subject.contents.located('/test.png').first.kind
      end
    end

    test 'import zip without folder entries' do
      Tempfile.open(['hello', '.zip']) do |f|
        ZipFileGenerator.new('test/files/site_imported', folder_entries: false).write(f)
        subject = Scribo::SiteImportService.new(f.path).call

        assert subject
        assert_equal 4, subject.contents.count
        assert_equal 'text', subject.contents.located('/').first.kind
        assert_equal "test\n", subject.contents.located('/').first.data
        assert_equal 'folder', subject.contents.located('/folder1').first.kind
        assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
        assert_equal 'asset', subject.contents.located('/test.png').first.kind
      end
    end

    test 'import zip without contents in _config.yml' do
      Tempfile.open(['hello', '.zip']) do |f|
        ZipFileGenerator.new('test/files/site_imported2', folder_entries: false).write(f)
        subject = Scribo::SiteImportService.new(f.path).call

        assert subject
        assert_equal 4, subject.contents.count
        assert_equal 'text', subject.contents.located('/').first.kind
        assert_equal "test\n", subject.contents.located('/').first.data
        assert_equal 'folder', subject.contents.located('/folder1').first.kind
        assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
        assert_equal 'asset', subject.contents.located('/test.png').first.kind
      end
    end

    test 'import zip without _config.yml' do
      Tempfile.open(['hello', '.zip']) do |f|
        ZipFileGenerator.new('test/files/site_imported3', folder_entries: false).write(f)
        subject = Scribo::SiteImportService.new(f.path).call

        assert subject
        assert_equal 4, subject.contents.count
        assert_equal 'text', subject.contents.located('/').first.kind
        assert_equal "test\n", subject.contents.located('/').first.data
        assert_equal 'folder', subject.contents.located('/folder1').first.kind
        assert_equal 'asset', subject.contents.located('/folder1/test.png').first.kind
        assert_equal 'asset', subject.contents.located('/test.png').first.kind
      end
    end
  end
end
