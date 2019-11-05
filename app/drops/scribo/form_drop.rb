# frozen_string_literal: true

class FormDrop < Liquid::Drop
  def initialize(model, attribute = nil)
    @model     = model
    @attribute = attribute
  end

  attr_reader :model, :attribute

  def class_name
    model.class.name.gsub(/Drop$/, '')
  end

  def errors
    errors = if @model&.instance_variable_get('@object')
               @model.instance_variable_get('@object').errors
             else
               ActiveModel::Errors.new([])
             end

    ActiveModel::ErrorsDrop.new errors
  end
end
