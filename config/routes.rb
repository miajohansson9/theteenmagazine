Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations"}

  devise_scope :user do
    get "/login" => "users/sessions#new"
    get "/onboarding" => "users#onboarding"
  end

  resources :users
  resources :contacts, only: [:new, :create]
  resources :applies
  resources :categories
  resources :pitches
  resources :reviews
  resources :feedbacks

  get 'welcome/index'
  root 'welcome#index'

  get 'criteria' => 'pages#criteria'
  get 'about-us' => 'pages#team'
  get 'choosing-a-topic' => 'pages#topics'
  get 'writing-the-perfect-article' => 'pages#writing'
  get 'finding-images' => 'pages#images'
  get 'how-to-style-your-articles' => 'pages#styling'
  get 'formatting' => 'pages#formatting'
  get 'checklist' => 'pages#checklist'
  get 'ranking' => 'pages#ranking'
  get 'privacy-policy' => 'pages#privacy'
  get 'subscribe' => 'pages#subscribe'
  get "/apply" => "applies#new"
  get "/submitted" => "applies#create"

  resources :posts, only: [:new, :create]
  resources :posts, path: "", except: [:new, :create]

  get '*path' => redirect('/')
end
