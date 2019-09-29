# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    acts_as_nested_set

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    belongs_to :layout, class_name: 'Content', optional: true

    before_save :nilify_blanks
    validate :layout_cant_be_current_content

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

    def self.located(path)
      return none unless path.present?
      published.where(path: path)
    end

    # Could be used to locate 'child' content like /articles/article1, where /articles is the
    # index page of all articles and /article1 is the first article
    def self.recursive_located(path)
      return none unless path.present?

      sql = <<-SQL
      WITH RECURSIVE recursive_contents(id, cpath) AS (
        SELECT id, ARRAY[path]
        FROM scribo_contents
        WHERE parent_id IS NULL
        UNION ALL
        SELECT scribo_contents.id, cpath || scribo_contents.path
        FROM recursive_contents
          JOIN scribo_contents ON scribo_contents.parent_id=recursive_contents.id
        WHERE NOT scribo_contents.path = ANY(cpath)
      )
      SELECT id FROM recursive_contents WHERE ARRAY_TO_STRING(cpath, '') = '#{path}'
      SQL
      published.where("id IN (#{sql})")
    end

    def self.identified(identifier = nil)
      if identifier.present?
        path = File.dirname(identifier).gsub(/^\./, '') + '/_' + File.basename(identifier)
        published.where(path: path)
      else
        published.where("path LIKE '%/_%'")
      end
    end

    def self.published
      where(state: 'published').where('published_at IS NULL OR published_at <= :now', now: Time.current.utc)
    end

    def self.content_group(group)
      where(content_type: Scribo.config.supported_mime_types[group])
    end

    def identifier
      File.basename(path).gsub('_', '')
    end

    def render(assigns = {}, registers = {})
      case kind
      when 'asset'
        data
      when 'text', 'redirect'
        Liquor.render(data, assigns: assigns.merge('content' => self), registers: registers.merge('content' => self), filter: filter, layout: layout&.data)
      end
    end

    # Returns the group of a certain content_type (text/plain => text, image/gif => image)
    def content_type_group
      Scribo.config.supported_mime_types.find { |_, v| v.include?(content_type) }&.first&.to_s
    end

    # Use this in ContentDrop
    def deep_path
      self_and_ancestors.reverse.map(&:path).join
    end

    # Is the content_type in the supported list?
    def self.content_type_supported?(content_type)
      Scribo.config.supported_mime_types.values.flatten.include?(content_type)
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

    def to_data_url
      "data:#{content_type};base64," + Base64.strict_encode64(data)
    end

    def translation_scope
      scope = []
      scope << 'scribo'
      scope << site.name.underscore.tr(' ', '_')
      if name.present?
        scope << "named"
        scope << name
      elsif identifier.present?
        scope << "identified"
        scope << identifier
      else
        p = path.tr('/', '.')[1..-1]
        scope << (p.present? ? p : 'index')
      end
      scope.join('.')
    end

    def cache_key
      super + '-' + I18n.locale.to_s
    end

    def text_based?
      %w[text style script].include? content_type_group
    end

    def self.text_based?(ct)
      %w[text style script].include? content_type_group(ct)
    end

    # Returns the group of a certain content_type (text/plain => text, image/gif => image)
    def self.content_type_group(ct)
      Scribo.config.supported_mime_types.find { |_, v| v.include?(ct) }&.first&.to_s
    end

    private

    def nilify_blanks
      self.path = nil if path.blank?
      # self.name = nil if name.blank?
      # self.identifier = nil if identifier.blank?
    end

    def layout_cant_be_current_content
      errors.add(:layout_id, "can't be current content") if layout_id == id && id.present?
    end
  end
end
