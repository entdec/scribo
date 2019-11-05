# frozen_string_literal: true

# Exposes additional model objects, similar to form, but it doesn't create a form-tag.
#
# == Basic usage:
#    {%fields_for location%}
#      {%text_field city%}
#    {%endform%}
#
# It will automatically build the association if need be. For polymorphic it needs a hint:
#    {%fields_for scribable Domain%}
#      {%text_field city%}
#    {%endform%}
#
# == Available variables:
#
# form.model:: model specified
# form.class_name:: class name of the model specified (original name, not the drop)
# form.errors:: errors of the exposed object
#
require_relative '../drops/form_drop'

class FieldsForTag < LiquorBlock
  def render(context)
    super

    result = ''

    context.stack do
      context['form'] = FormDrop.new(new_model, argv1)
      result += render_body

      if context['form.model.id']
        result += %[<input] +
                  attr_str(:id, arg(:id), input(:id, 'id')) +
                  attr_str(:name, arg(:name), input(:name, 'id')) +
                  attr_str(:value, arg(:value), input(:value, 'id')) +
                  %[type="hidden"/>]
      end
    end

    result
  end

  private

  def new_model
    new_model = @context["form.model.#{argv1}"] rescue nil
    unless new_model

      association_name = if argv1.match(/([^\[\]])+/)
                           Regexp.last_match(0)
                         end

      new_model = begin
        reflection = real_object_from_drop(@context['form.model']).class.reflect_on_association(association_name)
        if reflection.polymorphic?
          # If it's polymorphic we need hints on what to do
          sargs.first.to_s.safe_constantize.new(attr_args)
        elsif reflection.is_a?(ActiveRecord::Reflection::HasManyReflection) && reflection.constructable?
          # Do model.association.new
          real_object_from_drop(@context['form.model']).send(association_name.to_sym).new(attr_args)
        elsif reflection.is_a?(ActiveRecord::Reflection::BelongsToReflection) && reflection.constructable?
          # Do model.build_association
          real_object_from_drop(@context['form.model']).send("build_#{association_name}".to_sym, attr_args)
        else
          # Just call new on the class
          reflection.klass.new(attr_args)
        end
      rescue ArgumentError
        nil
      end

      new_model
    end
    new_model
  end
end

Liquid::Template.register_tag('fields_for', FieldsForTag)
