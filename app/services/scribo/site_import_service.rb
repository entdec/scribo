# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class SiteImportService < ApplicationService
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def perform
      Zip::File.open(path) do |zip_file|
        # Find specific entry
        meta_info_entry = zip_file.glob('site_*/_config.yml').first
        return false unless meta_info_entry

        meta_info_site = YAML.load(meta_info_entry.get_input_stream.read)
        # TODO: Check version numbers
        site = Site.where(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'])
                   .where(name: meta_info_site['name']).first
        site ||= Site.create(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'], name: meta_info_site['name'])

        site.purpose = meta_info_site['purpose']

        base_path = "site_#{meta_info_site['name']}"

        site.save

        max_depth = meta_info_site['contents'].map{|c|depth(c)}.max
        puts "max_depth: #{max_depth}"

        # FIXME: Ones with layout could still go wrong
        (0..max_depth).to_a.each do |depth|
          zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/_config.yml" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') }.each do |entry|
            next if entry_path(base_path, entry.name).empty?

            meta_info = meta_info_for_entry_name(meta_info_site, base_path, entry.name)

            puts "depth: #{depth} - entrypath: #{entry_path(base_path, entry.name)} - metainfodepth: #{depth(meta_info)} == #{depth}"
            next unless depth(meta_info) == depth

            if meta_info['kind'] != 'folder'
              Rails.logger.warn "Scribo: Not importing #{entry.name} it's a non-supported content-type!" unless meta_info['content_type']
              next unless meta_info['content_type']
            end

            create_content(site, entry, meta_info_site, meta_info)
          end
        end

        site.contents.rebuild!
      end

      true
    end

    private

    def create_content(site, entry, meta_info_site, meta_info)
      content = site.contents.find_or_create_by(site: site, path: File.basename(meta_info['path']), full_path: meta_info['path'])

      if entry.get_input_stream.respond_to?(:read)
        content.data = entry.get_input_stream.read
      end
      content.kind = meta_info['kind']
      content.path = File.basename(meta_info['path'])
      content.content_type = meta_info['content_type']
      content.title = meta_info['title']
      content.description = meta_info['description']
      content.filter = meta_info['filter']
      content.caption = meta_info['caption']
      content.breadcrumb = meta_info['breadcrumb']
      content.keywords = meta_info['keywords']
      content.state = meta_info['state']
      if meta_info['layout']
        content.layout_id = meta_info_site['contents'].find {|mi| mi['path'] == meta_info['layout']}['id']
      end
      if meta_info['parent']
        content.parent_id = meta_info_site['contents'].find {|mi| mi['path'] == meta_info['parent']}['id']
      end
      content.properties = meta_info['properties']
      content.published_at = meta_info['published_at']
      content.save!

      meta_info['id'] = content.id

      content.update_columns(lft: meta_info['lft'], rgt: meta_info['rgt'], depth: meta_info['depth'])
    rescue Exception => e
      binding.pry
    end

    def guess_info_for_entry_name(prefill, entry_name)
      meta_info = prefill
      meta_info['state'] = 'published'
      meta_info['content_type'] = MIME::Types.type_for(entry_name).find { |mt| Content.content_type_supported?(mt.simplified) }&.content_type
      meta_info['kind'] = Scribo.config.supported_mime_types[:text].include?(meta_info['content_type']) ? 'text' : 'asset'
      meta_info['published_at'] = Time.new
      meta_info
    end

    def meta_info_for_entry_name(meta_info_site, base_path, entry_name)
      path = entry_path(base_path, entry_name)
      path = '/' if path == '/index'
      meta_info = meta_info_site['contents'].find { |m| m['path'] == path }
      meta_info ||= guess_info_for_entry_name({ 'path' => path }, entry_name)
      meta_info
    end

    def entry_path(base_path, entry_name)
      entry_name[base_path.size..-1].gsub(/\.html$/, '').gsub(/\/$/, '')
    end

    def depth(meta_info)
      return 0 unless meta_info['parent']

      meta_info['parent'].split('/').size - 1
    end
  end
end
