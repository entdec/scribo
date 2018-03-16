# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Site < ApplicationRecord
    # belongs_to :scribable, polymorphic: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id'

    attr_accessor :zip_file

    def self.named(name)
      where(name: name)
    end

    def self.guess_info_for_entry_name(prefill, entry_name)
      meta_info                 = prefill
      meta_info['state']        = 'published'
      meta_info['content_type'] = MIME::Types.type_for(entry_name).find { |mt| Content.content_type_supported?(mt.simplified) }&.content_type
      meta_info['kind']         = Scribo.supported_mime_types[:text].include?(meta_info['content_type']) ? 'text' : 'asset'
      meta_info['published_at'] = Time.new
      meta_info
    end

    def self.meta_info_for_entry_name(meta_info_site, base_path, entry_name)
      if entry_name.start_with?(base_path + '/_identified/')
        identifier = entry_name[(base_path + '/_identified/').size..-1].gsub(/\.html$/, '').tr('_', '/')
        meta_info  = meta_info_site['contents'].find { |m| m['identifier'] == identifier }
        meta_info ||= guess_info_for_entry_name({ 'identifier' => identifier }, entry_name)
      elsif entry_name.start_with?(base_path + '/_named/')
        name      = entry_name[(base_path + '/_named/').size..-1].gsub(/\.html$/, '').tr('_', '/')
        meta_info = meta_info_site['contents'].find { |m| m['name'] == name }
        meta_info ||= guess_info_for_entry_name({ 'name' => name }, entry_name)
      else
        path      = entry_name[base_path.size..-1].gsub(/\.html$/, '')
        path      = '/' if path == '/index'
        meta_info = meta_info_site['contents'].find { |m| m['path'] == path }
        meta_info ||= guess_info_for_entry_name({ 'path' => path }, entry_name)
      end
      meta_info
    end

    def self.content_path_for_zip(path, identifier, name)
      if path.present?
        zip_path = path[0] == '/' ? path[1..-1] : path
        zip_path = 'index' if zip_path.blank?
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      elsif identifier
        zip_path = '_identified/' + identifier.tr('/', '_')
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      elsif name
        zip_path = '_named/' + name
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      end
    end

    def self.import(path)
      Zip::File.open(path) do |zip_file|
        # Find specific entry
        meta_info_entry = zip_file.glob('site_*/scribo_site.json').first
        return false unless meta_info_entry

        meta_info_site = JSON.parse(meta_info_entry.get_input_stream.read)
        # TODO: Check version numbers
        site = Site.where(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'])
                   .where(name: meta_info_site['name']).first
        site ||= Site.create(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'], name: meta_info_site['name'])

        site.host_name = meta_info_site['host_name']
        site.save

        base_path = "site_#{meta_info_site['name']}"

        zip_file.glob('**/*').reject { |e| e.name == "#{base_path}/scribo_site.json" || e.name.start_with?('__MACOSX/') || e.name.end_with?('/.DS_Store') || !e.get_input_stream.respond_to?(:read) }.each do |entry|
          meta_info = meta_info_for_entry_name(meta_info_site, base_path, entry.name)
          Rails.logger.warn "Scribo: Not importing #{entry.name} it's a non-supported content-type!" unless meta_info['content_type']
          next unless meta_info['content_type']

          content = if meta_info['path']
                      site.contents.find_or_create_by(site: site, path: meta_info['path'])
                    elsif meta_info['name']
                      site.contents.find_or_create_by(site: site, name: meta_info['name'])
                    elsif meta_info['identifier']
                      site.contents.find_or_create_by(site: site, identifier: meta_info['identifier'])
                    end

          content.data         = entry.get_input_stream.read
          content.kind         = meta_info['kind']
          content.path         = meta_info['path']
          content.name         = meta_info['name']
          content.identifier   = meta_info['identifier']
          content.content_type = meta_info['content_type']
          content.title        = meta_info['title']
          content.description  = meta_info['description']
          content.filter       = meta_info['filter']
          content.caption      = meta_info['caption']
          content.breadcrumb   = meta_info['breadcrumb']
          content.keywords     = meta_info['keywords']
          content.state        = meta_info['state']
          content.layout       = site.contents.find_by(identifier: meta_info['layout']) if meta_info['layout']
          content.properties   = meta_info['properties']
          content.published_at = meta_info['published_at']
          content.save
        end
      end
      true
    end

    def self.site_for_hostname(host_name)
      where('? ~ host_name', host_name).first
    end

    def export
      return unless contents.count.positive?

      zip_name  = 'site_' + (name || 'untitled')
      base_path = zip_name + '/'
      stringio  = Zip::OutputStream.write_buffer do |zio|
        meta_info = site_meta_information

        contents.each do |content|
          content_path = content_path_for_zip(content.path, content.identifier, content.name)
          next unless content_path
          zio.put_next_entry(base_path + content_path)
          zio.write content.data

          meta_info[:contents] << content_meta_information(content)
        end

        zio.put_next_entry(base_path + 'scribo_site.json')
        zio.write JSON.pretty_generate(meta_info)
      end

      [zip_name + '.zip', stringio.string]
    end

    private

    def site_meta_information
      { version:        Scribo::VERSION,
        name:           name,
        host_name:      host_name,
        scribable_type: scribable_type,
        scribable_id:   scribable_id,
        properties:     {},
        contents:       [] }.reject { |_, v| v.nil? }
    end

    def content_meta_information(content)
      { path:         content.path,
        kind:         content.kind,
        content_type: content.content_type,
        title:        content.title,
        description:  content.description,
        filter:       content.filter,
        caption:      content.caption,
        breadcrumb:   content.breadcrumb,
        keywords:     content.keywords,
        state:        content.state,
        layout:       content.layout&.identifier,
        identifier:   content.identifier,
        name:         content.name,
        properties:   content.properties,
        published_at: content.published_at }.reject { |_, v| v.nil? }
    end

    def content_path_for_zip(path, identifier, name)
      self.class.content_path_for_zip(path, identifier, name)
    end
  end
end
