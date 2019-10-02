# frozen_string_literal: true

require_dependency 'scribo/application_service'
require 'mime/types'

module Scribo
  class SiteImportService < ApplicationService
    attr_reader :path, :zip_file, :meta_info_site, :base_path

    def initialize(path)
      @path = path
      @zip_file = Zip::File.open(path)

      # Find specific entry
      meta_info_entry = zip_file.glob('site_*/_config.yml').first
      raise 'Site import needs a _config.yml file in the root of the zip' unless meta_info_entry

      @meta_info_site = YAML.safe_load(meta_info_entry.get_input_stream.read, permitted_classes: [Time])
      meta_info_site['contents'] = [] unless meta_info_site['contents']

      # TODO: Check version numbers
      @base_path = "site_#{meta_info_site['name']}"
      zip_file.glob('**/*').reject { |e| e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.each do |entry|
        raise "Site import needs all site content to be in a folder starting with #{base_path}/" unless entry.name.start_with?(base_path + '/')
      end
    end

    def perform
      site = create_site

      # FIXME: Ones with layout could still go wrong
      (0..max_depth).to_a.each do |depth|
        zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/_config.yml" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.each do |entry|
          entry_path = entry_path(base_path, entry.name)
          next if entry_path.empty?
          next if entry_depth(entry_path) != depth

          # puts "depth: #{depth} - entrypath: #{entry_path} - entry depth: #{entry_depth(entry_path)} => #{entry_path}"

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

      site.contents.rebuild!

      zip_file.close
      site
    end

    private

    def max_depth
      @maxdepth ||= zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/_config.yml" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.map do |entry|
        entry_path = entry_path(base_path, entry.name)
        entry_depth(entry_path)
      end.max
      @maxdepth
    end

    def create_site
      site = Site.where(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id']).where(name: meta_info_site['name']).first
      site ||= Site.create(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'], name: meta_info_site['name'])
      site.purpose = meta_info_site['purpose']
      site.save!

      site
    end

    def create_content(site, entry_path, entry)
      meta_info = meta_info_for_entry_name(meta_info_site, entry_path, entry)
      if meta_info['kind'] != 'folder'
        Scribo.config.logger.warn "Scribo: Not importing #{entry_path} it's a non-supported content-type!" unless meta_info['content_type']
        return unless meta_info['content_type']
      end

      parent = meta_info_site['contents'].find { |mi| mi['path'] == meta_info['parent'] }['record'] if meta_info['parent']

      site.contents.rebuild!(validate: false) # WHY
      content = site.contents.find_or_create_by(path: File.basename(meta_info['path']), full_path: meta_info['path'], parent: parent)

      content.data = entry.get_input_stream.read if entry&.get_input_stream&.respond_to?(:read)
      content.kind = meta_info['kind']
      content.content_type = meta_info['content_type']
      content.title = meta_info['title']
      content.description = meta_info['description']
      content.filter = meta_info['filter']
      content.caption = meta_info['caption']
      content.breadcrumb = meta_info['breadcrumb']
      content.keywords = meta_info['keywords']
      content.state = meta_info['state']
      content.layout = meta_info_site['contents'].find { |mi| mi['path'] == meta_info['layout'] }['record'] if meta_info['layout']
      content.properties = meta_info['properties']
      content.published_at = meta_info['published_at']
      content.save!

      meta_info['record'] = content

      # content.update_columns(lft: meta_info['lft'].to_i, rgt: meta_info['rgt'].to_i, depth: meta_info['depth'].to_i)
    end

    def guess_info_for_entry_name(prefill, entry_name, entry)
      meta_info = prefill
      meta_info['state'] = 'published'
      meta_info['content_type'] = MIME::Types.type_for(entry_name).find { |mt| Content.content_type_supported?(mt.simplified) }&.content_type
      meta_info['kind'] = if entry
                            Scribo.config.supported_mime_types[:text].include?(meta_info['content_type']) ? 'text' : 'asset'
                          else
                            'folder'
                          end
      meta_info['published_at'] = Time.new
      meta_info
    end

    def meta_info_for_entry_name(meta_info_site, entry_path, entry)
      path = entry_path
      path = path.gsub(/\.html$/, '')
      path = '/' if path == '/index'
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
  end
end
