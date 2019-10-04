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

    after_save :set_full_path
    after_move :set_full_path

    state_machine initial: :draft do
      state :draft
      state :published
      state :reviewed
      state :hidden

      event :publish do
        transition to: :published
      end
      event :review do
        transition to: :reviewed
      end
      event :hide do
        transition to: :hidden
      end
    end

    scope :layouts, -> { where("full_path LIKE '/_layouts/%'") }

    def self.layout(name)
      possibles = ["/_layouts/#{name}.html", "/_layouts/#{name}.md"]
      published.where(full_path: possibles)
    end

    def self.data(name)
      possibles = ["/_data/#{name}.yml", "/_data/#{name}.yaml", "/_data/#{name}.json", "/_data/#{name}.csv", "/_data/#{name}"]
      published.where(full_path: possibles)
    end

    def self.locale(name)
      published.where(full_path: "/_locales/#{name}.yml")
    end

    def self.located(path, allow_non_public = false)
      return none unless path.present?
      return none if !allow_non_public && File.basename(path).start_with?('_')

      published.where(full_path: path == '/' ? %w[/index.html /index.link] : path)
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

    def self.published
      where(state: 'published').where('published_at IS NULL OR published_at <= :now', now: Time.current.utc)
    end

    def layout?
      full_path.start_with?('/_layouts/')
    end

    def identifier
      # TODO: Remove this
      if Scribo::Content.columns.map(&:name).include?('identifier')
        attributes['identifier']
      else
        File.basename(path, File.extname(path)).gsub('_', '')
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
        data
      when 'text', 'redirect'
        Liquor.render(data, assigns: assigns.merge('content' => self), registers: registers.merge('content' => self), filter: filter, layout: layout&.data)
      end
    end

    def data_with_frontmatter
      YAML.dump(properties) + "---\n" + data
    end

    def data_with_frontmatter=(data)
      data_with_metadata = Scribo::Preamble.parse(data)
      self.properties = data_with_metadata.metadata
      self.data = data_with_metadata.content
    end

    def content_type
      mime_type&.content_type || 'application/octet-stream'
    end

    def media_type
      mime_type&.media_type
    end

    def mime_type
      file_name = path.split('/').last.to_s
      file_name.split('.').lazy.map { |part| MIME::Types.type_for(part).first }.detect(&:itself)
    end

    def self.redirect_options(redirect_data)
      options = redirect_data.split
      if options.length == 2
        options[0] = options[0].to_i
      else
        options.unshift 302
      end
      options
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

    private

    def layout_cant_be_current_content
      errors.add(:layout_id, "can't be current content") if layout_id == id && id.present?
    end
  end
end
