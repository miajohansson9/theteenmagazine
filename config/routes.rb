Rails.application.routes.draw do
  devise_for :users
  resources :posts
  resources :contacts, only: [:new, :create]
  resources :users

  get 'welcome/index'
  root 'welcome#index'

  get '*path' => redirect('/')
end
