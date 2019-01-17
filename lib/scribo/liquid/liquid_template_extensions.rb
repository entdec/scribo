# frozen_string_literal: true

#
# This is here to allow you to block certain tags for certain templates.
# Say in emails or exports it doesn't make sense to allow forms, you could exclude it as follows:
#
#   template = Liquid::Template.parse(data, block_tags: %w[form])
#
module Liquid
  class ParseContext
    def block_tags
      @options[:block_tags]
    end
  end

  class BlockBody
    alias parse_without_setting_parse_context parse

    def parse(tokenizer, parse_context, &block)
      @parse_context = parse_context
      parse_without_setting_parse_context(tokenizer, parse_context, &block)
    end

    def registered_tags
      allowed_tags = Template.tags.dup
      if @parse_context.block_tags.present?
        @parse_context.block_tags.each do |tag|
          allowed_tags.delete(tag)
        end
      end
      allowed_tags
    end
  end
end
