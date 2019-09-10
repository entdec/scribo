# frozen_string_literal: true

require_dependency 'scribo/application_controller'

module Scribo
  module Admin
    module Sites
      module Contents
        class PartsController < ApplicationController
          protect_from_forgery except: :show
          skip_before_action :verify_authenticity_token

          def show
            content = Scribo::Content.find(params[:content_id])
            doc = Nokogiri::HTML.fragment(content.data)

            value = doc.css("[data-editable-url$='/#{params[:id]}']").first.content
            render json: { part: { value: value } }
          end

          def update
            content = Scribo::Content.find(params[:content_id])
            doc = Nokogiri::HTML.fragment(content.data)

            doc.css("[data-editable-url$='/#{params[:id]}']").first.content = params[:part][:value]
            content.data = doc.to_s
            content.save
            render json: { part: { value: params[:part][:value] } }
          end
        end
      end
    end
  end
end
