# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class SiteDrop < ApplicationDrop
    delegate :name, to: :@object
    delegate :scribable, :contents, to: :@object

    def children
      @object.children.to_a
    end

    def data
      Scribo::DataDrop.new(@object)
    end
  end
end
