# frozen_string_literal: true

module Scribo
  module Utility
    module_function

    def kind_for_content_type(content_type)
      MIME::Types.type_for(content_type).any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
    end

    def kind_for_path(path)
      known_text = %w[scss sass less slim es6 babel jsx]
      if known_text.include?(File.extname(path)[1..-1].to_s)
        'text'
      else
        MIME::Types.type_for(path).any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
      end
    end

    def filter_for_path(path)
      case File.extname(path.to_s)[1..-1].to_s
      when 'scss'
        'scss'
      when 'sass'
        'sass'
      when 'md', 'markdown', 'mkd'
        'markdown'
      when 'slim'
        'slim'
      when 'es6', 'babel', 'jsx', 'js'
        'babel'
      end
    end

    def variations_for_path(path)
      result = []
      MIME::Types.type_for(path).each do |mime_type|
        result += mime_type.extensions if mime_type.extensions
        additional_extensions = case mime_type.content_type
                                when 'text/css'
                                  %w[scss sass]
                                when 'text/html'
                                  %w[md markdown mkd slim]
                                when 'application/javascript'
                                  %w[es6 babel jsx js]
                                end
        result += additional_extensions if additional_extensions.present?
      end
      result += [File.extname(path).gsub(/^\./, '')]
      dir = File.dirname(path)
      ext = File.extname(path)
      base = File.basename(path, ext)
      variations = result.compact.uniq.map do |e|
        (dir.end_with?('/') ? dir : dir + '/') + base + '.' + e
      end
      variations + [(dir.end_with?('/') ? dir : dir + '/') + base]
    end

    def output_content_type(content)
      case File.extname(content.path)[1..-1].to_s
      when 'scss', 'sass'
        'text/css'
      when 'md', 'markdown', 'mkd'
        'text/html'
      when 'slim'
        'text/html'
      when 'es6', 'babel', 'jsx', 'js'
        'application/javascript'
      else
        content.content_type
      end
    end
  end
end
