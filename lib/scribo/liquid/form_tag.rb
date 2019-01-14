class FormTag < Liquid::Block
  Syntax = /\s*([^\s]+)\s*/

  def initialize(tag, args, tokens)
    @args = Liquid::Tag::Parser.new(args).args
    @raw_args = args
    @tag = tag.to_sym
    @tokens = tokens
    super
  end

  def render(context)
    obj = context.find_variable(@args[:argv1])
    result = %[<form#{attr_str(:url, @args[:url])}>]
    context.stack do
      context['form_model'] = obj
      result += super
    end
    result += "</form>"
    result
  end

  private

  def attr_str(attr, value)
    value.present? ? " #{attr}=\"#{value}\"" : ""
  end
end

Liquid::Template.register_tag('form', FormTag)
