# frozen_string_literal: true

require_dependency File.expand_path(File.join(File.dirname(__FILE__), '..', 'application_drop.rb'))

module Scribo
  class ActionDispatch::RequestDrop < ApplicationDrop
    delegate :fullpath, :headers, :ip, :media_type, :query_parameters, :uuid, :request_method, to: :@object
  end
end
