HangmanLeague::Application.routes.draw do

  get "redeem_winnings/index"

  get "purchase_transactions", to: 'purchase_transactions#index', as: 'purchases'
  get "purchase_transactions/new", as: 'new_purchase'
  match "purchase_transactions/create", to: 'purchase_transactions#create', as: 'create_purchase'
  match "Transaction/PaymentRequest", to: 'purchase_transactions#simulate_purchase', as: 'mxit_purchase'


  resources :games, :except => [:edit, :update, :destroy] do
    get 'page/:page', :action => :index, :on => :collection
    member do
      get "letter/:letter", action: 'play_letter', as: 'play_letter'
    end
  end
  resources :users, :except => [:create, :new, :destroy] do
    collection do
      get 'stats', action: "stats"
      get 'my_rank', action: "show"
      get 'mxit_oauth', action: 'mxit_oauth', as: 'mxit_oauth'
      get 'profile', action: 'profile', as: 'profile'
    end
  end
  resources :feedback, :except => [:show, :edit, :update, :destroy]
  resources :winners, :except => [:edit, :update, :create, :new, :destroy]
  resources :redeem_winnings, :except => [:show, :edit, :update, :create, :new, :destroy]

  match '/define/:word', to: 'words#define', as: 'define_word'
  match '/facebook_oauth', to: 'users#facebook_oauth', as: 'facebook_oauth'
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/authorize', to: 'users#mxit_authorise', as: 'mxit_authorise'

  root :to => 'games#index'
end
