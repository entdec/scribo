# frozen_string_literal: true

Scribo::Engine.routes.draw do
  namespace :admin do
    resources :sites do
      member do
        get 'export'
      end
      collection do
        get 'import'
        post 'import'
      end
    end
    resources :assets
    resources :contents
  end

  root to: 'contents#show'
  get '(*path)', to: 'contents#show'
end
