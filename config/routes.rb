# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root 'gauges#index', as: :authenticated_root
  end

  devise_scope :user do
    root to: 'devise/sessions#new'
  end

  resources :gauges do
    resources :readings do
      member do
        patch :approve
      end
    end
  end
end
