# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Buckets::TranslationsController < ApplicationAdminController
      before_action :set_objects

      def index
        @languages = @bucket.translations.keys
        keys_count = @translations.select { |t| t.start_with?("#{@source_language}.") }.keys.reduce(0) { |sum, key| sum + 1 }.to_f
        @languages = @languages.map do |l|
          translated_keys_count = @translations.select { |t| t.start_with?("#{l}.") }.keys.reduce(0) { |sum, key| sum + 1 if @translations[key].present? }
          pct = ((translated_keys_count / keys_count) * 100).round(1)
          [l, pct]
        end
      end

      def edit
        add_breadcrumb(@destination_language, edit_admin_bucket_translation_path(@bucket, @destination_language)) if defined? add_breadcrumb
        @translations = convert_hash(@bucket.translations)
      end

      def update
        @bucket.translations = @bucket.translations.deep_merge(translations_params)
        @bucket.save
      end

      private

      def translations_params
        params.fetch(:translations, {}).permit!
      end

      def set_objects
        @bucket = Scribo::Bucket.find(params[:bucket_id])
        @source_language = 'en'
        @translations = convert_hash(@bucket.translations)
        @destination_language = params[:id]

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.buckets'), :admin_buckets_path if defined? add_breadcrumb
        add_breadcrumb(@bucket.name, edit_admin_bucket_path(@bucket)) if defined? add_breadcrumb
        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.translations'), admin_bucket_translations_path(@bucket) if defined? add_breadcrumb
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
