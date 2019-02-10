# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Bucket < ApplicationRecord
    settable if defined?(settable) # Vario

    belongs_to :scribable, polymorphic: true
    validates :scribable, presence: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_bucket_id'
    has_many :assets, class_name: 'Asset', foreign_key: 'scribo_bucket_id'

    attr_accessor :zip_file

    scope :owned, -> { where(scribable: Scribo.config.scribable_objects) }
    scope :owned_by, ->(owner) { where(scribable: owner) }
    scope :named, ->(name) { where(name: name) }
    scope :purposed, ->(purpose) { where(purpose: purpose) }
  end
end
