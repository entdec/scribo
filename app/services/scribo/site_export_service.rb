# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class SiteExportService < ApplicationService
    attr_reader :site

    def initialize(site)
      @site = site
    end

    def perform
      return unless site.contents.count.positive?

      site.contents.rebuild!

      zip_name = 'site_' + (site.name || 'untitled')
      base_path = zip_name + '/'
      stringio = Zip::OutputStream.write_buffer do |zio|
        meta_info = site_meta_information

        site.contents.each do |content|
          content_path = content_path_for_zip(content)
          next unless content_path

          puts "content_path: #{content_path}"

          meta_info[:contents] << content_meta_information(content)

          next if content.kind == 'folder'

          zio.put_next_entry(base_path + content_path)
          zio.write content.data
        end

        zio.put_next_entry(base_path + '_config.yml')
        zio.write YAML.dump(meta_info.deep_stringify_keys)
      end

      [zip_name + '.zip', stringio.string]
    end

    private

    def site_meta_information
      { version: Scribo::VERSION,
        name: site.name,
        purpose: site.purpose,
        scribable_type: site.scribable_type,
        scribable_id: site.scribable_id,
        properties: {},
        contents: [] }.reject { |_, v| v.nil? }
    end

    def content_meta_information(content)
      { path: content.full_path,
        kind: content.kind,
        content_type: content.content_type,
        title: content.title,
        description: content.description,
        filter: content.filter,
        caption: content.caption,
        breadcrumb: content.breadcrumb,
        keywords: content.keywords,
        state: content.state,
        lft: content.lft,
        rgt: content.rgt,
        depth: content.depth,
        parent: content.parent&.full_path,
        layout: content.layout&.full_path,
        properties: content.properties,
        published_at: content.published_at.to_time }.reject { |_, v| v.nil? }
    end

    def content_path_for_zip(content)
      zip_path = content.full_path[0] == '/' ? content.full_path[1..-1] : content.full_path
      zip_path = '' if zip_path == '/'
      zip_path = 'index' if zip_path.blank?
      zip_path += '.html' if File.extname(zip_path).blank?
      zip_path
    end

  end
end
