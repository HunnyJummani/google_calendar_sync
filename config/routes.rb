Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  get 'auth/google_oauth2/callback/', to: 'auth#redirect', as: :google_webhook
  get 'revoke_calendar_access', to: 'google_webhook#revoke_access', as: :revoke_access
  get 'fetch_events', to: 'google_webhook#fetch_events', as: :fetch_google_events
  get 'list_events', to: 'google_webhook#list_events', as: :list_events
  get '/redirect', to: 'home#redirect'
  get '/create_channel', to: 'home#create_channel'
  get 'stop_channel', to: 'home#stop_channel'

  post '/google/web_hook/callback', to: 'google_webhook#callback', as: :callback

  resources :sessions

  devise_for :users, path: 'users', controllers: {
    registrations: 'registrations',
    confirmations: 'confirmations',
    passwords: 'users/passwords',
    invitations: 'users/invitations',
    sessions: 'users/sessions'
  }
  root 'home#index'
end
