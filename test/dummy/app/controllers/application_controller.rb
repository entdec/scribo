# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  prepend_before_action :cleanup_authentication
  before_action :set_current_objects

  private

  def set_current_objects
    @current_account = Account.find_by_name('Theme')
    @current_account.current!
  end

  def cleanup_authentication
    Account.reset_current!
  end

  def default_url_options
    { host: 'example.com' }
  end
end
