TourConf::Application.routes.draw do
  namespace :admin do
    resources :conferences
    resources :events
    resources :sessions, only: [:new, :create, :edit, :update, :destroy]
    resources :speakers

    root to: 'conferences#index'
  end
end
