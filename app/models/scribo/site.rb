# frozen_string_literal: true

require_dependency 'scribo/application_record'

module Scribo
  class Site < ApplicationRecord
    belongs_to :scribable, polymorphic: true

    has_many :contents, class_name: 'Content', foreign_key: 'scribo_site_id'

    def self.named(name)
      where(name: name)
    end
  end
end
