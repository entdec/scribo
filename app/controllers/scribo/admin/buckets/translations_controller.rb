# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Buckets::TranslationsController < ApplicationAdminController
      before_action :set_objects

      def index
        @translations = convert_hash(@bucket.translations)
      end

      private

      def set_objects
        @bucket = Scribo::Bucket.find(params[:bucket_id])
      end

      def convert_hash(hash, path = "")
        hash.each_with_object({}) do |(k, v), ret|
          key = path + k

          if v.is_a? Hash
            ret.merge! convert_hash(v, key + ".")
          else
            ret[key] = v
          end
        end
      end
    end
  end
end
