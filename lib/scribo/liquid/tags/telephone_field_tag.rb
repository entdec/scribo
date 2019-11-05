# frozen_string_literal: true

# Add a telephone-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%telephone_field name:"phone" value:"1"%}
#
# == Advanced usage:
#    {%telephone_field phone%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class TelephoneFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'tel'
  end
end

Liquid::Template.register_tag('telephone_field', TelephoneFieldTag)
