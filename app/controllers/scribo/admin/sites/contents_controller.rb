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
          @content.update(parent: new_parent)
        else
          @content.update(parent_id: nil)
        end
      end

      def rename
        @content.update(path: params[:to]) if params[:to]
      end

      def create
        @content = @site.contents.create(path: params[:path], kind: params[:kind])
        if params[:parent]
          parent = @site.contents.find(params[:parent])
          @content.update(parent: parent)
        end
      end

      def upload
        @parent = Scribo::Content.find(params[:content][:parent_id]) if params[:content][:parent_id]

        params[:content][:files]&.each do |file|
          content = @site.contents.create!(kind: Scribo::Utility.kind_for_path(file.original_filename),
                                           path: file.original_filename, data_with_frontmatter: file.read)
          content.update(parent: @parent)  if @parent
          
        end

        @contents = @site.contents.roots.reorder(:path) # unless params[:content][:parent_id]
      end

      private

      def set_objects
        @site          = Scribo::Site.find(params[:site_id])
        @content       = if params[:id]
                           @site.contents.find(params[:id])
                         else
                           params[:content] ? @site.contents.new(content_params) : @site.contents.new
                         end

        @contents = @site.contents.roots.where(kind: 'folder').reorder(:path) + @site.contents.roots.where("kind <> 'folder'").reorder(:path)
        @readme = @site.contents.roots.where("path ilike '%readme%'").first
      end

      def content_params
        params.require(:content).permit(:data_with_frontmatter).tap do |whitelisted|
          whitelisted[:data_with_frontmatter] = params[:content][:data_with_frontmatter].read.force_encoding('utf-8') if params[:content][:data_with_frontmatter].respond_to?(:read)
        end
      end
    end
  end
end
