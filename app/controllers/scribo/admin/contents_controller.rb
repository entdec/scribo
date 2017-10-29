# frozen_string_literal: true

require_dependency "scribo/application_controller"

module Scribo
  class Admin::ContentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_objects, except: [:index]
    authorize_resource

    add_breadcrumb I18n.t('breadcrumbs.admin.contents'), :admin_contents_path

    def new
      render :edit
    end

    def create
      flash_and_redirect @content.save, admin_contents_url, 'Content created successfully', 'There were problems creating the content'
    end

    def index
      @contents = Scribo::Site.first.contents.where(kind: 'content')
    end

    def edit
      @content = Scribo::Content.find(params[:id])
    end

    def update
      flash_and_redirect @content.update(content_params), admin_contents_url, 'Content updated successfully', 'There were problems updating the content'
    end

    def show
      redirect_to :edit_admin_content
    end

    private

    def set_objects
      @current_site = Scribo::Site.first
      @content = if params[:id]
                   @current_site.contents.where(kind: 'content').find(params[:id])
                 else
                   params[:content] ? @current_site.contents.new(content_params) : @current_site.contents.new
                 end
      @layouts = @current_site.contents.where(kind: 'content').where.not(identifier: nil).where.not(id: @content.id)
      @content_types = Scribo::Content::SUPPORTED_MIME_TYPES[:text]
    end

    def content_params
      params.require(:content).permit(:path, :content_type, :layout_id, :breadcrumb, :name, :identifier, :filter, :title, :keywords, :description, :data).tap do |w|
        w[:kind] = 'content' if w[:kind].blank?
      end
    end
  end
end
