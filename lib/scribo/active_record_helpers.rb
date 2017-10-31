# frozen_string_literal: true

module ActiveRecordHelpers
  extend ActiveSupport::Concern

  class_methods do
    def scribable(options = {})
      configuration = {
        name:         :sites
      }

      configuration.update(options) if options.is_a?(Hash)

      has_many configuration[:name], as: :scribable, class_name: 'Scribo::Site'
    end
  end
end
