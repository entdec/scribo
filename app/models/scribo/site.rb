# frozen_string_literal: true

require_dependency 'scribo/application_record'
require_dependency 'scribo/liquid/parser'

module Scribo
  class Site < ApplicationRecord
    NEW_SITE_NAME = 'Untitled site'

    belongs_to :scribable, polymorphic: true, optional: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id', dependent: :destroy

    attr_accessor :zip_file

    scope :adminable, -> { where(scribable: Scribo.config.scribable_objects) }
    scope :owned_by, ->(owner) { where(scribable: owner) }
    scope :titled, ->(title) { where("properties->>'title' = ?", title).first }

    def self.for_path(path)
      return none if path.blank?

      paths = path.split('/').map.with_index { |_part, i| path.split('/')[0..i].join('/') }
      where("properties->>'baseurl' IN (?) OR properties->>'baseurl' IS NULL", paths).order("COALESCE(LENGTH(scribo_sites.properties->>'baseurl'), 0) DESC")
    end

    class << self
      def all_translation_keys
        parser = Scribo::LiquidParser.new
        result = {}
        Scribo::Content.includes(:site).where(content_type: Scribo.config.supported_mime_types[:text]).each do |content|
          parts = parser.parse(content.data)
          [*parts].select { |part| part.is_a?(Hash) && part[:filter] == 't' }.each do |part|
            result[content.translation_scope + part[:value].to_s] = part[:value].to_s[1..-1].humanize
          end
        end
        result
      end
    end

    def scribable_for
      "#{scribable.class.name.demodulize.underscore}:#{scribable}"
    end

    # See https://jekyllrb.com/docs/permalinks/
    def perma_link
      properties['permalink'] || '/:year/:month/:day/:title:output_ext'
    end

    def collections
      properties['collections'].to_h.keys.map(&:to_s) + %w[posts]
    end

    def title
      properties['title'] || NEW_SITE_NAME
    end

    def baseurl
      properties['baseurl'] || '/'
    end

    def properties
      attributes['properties'].present? ? attributes['properties'] : { 'title' => NEW_SITE_NAME, 'baseurl' => '/' }
    end

    #
    # Calculates the total size of the site in bytes, including assets
    #
    # @return [Integer] size in bytes
    #
    def total_size
      contents.map { |c| c.data ? c.data.size : c.asset.attachment&.download&.size || 0 }.sum
    end

    def create_index_page
      contents.build(kind: 'text', path: 'index.html', data: "<html>\n  <head><title>#{title}</title></head>\n  <body></body>\n</html>")
    end
  end
end
