# frozen_string_literal: true

require_dependency 'scribo/application_controller'

module Scribo
  class Admin::ContentsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_objects, except: [:index]
    authorize_resource class: Content

    add_breadcrumb I18n.t('scribo.breadcrumbs.admin.contents'), :admin_contents_path

    def new
      render :edit
    end

    def create
      flash_and_redirect @content.save, admin_contents_url, 'Content created successfully', 'There were problems creating the content'
    end

    def index
      @contents = Content.where(kind: %w[text redirect]).order(:scribo_site_id)
    end

    def edit
      @content = Content.find(params[:id])
    end

    def update
      flash_and_redirect @content.update(content_params), admin_contents_url, 'Content updated successfully', 'There were problems updating the content'
    end

    def show
      redirect_to :edit_admin_content
    end

    def preview
      @content = Content.find(params[:id])
      @content.data = params[:data]
      render body: @content.render(request: ActionDispatch::RequestDrop.new(request)), content_type: @content.content_type, layout: false
    end

    private

    def set_objects
      @current_site  = scribo_current_site
      @content       = if params[:id]
                         Content.where(kind: %w[text redirect]).find(params[:id])
                       else
                         params[:content] ? Content.new(content_params) : Content.new
                       end
      @layouts       = Content.where(kind: %w[text redirect]).where.not(identifier: nil).where.not(id: @content.id)
      @content_types = Content::SUPPORTED_MIME_TYPES[:text]
      @states        = Scribo::Content.state_machine.states.map(&:value)
      @sites         = Scribo::Site.order(:name)
      @kinds         = %w[text redirect]
    end

    def content_params
      params.require(:content).permit(:scribo_site_id, :kind, :state, :path, :content_type, :layout_id, :breadcrumb, :name, :identifier, :filter, :title, :keywords, :description, :data).tap do |w|
        w[:kind] = 'text' if w[:kind].blank?
      end
    end
  end
end
