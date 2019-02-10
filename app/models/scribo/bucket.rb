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

    def self.owned
      objects = Scribo.config.scribable_objects
      where(scribable: objects)
    end

    def self.owned_by(owner)
      where(scribable: owner)
    end

    def self.named(name)
      where(name: name)
    end

    def self.purposed(purpose)
      where(purpose: purpose)
    end
  end
end
