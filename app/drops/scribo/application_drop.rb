# frozen_string_literal: true

module Scribo
  class ApplicationDrop < Liquid::Drop
    def initialize(object)
      @object = object
    end
  end
end
