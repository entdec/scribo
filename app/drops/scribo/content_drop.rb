# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class ContentDrop < ApplicationDrop
    delegate :name, :path, :content_type, :title, :breadcrumb, :keywords, :description, to: :@object
    # Boxture specific
    delegate :bucket, to: :@object

    def children
      @object.children.to_a
    end
  end
end
