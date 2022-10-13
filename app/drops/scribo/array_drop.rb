# frozen_string_literal: true

require_dependency 'scribo/application_drop'

module Scribo
  class ArrayDrop < ApplicationDrop
    delegate :each, :map, :size, :length, :first, :last, :empty?, :join, to: :@object

    def ==(other)
      @object.include?(other) || @object == other
    end
  end
end
