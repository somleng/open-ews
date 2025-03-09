Rails.application.routes.draw do
  devise_scope :user do
    resource(
      :registration,
      only: %i[edit update],
      controller: "users/registrations",
      as: :user_registration,
      path: "users"
    )
  end

  devise_for :users,
             controllers: { invitations: "users/invitations" },
             skip: :registrations

  get "dashboard", to: "dashboard/home#index", as: :user_root
  root to: "dashboard/home#index"

  namespace :admin do
    mount(PgHero::Engine, at: "pghero")
  end

  namespace "dashboard" do
    root to: "home#index"
    resources :access_tokens
    resource :account, only: %i[edit update]

    namespace :settings do
      root to: "account#show"

      resource :account, only: :show
      resources :users, only: :index
      resources :developers, only: :index
    end

    namespace :batch_operation do
      resources :callout_populations, only: %i[edit update]
    end

    resources :batch_operations, only: %i[index show destroy] do
      resources :batch_operation_events, only: :create
    end

    resources :beneficiaries do
      resources :alerts, only: :index
      resources :delivery_attempts, only: :index
    end

    resources :broadcasts do
      namespace :batch_operation do
        resources :callout_populations, only: %i[new create]
      end
      resources :batch_operations, only: %i[index destroy]
      resources :callout_events, only: :create
      resources :alerts, only: :index
      resources :delivery_attempts, only: :index
    end

    resources :alerts, only: %i[index show destroy] do
      resources :delivery_attempts, only: :index
    end

    resources :delivery_attempts, only: %i[index show] do
      resources :remote_phone_call_events, only: :index
    end

    resources :remote_phone_call_events, only: %i[index show]
    resources :users, except: %i[new create]
    resources :recordings, only: %i[index show]
    resource :locale, only: :update
  end

  namespace :v1, module: "api/v1", as: "api_v1", defaults: { format: "json" } do
    resources :broadcasts, only: [ :index, :show, :create, :update ] do
      resources :alerts, controller: "broadcasts/alerts", only: [ :index, :show ] do
        get "stats" => "broadcasts/alerts/stats#index", on: :collection
      end
    end

    resources :beneficiaries, only: [ :index, :create, :show, :update, :destroy ] do
      get "stats" => "beneficiaries/stats#index", on: :collection
      resources :addresses, only: [ :index, :create, :show, :destroy ]
    end
  end

  namespace "api", defaults: { format: "json" } do
    resources :callouts, except: %i[new edit] do
      resources :callout_events, only: :create
      resources :callout_participations, only: %i[index]
      resources :phone_calls, only: :index
      resources :batch_operations, only: %i[create index]
    end

    resources :batch_operations, except: %i[new edit] do
      resources :batch_operation_events, only: :create
    end

    resources :phone_calls, only: %i[index show]
    resources :recordings, only: %i[index show]
  end

  namespace :twilio_webhooks, defaults: { format: :xml } do
    resources :recording_status_callbacks, only: :create
    resources :phone_call_events, only: :create
  end
end
