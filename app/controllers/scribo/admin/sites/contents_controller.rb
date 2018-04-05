# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Sites::ContentsController < ApplicationAdminController
      before_action :set_objects

      def new
        add_breadcrumb('New content', new_admin_site_content_path(@site)) if defined? add_breadcrumb
        render :edit
      end

      def create
        flash_and_redirect @content.save, admin_site_contents_url(@site), 'Content created successfully', 'There were problems creating the content'
      end

      def index
        # nothing here
      end

      def edit
        add_breadcrumb(@content.name || @content.identifier || @content.path, edit_admin_site_content_path(@site, @content)) if defined? add_breadcrumb
        @content = Content.find(params[:id])
      end

      def update
        flash_and_redirect @content.update(content_params), admin_site_contents_url(@site), 'Content updated successfully', 'There were problems updating the content'
      end

      def show
        redirect_to admin_site_contents_path(@site)
      end

      def preview
        @content      = Content.find(params[:id])
        @content.data = params[:data]
        render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @contents      = @site.contents.where(kind: %w[text redirect]).order(:path, :identifier)
        @content       = if params[:id]
                           Content.where(site: params[:site_id]).where(kind: %w[text redirect]).find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end
        @layouts       = Content.where(kind: %w[text redirect]).where.not(identifier: nil).where.not(id: @content.id)
        @content_types = Scribo.supported_mime_types[:text]
        @states        = Scribo::Content.aasm.states.map(&:name)
        @sites         = Scribo::Site.order(:name)
        @kinds         = %w[text redirect]

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path if defined? add_breadcrumb
        add_breadcrumb(@site.name, edit_admin_site_path(@site)) if defined? add_breadcrumb
        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.contents'), admin_site_contents_url(@site) if defined? add_breadcrumb
      end

      def content_params
        params.require(:content).permit(:kind, :state, :path, :content_type, :layout_id, :breadcrumb, :name, :identifier, :filter, :title, :keywords, :description, :data).tap do |w|
          w[:kind] = 'text' if w[:kind].blank?
        end
      end
    end
  end
end
