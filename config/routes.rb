Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users, controllers: {:registrations => "users/registrations", :sessions => "users/sessions"}

  devise_scope :user do
    get "/login" => "users/sessions#new"
    get "/onboarding" => "users#onboarding"
    get "/editor-onboarding" => "users#editor_onboarding"
    post "/writers" => "users/registrations#create"
    post "/partners" => "users#create"
  end

  resources :posts do
    member do
      patch :update_newsletter
    end
  end
  resources :users, path: "writers", except: [:new]
  resources :users, path: "partners", only: [:new]
  resources :contacts, only: [:new, :create]
  resources :applies
  resources :categories
  resources :pitches
  resources :reviews
  resources :feedbacks
  resources :constants
  resources :analytics
  resources :comments
  resources :outreaches
  resources :newsletters

  #asynchronously fetched
  get :get_trending_posts, controller: :welcome
  get :get_category_1_welcome, controller: :welcome
  get :get_category_2_welcome, controller: :welcome
  get :get_category_3_welcome, controller: :welcome
  get :get_category_4_welcome, controller: :welcome
  get :get_recent_posts, controller: :welcome

  get :get_trending_posts_in_category, controller: :posts
  get :get_conversations_following, controller: :posts

  get :get_profile, controller: :users
  get :get_editor_stats, controller: :users

  get :get_editor_activity, controller: :reviews
  get :enable_notify_of_new_review, controller: :reviews
  get :disable_notify_of_new_review, controller: :reviews

  get 'welcome/index'
  root 'welcome#index'

  get '/community' => 'posts#index'
  get '/drafts/:id' => 'posts#preview_draft'
  get '/drafts/:id/edit' => 'posts#edit'
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
  get 'trending' => 'pages#trending'
  get 'newsletters/:id/featured-posts' => 'newsletters#featured'
  get 'reviews:post_id' => 'pages#reviews'
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
  get '/editors', to: 'users#editors'
  get '/partners/:id/share', to: 'users#share'
  get '/writers/:id/extensions', to: 'users#extensions'
  get '/partners/:id/published', to: 'users#sponsored'
  get '/january_2021_773ae935-d06c-4ed2-b939-4aaee072bfd4', to: 'pages#issue'
  post '/january_2021_773ae935-d06c-4ed2-b939-4aaee072bfd4', to: 'pages#issue'

  patch 'pitches/:id/modal' => 'pitches#pitch_modal', as: :pitch_modal
  post 'pitches/:id/claim' => 'pitches#pitch_onboarding_claim', as: :pitch_onboarding_claim
  patch 'pitches/:id/unclaim' => 'pitches#pitch_onboarding_unclaim', as: :pitch_onboarding_unclaim

  get '/community', to: 'posts#index'
  post '/community', to: 'posts#index'

end
