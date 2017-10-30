# frozen_string_literal: true

module Scribo
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def to_liquid
      Kernel.const_get("#{self.class.name}Drop").new(self)
    end
  end
end
