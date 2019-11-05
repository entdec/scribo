# frozen_string_literal: true

# Add a url-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%url_field name:"homepage" value:"1"%}
#
# == Advanced usage:
#    {%url_field homepage%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class UrlFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'url'
  end
end

Liquid::Template.register_tag('url_field', UrlFieldTag)
