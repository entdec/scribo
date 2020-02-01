# frozen_string_literal: true

module Scribo
  class ActionDispatch::RequestDrop < ApplicationDrop
    delegate :fullpath, :host, :scheme, :ip, :media_type, :query_parameters, :uuid, :request_method, to: :@object

    def headers
      @object.headers.to_h
    end
  end
end
