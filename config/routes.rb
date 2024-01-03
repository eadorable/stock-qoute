Rails.application.routes.draw do
  resources :stocks do
    member do
      patch :update_price
    end
  end

  devise_for :users
  root 'home#index'
  get 'home/about'
end
