# frozen_string_literal: true

module Scribo
  class Admin::AssetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_objects, except: [:index]
    authorize_resource class: Content

    add_breadcrumb I18n.t('breadcrumbs.admin.assets'), :admin_assets_path

    def new
      render :edit
    end

    def create
      flash_and_redirect @content.save, admin_assets_url, 'Asset created successfully', 'There were problems creating the asset'
    end

    def index
      @contents = Site.first.contents.where(kind: 'asset')
    end

    def edit
      @content = Content.find(params[:id])
    end

    def update
      flash_and_redirect @content.update(content_params), admin_assets_url, 'Asset updated successfully', 'There were problems updating the asset'
    end

    def show
      redirect_to :edit_admin_asset
    end

    private

    def set_objects
      @current_site = scribo_current_site
      @content = if params[:id]
                   @current_site.contents.where(kind: 'asset').find(params[:id])
                 else
                   params[:content] ? @current_site.contents.new(content_params) : @current_site.contents.new
                 end
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
