# frozen_string_literal: true

module Scribo
  module Utility
    extend self
    def kind_for_content_type(content_type)
      MIME::Types.type_for(content_type).any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
    end
  end
end
