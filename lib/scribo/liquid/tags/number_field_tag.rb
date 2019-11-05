# frozen_string_literal: true

# Add a number-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%number_field name:"name" value:"1"%}
#
# == Advanced usage:
#    {%number_field name%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class NumberFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'number'
  end
end

Liquid::Template.register_tag('number_field', NumberFieldTag)
