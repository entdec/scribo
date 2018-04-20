# frozen_string_literal: true

# Helper tag
#
# {% helper user_index_path %}
class HelperTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super

    @markup = markup
    if @markup =~ /({.*})/
      @options = JSON.parse(Regexp.last_match(1))
      @markup = @markup.gsub(Regexp.last_match(1), '').strip
    end
    
    @variables = @markup.split(' ')
    @helper = @variables.shift.to_sym

    @variables = @variables.map do |v|
      if v.include? ':'
        key, val = v.split(':')
        @options[key] = val
      else
        Liquid::Expression.parse(v.strip)
      end
    end
  end

  def render(context)
    vars = @variables.map do |v|
      [Liquid::RangeLookup, Liquid::VariableLookup].include?(v.class) ? v.evaluate(context) : v
    end
    vars << @options
    context.registers['controller'].helpers.send(@helper, *vars) if context.registers['controller'].helpers.respond_to? @helper
  end
end

Liquid::Template.register_tag('helper', HelperTag)
