# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class BucketExportService < ApplicationService
    attr_reader :bucket

    def initialize(bucket)
      @bucket = bucket
    end

    def perform
      return unless bucket.contents.count.positive?

      zip_name = 'bucket_' + (bucket.name || 'untitled')
      base_path = zip_name + '/'
      stringio = Zip::OutputStream.write_buffer do |zio|
        meta_info = bucket_meta_information

        bucket.contents.each do |content|
          content_path = content_path_for_zip(content)
          next unless content_path

          zio.put_next_entry(base_path + content_path)
          zio.write content.data

          meta_info[:contents] << content_meta_information(content)
        end

        bucket.translations.keys.each do |locale|
          zio.put_next_entry(base_path + "_locales/#{locale}.yml")
          zio.write YAML.dump(locale => bucket.translations[locale])
        end

        zio.put_next_entry(base_path + 'scribo_bucket.json')
        zio.write JSON.pretty_generate(meta_info)
      end

      [zip_name + '.zip', stringio.string]
    end

    private

    def bucket_meta_information
      { version: Scribo::VERSION,
        name: bucket.name,
        purpose: bucket.purpose,
        scribable_type: bucket.scribable_type,
        scribable_id: bucket.scribable_id,
        properties: {},
        contents: [] }.reject { |_, v| v.nil? }
    end

    def content_meta_information(content)
      { path: content.path,
        kind: content.kind,
        content_type: content.content_type,
        title: content.title,
        description: content.description,
        filter: content.filter,
        caption: content.caption,
        breadcrumb: content.breadcrumb,
        keywords: content.keywords,
        state: content.state,
        layout: content.layout&.identifier,
        identifier: content.identifier,
        name: content.name,
        properties: content.properties,
        published_at: content.published_at }.reject { |_, v| v.nil? }
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
