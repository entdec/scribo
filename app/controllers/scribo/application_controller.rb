# frozen_string_literal: true

require_dependency 'concerns/maintenance_standards'

module Scribo
  class ApplicationController < (Scribo.base_controller || '::ApplicationController').constantize
    include MaintenanceStandards
  end
end
