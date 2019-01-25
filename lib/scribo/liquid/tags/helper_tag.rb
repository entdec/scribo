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
    super

    helper_args = sargs
    helper_args = helper_args.concat([attr_args]) if attr_args.present?

    if respond_to?(argv1.to_sym)
      send(argv1.to_sym, *helper_args)
    else
      context.registers['controller'].helpers.send(argv1.to_sym, *helper_args)
    end
  end
end

Liquid::Template.register_tag('helper', HelperTag)
