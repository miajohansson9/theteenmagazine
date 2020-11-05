Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations", :sessions => "users/sessions"}

  devise_scope :user do
    get "/login" => "users/sessions#new"
    get "/onboarding" => "users#onboarding"
    post "/writers" => "users/registrations#create"
    post "/partners" => "users#create"
  end

  resources :users, path: "writers", except: [:new]
  resources :users, path: "partners", only: [:new]
  resources :contacts, only: [:new, :create]
  resources :applies
  resources :categories
  resources :pitches
  resources :reviews
  resources :feedbacks
  resources :analytics
  resources :comments
  resources :outreaches

  get 'welcome/index'
  root 'welcome#index'

  get 'community' => 'posts#index'
  get 'criteria' => 'pages#criteria'
  get 'about-us' => 'pages#team'
  get 'contact-us' => 'pages#contact'
  get 'choosing-a-topic' => 'pages#topics'
  get '/pitch-requirements' => 'pages#reviewing_pitches'
  get '/article-requirements' => 'pages#reviewing_articles'
  get '/pitching-new-articles' => 'pages#pitching_new_articles'
  get '/editor-requirements' => 'pages#start'
  get '/editor-onboarding' => 'users#editor_onboarding'
  get '/editors/:id' => 'reviews#index'
  get 'writing-the-perfect-article' => 'pages#writing'
  get 'finding-images' => 'pages#images'
  get 'formatting' => 'pages#formatting'
  get 'checklist' => 'pages#checklist'
  get 'ranking' => 'pages#ranking'
  get 'privacy-policy' => 'pages#privacy'
  get 'subscribe' => 'pages#subscribe'
  get 'reviews:post_id' => 'pages#reviews'
  get 'newsletter' => 'pages#newsletter'
  get "/apply" => "applies#new"
  get '/applications/editor', to: 'applies#editor'
  get "/submitted" => "applies#create"
  get "/reset-password" => "pages#reset"
  get "/search" => "pages#search"
  get '/sitemap.xml', to: 'pages#sitemap'
  get '/ads.txt', to: 'pages#ads'
  get '/users/:id', to: 'users#redirect'
  get '/partners/:id', to: 'users#partner'
  get '/partners/:id/edit', to: 'users#edit'
  get '/partners', to: 'users#partners'
  get '/partners/:id/share', to: 'users#share'
  get '/partners/:id/published', to: 'users#sponsored'
  get '/september_2020_mbDFSSOqy0rqUJrgazud', to: 'pages#issue'
  post '/september_2020_mbDFSSOqy0rqUJrgazud', to: 'pages#issue'

  get '/community', to: 'posts#index'
  post '/community', to: 'posts#index'

  resources :posts, only: [:new, :create, :index]
  resources :posts, path: "", except: [:new, :create]

  get '*path' => redirect('/')
end
