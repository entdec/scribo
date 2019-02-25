# frozen_string_literal: true

Scribo::Engine.routes.draw do
  namespace :admin, path: Scribo.config.admin_mount_point do
    root to: 'buckets#index'
    resources :buckets do
      resources :assets, controller: 'buckets/assets'
      resources :contents, controller: 'buckets/contents' do
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
  get '(*path)', to: 'contents#show', as: 'content', constraints: ->(request) { !request.path.starts_with?('/rails') }
end
