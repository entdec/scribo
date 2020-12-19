# frozen_string_literal: true

Scribo::Engine.routes.draw do
  namespace :admin, path: Scribo.config.admin_mount_point do
    resources :sites do
      resources :contents, controller: 'sites/contents' do
        member do
          put 'rename', as: :rename
        end
        collection do
          # post 'remote_create'
          post 'upload'
          put 'move', as: :move
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
  namespace :api do
    resources :sites do
      collection do
        post 'import'
      end
    end
  end

  root to: 'contents#show'
  get '(*path)', to: 'contents#show', as: 'content', constraints: ->(request) { !request.path.starts_with?('/rails') }
end
