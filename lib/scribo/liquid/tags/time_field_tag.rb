# frozen_string_literal: true

# Add a time-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%time_field name:"name" value:"1"%}
#
# == Advanced usage:
#    {%time_field name%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class TimeFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'time'
  end
end

Liquid::Template.register_tag('time_field', TimeFieldTag)
