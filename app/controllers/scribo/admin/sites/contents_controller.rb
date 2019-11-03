# frozen_string_literal: true

require_dependency 'scribo/application_admin_controller'

module Scribo
  module Admin
    class Sites::ContentsController < ApplicationAdminController
      before_action :set_objects

      # Render the IDE
      def index; end

      def edit; end

      def update
        @content.update(content_params)
        render :edit
      end

      def show
        render :edit
      end

      def destroy
        @content.destroy
        head 200
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
      end

      def upload
        @parent = @site.contents.find(params[:content][:parent_id]) if params[:content][:parent_id]

        params[:content][:files]&.each do |extra_file|
          @site.contents.create(kind: Scribo::Utility.kind_for_content_type(extra_file.content_type),
                                path: extra_file.original_filename, data: extra_file.read, parent: @parent)
        end

        @contents = @site.contents.roots.reorder(:path) unless @parent
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @content       = if params[:id]
                           @site.contents.find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end
        @contents      = @site.contents.roots.reorder(:path) if request.format == :html
      end

      def content_params
        params.require(:content).permit(:data_with_frontmatter, :properties)
      end
    end
  end
end
