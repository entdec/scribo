# frozen_string_literal: true

require_dependency 'scribo/application_controller'
require_dependency 'concerns/maintenance_standards'

module Scribo
  class ApplicationAdminController < ApplicationController
    include MaintenanceStandards
    include Scribo.config.admin_authentication_module.constantize if Scribo.config.admin_authentication_module
  end
end
