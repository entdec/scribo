# frozen_string_literal: true

# Add a search-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%search_field name:"name" value:"1"%}
#
# == Advanced usage:
#    {%search_field name%}
#
# This last usage requires a model on the form
#

require_relative './text_field_tag'

class SearchFieldTag < TextFieldTag
  def initialize(tag, args, tokens)
    super
    @field_type = 'search'
  end
end

Liquid::Template.register_tag('search_field', SearchFieldTag)
