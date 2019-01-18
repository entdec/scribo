# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class BucketDrop < ApplicationDrop
    delegate :name, to: :@object
    # Boxture specific
    delegate :scribable, :contents, to: :@object

    def children
      @object.children.to_a
    end
  end
end
