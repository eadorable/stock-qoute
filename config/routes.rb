Rails.application.routes.draw do
  resources :stocks
  devise_for :users
  root 'home#index'
  get 'home/about'
end
