# frozen_string_literal: true

Rails.application.routes.draw do
  resource :accounts
  mount Scribo::Engine => '/'
end
