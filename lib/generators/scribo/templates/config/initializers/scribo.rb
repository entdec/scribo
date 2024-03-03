# frozen_string_literal: true

Scribo.setup do |config|
  config.base_controller = "::UnauthenticatedController"
  config.admin_authentication_module = "Auxilium::Concerns::AdminAuthenticated"

  config.scribable_objects = lambda do
    return [] unless Current.account

    [Current.account]
  end

  config.scribable_for_request = lambda do |request|
    Current.account
  end
end
