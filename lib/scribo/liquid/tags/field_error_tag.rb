# frozen_string_literal: true

# Add errors for a specific form field, only works inside a form
#
# == Basic usage:
#    {%field_error name%}
#
class FieldErrorTag < LiquorTag
  attr_accessor :field_type

  def render(context)
    super

    error_messages = lookup(context, "form.errors.messages.#{argv1}")

    if error_messages.present?
      result = %[<span>] +
               attr_str(:class, arg(:class), input(:class, argv1)) +
               (error_messages || []).join(', ') + %[</span>]
    end

    result
  end
end

Liquid::Template.register_tag('field_error', FieldErrorTag)
