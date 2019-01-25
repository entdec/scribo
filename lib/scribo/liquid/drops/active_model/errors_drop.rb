# frozen_string_literal: true

module Scribo
  class ActiveModel::ErrorsDrop < Liquid::Drop
    def initialize(object)
      @object = object
    end
    delegate :base, :details, :messages, to: :@object
  end
end
