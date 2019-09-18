# frozen_string_literal: true

Scribo::Engine.routes.draw do
  namespace :admin, path: Scribo.config.admin_mount_point do
    root to: 'sites#index'
    resources :sites do
      resources :assets, controller: 'sites/assets' do
        member do
          get 'destroy', as: :destroy
        end
      end
      resources :contents, controller: 'sites/contents' do
        member do
          get 'destroy', as: :destroy
        end
        resources :parts, controller: 'sites/contents/parts'
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
