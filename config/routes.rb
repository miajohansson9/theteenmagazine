Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations"}

  resources :users
  resources :contacts, only: [:new, :create]
  resources :applies
  resources :categories

  get 'welcome/index'
  root 'welcome#index'

  get 'criteria' => 'pages#criteria'
  get 'about-us' => 'pages#team'
  get 'choosing-a-topic' => 'pages#topics'
  get 'writing-the-perfect-article' => 'pages#writing'
  get 'finding-images' => 'pages#images'
  get 'how-to-style-your-articles' => 'pages#styling'
  get 'ranking' => 'pages#ranking'
  get 'privacy-policy' => 'pages#privacy'
  get "/login" => "users/sessions#new" # custom path to login/sign_in
  get "/apply" => "applies#new"
  get "/submitted" => "applies#create"

  resources :posts, only: [:new, :create]
  resources :posts, path: "", except: [:new, :create]

  get '*path' => redirect('/')

end
