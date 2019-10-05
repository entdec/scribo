# frozen_string_literal: true

# Add scribo as a renderer
module ActionController::Renderers
  add :scribo do |site, options|
    site = SiteFindService.new(options.merge(site: site, hostname: request.env['SERVER_NAME'])).call
    content = ContentFindService.new(site, options).call

    if content
      self.content_type ||= Scribo::Utility.output_content_type(content)

      Scribo.config.logger.info "Scribo: rendering #{content.id} last-updated #{content.updated_at} cache-key #{content.cache_key} path #{content.path} identifier #{content.identifier}"
      if content.kind == 'redirect'
        redirect_options = Scribo::Content.redirect_options(ContentRenderService.new(content, self).call)
        redirect_to redirect_options.last, status: redirect_options.first
      elsif stale?(etag: content.cache_key, public: true)
        if content.kind == 'asset'
          send_data(content.render, type: content.content_type, disposition: 'inline')
        else
          ContentRenderService.new(content, self).call
        end
      else
        head 304
      end
    else
      render body: Scribo.config.default_404_txt, status: 404
    end
  end
end
