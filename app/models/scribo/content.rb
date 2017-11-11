# frozen_string_literal: true

require_dependency 'scribo/application_record'

require 'liquid'

module Scribo
  # Represents any content in the system
  class Content < ApplicationRecord
    acts_as_tree

    belongs_to :site, class_name: 'Site', foreign_key: 'scribo_site_id'
    belongs_to :layout, class_name: 'Content'

    before_save :nilify_blanks

    # TODO: Validate that layout_id is not the same as id
    SUPPORTED_MIME_TYPES = {
      image:    %w[image/gif image/png image/jpeg image/bmp image/webp],
      text:     %w[text/plain text/html text/css text/javascript application/javascript application/json application/xml],
      audio:    %w[audio/midi audio/mpeg audio/webm audio/ogg audio/wav],
      video:    %w[video/webm video/ogg video/mp4],
      document: %w[application/msword application/vnd.ms-powerpoint application/vnd.ms-excel application/pdf application/zip],
      font:     %w[font/collection font/otf font/sfnt font/ttf font/woff font/woff2],
      other:    %w[application/octet-stream]
    }.freeze

    state_machine initial: :draft do
      event :publish do
        transition any => :published
      end

      event :review do
        transition any => :reviewed
      end

      event :hide do
        transition any => :hidden
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

    def render(context = {})
      case kind
      when 'asset'
        data
      when 'text'
        # TODO: Switch _yield to registers:
        # https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers#difference-between-assigns-and-registers
        render_with_liquid(self, context.merge('_yield' => { '' => '' }, 'content' => self))
      end
    end

    def render_with_liquid(content, context)
      # result  = Tilt['liquid'].new { content.data }.render(context) - This doesn't work, 'content' overwritten by tilt :(
      result  = Liquid::Template.parse(content.data).render(context)
      result  = Tilt[content.filter].new { result }.render if content.filter.present?
      context = context.stringify_keys
      if content.layout
        context['_yield'][''] = result
        result                = render_with_liquid(content.layout, context)
      end
      result
    end

    def content_type_group
      Content::SUPPORTED_MIME_TYPES.find { |_, v| v.include?(content_type) }.first.to_s
    end

    # Use this in ContentDrop
    def deep_path
      self_and_ancestors.reverse.map(&:path).join
    end

    def self.content_type_supported?(content_type)
      Content::SUPPORTED_MIME_TYPES.values.flatten.include?(content_type)
    end

    def redirect_options
      options = data.split
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
  end
end
