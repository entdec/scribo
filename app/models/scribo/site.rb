# frozen_string_literal: true

require_dependency 'scribo/application_record'
require_dependency 'scribo/liquid/parser'

module Scribo
  class Site < ApplicationRecord
    NEW_SITE_NAME = 'Untitled site'

    belongs_to :scribable, polymorphic: true, optional: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id', dependent: :destroy

    before_validation :store_scribable

    attr_accessor :zip_file

    scope :adminable, -> { where(scribable: Scribo.config.scribable_objects) }
    scope :owned_by, ->(owner) { where(scribable: owner) }
    scope :titled, ->(title) { where("properties->>'title' = ?", title).first }

    def self.for_path(path)
      return none if path.blank?

      # Remove any segment which does not end in /
      path = path[0..-(path.reverse.index('/').to_i + 1)]

      paths = []
      paths.concat(path.split('/').map.with_index { |_, i| path.split('/')[0..i].join('/') }.reject(&:empty?))
      paths <<= '/'

      where("properties->>'baseurl' IN (?) OR properties->>'baseurl' = '' OR properties->>'baseurl' IS NULL", paths).order(Arel.sql("COALESCE(LENGTH(scribo_sites.properties->>'baseurl'), 0) DESC"))
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

    def reshuffle!
      contents.roots.each(&:set_full_path)
    end

    # See https://jekyllrb.com/docs/permalinks/
    def perma_link
      properties['permalink'] || '/:year/:month/:day/:title:output_ext'
    end

    def collections
      properties['collections'].to_h.keys.map(&:to_s) + %w[posts]
    end

    def output_collection?(collection)
      col = properties['collections'].to_h[collection.to_s]
      col['output'] == true
    end

    def title
      properties['title'] || NEW_SITE_NAME
    end

    def baseurl
      properties['baseurl'] || '/'
    end

    def thumbnail
      properties['thumbnail']
    end

    def url
      properties['url']
    end

    def properties
      attributes['properties'].present? ? attributes['properties'] : { 'title' => NEW_SITE_NAME, 'baseurl' => '/' }
    end

    def sass_dir
      result = properties.value_at_keypath('sass.sass_dir') || '/_sass/'
      result = '/' + result unless result.start_with?('/')

      result
    end

    def defaults_for(content)
      site_defaults = properties&.[]('defaults')
      return {} unless site_defaults
      return {} unless content.full_path

      props = site_defaults.find do |d|
        s = d['scope']
        next unless s

        result = false

        if s['path']
          result = true
          p = s['path']
          unless p.include?('*')
            p = "/#{p}" unless p.start_with?('/')
            p = "#{p}/" unless p.ends_with?('/')
            p += '*'
          end

          result &= File.fnmatch?(p, content.full_path.to_s, File::FNM_EXTGLOB)
        end

        result &= s['type'] == content.type if s['type']

        result
      end

      (props || {}).fetch('values', {})
    end

    #
    # Calculates the total size of the site in bytes, including assets
    #
    # @return [Integer] size in bytes
    #
    def total_size
      contents.map { |c| c.data ? c.data.size : c.asset.attachment&.download&.size || 0 }.sum
    end

    private

    def store_scribable
      return if scribable

      self.scribable = Scribo.config.current_scribable
    end
  end
end
