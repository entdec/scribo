# Liquid

Scribo uses liquid for all its template rendering, liquid is simple and safe.
You can read more about liquid here: https://shopify.github.io/liquid/

When you render a template, you can pass it assigns and registers.
The difference is subtle: assigns are exposed to the template, while registers are exposed to Drops, Tags, and Filters.

## Customizing

### Filters
Filters are methods which take one or more parameters and return a value.
Filters can access the context and registers as in the below example: 

```ruby
module RenderFilter
  def render(input)
    template = Liquid::Template.parse(input)
    template.render(@context, registers: @context.registers)
  end
end

Liquid::Template.register_filter(RenderFilter)
```

### Tags

"Tags" are tags that take any number of arguments, but do not contain a block of template code.

```ruby
# Renders content
#
# {% render variable%}
class RenderTag < Liquid::Tag
  def initialize(tag_name, markup, options)
    super
    @name = markup.strip
  end

  def render(context)
    value = Liquid::VariableLookup.parse(@name).evaluate(context)
    template = Liquid::Template.parse(value)
    template.render(context, registers: context.registers)
  end
end

Liquid::Template.register_tag('render', RenderTag)
```

### Block tags

"Blocks" are tags that contain a block of template code which is delimited by a {% end<TAGNAME> %} tag.

## Reference

https://github.com/Shopify/liquid/wiki/Liquid-for-Programmers
https://github.com/Shopify/liquid/wiki/Liquid-for-Designers
https://shopify.github.io/liquid/

