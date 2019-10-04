# frozen_string_literal: true

module Scribo
  module Utility
    extend self
    def kind_for_content_type(content_type)
      MIME::Types.type_for(content_type).any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
    end

    def filter_for_path(path)
      case File.extname(path)
      when '.scss', '.sass'
        'sass'
      when '.md', '.markdown', '.mkd'
        'markdown'
      when '.slim'
        'slim'
      when '.es6', '.babel', '.jsx', '.js'
        'babel'
      end
    end

    def output_content_type(content)
      case File.extname(content.path)
      when '.scss', '.sass'
        'text/css'
      when '.md', '.markdown', '.mkd'
        'text/html'
      when '.slim'
        'text/html'
      when '.es6', '.babel', '.jsx', '.js'
        'application/javascript'
      else
        content.content_type
      end
    end
  end
end
