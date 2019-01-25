# frozen_string_literal: true

# Adds a Google Analytics Javascript block
#
# == Basic usage:
#    {%google_analytics_javascript 'UA-000000-01'%}
#
# == Advanced usage:
#    {%google_analytics_javascript retailer.code%}
#
# Where 'UA-000000-01' is your analytics id
class GoogleAnalyticsJavascriptTag < ScriboTag
  def render(context)
    super

    return unless Rails.env == 'production'
    return unless argv1

    Scribo.config.logger.warn "Inserting google analytics with code: #{argv1}"
    %(<script>(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', '#{argv1}', 'auto');
  ga('send', 'pageview');</script>)
  end
end

Liquid::Template.register_tag('google_analytics_javascript', GoogleAnalyticsJavascriptTag)
