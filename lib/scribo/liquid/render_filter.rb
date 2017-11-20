module RenderFilter
  def render(input)
    template = Liquid::Template.parse(input)
    template.render(@assignes, registers: @registers)
  end
end

Liquid::Template.register_filter(RenderFilter)
