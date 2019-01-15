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
  def render(context)
    # Grab the ones without a value
    @variables = @args.select{|_k,v|v.nil?}.keys.map(&:to_s)

    vars = @variables.map do |v|
      lookup(context, v)
    end
    context.registers['controller'].helpers.send(@argv1, *vars)
  end
end

Liquid::Template.register_tag('helper', HelperTag)
