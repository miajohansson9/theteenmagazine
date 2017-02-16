Rails.application.routes.draw do
  devise_for :users,
      controllers: {:registrations => "users/registrations"}
  resources :posts
  resources :contacts, only: [:new, :create]
  resources :users
  resources :applies, only: [:new, :create]

  get 'welcome/index'
  root 'welcome#index'

  get '*path' => redirect('/')
end
