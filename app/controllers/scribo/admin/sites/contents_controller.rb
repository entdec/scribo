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
        if params[:content][:files]

          contents = []
          params[:content][:files].each do |file|
            next unless Content.content_type_supported?(file.content_type)

            c = @site.contents.new(kind: Content.text_based?(file.content_type) ? 'text' : 'asset')

            c.content_type = file.content_type
            c.path = file.original_filename
            c.data = file.read
            c.state = 'published'
            c.save!

            contents << c

          end

          flash_and_redirect contents.first.valid?, edit_admin_site_content_url(@site, contents.first), 'Content created successfully', 'There were problems creating the content'
        else
          flash_and_redirect @content.save, edit_admin_site_content_url(@site, @content), 'Content created successfully', 'There were problems creating the content'
        end
      end

      def index
        # nothing here
        redirect_to edit_admin_site_content_url(@site, @contents.first)
      end

      def edit
        # add_breadcrumb(@content.name || @content.identifier || @content.path, edit_admin_site_content_path(@site, @content)) if defined? add_breadcrumb
        @content = Content.find(params[:id])
      end

      def update
        flash_and_redirect @content.update(content_params), edit_admin_site_content_url(@site, @content), 'Content updated successfully', 'There were problems updating the content'
      end

      def show
        redirect_to admin_site_contents_path(@site)
      end

      def preview
        @content      = Content.find(params[:id])
        @content.data = params[:data]
        render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
      end

      def destroy
        flash_and_redirect @content.destroy, edit_admin_site_content_url(@site, @contents.first), 'Content deleted successfully', 'There were problems deleting the content'
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @contents      = @site.contents.where(kind: %w[text redirect]).roots.reorder(:path)
        @content       = if params[:id]
                           Content.where(site: params[:site_id]).find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end
        @layouts       = @site.contents.where(kind: %w[text redirect]).identified.where.not(id: @content.id)
        @content_types = Scribo.config.supported_mime_types[:text]
        @content_types += Scribo.config.supported_mime_types[:script]
        @content_types += Scribo.config.supported_mime_types[:style]
        @states        = Scribo::Content.state_machine.states.map(&:value)
        @sites         = Scribo::Site.order(:name)
        @kinds         = %w[text redirect asset]

        @assets        = @site.contents.where(kind: 'asset').order(:path) if @site

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path if defined? add_breadcrumb
        add_breadcrumb(@site.name, edit_admin_site_path(@site)) if defined? add_breadcrumb
        # add_breadcrumb I18n.t('scribo.breadcrumbs.admin.contents'), admin_site_contents_url(@site) if defined? add_breadcrumb
      end

      def content_params
        params.require(:content).permit(:kind, :state, :path, :content_type, :layout_id, :parent_id, :position, :breadcrumb, :filter, :title, :keywords, :description, :data, :caption).tap do |w|
          w[:kind]       = 'text' if w[:kind].blank?
          w[:properties] = YAML.safe_load(params[:content][:properties])
        end
      end
    end
  end
end
