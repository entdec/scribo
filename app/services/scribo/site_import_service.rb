# frozen_string_literal: true

require_dependency 'scribo/application_service'
require 'mime/types'
require 'yaml'

module Scribo
  class SiteImportService < ApplicationService
    attr_reader :path

    def initialize(path)
      super()
      @path = path
    end

    def perform
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          unzip(dir)

          Dir.glob('**/*').each do |name|
            parent = if File.dirname(name) == name
                       nil
                     else
                       site.contents.located(File.dirname(name), restricted: false).first
                     end

            content = site.contents.find_or_create_by(path: File.basename(name), full_path: name, parent: parent)
            if File.directory?(name)
              content.kind = 'folder'
            else
              File.open(name) do |f|
                content.kind = Scribo::Utility.kind_for_path(name)
                content.data_with_frontmatter = f.read
              end
            end
            content.save!
          end
        end
      end
      site
    end

    private

    def unzip(dir)
      Zip::File.open(path) do |zipfile|
        zipfile.reject { |e| e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.each do |f|
          file_path = File.join(dir, f.name[base_path(zipfile).length..-1])
          FileUtils.mkdir_p(File.dirname(file_path)) unless File.exist?(File.dirname(file_path))

          f.extract(file_path) unless File.exist?(file_path)
        end
      end
    end

    def base_path(zipfile)
      return @base_path if @base_path

      base_paths = zipfile.reject { |e| e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }
                          .map { |f| f.name.split('/').first }.uniq
      @base_path = base_paths.size == 1 ? base_paths.first : ''
    end

    def site
      return @site if @site

      scribable = Scribo.config.scribable_objects.first

      @site = Site.where(scribable: scribable)
                  .where("properties->>'title' = ?", properties['title'])
                  .where("properties->>'baseurl' = ?", properties['baseurl']).first

      @site ||= Site.create!(scribable: scribable, properties: properties)
    end

    def properties
      @properties = Scribo::Utility.yaml_safe_parse(File.read('_config.yml')) if File.exist?('_config.yml')
      @properties ||= {}
    end
  end
end
