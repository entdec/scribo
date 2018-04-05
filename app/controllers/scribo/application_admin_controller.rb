# frozen_string_literal: true

require_dependency 'concerns/maintenance_standards'

module Scribo
  # TODO: This doesn't work properly at the moment
  class ApplicationAdminController < ApplicationController # Scribo.admin_base_controller.constantize
    include MaintenanceStandards
  end
end
