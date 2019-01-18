# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class BucketsController < ApplicationAdminController
      before_action :set_objects, except: [:index]

      add_breadcrumb I18n.t('scribo.breadcrumbs.admin.buckets'), :admin_buckets_path if defined? add_breadcrumb

      def new
        add_breadcrumb('New bucket', :new_admin_bucket_path) if defined? add_breadcrumb
        render :edit
      end

      def create
        flash_and_redirect @bucket.save, admin_buckets_path, 'Bucket created successfully', 'There were problems creating the bucket'
      end

      def index
        @buckets = Bucket.owned.order(:name)
      end

      def edit
        @bucket = Bucket.find(params[:id])
        add_breadcrumb(@bucket.name, :edit_admin_bucket_path) if defined? add_breadcrumb
      end

      def update
        flash_and_redirect @bucket.update(bucket_params), admin_buckets_path, 'Bucket updated successfully', 'There were problems updating the bucket'
      end

      def show
        redirect_to :edit_admin_bucket
      end

      def import
        if request.post?
          flash_and_redirect Bucket.import(params[:bucket][:zip_file].path), admin_buckets_path, 'Bucket imported successfully', 'There were problems importing the bucket'
        end
      end

      def export
        name, data = @bucket.export
        send_data data, type: 'application/zip', filename: name
      end

      private

      def set_objects
        @bucket = if params[:id]
                  Bucket.owned.find(params[:id])
                else
                  params[:bucket] ? Bucket.new(bucket_params) : Bucket.new
                end
        @contents = @bucket.contents.where(kind: %w[text redirect]).order(:path, :identifier) if @bucket
      end

      def bucket_params
        params.require(:bucket).permit(:name, :purpose, :scribable_id).tap do |whitelisted|
          whitelisted[:scribable] = GlobalID::Locator.locate_signed(whitelisted[:scribable_id])
        end
      end
    end
  end
end
