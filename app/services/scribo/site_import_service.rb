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
        meta_info_entry = zip_file.glob('site_*/scribo_site.json').first
        return false unless meta_info_entry

        meta_info_site = JSON.parse(meta_info_entry.get_input_stream.read)
        # TODO: Check version numbers
        site = Site.where(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'])
                   .where(name: meta_info_site['name']).first
        site ||= Site.create(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'], name: meta_info_site['name'])

        site.purpose = meta_info_site['purpose']

        base_path = "site_#{meta_info_site['name']}"

        # FIXME: Skip these for now - no place to put them atm
        # site.translations = {}
        # zip_file.glob("#{base_path}/_locales/*.yml").each do |translation_file|
        #   locale = File.basename(translation_file.name, '.yml')
        #   site.translations[locale] = YAML.safe_load(translation_file.get_input_stream.read)[locale]
        # end

        site.save

        zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/scribo_site.json" || e.name.start_with?("#{base_path}/_locales/") || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') || !e.get_input_stream.respond_to?(:read) }.each do |entry|
          meta_info = meta_info_for_entry_name(meta_info_site, base_path, entry.name)
          Rails.logger.warn "Scribo: Not importing #{entry.name} it's a non-supported content-type!" unless meta_info['content_type']
          next unless meta_info['content_type']

          content = if meta_info['path']
                      site.contents.find_or_create_by(site: site, path: meta_info['path'])
                    elsif meta_info['identifier']
                      site.contents.find_or_create_by(site: site, identifier: meta_info['identifier'])
                    elsif meta_info['name']
                      site.contents.find_or_create_by(site: site, name: meta_info['name'])
                    end

          content.data = entry.get_input_stream.read
          content.kind = meta_info['kind']
          content.path = meta_info['path']
          content.name = meta_info['name']
          content.identifier = meta_info['identifier']
          content.content_type = meta_info['content_type']
          content.title = meta_info['title']
          content.description = meta_info['description']
          content.filter = meta_info['filter']
          content.caption = meta_info['caption']
          content.breadcrumb = meta_info['breadcrumb']
          content.keywords = meta_info['keywords']
          content.state = meta_info['state']
          content.layout = site.contents.find_by(identifier: meta_info['layout']) if meta_info['layout']
          content.parent = site.contents.find_by(identifier: meta_info['parent']) if meta_info['parent']
          content.properties = meta_info['properties']
          content.published_at = meta_info['published_at']
          content.save
        end
      end
      true
    end

    private

    def guess_info_for_entry_name(prefill, entry_name)
      meta_info = prefill
      meta_info['state'] = 'published'
      meta_info['content_type'] = MIME::Types.type_for(entry_name).find { |mt| Content.content_type_supported?(mt.simplified) }&.content_type
      meta_info['kind'] = Scribo.config.supported_mime_types[:text].include?(meta_info['content_type']) ? 'text' : 'asset'
      meta_info['published_at'] = Time.new
      meta_info
    end

    def meta_info_for_entry_name(meta_info_site, base_path, entry_name)
      if entry_name.start_with?(base_path + '/_identified/')
        identifier = entry_name[(base_path + '/_identified/').size..-1].gsub(/\.html$/, '').tr('_', '/')
        meta_info = meta_info_site['contents'].find { |m| m['identifier'] == identifier }
        meta_info ||= guess_info_for_entry_name({ 'identifier' => identifier }, entry_name)
      elsif entry_name.start_with?(base_path + '/_named/')
        name = entry_name[(base_path + '/_named/').size..-1].gsub(/\.html$/, '').tr('_', '/')
        meta_info = meta_info_site['contents'].find { |m| m['name'] == name }
        meta_info ||= guess_info_for_entry_name({ 'name' => name }, entry_name)
      else
        path = entry_name[base_path.size..-1].gsub(/\.html$/, '')
        path = '/' if path == '/index'
        meta_info = meta_info_site['contents'].find { |m| m['path'] == path }
        meta_info ||= guess_info_for_entry_name({ 'path' => path }, entry_name)
      end
      meta_info
    end

  end
end
