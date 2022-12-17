Rails.application.routes.draw do
  resources :line_items
  resources :carts
  resources :instruments

  root 'instruments#index'

  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
