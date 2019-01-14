# frozen_string_literal: true

# Sets the value in the session
#
# {%set_session name value%}
# {%set_session locale 'nl'%}
# {%set_session locale request.query_parameters['lang']%}
# {%set_session locale request.query_parameters['lang']%}
# {%set_session coupon_code 'beyou'%}
class SetSessionTag < Liquid::Tag
  SYNTAX = /(?<name>([a-z_]+))\s(?<value>(.+))/

  def initialize(tag_name, markup, options)
    super

    if markup =~ SYNTAX
      @name = Regexp.last_match[:name]
      @value = Regexp.last_match[:value]
    else
      raise SyntaxError, "Syntax Error in 'set_session' - Valid syntax: set_session name value"
    end
  end

  def render(context)
    value = Liquid::VariableLookup.parse(@value).evaluate(context)
    context.registers['controller'].session[@name] = value
    nil
  end
end

Liquid::Template.register_tag('set_session', SetSessionTag)
