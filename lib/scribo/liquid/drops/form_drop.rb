# frozen_string_literal: true

class FormDrop < Liquid::Drop
  def initialize(model, attribute = nil)
    @model = model
    @attribute = attribute
  end

  attr_reader :model, :attribute

  def class_name
    model.class.name.gsub(/Drop$/, '')
  end

  def errors
    ActiveModel::ErrorsDrop.new @model.instance_variable_get('@object').errors
  end
end
