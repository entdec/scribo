# frozen_string_literal: true

# Adds a Google Tag Manager Javascript block
#
# == Basic usage:
#    {%google_tag_manager_javascript 'GTM-XXXXXXX'%}
#
# Where 'GTM-XXXXXXX' is your container id
class GoogleTagManagerJavascriptTag < Liquid::Tag
  def validate
    raise SyntaxError, "Missing google tag manager code" unless @args[:argv1]
  end

  def render(context)
    code = lookup(context, @args[:argv1])
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
