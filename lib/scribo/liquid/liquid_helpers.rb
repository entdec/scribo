# frozen_string_literal: true

module Scribo
  module LiquidHelpers

    private

    def initialize(tag, args, tokens)
      @args = Liquid::Tag::Parser.new(args).args
      @raw_args = args
      @tag = tag.to_sym
      @tokens = tokens
      @argv = @args.select{|_k,v|v.nil?}.keys.map(&:to_s)
      @argv1 = @args[:argv1]
      Scribo.config.logger.info "@args: #{@args}"
      Scribo.config.logger.info "@raw_args: #{@raw_args}"
      Scribo.config.logger.info "@tag: #{@tag}"
      Scribo.config.logger.info "@tokens: #{@tokens}"
      Scribo.config.logger.info "@argv: #{@argv}"
      Scribo.config.logger.info "@argv1: #{@argv1}"
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
    def attribute(context, attr, value, default = nil)
      v = lookup(context, value) || default
      v.present? ? " #{attr}=\"#{v}\"" : ""
    end

    def attributes(context, *attrs)
      result = []
      attrs.each do |attr|
        result << attribute(context, attr, @args[attr])
      end
      result.join
    end

    # Lookup allows access to the assigned variables through the tag context or returns name itself
    def lookup(context, name, allow_name_itself = false)
      return unless name

      context[name] || (allow_name_itself && name)
    end
  end
end
