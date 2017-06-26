Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations"}
  resources :users
  resources :contacts, path: "", only: [:new, :create]
  resources :categories, only: [:new, :edit, :show]
  resources :applies, path: "", only: [:new, :create]

  get 'welcome/index'
  root 'welcome#index'

  get 'contact-us' => 'contacts#new'
  get 'apply' => 'applies#new'

  get 'criteria' => 'pages#criteria'
  get 'choosing-a-topic' => 'pages#topics'
  get 'writing-the-perfect-article' => 'pages#writing'
  get 'finding-images' => 'pages#images'
  get 'how-to-style-your-articles' => 'pages#styling'
  get 'ranking' => 'pages#ranking'

  resources :posts, only: [:new, :create]
  resources :posts, path: "", except: [:new, :create]

  get '*path' => redirect('/')

end
