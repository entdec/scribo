# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    include AASM
    acts_as_tree

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    belongs_to :layout, class_name: 'Content'

    before_save :nilify_blanks
    validate :layout_cant_be_current_content

    aasm column: :state do
      state :draft, initial: true
      state :published
      state :reviewed
      state :hidden

      event :publish do
        transitions to: :published
      end
      event :review do
        transitions to: :reviewed
      end
      event :hide do
        transitions to: :hidden
      end
    end

    def self.located(path)
      published.where(path: path)
    end

    # Could be used to locate 'child' content like /articles/article1, where /articles is the
    # index page of all articles and /article1 is the first article
    def self.recursive_located(path)
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

    def self.identified(identifier)
      published.where(identifier: identifier)
    end

    # Named content, only non-child content
    def self.named(name)
      published.where(parent_id: nil).where(name: name)
    end

    def self.published
      where(state: 'published').where('published_at IS NULL OR published_at <= :now', now: Time.current.utc)
    end

    def render(assigns = {}, registers = {})
      case kind
      when 'asset'
        data
      when 'text', 'redirect'
        render_with_liquid(self, assigns.merge('content' => self), registers.merge('content' => self))
      end
    end

    def render_with_liquid(content, assigns, registers)
      template = Liquid::Template.parse(content.data)
      result   = template.render(assigns, registers: registers)

      assigns   = template.assigns.stringify_keys
      registers = template.registers.stringify_keys

      result    = Tilt[content.filter].new { result }.render if content.filter.present?
      if content.layout
        registers['_yield']     = {} unless registers['_yield']
        registers['_yield'][''] = result.delete("\n")
        result                  = render_with_liquid(content.layout, assigns, registers)
      end
      result
    end

    def content_type_group
      Scribo.supported_mime_types.find { |_, v| v.include?(content_type) }.first.to_s
    end

    # Use this in ContentDrop
    def deep_path
      self_and_ancestors.reverse.map(&:path).join
    end

    def self.content_type_supported?(content_type)
      Scribo.supported_mime_types.values.flatten.include?(content_type)
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

    private

    def nilify_blanks
      self.class.columns.map(&:name).each do |c|
        send(c + '=', nil) if send(c).respond_to?(:blank?) && send(c).blank?
      end
    end

    def layout_cant_be_current_content
      errors.add(:layout_id, "can't be current content") if layout_id == id
    end
  end
end
