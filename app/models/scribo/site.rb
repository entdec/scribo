# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Site < ApplicationRecord
    belongs_to :scribable, polymorphic: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id'

    attr_accessor :zip_file

    def self.named(name)
      where(name: name)
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

        meta_info_site['contents'].each do |meta_info|
          entry_path = base_path + '/' + content_path_for_zip(meta_info['path'], meta_info['identifier'], meta_info['name'])
          entry      = zip_file.find_entry(entry_path)

          content = if meta_info['identifier']
                      site.contents.find_or_create_by(site: site, identifier: meta_info['identifier'])
                    elsif meta_info['name']
                      site.contents.find_or_create_by(site: site, name: meta_info['name'])
                    else
                      site.contents.find_or_create_by(site: site, path: meta_info['path'])
                    end

          content.data         = entry.get_input_stream.read
          content.kind         = meta_info['kind']
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
