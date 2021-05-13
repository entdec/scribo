# frozen_string_literal: true

# Add scribo as a renderer
module ActionController::Renderers
  add :scribo do |request, options|
    options.merge!(request: request, uri: URI.parse(request.original_url), host: request.host, path: URI.parse(request.original_url).path)

    site = Scribo::SiteFindService.new(options).call
    content = nil

    unless site
      # If we have no site, see if we have one when we add an /
      site = Scribo::SiteFindService.new(options.merge(path: "#{options[:path]}/")).call
      redirect_to("#{options[:path]}/") && return if site
    end

    if options[:path] == site.baseurl && !options[:path].ends_with?('/')
      redirect_to("#{site.baseurl}/") && return
    end

    options.merge!(site: site)
    site ||= Scribo::Site.default(request: request)
    content ||= Scribo::ContentFindService.new(site, options).call

    if content
      self.content_type ||= Scribo::Utility.output_content_type(content)

      Scribo.config.logger.info "Scribo: rendering #{content.id} last-updated #{content.updated_at} cache-key #{content.cache_key} path #{content.path} identifier #{content.identifier}"
      if content.redirect?
        redirect_options = Scribo::Content.redirect_options(Scribo::ContentRenderService.new(content, self, options).call)
        redirect_to redirect_options.last, status: redirect_options.first
      elsif stale?(etag: content.cache_key, public: true)
        if content.kind == 'asset'
          data = Rails.cache.fetch("#{content.cache_key}/asset", expires_in: 12.hours) { Scribo::ContentRenderService.new(content, self, options).call }
          stream_data(data, type: content.content_type)
        else
          Scribo::ContentRenderService.new(content, self, options).call
        end
      else
        head 304
      end
    else
      render body: Scribo.config.default_404_txt, status: 404
    end
  end

  # See: https://stackoverflow.com/a/57786143
  def stream_data(data, options = {})
    range_start = 0
    file_size = data.length
    range_end = file_size
    status_code = '200'

    if request.headers['Range']
      status_code = '206'
      request.headers['range'].match(/bytes=(\d+)-(\d*)/).try do |match|
        range_start = match[1].to_i
        range_end = match[2].to_i unless match[2] && match[2].empty?
      end
      response.header['Content-Range'] = "bytes #{range_start}-#{range_end}/#{file_size}"
    end

    response.header['Accept-Ranges'] = 'bytes'

    send_data(data[range_start, range_end],
              filename: options[:filename],
              type: options[:type],
              disposition: 'inline',
              status: status_code)
  end
end
