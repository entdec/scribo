# frozen_string_literal: true

module Scribo
  class ApplicationController < (Scribo.base_controller || '::ApplicationController').constantize
  end
end
