# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  # Represents any content in the system
  class Asset < ApplicationRecord
    belongs_to :bucket, class_name: 'Bucket', foreign_key: 'scribo_bucket_id'

    before_save :nilify_blanks

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

    def self.identified(identifier)
      return none unless identifier.present?

      published.where(identifier: identifier)
    end

    # Named content, only non-child content
    def self.named(name)
      return none unless name.present?

      published.where(parent_id: nil).where(name: name)
    end

    def self.published
      where(state: 'published').where('published_at IS NULL OR published_at <= :now', now: Time.current.utc)
    end

    def self.content_group(group)
      where(content_type: Scribo.config.supported_mime_types[group])
    end

    # Returns the group of a certain content_type (text/plain => text, image/gif => image)
    def content_type_group
      Scribo.config.supported_mime_types.find { |_, v| v.include?(content_type) }&.first&.to_s
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

    def cache_key
      super + '-' + I18n.locale.to_s
    end

    private

    def nilify_blanks
      self.path = nil if path.blank?
      self.name = nil if name.blank?
      self.identifier = nil if identifier.blank?
    end
  end
end
