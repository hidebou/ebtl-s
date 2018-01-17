Rails.application.routes.draw do
  root to: 'top#index'

  get 'top/index'
  get 'top/crawl'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
