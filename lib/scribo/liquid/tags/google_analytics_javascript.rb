# frozen_string_literal: true

# Adds a Google Analytics Javascript block
#
# == Basic usage:
#    {%google_analytics_javascript 'UA-000000-01'%}
#
# Where 'UA-000000-01' is your analytics id
class GoogleAnalyticsJavascriptTag < Liquid::Tag
  def validate
    raise SyntaxError, "Missing google analytics code" unless @args[:argv1]
  end

  def render(context)
    code = lookup(context, @args[:argv1])
    return unless Rails.env == 'production'
    return unless code
    Scribo.config.logger.warn "Inserting google analytics with code: #{code}"
    %(<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', '#{code}', 'auto');
  ga('send', 'pageview');</script>)
  end
end

Liquid::Template.register_tag('google_analytics_javascript', GoogleAnalyticsJavascriptTag)
