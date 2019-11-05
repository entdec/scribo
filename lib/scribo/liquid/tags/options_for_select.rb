# frozen_string_literal: true

# Add a text-field, either specifying everything manually or using a model object on the form
#
# == Basic usage:
#    {%assign airports = "Eindhoven, Schiphol" | split: ', '%}
#    {%options_for_select airports%}
#
# == Advanced usage:
#    {%assign airports = "Eindhoven, Schiphol" | split: ', '%}
#    {%options_for_select airports selected:"Schiphol" disabled:"Eindhoven"%}
#
# == Advanced usage:
#    {%options_for_select airports name value selected:"Schiphol" disabled:"Eindhoven"%}
#
# This last usage requires a model on the form
#
class OptionsForSelectTag < LiquorTag
  def render(context)
    super

    options = argv1.map(&:to_liquid)

    if sargs.present?
      options = options.map do |option|
        result = sargs.map {|a| option[a.to_s] }
        result = result.first if result.length == 1
        result
      end
    end

    context.registers['controller'].helpers.options_for_select(options, attr_args).to_s
  end
end

Liquid::Template.register_tag('options_for_select', OptionsForSelectTag)
