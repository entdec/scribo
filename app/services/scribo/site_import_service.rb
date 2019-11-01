# frozen_string_literal: true

require_dependency 'scribo/application_service'
require 'mime/types'
require 'yaml'

module Scribo
  class SiteImportService < ApplicationService
    attr_reader :path, :zip_file, :meta_info_site, :base_path

    def initialize(path)
      @path = path
      @zip_file = Zip::File.open(path)

      # Find specific entry
      meta_info_entry = zip_file.glob('*/_config.yml').first

      @meta_info_site = if meta_info_entry
                          Scribo::Utility.yaml_safe_parse(meta_info_entry.get_input_stream.read)
                        else
                          {}
                        end
      meta_info_site['contents'] = [] unless meta_info_site['contents']

      @base_path = nil
      zip_file.glob('**/*').reject { |e| e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.each do |entry|
        @base_path ||= entry.name.split('/').first
        raise "Site import needs all site content to be in one folder starting with #{base_path}/" unless entry.name.start_with?(base_path + '/')
      end

      meta_info_site['properties'] ||= {}
      meta_info_site['properties']['title'] = base_path
    end

    def perform
      site = create_site

      (0..max_depth).to_a.each do |depth|
        zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/_config.yml" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') || e.name.start_with?("#{base_path}/.") }.each do |entry|
          entry_path = entry_path(base_path, entry.name)
          next if entry_path.empty?
          next if entry_depth(entry_path) != depth

          if depth.positive?
            parts = entry_path.split('/')[1..-1]
            (parts.size - 1).times do |t|
              sub_path = '/' + parts[0..t].join('/')

              create_content(site, sub_path, nil)
            end
          end
          create_content(site, entry_path, entry)
        end
      end

      zip_file.close
      site
    end

    private

    def max_depth
      @maxdepth ||= zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/_config.yml" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') || e.name.start_with?("#{base_path}/.") }.map do |entry|
        entry_path = entry_path(base_path, entry.name)
        entry_depth(entry_path)
      end.max
      @maxdepth
    end

    def create_site
      site = Site.where(scribable: scribable_object_for(meta_info_site['for'])).where("properties->>'title' = ?", meta_info_site['properties']['title']).where("properties->>'baseurl' = ?", meta_info_site['properties']['baseurl']).first
      site ||= Site.create(scribable: scribable_object_for(meta_info_site['for']), properties: meta_info_site['properties'])
      site.properties = meta_info_site.except('contents', 'for', 'properties')
      site.save!

      site
    end

    def create_content(site, entry_path, entry)
      meta_info = meta_info_for_entry_name(meta_info_site, entry_path, entry)

      parent = meta_info_site['contents'].find { |mi| mi['path'] == meta_info['parent'] }['record'] if meta_info['parent']
      content = site.contents.find_or_create_by(path: File.basename(meta_info['path']), full_path: meta_info['path'], parent: parent)

      content.kind = meta_info['kind']
      content.data_with_frontmatter = entry.get_input_stream.read if entry&.get_input_stream&.respond_to?(:read)
      content.properties ||= meta_info['properties']
      content.save!

      meta_info['record'] = content
    end

    def guess_info_for_entry_name(prefill, entry_name, entry)
      meta_info = prefill
      meta_info['state'] = 'published'

      meta_info['kind'] = if entry.nil?
                            'folder'
                          elsif entry.directory?
                            'folder'
                          elsif File.extname(entry_name).present?
                            Scribo::Utility.kind_for_path(entry_name)
                          elsif entry&.get_input_stream&.respond_to?(:read) && entry.get_input_stream.read.encoding.name != 'ASCII-8BIT'
                            'asset'
                          else
                            'text'
                          end

      meta_info['published_at'] = Time.new
      meta_info
    end

    def meta_info_for_entry_name(meta_info_site, entry_path, entry)
      path = entry_path
      meta_info = (meta_info_site['contents'] || []).find { |m| m['path'] == path }
      unless meta_info
        meta_info = guess_info_for_entry_name({ 'path' => path }, entry_path, entry)
        meta_info['parent'] = File.dirname(entry_path) if entry_depth(entry_path).positive?
        meta_info_site['contents'] << meta_info
      end
      meta_info
    end

    def entry_path(base_path, entry_name)
      entry_name[base_path.size..-1].gsub(%r[/$], '')
    end

    def entry_depth(entry_path)
      entry_path.split('/').size - 2
    end

    def scribable_object_for(str)
      return Scribo.config.scribable_objects.first unless str

      klass, name = str.split(':')
      result = Scribo.config.scribable_objects.find do |so|
        so.class.name.demodulize.underscore == klass && so.to_s == name
      end
      result ||= Scribo.config.scribable_objects.first
      result
    end
  end
end
