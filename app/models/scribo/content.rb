# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    acts_as_nested_set

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    has_one_attached :asset

    validate :layout_cant_be_current_content

    before_save :upload_asset
    after_save :set_full_path
    after_move :set_full_path

    scope :layouts, -> { where("full_path LIKE '/_layouts/%'") }
    scope :posts, -> { where("full_path LIKE '/_posts/%'") }
    scope :include, ->(name) { published.where(full_path: ["/_includes/#{name}"]) }
    scope :layout, ->(name) { published.where(full_path: ["/_layouts/#{name}.html", "/_layouts/#{name}.md", "/_layouts/#{name}.xml", "/_layouts/#{name}.css"]) }
    scope :data, ->(name) { published.where(full_path: ["/_data/#{name}.yml", "/_data/#{name}.yaml", "/_data/#{name}.json", "/_data/#{name}.csv", "/_data/#{name}"]) }
    scope :locale, ->(name) { published.where(full_path: "/_locales/#{name}.yml") }
    scope :published, -> { where("properties->>'published' = 'true' OR properties->>'published' IS NULL").where("properties->>'published_at' IS NULL OR properties->>'published_at' <= :now", now: Time.current.utc) }

    def self.located(*paths, restricted: true)
      restricted = true if restricted.nil? # If blank it's still restricted
      return none if paths.blank?

      paths = paths.map do |path|
        path = '/' + path unless path.start_with?('/')
        path = '/index.html' if path == '/'

        result = File.extname(path).present? ? Scribo::Utility.variations_for_path(path) : [path]
        result.unshift(Scribo::Utility.switch_extension(path, 'link'))
        result
      end

      result = published.where(full_path: paths.flatten)
      result = result.where("full_path NOT LIKE '%/\\_%'") if restricted
      result
    end

    def layout
      return nil unless properties&.[]('layout')

      site.contents.layout(properties['layout']).first
    end

    def layout?
      full_path.start_with?('/_layouts/')
    end

    def identifier
      # TODO: Remove this
      if Scribo::Content.columns.map(&:name).include?('identifier')
        attributes['identifier']
      else
        File.basename(path, File.extname(path))
      end
    end

    def data_with_frontmatter
      return data if kind != 'text'

      result = ''
      result += (YAML.dump(properties) + "---\n") if properties.present?

      result + data.to_s
    end

    def data_with_frontmatter=(text)
      if kind == 'text'
        data_with_metadata = Scribo::Preamble.parse(text)
        self.properties = data_with_metadata.metadata
        self.data = data_with_metadata.content
      else
        self.data = text
      end
    end

    def date
      prop_date = begin
                    Time.zone.parse(properties['date'])
                  rescue StandardError
                    nil
                  end
      prop_date || (post? ? post_date : nil) || created_at
    end

    def post?
      full_path.start_with?('/_posts/')
    end

    def post_date
      Time.zone.parse(path[0, 10], '%Y-%m-%d')
    end

    def data
      return attributes['data'] if kind == 'asset'

      attributes['data']&.force_encoding('utf-8')
    end

    def excerpt
      Scribo::ContentRenderService.new(self, {}, data: data.gsub("\r\n", "\n\n").split("\n\n").reject(&:empty?).first, layout: false).call
    end

    def categories
      (properties&.[]('categories') || '').split(' ')
    end

    def tags
      (properties&.[]('tags') || '').split(' ')
    end

    def content_type
      mime_type&.content_type || 'application/octet-stream'
    end

    def media_type
      mime_type&.media_type
    end

    def extension
      mime_type&.extensions&.first
    end

    def mime_type
      MIME::Types.type_for(path).first
    end

    def translation_scope
      scope = []

      p = full_path.tr('/', '.')[1..-1]
      scope << (p.present? ? p : 'index')

      scope.join('.')
    end

    def cache_key
      super + '-' + I18n.locale.to_s
    end

    def set_full_path
      return unless respond_to?(:full_path_changed?)

      result = (ancestors.map(&:path) << path).join('/')
      result = '/' + result unless result.start_with?('/')

      update_column(:full_path, result)

      children.each(&:set_full_path)
    end

    def upload_asset
      return unless asset?
      # return unless data.present? -> Breaks with utf8?
      return unless data
      return unless data.size.positive?

      asset.attach(io: StringIO.new.tap { |s| s.write(data) && s.rewind }, filename: path, content_type: content_type)
      self.data = nil
    end

    def asset?
      kind == 'asset'
    end

    private

    def layout_cant_be_current_content
      return unless layout

      errors.add(:base, "layout can't be layout of itself") if layout.full_path == full_path
    end

    class << self
      def redirect_options(redirect_data)
        options = redirect_data.split
        if options.length == 2
          options[0] = options[0].to_i
        else
          options.unshift 302
        end
        options
      end
    end
  end
end
