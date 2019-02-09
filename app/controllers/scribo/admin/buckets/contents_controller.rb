# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Buckets::ContentsController < ApplicationAdminController
      before_action :set_objects

      def new
        add_breadcrumb('New content', new_admin_bucket_content_path(@bucket)) if defined? add_breadcrumb
        render :edit
      end

      def create
        flash_and_redirect @content.save, admin_bucket_contents_url(@bucket), 'Content created successfully', 'There were problems creating the content'
      end

      def index
        # nothing here
      end

      def edit
        add_breadcrumb(@content.name || @content.identifier || @content.path, edit_admin_bucket_content_path(@bucket, @content)) if defined? add_breadcrumb
        @content = Content.find(params[:id])
      end

      def update
        flash_and_redirect @content.update(content_params), admin_bucket_contents_url(@bucket), 'Content updated successfully', 'There were problems updating the content'
      end

      def show
        redirect_to admin_bucket_contents_path(@bucket)
      end

      def preview
        @content      = Content.find(params[:id])
        @content.data = params[:data]
        render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
      end

      private

      def set_objects
        @bucket = Scribo::Bucket.find(params[:bucket_id])
        @contents      = @bucket.contents.where(kind: %w[text redirect]).order('lft ASC')
        @content       = if params[:id]
                           Content.where(bucket: params[:bucket_id]).where(kind: %w[text redirect]).find(params[:id])
                         else
                           params[:content] ? @bucket.contents.new(content_params) : @bucket.contents.new
                         end
        @layouts       = @bucket.contents.where(kind: %w[text redirect]).where.not(identifier: nil).where.not(id: @content.id)
        @content_types = Scribo.config.supported_mime_types[:text]
        @states        = Scribo::Content.state_machine.states.map(&:value)
        @buckets = Scribo::Bucket.order(:name)
        @kinds = %w[text redirect]

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.buckets'), :admin_buckets_path if defined? add_breadcrumb
        add_breadcrumb(@bucket.name, edit_admin_bucket_path(@bucket)) if defined? add_breadcrumb
        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.contents'), admin_bucket_contents_url(@bucket) if defined? add_breadcrumb
      end

      def content_params
        params.require(:content).permit(:kind, :state, :path, :content_type, :layout_id, :parent_id, :position, :breadcrumb, :name, :identifier, :filter, :title, :keywords, :description, :data).tap do |w|
          w[:kind] = 'text' if w[:kind].blank?
        end
      end
    end
  end
end
