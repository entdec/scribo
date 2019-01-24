# frozen_string_literal: true

class DummyObjectDrop < Liquid::Drop
  delegate :dummy_attr, to: :@object

  def initialize(object)
    @object = object
  end
end

class DummyObject
  attr_accessor :dummy_attr

  def initialize(dummy_attr)
    @dummy_attr = dummy_attr
  end

  def to_liquid
    DummyObjectDrop.new(self)
  end
end
