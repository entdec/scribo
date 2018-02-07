# frozen_string_literal: true

# Adds a Google Tag Manager Javascript block
#
# {% google_tag_manager_javascript 'GTM-XXXXXXX' %}
class GoogleTagManagerJavascriptTag < Liquid::Tag
  def initialize(tag_name, markup, tokens)
    super
    @code = Liquid::Expression.parse(markup.strip)
    unless @code
      raise SyntaxError, "Syntax Error in 'google_tag_manager_javascript' - Valid syntax: yield 'container_id'"
    end
  end

  def render(context)
    code = [Liquid::RangeLookup, Liquid::VariableLookup].include?(@code.class) ? @code.evaluate(context) : @code
    return unless Rails.env == 'production'
    return unless code
    Rails.logger.warn "Inserting google tag manager with code: #{code}"
    %(<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
    new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
    j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
    'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','#{code}');</script>)
  end
end

Liquid::Template.register_tag('google_tag_manager_javascript', GoogleTagManagerJavascriptTag)
