# frozen_string_literal: true

# Add scribo as a renderer
module ActionController::Renderers
  add :scribo do |bucket, options|
    current_bucket = if bucket.is_a? Scribo::Bucket
                       bucket
                     else
                       scope = Scribo::Bucket.named(bucket)
                       scope = scope.owned_by(options[:owner]) if options[:owner]
                       scope.first
                     end

    raise 'No bucket found' unless current_bucket

    content = current_bucket.contents
    content = content.identified(options[:identifier]) if options[:identifier]
    content = content.located(options[:path]) if options[:path]
    content = if options[:root]
                content.root
              else
                content.first
              end

    content ||= current_bucket&.contents&.located(options[:path])&.first
    if !content && options[:path] && options[:path][1..-1].length == 36
      content = Scribo::Content&.published&.find(options[:path][1..-1])
    end

    if options[:path] == '/humans.txt'
      content = Scribo::Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_humans_txt)
    elsif options[:path] == '/robots.txt'
      content = Scribo::Content.new(kind: 'text', content_type: 'text/plain', data: Scribo.config.default_robots_txt)
    elsif options[:path] == '/favicon.ico'
      content = Scribo::Content.new(kind: 'asset', content_type: 'image/x-icon', data: Base64.decode64(Scribo.config.default_favicon_ico))
    end
    content ||= current_bucket&.contents&.located('/404')&.first

    if content
      # Prepare assigns and registers
      assigns = { 'request' => ActionDispatch::RequestDrop.new(request) }
      instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
        assigns[i.to_s[1..-1]] = instance_variable_get(i)
      end
      registers = { 'controller' => self }.stringify_keys

      self.content_type ||= content.content_type

      Scribo.config.logger.info "Scribo: rendering #{content.id} last-updated #{content.updated_at} cache-key #{content.cache_key} path #{content.path} identifier #{content.identifier}"
      if content.kind == 'redirect'
        redirect_options = Scribo::Content.redirect_options(content.render(assigns, registers))
        redirect_to redirect_options.last, status: redirect_options.first
      elsif stale?(etag: content.cache_key, public: true)
        if content.kind == 'asset'
          send_data(content.render(assigns, registers), type: content.content_type, disposition: 'inline')
        else
          content.render(assigns, registers)
        end
      else
        head 304
      end
    else
      render body: Scribo.config.default_404_txt, status: 404
    end
  end
end
