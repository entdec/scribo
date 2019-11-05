# frozen_string_literal: true

# Add a date-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%date_field name:"start_date" value:"2019-09-27"%}
#
# == Advanced usage:
#    {%date_field start_date%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class DateFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'date'
  end
end

Liquid::Template.register_tag('date_field', DateFieldTag)
