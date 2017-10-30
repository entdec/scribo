# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Site < ApplicationRecord
    belongs_to :scribable, polymorphic: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id'

    def self.named(name)
      where(name: name)
    end

    def export
      return unless contents.count.positive?

      base_path = 'site_' + (name || 'untitled') + '/'
      stringio  = Zip::OutputStream.write_buffer do |zio|
        contents.each do |content|
          zip_path = if content.path.present?
                       zip_path = content.path[0] == '/' ? content.path[1..-1] : content.path
                       zip_path = 'index' if zip_path.blank?
                       if content.layout.present?
                         zip_path += "##{content.layout.identifier.tr('/', '_')}"
                       end
                       zip_path
                     elsif content.identifier
                       '_identified/' + content.identifier.tr('/', '_')
                     elsif content.name
                       '_named/' + content.name
                     end
          next unless zip_path
          comment = JSON.dump({ content_type: content.content_type,
                                title:        content.title,
                                description:  content.description,
                                filter:       content.filter,
                                caption:      content.caption,
                                breadcrumb:   content.breadcrumb,
                                keywords:     content.keywords,
                                state:        content.state,
                                properties:   content.properties,
                                published_at: content.published_at }.reject { |_, v| v.nil? })
          zio.put_next_entry(base_path + zip_path, comment)
          zio.write content.data
        end
      end

      # TODO: Just return string and use this elsewhere
      open('./site.zip', 'wb') do |file|
        file.write stringio.string
      end
    end
  end
end
