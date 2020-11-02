# frozen_string_literal: true

require_relative '../application_drop'

module Scribo
  module ActionDispatch
    class RequestDrop < ::Scribo::ApplicationDrop
      delegate :fullpath, :host, :scheme, :ip, :media_type, :query_parameters, :uuid, :request_method, to: :@object

      def headers
        @object.headers.to_h
      end
    end
  end
end
