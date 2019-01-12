# frozen_string_literal: true

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'application_drop.rb'))

module Scribo
  class ActionDispatch::RequestDrop < ApplicationDrop
    delegate :fullpath, :ip, :media_type, :query_parameters, :uuid, :request_method, to: :@object

    def headers
      @object.headers.to_h
    end
  end
end
