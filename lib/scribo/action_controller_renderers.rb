# frozen_string_literal: true

# Add scribo as a renderer
module ActionController::Renderers
  add :scribo do |site, options|
    site = Scribo::SiteFindService.new(options.merge(site: site, uri: URI.parse(request.original_url))).call
    site ||= Scribo::Site.new
    content = Scribo::ContentFindService.new(site, options).call

    if content
      self.content_type ||= Scribo::Utility.output_content_type(content)

      Scribo.config.logger.info "Scribo: rendering #{content.id} last-updated #{content.updated_at} cache-key #{content.cache_key} path #{content.path} identifier #{content.identifier}"
      if content.redirect?
        redirect_options = Scribo::Content.redirect_options(content.content(self))
        redirect_to redirect_options.last, status: redirect_options.first
      elsif stale?(etag: content.cache_key, public: true)
        if content.kind == 'asset'
          data = Rails.cache.fetch("#{content.cache_key}/asset", expires_in: 12.hours) { content.content(self) }
          send_data(data, type: content.content_type, disposition: 'inline')
        else
          content.content(self)
        end
      else
        head 304
      end
    else
      render body: Scribo.config.default_404_txt, status: 404
    end
  end
end
