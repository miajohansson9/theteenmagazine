Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations"}
  resources :posts
  resources :contacts, only: [:new, :create]
  resources :users
  resources :categories, only: [:new, :edit, :show]
  resources :applies, only: [:new, :create]

  get 'welcome/index'
  root 'welcome#index'

  get 'beauty' => 'categories#beauty'


  get 'criteria' => 'pages#criteria'
  get 'choosing-a-topic' => 'pages#topics'
  get 'writing-the-perfect-article' => 'pages#writing'
  get 'finding-images' => 'pages#images'
  get 'how-to-style-your-articles' => 'pages#styling'


  get '*path' => redirect('/')
end
