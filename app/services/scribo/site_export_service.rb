# frozen_string_literal: true

require_dependency 'scribo/application_service'

module Scribo
  class SiteExportService < ApplicationService
    attr_reader :site

    def initialize(site)
      super()
      @site = site
    end

    def perform
      return unless site.contents.count.positive?

      zip_name = (site.properties['title'] || 'untitled').to_s
      base_path = "#{zip_name}/"

      stringio = Zip::OutputStream.write_buffer do |zio|
        site.contents.each do |content|
          content_path = content_path_for_zip(content)
          next unless content_path

          next if content.kind == 'folder'

          zio.put_next_entry(base_path + content_path)
          zio.write content.data_with_frontmatter
        end
      end

      ["#{zip_name}.zip", stringio.string]
    end

    private

    def content_path_for_zip(content)
      content.tree_path[0] == '/' ? content.tree_path[1..-1] : content.tree_path
    end
  end
end
