# frozen_string_literal: true

module ActiveRecordHelpers
  extend ActiveSupport::Concern

  class_methods do
    def scribable
      has_many :buckets, as: :scribable, class_name: 'Scribo::Bucket'
    end
  end
end
