# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Buckets::AssetsController < ApplicationAdminController
      before_action :set_objects

      def new
        add_breadcrumb('New asset', new_admin_bucket_asset_path(@bucket)) if defined? add_breadcrumb
        render :edit
      end

      def create
        flash_and_redirect @content.save, admin_bucket_assets_url(@bucket), 'Asset created successfully', 'There were problems creating the asset'
      end

      def index
        @contents = @bucket.contents.where(kind: 'asset').order(:path, :identifier)
      end

      def edit
        add_breadcrumb(@content.name || @content.identifier || @content.path, edit_admin_bucket_asset_path(@bucket, @content)) if defined? add_breadcrumb
        @content = Content.find(params[:id])
      end

      def update
        flash_and_redirect @content.update(content_params), admin_bucket_assets_url(@bucket), 'Asset updated successfully', 'There were problems updating the asset'
      end

      def show
        redirect_to admin_bucket_assets_path(@bucket)
      end

      private

      def set_objects
        @bucket = Bucket.find(params[:bucket_id])
        @content = if params[:id]
                     @bucket.contents.where(kind: 'asset').find(params[:id])
                   else
                     params[:content] ? @bucket.contents.new(content_params) : @bucket.contents.new
                   end
        @states  = Scribo::Content.state_machine.states.map(&:value)

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.buckets'), :admin_buckets_path if defined? add_breadcrumb
        add_breadcrumb(@bucket.name, edit_admin_bucket_path(@bucket)) if defined? add_breadcrumb
        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.assets'), admin_bucket_assets_path(@bucket) if defined? add_breadcrumb
      end

      def content_params
        params.require(:content).permit(:state, :name, :path, :title, :caption, :keywords, :description, :data).tap do |w|
          w[:kind] = 'asset' if w[:kind].blank?
          if w[:data]
            w[:content_type] = w[:data].content_type
            if Content.content_type_supported?(w[:content_type])
              w[:name] = w[:data].original_filename if w[:name].blank?
              w[:data] = w[:data].read
            else
              w.delete(:data)
            end
          end
        end
      end
    end
  end
end
