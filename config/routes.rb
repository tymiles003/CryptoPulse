Rails.application.routes.draw do
  resources :configs
  scope :api, defaults: {format: :json} do
    resources :configs, only: [:index, :show, :update]
  end
end
