HangmanLeague::Application.routes.draw do

  resources :games, :except => [:edit, :update, :destroy] do
    get 'page/:page', :action => :index, :on => :collection
    member do
      get "letter/:letter", action: 'play_letter', as: 'play_letter'
    end
  end
  resources :users, :except => [:create, :new, :destroy] do
    collection do
      get 'my_rank', action: "show"
      get 'mxit_oauth', action: 'mxit_oauth', as: 'mxit_oauth'
      get 'profile', action: 'profile', as: 'profile'
    end
  end
  resources :feedback, :except => [:show, :edit, :update, :destroy]
  resources :winners, :except => [:edit, :update, :create, :new, :destroy]

  match '/define/:word', to: 'words#define', as: 'define_word'
  match '/facebook_oauth', to: 'users#facebook_oauth', as: 'facebook_oauth'
  match '/auth/:provider/callback', to: 'sessions#create'
  match '/authorize', to: 'users#mxit_authorise', as: 'mxit_authorise'

  root :to => 'games#index'
end
