# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    acts_as_nested_set

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    belongs_to :layout, class_name: 'Content', optional: true
    has_many :layouted, class_name: 'Content', foreign_key: 'layout_id', dependent: :destroy

    validate :layout_cant_be_current_content

    before_save :upload_asset
    after_save :set_full_path
    after_move :set_full_path

    has_one_attached :asset

    scope :layouts, -> { where("full_path LIKE '/_layouts/%'") }
    scope :include, ->(name) { published.where(full_path: ["/_includes/#{name}", "/_includes/#{name}.html", "/_includes/#{name}.md"]) }
    scope :layout, ->(name) { published.where(full_path: ["/_layouts/#{name}.html", "/_layouts/#{name}.md"]) }
    scope :data, ->(name) { published.where(full_path: ["/_data/#{name}.yml", "/_data/#{name}.yaml", "/_data/#{name}.json", "/_data/#{name}.csv", "/_data/#{name}"]) }
    scope :locale, ->(name) { published.where(full_path: "/_locales/#{name}.yml") }
    scope :published, -> { where("properties->>'published' = 'true' OR properties->>'published' IS NULL").where("properties->>'published_at' IS NULL OR properties->>'published_at' <= :now", now: Time.current.utc) }

    def self.located(path, allow_private = false)
      return none if path.blank?
      return none if !allow_private && File.basename(path).start_with?('_')

      path = '/' + path unless path.start_with?('/')

      if path == '/'
        path = '/index.html'
        variations = Scribo::Utility.variations_for_path(path)
        variations.unshift '/index.link'
      else
        variations = Scribo::Utility.variations_for_path(path)
      end
      published.where(full_path: variations)
    end

    def self.identified(identifier = nil)
      if identifier
        path = File.dirname(identifier).gsub(/^\./, '') + '/_' + File.basename(identifier)
        path = '/' + path unless path[0] == '/'

        # Allow to be not so specific with extensions, if it clashes, you need to specify the extension
        published.where('full_path LIKE ?', "#{path}%")
      else
        # For now this makes the extension irrelevant, which is fine
        published.where("full_path LIKE '%_%'")
      end
    end

    def layout?
      full_path.start_with?('/_layouts/')
    end

    def identifier
      # TODO: Remove this
      if Scribo::Content.columns.map(&:name).include?('identifier')
        attributes['identifier']
      else
        File.basename(path, File.extname(path)).gsub('/_', '/')
      end
    end

    def filter
      if Scribo::Content.columns.map(&:name).include?('filter') && attributes['filter']
        attributes['filter']
      else
        Scribo::Utility.filter_for_path(path)
      end
    end

    def render(assigns = {}, registers = {})
      case kind
      when 'asset'
        render_asset
      when 'text', 'redirect'

        total_data = data
        current_layout = layout
        begin
          total_data = Liquor.render(total_data, assigns: assigns, registers: registers.merge('content' => self), filter: filter, layout: current_layout&.data)
          current_layout = current_layout.layout
        end while current_layout
        total_data
      end
    end

    def render_asset
      return unless kind == 'asset'
      return data if data.present?
      return unless asset.attached?

      asset.download
    end

    def data_with_frontmatter
      return data if kind != 'text'

      result = ''
      result += (YAML.dump(properties) + "---\n") if properties.present?

      result + data
    end

    def data_with_frontmatter=(text)
      if kind == 'text'
        data_with_metadata = Scribo::Preamble.parse(text)
        self.properties = data_with_metadata.metadata
        self.data = data_with_metadata.content
      else
        self.data = data
      end
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
      file_name = path.split('/').last.to_s
      file_name.split('.').lazy.map { |part| MIME::Types.type_for(part).first }.detect(&:itself)
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
      errors.add(:layout_id, "can't be current content") if layout_id == id && id.present?
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
