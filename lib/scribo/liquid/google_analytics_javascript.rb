# frozen_string_literal: true

# Adds a Google Analytics Javascript block
#
# {% google_analytics_javascript 'UA-000000-01' %}
class GoogleAnalyticsJavascriptTag < Liquid::Tag
  SYNTAX = /(#{Liquid::QuotedFragment})?/o

  def initialize(tag_name, markup, tokens)
    super
    if markup =~ SYNTAX
      @code = Liquid::Expression.parse(Regexp.last_match[1]).to_s
    else
      raise SyntaxError, "Syntax Error in 'google_analytics_javascript' - Valid syntax: yield 'tracking_id'"
    end
  end

  def render(context)
    return unless Rails.env == 'production'
    Rails.logger.warn "Inserting google analytics with code: #{@code}"
    %(<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', '#{@code}', 'auto');
  ga('send', 'pageview');</script>)
  end
end

Liquid::Template.register_tag('google_analytics_javascript', GoogleAnalyticsJavascriptTag)
