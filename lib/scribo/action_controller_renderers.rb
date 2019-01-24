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
    content = content.named(options[:name]) if options[:name]
    content = content.located(options[:path]) if options[:path]
    content = content.first

    # Prepare assigns and registers
    assigns = { 'request' => ActionDispatch::RequestDrop.new(request) }
    instance_variables.reject { |i| i.to_s.starts_with?('@_') }.each do |i|
      assigns[i.to_s[1..-1]] = instance_variable_get(i)
    end
    registers = { 'controller' => self }.stringify_keys

    self.content_type ||= content.content_type
    content.render(assigns, registers)
  end
end
