# frozen_string_literal: true

require_dependency 'concerns/maintenance_standards'

module Scribo
  class ApplicationAdminController < Scribo.admin_base_controller.constantize
    include MaintenanceStandards
  end
end
