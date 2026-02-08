Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"

  # Temporary debug endpoint - remove after debugging
  get "debug/github" => ->(env) {
    token_present = ENV['GITHUB_TOKEN'].present?
    token_preview = ENV['GITHUB_TOKEN'].to_s[0..10] + "..." if token_present
    curl_exists = system("which curl > /dev/null 2>&1")

    [200, {"Content-Type" => "text/plain"}, [
      "GITHUB_TOKEN present: #{token_present}\n",
      "Token preview: #{token_preview}\n",
      "Curl available: #{curl_exists}\n"
    ]]
  }
end
