# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  prepend_before_action :cleanup_authentication
  before_action :set_current_objects

  private

  def set_current_objects
    @current_account = Account.find_by(id: request.headers['X-ACCOUNT'])
    @current_account&.current!
  end

  def cleanup_authentication
    Account.reset_current!
  end

  def default_url_options
    if Rails.env.test?
      { host: 'example.com' }
    else
      {}
    end
  end
end
