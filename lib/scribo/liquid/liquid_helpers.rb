# frozen_string_literal: true

module Scribo
  module LiquidHelpers

    private

    def initialize(tag, args, tokens)
      @args = Liquid::Tag::Parser.new(args).args
      super
    end

    def render(context)
      @context = context
    end

    def render_body
      @body.render(@context)
    end

    # Return named argument
    def arg(name)
      raise "No @context set" unless @context

      attr = @args.find { |a| a[:attr] == name.to_s }
      return unless attr

      if attr.key? :value
        attr[:value].to_s
      elsif attr.key? :lvalue
        lookup(@context, attr[:lvalue].to_s)
      end
    end

    # Returns the first argument - usually reserved for literal or quoted values, not for attribute value pairs
    # When the first attribute is a pair, it will return nil
    def argv1
      raise "No @context set" unless @context

      argv1 = @args[0]
      return unless argv1

      if argv1.key? :quoted
        argv1[:quoted].to_s
      elsif argv1.key? :literal
        lookup(@context, argv1[:literal].to_s) || argv1[:literal]
      end
    end

    # Returns the standalone arguments
    def sargs
      raise "No @context set" unless @context

      @args.slice(1..-1).select { |a| a.key?(:quoted) || a.key?(:literal) }.map do |a|
        if a.key? :quoted
          a[:quoted].to_s
        elsif a.key? :literal
          lookup(@context, a[:literal].to_s) || a[:literal]
        end
      end
    end

    # Returns the attribute-value-pair arguments as a hash
    def attr_args
      raise "No @context set" unless @context

      result = {}
      @args.select { |a| a.key?(:value) || a.key?(:lvalue) }.map do |a|
        if a.key? :value
          result[a[:attr].to_sym] = a[:value].to_s
        elsif a.key? :lvalue
          result[a[:attr].to_sym] = lookup(@context, a[:lvalue].to_s) || a[:lvalue]
        end
      end
      result
    end

    # Returns an attribute string if the attribute has a value, for use in making HTML
    #
    # @param [Symbol] attr
    # @param [Object] value
    # @param [Object] default
    # @return [String]
    def attr_str(attr, value, default = nil)
      v = value || default
      v.present? ? " #{attr}=\"#{v}\"" : ""
    end

    def attrs_str(*attrs)
      result = []
      attrs.each do |attr|
        result << attr_str(attr, arg(attr))
      end
      result.join
    end

    # Lookup allows access to the assigned variables through the tag context or returns name itself
    def lookup(context, name)
      return unless name

      context[name]
    end

    # For use with forms and inputs
    def input(purpose, name)

      form_model = lookup(@context, 'form.model')
      form_class_name = lookup(@context, 'form.class_name')

      parts = @context.scopes.select { |scope| scope.key? 'form' }.map do |scope|
        scope['form'].attribute ? "#{scope['form'].attribute}_attributes" : scope['form'].class_name.underscore
      end
      parts = parts.unshift(argv1.to_s).reverse

      return unless form_model && form_class_name && name

      case purpose
      when :id
        parts.join('_')
      when :value
        # This is executed on the drop, drops provide the values for the form
        form_model.send(name.to_sym)
      when :name
        # The original class's name dictates the name of the fields
        parts.first + "[" + parts.slice(1..-1).join("][") + "]"

      when :checked
        'checked' if (input(:value, name) ? 1 : 0) == 1
      end
    end
  end
end
