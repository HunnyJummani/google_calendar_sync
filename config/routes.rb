Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  devise_for :users
  get 'auth/google_oauth2/callback/', to: 'auth#redirect', as: :google_webhook
  get 'revoke_calendar_access', to: 'google_webhook#revoke_access', as: :revoke_access
  get 'fetch_events', to: 'google_webhook#fetch_events', as: :fetch_google_events
  get 'list_events', to: 'google_webhook#list_events', as: :list_events
  get '/redirect_to_google_auth', to: 'home#redirect'
  get '/create_channel', to: 'home#create_channel'
  get 'stop_channel', to: 'home#stop_channel'

  post '/google/web_hook/callback', to: 'google_webhook#callback', as: :callback


  namespace :event do
    resources :sessions
  end
  root 'home#index'
end
