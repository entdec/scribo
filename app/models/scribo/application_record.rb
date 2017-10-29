# frozen_string_literal: true

module Scribo
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
