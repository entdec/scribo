# frozen_string_literal: true

# Adds a Google Tag Manager Javascript block
#
# == Basic usage:
#    {%google_tag_manager_javascript 'GTM-XXXXXXX'%}
#
# == Advanced usage:
#    {%google_tag_manager_javascript retailer.code%}
#
# Where 'GTM-XXXXXXX' is your container id
class GoogleTagManagerJavascriptTag < LiquorTag
  def render(context)
    super

    return unless Rails.env == 'production'
    return unless argv1
    Rails.logger.warn "Inserting google tag manager with code: #{argv1}"
    %(<script>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
    new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
    j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
    'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
    })(window,document,'script','dataLayer','#{argv1}');</script>)
  end
end

Liquid::Template.register_tag('google_tag_manager_javascript', GoogleTagManagerJavascriptTag)
