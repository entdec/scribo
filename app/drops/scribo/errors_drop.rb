# frozen_string_literal: true

module Liquor
  class ActiveModel::ErrorsDrop < Liquid::Drop
    def initialize(object)
      @object = object
    end
    delegate :base, :details, to: :@object

    def messages
      @object.messages.stringify_keys
    end
  end
end
