# frozen_string_literal: true

module Scribo
  module Utility
    module_function

    ADDITIONAL_EXTENSIONS = {
      'text/css' => %w[scss sass],
      'text/html' => %w[md markdown mkd slim],
      'application/javascript' => %w[es6 babel jsx js]
    }.freeze

    KNOWN_TEXT_FILES = %w[Gemfile].freeze
    KNOWN_TEXT_EXTENSIONS = %w[scss sass less slim es6 babel jsx json link].freeze

    FILTER_FOR_EXTENSION = {
      'scss' => 'scss',
      'sass' => 'sass',
      'md' => 'markdown',
      'markdown' => 'markdown',
      'mkd' => 'markdown',
      'slim' => 'slim',
      'es6' => 'babel',
      'babel' => 'babel',
      'jsx' => 'babel'
    }.freeze

    OUTPUT_CONTENT_TYPE_FOR_EXTENSION = {
      'scss' => 'text/css',
      'sass' => 'text/css',
      'md' => 'text/html',
      'markdown' => 'text/html',
      'mkd' => 'text/html',
      'slim' => 'text/html',
      'es6' => 'application/javascript',
      'babel' => 'application/javascript',
      'jsx' => 'application/javascript',
      'js' => 'application/javascript'
    }.freeze

    def yaml_safe_parse(text)
      permitted_classes = [Date, Time]
      YAML.safe_load(text, permitted_classes: permitted_classes, aliases: true)
    end

    def file_name(path)
      File.basename(path, File.extname(path))
    end

    def switch_extension(path, new_extension = '')
      new_extension = '.' + new_extension if new_extension.present? && !new_extension.start_with?('.')
      ext = File.extname(path)
      path.gsub(/#{ext}$/, new_extension)
    end

    def kind_for_content_type(content_type)
      MIME::Types[content_type].any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
    end

    def kind_for_path(path)
      if KNOWN_TEXT_EXTENSIONS.include?(File.extname(path)[1..-1].to_s) ||
         KNOWN_TEXT_FILES.include?(File.basename(path))
        'text'
      else
        MIME::Types.type_for(path).any? { |t| t.media_type == 'text' } ? 'text' : 'asset'
      end
    end

    def filter_for_path(path)
      FILTER_FOR_EXTENSION[File.extname(path.to_s)[1..-1].to_s]
    end

    def variations_for_path(path)
      path = path.to_s
      result = []
      MIME::Types.type_for(path).each do |mime_type|
        result += mime_type.extensions if mime_type.extensions
        result += ADDITIONAL_EXTENSIONS[mime_type.content_type] || []
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
      OUTPUT_CONTENT_TYPE_FOR_EXTENSION[File.extname(content.path)[1..-1].to_s] || content.content_type
    end
  end
end
