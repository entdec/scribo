# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Site < ApplicationRecord
    belongs_to :scribable, polymorphic: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id'

    def self.named(name)
      where(name: name)
    end

    def self.import
      Zip::File.open('site_untitled.zip') do |zip_file|
        # Find specific entry
        meta_info_entry = zip_file.glob('site_*/._site.json').first
        break unless meta_info_entry

        meta_info_site = JSON.parse(meta_info_entry.get_input_stream.read)
        # TODO: Check version numbers
        site = Site.where(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'])
                   .where(name: meta_info_site['name']).first
        site ||= Site.create(scribable_type: meta_info_site['scribable_type'], scribable_id: meta_info_site['scribable_id'], name: meta_info_site['name'])

        zip_file.glob('**/*').reject { |e| File.basename(e.name)[0..1] == '._' }.each do |entry|
          import_path = entry.name[entry.name.index('/')..-1].chomp('.html')

          meta_info_name  = File.dirname(entry.name) + '/._' + File.basename(entry.name) + '.json'
          meta_info_entry = zip_file.find_entry(meta_info_name)

          meta_info = JSON.parse(meta_info_entry.get_input_stream.read)

          content = if meta_info['identifier']
                      site.contents.find_or_create_by(site: site, identifier: meta_info['identifier'])
                    elsif meta_info['name']
                      site.contents.find_or_create_by(site: site, name: meta_info['name'])
                    else
                      site.contents.find_or_create_by(site: site, path: import_path)
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

      nil
    end

    def export
      return unless contents.count.positive?

      zip_name  = 'site_' + (name || 'untitled')
      base_path = zip_name + '/'
      stringio  = Zip::OutputStream.write_buffer do |zio|
        zio.put_next_entry(base_path + '._site.json')
        zio.write site_meta_information

        contents.each do |content|
          content_path = content_path_for_zip(content)
          next unless content_path
          zio.put_next_entry(base_path + content_path)
          zio.write content.data

          dirname  = File.dirname(base_path + content_path)
          basename = File.basename(base_path + content_path)
          zio.put_next_entry(dirname + '/._' + basename + '.json')
          zio.write content_meta_information(content)
        end
      end

      # TODO: Just return string and use this elsewhere
      open(zip_name + '.zip', 'wb') do |file|
        file.write stringio.string
      end
    end

    private

    def site_meta_information
      JSON.pretty_generate({ version:        Scribo::VERSION,
                             name:           name,
                             scribable_type: scribable_type,
                             scribable_id:   scribable_id,
                             properties:     {} }.reject { |_, v| v.nil? })
    end

    def content_meta_information(content)
      JSON.pretty_generate({ kind:         content.kind,
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
                             published_at: content.published_at }.reject { |_, v| v.nil? })
    end

    def content_path_for_zip(content)
      if content.path.present?
        zip_path = content.path[0] == '/' ? content.path[1..-1] : content.path
        zip_path = 'index' if zip_path.blank?
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      elsif content.identifier
        zip_path = '_identified/' + content.identifier.tr('/', '_')
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      elsif content.name
        zip_path = '_named/' + content.name
        zip_path += '.html' if File.extname(zip_path).blank?
        zip_path
      end
    end
  end
end
