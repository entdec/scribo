# frozen_string_literal: true

# Add a email-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%email_field name:"email" value:"1"%}
#
# == Advanced usage:
#    {%email_field email%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class EmailFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'email'
  end
end

Liquid::Template.register_tag('email_field', EmailFieldTag)
