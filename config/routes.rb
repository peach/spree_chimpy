# TODO: upgrade-solidus-2-1
#Spree::Core::Engine.add_routes do
Spree::Core::Engine.routes.draw do
  namespace :chimpy, path: "" do
    resource :subscribers, only: [:create]
  end
end
