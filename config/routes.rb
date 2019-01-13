# frozen_string_literal: true

Scribo::Engine.routes.draw do
  namespace :admin do
    resources :sites do
      resources :assets, controller: 'sites/assets'
      resources :contents, controller: 'sites/contents' do
        member do
          post :preview
        end
      end
      member do
        get 'export'
      end
      collection do
        get 'import'
        post 'import'
      end
    end
  end

  root to: 'contents#show'
  get '(*path)', to: 'contents#show', as: 'content'
end
