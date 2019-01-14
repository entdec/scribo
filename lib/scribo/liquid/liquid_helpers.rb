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
      super
    end

    def attr_str(attr, value, default = nil)
      v = value || default
      v.present? ? " #{attr}=\"#{v}\"" : ""
    end
  end
end
