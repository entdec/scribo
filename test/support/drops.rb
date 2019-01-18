# frozen_string_literal: true

class DummyObjectDrop < Liquid::Drop
  delegate :dummy_attr, to: :@object

  def initialize(object)
    @object = object
  end
end

class DummyObject
  attr_accessor :dummy_attr

  def initialize(da)
    @dummy_attr = da
  end

  def to_liquid
    DummyObjectDrop.new(self)
  end
end
