Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_scope :user do
    # get "/sign_in" => "users/sessions#new" # custom path to login/sign_in
    get "/apply" => "users/registrations#new", as: "new_user_registration" # custom path to sign_up/registration
  end
  devise_for :users, controllers: { :registrations => "users/registrations", :confirmations => "users/confirmations" }

  resources :users
  resources :contacts, only: [:new, :create]
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
  get 'submitted' => 'pages#submitted'

  resources :posts, only: [:new, :create]
  resources :posts, path: "", except: [:new, :create]

  get '*path' => redirect('/')

end
