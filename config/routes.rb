Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "healthz", to: proc { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  namespace :api do
    resources :events, only: [:index, :show], param: :slug do
      resources :registrations, only: [:create, :index]
    end
  end

  root to: redirect("/index.html")
end
