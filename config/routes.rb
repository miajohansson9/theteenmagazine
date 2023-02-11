Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               sessions: 'users/sessions'
             }

  devise_scope :user do
    get '/login' => 'users/sessions#new'
    get '/onboarding' => 'users#onboarding'
    get '/editor-onboarding' => 'users#editor_onboarding'
    post '/writers' => 'users/registrations#create'
    post '/partners' => 'users#create'
  end

  resources :users, path: 'writers', except: [:new]
  resources :users, path: 'partners', only: [:new]
  resources :contacts, only: %i[new create]
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
  resources :invitations

  #asynchronously fetched
  get :get_trending_posts, controller: :welcome
  get :get_category_1_welcome, controller: :welcome
  get :get_category_2_welcome, controller: :welcome
  get :get_category_3_welcome, controller: :welcome
  get :get_category_4_welcome, controller: :welcome
  get :get_recent_posts, controller: :welcome

  get :get_trending_posts_in_category, controller: :posts
  get :get_conversations_following, controller: :posts
  get :get_promoted_posts, controller: :posts

  get :get_sent_invitations, controller: :invitations
  get :get_sent_invitations_admin, controller: :invitations
  get :dismissed_notification, controller: :invitations

  get :get_profile, controller: :users
  get :get_editor_stats, controller: :users
  get :get_past_invites, controller: :users
  get :get_published_articles, controller: :users

  get :get_editor_activity, controller: :reviews
  get :enable_notify_of_new_review, controller: :reviews
  get :disable_notify_of_new_review, controller: :reviews

  get :send_test_newsletter, controller: :newsletters

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
  get 'email-preferences' => 'pages#email_preferences'
  post 'email-preferences', to: 'pages#email_preferences'
  get 'trending' => 'pages#trending'
  get 'most-viewed' => 'pages#most_viewed'
  get 'newsletters/:id/featured-posts' => 'newsletters#featured'
  get 'reviews:post_id' => 'pages#reviews'
  get '/apply' => 'applies#new'
  get '/applications/editor', to: 'applies#editor'
  get '/submitted' => 'applies#create'
  get '/reset-password' => 'pages#reset'
  get '/search' => 'pages#search'
  get '/sitemap.xml', to: 'pages#sitemap'
  get '/users/:id', to: 'users#redirect'
  get '/partners/:id', to: 'users#partner'
  get '/partners/:id/edit', to: 'users#edit'
  get '/partners', to: 'users#partners'
  get '/editors', to: 'users#editors'
  get '/partners/:id/share', to: 'users#share'
  get '/writers/:id/extensions', to: 'users#extensions'
  get '/writers/:id/invitations', to: 'invitations#index'
  get '/writers/:slug/invitations/:token', to: 'invitations#show'
  get '/partners/:id/published', to: 'users#sponsored'
  get 'checkout', to: 'checkouts#show'
  get 'checkout/success', to: 'checkouts#success'
  get 'billing', to: 'billing#show'
  get '/september-2021-bexesyjj-bxducjpuj-hrhhqug-xqkoktbve', to: 'pages#issue'
  post '/september-2021-bexesyjj-bxducjpuj-hrhhqug-xqkoktbve', to: 'pages#issue'
  post '/posts/:id/subscribe', to: 'posts#subscribe'

  patch 'users/:id/:post_id/modal' => 'users#post_modal', :as => :post_modal
  patch 'users/:id/:post_id/promote' => 'users#promote_post',
        :as => :promote_post

  patch 'pitches/:id/modal' => 'pitches#pitch_modal', :as => :pitch_modal
  post 'pitches/:id/claim' => 'pitches#pitch_onboarding_claim',
       :as => :pitch_onboarding_claim
  patch 'pitches/:id/unclaim' => 'pitches#pitch_onboarding_unclaim',
        :as => :pitch_onboarding_unclaim

  post 'writers/:slug/invitations/:token/apply_through_invitation' =>
         'invitations#apply_through_invitation',
       :as => :apply_through_invitation

  get '/community', to: 'posts#index'
  post '/community', to: 'posts#index'

  resources :posts, only: %i[new create index] do
    member { patch :update_newsletter }
  end
  resources :posts, path: '', except: %i[new create]
end
