# frozen_string_literal: true

require_dependency "scribo/application_record"

module Scribo
  class Site < ApplicationRecord
    belongs_to :scribable, polymorphic: true

    has_many :contents, foreign_key: 'scribo_site_id'
  end

end
