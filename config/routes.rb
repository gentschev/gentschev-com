Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Resume PDFs at shareable URLs: /resume-ai-agents, /resume-data-platform, etc.
  # Routes are generated from config/content/resumes.yml, so adding a variant
  # there (plus the PDF in resumes/) is all it takes. The first entry is the
  # primary one that bare /resume redirects to.
  resume_variants = YAML.safe_load_file(Rails.root.join("config/content/resumes.yml")).keys
  resume_variants.each do |slug|
    get "resume-#{slug}", to: "resumes#show", defaults: { variant: slug }
  end
  # 302, not the redirect() default of 301: a permanent redirect gets cached by
  # browsers forever, which would strand people on the old primary if it changes.
  get "resume", to: redirect("/resume-#{resume_variants.first}", status: 302)

  # Defines the root path route ("/")
  root "pages#home"
end
