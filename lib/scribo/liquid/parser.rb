require 'parslet'

module Scribo
class LiquidParser < Parslet::Parser
  rule(:liquid) { (str('}}').absent? >> any).repeat }

  rule(:space) { match('\s').repeat(1) }
  rule(:space?) { space.maybe }

  rule(:squote) { str("'").repeat(1) }
  rule(:dquote) { str('"').repeat(1) }

  rule(:pipe) { str('|').repeat(1) }

  rule(:nsqvalue) { match["^'"] }
  rule(:ndqvalue) { match['^"'] }

  rule(:squoted_value) { squote >> nsqvalue.repeat.as(:value) >> squote }
  rule(:dquoted_value) { dquote >> ndqvalue.repeat.as(:value) >> dquote }
  rule(:quoted_value) { squoted_value | dquoted_value }

  rule(:translation_key) { quoted_value >> space? >> pipe >> liquid.as(:filter) >> space? >> liquid }

  rule(:liquid_code) { translation_key | liquid }

  rule(:liquid_with_brackets) { str('{{') >> liquid_code >> str('}}') }
  rule(:text) { (str('{{').absent? >> any).repeat(1) }

  rule(:text_with_liquid) { (text | liquid_with_brackets).repeat }
  root(:text_with_liquid)
end
end
