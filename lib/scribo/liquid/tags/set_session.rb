# frozen_string_literal: true

# Sets the value in the session
#
# {%set_session name value%}
# {%set_session locale 'nl'%}
# {%set_session locale request.query_parameters['lang']%}
# {%set_session locale request.query_parameters['lang']%}
# {%set_session coupon_code 'beyou'%}
class SetSessionTag < ScriboTag
  def render(context)
    value = lookup(context, @argv.first, true)
    context.registers['controller'].session[@argv1] = value
    nil
  end
end

Liquid::Template.register_tag('set_session', SetSessionTag)