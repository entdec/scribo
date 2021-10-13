# frozen_string_literal: true

require_dependency 'scribo/application_service'
require 'mime/types'
require 'yaml'

module Scribo
  class SiteImportService < ApplicationService
    attr_reader :path, :scribable, :properties_override

    IGNORED_FILES = [%r[^__MACOSX/], %r[/\.DS_Store], %r[^/_site], /^node_modules/].freeze

    def initialize(path, scribable: nil, properties: {})
      super()
      @path = path
      @scribable = scribable
      @properties_override = properties
    end

    def perform
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          unzip(dir)

          all_files = Dir.glob('**/*')
          all_files = all_files.reject { |p| p == '_config.yml' } if properties_override.present?
          all_files.each do |name|
            parent = if File.dirname(name) == name
                       nil
                     else
                       site.contents.located(File.dirname(name), restricted: false).first
                     end

            content = site.contents.find_or_create_by(path: File.basename(name), parent: parent)
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
      site.contents.create(path: '_config.yml', data: YAML.dump(site.properties)) if properties_override.present?
      site
    end

    private

    def unzip(dir)
      Zip::File.open(path) do |zipfile|
        zipfile.reject { |e| IGNORED_FILES.any? { |r| r.match(e.name) } }.each do |f|
          file_path = File.join(dir, f.name[base_path(zipfile).length..-1])
          FileUtils.mkdir_p(File.dirname(file_path)) unless File.exist?(File.dirname(file_path))

          f.extract(file_path) unless File.exist?(file_path)
        end
      end
    end

    def base_path(zipfile)
      return @base_path if @base_path

      base_paths = zipfile.reject { |e| IGNORED_FILES.any? { |r| r.match(e.name) } }
                          .map { |f| f.name.split('/').first }.uniq
      @base_path = base_paths.size == 1 ? base_paths.first : ''
    end

    def site
      return @site if @site

      @site = Site.where(scribable: scribable)

      %w[host title baseurl].each do |property|
        if properties[property].nil?
          @site = @site.where("properties->>'#{property}' IS NULL")
        else
          @site = @site.where("properties->>'#{property}' = ?", properties[property])
        end
      end

      @site = @site.first

      @site ||= Site.create!(scribable: scribable, properties: properties.merge(properties_override))
    end

    def properties
      @properties = Scribo::Utility.yaml_safe_parse(File.read('_config.yml')) if File.exist?('_config.yml')
      @properties ||= {}
    end
  end
end
