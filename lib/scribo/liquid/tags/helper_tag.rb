# frozen_string_literal: true

# Allow you to use helpers
#
# == Basic usage:
#    {%helper 'user_index_path'%}
#
# == Advanced usage:
#    {%helper 'user_index_path' user%}
#

class HelperTag < ScriboTag
  include Rails.application.routes.url_helpers

  def render(context)
    vars = @argv.map do |v|
      lookup(context, v, true)
    end
    attrs = {}
    @attrs.each{ |key,v| attrs[key] = lookup(context, v, true) }

    vars = vars.push(attrs) if @attrs.present?
    if respond_to?(@argv1.to_sym)
      send(@argv1.to_sym, *vars)
    else
      context.registers['controller'].helpers.send(@argv1.to_sym, *vars)
    end
  end
end

Liquid::Template.register_tag('helper', HelperTag)
