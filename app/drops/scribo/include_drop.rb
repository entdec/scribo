# frozen_string_literal: true

module Scribo
  class IncludeDrop < Liquid::Drop
    def initialize(attributes)
      @attributes = attributes
    end

    def liquid_method_missing(method)
      @attributes[method.to_s]
    end
  end
end
