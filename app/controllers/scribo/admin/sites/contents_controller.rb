# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Sites::ContentsController < ApplicationAdminController
      before_action :set_objects
      skip_before_action :verify_authenticity_token, only: %i[move rename remote_create upload]

      def new
        add_breadcrumb('New content', new_admin_site_content_path(@site)) if defined? add_breadcrumb
        render :edit
      end

      def create
        if params[:content][:files]

          contents = []
          params[:content][:files].each do |file|
            c = @site.contents.new(kind: Scribo::Utility.kind_for_content_type(extra_file.content_type))

            c.content_type = file.content_type
            c.path = file.original_filename
            c.data = file.read
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
        redirect_to edit_admin_site_content_url(@site, @contents.pages.first)
      end

      def edit
        # add_breadcrumb(@content.name || @content.identifier || @content.path, edit_admin_site_content_path(@site, @content)) if defined? add_breadcrumb
        @content = Content.find(params[:id])
      end

      def update
        if params[:content][:files]

          file = params[:content][:files].first

          @content.kind = Scribo::Utility.kind_for_content_type(file.content_type)
          @content.data = file.read

          # Just store extra files
          params[:content][:files][1..-1].each do |extra_file|
            c = @site.contents.new(kind: Scribo::Utility.kind_for_content_type(extra_file.content_type))
            c.path = extra_file.original_filename
            c.data = extra_file.read
            c.save!
          end

          flash_and_redirect @content.save, edit_admin_site_content_url(@site, @content), 'Content updated successfully', 'There were problems updating the content'
        else
          flash_and_redirect @content.update(content_params), edit_admin_site_content_url(@site, @content), 'Content updated successfully', "There were problems updating the content: #{@content.errors.messages}"
        end
      end

      def show
        redirect_to admin_site_contents_path(@site)
      end

      def destroy
        flash_and_redirect @content.destroy, admin_site_contents_url(@site), 'Content deleted successfully', 'There were problems deleting the content'
      end

      def move
        if params[:to]
          new_parent = @site.contents.find(params[:to])
          @content.move_to_child_with_index(new_parent, params[:index])
        else
          @content.move_to_left_of(@contents[params[:index]])
        end

        head 200
      end

      def rename
        @content.update(path: params[:to]) if params[:to]
        head 200
      end

      def remote_create
        new_content = @site.contents.create(path: params[:path], kind: params[:kind])
        if params[:parent]
          parent = @site.contents.find(params[:parent])
          new_content.move_to_child_with_index(parent, 0)
        else
          new_content.move_to_left_of(@contents[0])
        end
        render json: { url: edit_admin_site_content_path(@site, new_content) }
      end

      def upload
        if params[:content][:files]
          params[:content][:files].each do |extra_file|
            c = @site.contents.new(kind: Scribo::Utility.kind_for_content_type(extra_file.content_type))
            c.path = extra_file.original_filename
            c.data = extra_file.read
            c.parent_id = params[:content][:parent_id]
            c.save!
          end
        end
        render json: { html: render_to_string('scribo/shared/_tree-view', layout: false, locals: { site: @site }) }
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @contents      = @site.contents.roots.reorder(:path)
        @content       = if params[:id]
                           Content.where(site: params[:site_id]).find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end
        @layouts       = @site.contents.layouts

        @sites = Scribo::Site.order(:name)
        @kinds = %w[text redirect asset]

        add_breadcrumb I18n.t('scribo.breadcrumbs.admin.sites'), :admin_sites_path if defined? add_breadcrumb
        add_breadcrumb(@site.properties['title'], edit_admin_site_path(@site)) if defined? add_breadcrumb
      end

      def content_params
        params.require(:content).permit(:kind, :layout_id, :parent_id, :data, :data_with_frontmatter, :properties)
      end
    end
  end
end
