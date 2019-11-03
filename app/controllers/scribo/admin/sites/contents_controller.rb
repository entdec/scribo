# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Sites::ContentsController < ApplicationAdminController
      before_action :set_objects
      skip_before_action :verify_authenticity_token, only: %i[update move rename create upload destroy]

      def index
        # This now renders the IDE
        @contents = @site.contents.roots.reorder(:path)
      end

      def edit
        # Either json/html
        @contents = @site.contents.roots.reorder(:path) if request.format == :html
      end

      def update
        @content.update(content_params)
        render json: { content: { id: @content.id, path: @content.path, full_path: @content.full_path, url: admin_site_content_path(@site, @content) }, html: render_to_string('edit', layout: false) }
      end

      def show
        render :edit
      end

      def destroy
        @content.destroy
        @content = @contents.pages.first
        render json: { html: '' }
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

      def create
        @content = @site.contents.create(path: params[:path], kind: params[:kind])
        if params[:parent]
          parent = @site.contents.find(params[:parent])
          @content.move_to_child_with_index(parent, 0)
        end

        render json: {
          content: {
            id: @content.id, kind: @content.kind, path: @content.path, full_path: @content.full_path, url: admin_site_content_path(@site, @content)
          },
          html: render_to_string('edit', layout: false),
          itemHtml: render_to_string('scribo/shared/_entry', layout: false, locals: { content: @content })
        }
      end

      def upload
        params[:content][:files]&.each do |extra_file|
          c = @site.contents.new(kind: Scribo::Utility.kind_for_content_type(extra_file.content_type))
          c.path = extra_file.original_filename
          c.data = extra_file.read
          c.parent_id = params[:content][:parent_id]
          c.save!
        end
        render json: { html: render_to_string('scribo/shared/_tree-view', layout: false, locals: { site: @site }) }
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @content       = if params[:id]
                           @site.contents.find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end
      end

      def content_params
        params.require(:content).permit(:data_with_frontmatter, :properties)
      end
    end
  end
end
