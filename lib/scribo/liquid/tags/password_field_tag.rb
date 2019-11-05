# frozen_string_literal: true

# Add a password-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%password_field name:"name" value:"1"%}
#
# == Advanced usage:
#    {%password_field name%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class PasswordFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'password'
  end
end

Liquid::Template.register_tag('password_field', PasswordFieldTag)
