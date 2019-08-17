# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class ContentDrop < ApplicationDrop
    delegate :name, :path, :identifier, :content_type, :title, :breadcrumb, :keywords, :description, :properties, to: :@object
    delegate :site, to: :@object

    def children
      @object.children.to_a
    end
  end
end
