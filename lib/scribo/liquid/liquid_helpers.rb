# frozen_string_literal: true

module Scribo
  module LiquidHelpers

    private

    def initialize(tag, args, tokens)
      @args = Liquid::Tag::Parser.new(args).args
      @raw_args = args
      @tag = tag.to_sym
      @tokens = tokens
      Scribo.config.logger.info "@args: #{@args}"
      Scribo.config.logger.info "@raw_args: #{@raw_args}"
      Scribo.config.logger.info "@tag: #{@tag}"
      Scribo.config.logger.info "@tokens: #{@tokens}"
      send(:validate) if respond_to?(:validate)
      super
    end

    # Returns an attribute string if the attribute has a value, for use in making HTML
    #
    # @param [Object] context
    # @param [Symbol] attr
    # @param [Object] value
    # @param [Object] default
    # @return [String]
    def attr_str(context, attr, value, default = nil)
      v = lookup(context, value) || default
      v.present? ? " #{attr}=\"#{v}\"" : ""
    end

    # Lookup allows access to the assigned variables through the tag context
    def lookup(context, name)
      return unless name

      lookup = context
      name.split('.').each { |value| lookup = lookup[value] }
      lookup
    end
  end
end
