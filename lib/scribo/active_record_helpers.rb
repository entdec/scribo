# frozen_string_literal: true

module ActiveRecordHelpers
  extend ActiveSupport::Concern

  class_methods do
    def scribable(options = {})
      has_many :sites, as: :scribable, class_name: 'Scribo::Site'
    end
  end
end
