# frozen_string_literal: true

class FormDrop < Liquid::Drop
  def initialize(model)
    @model = model
  end

  attr_reader :model

  def class_name
    model.class.name.gsub(/Drop$/, '')
  end
end
