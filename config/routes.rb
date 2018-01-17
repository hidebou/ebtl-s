Rails.application.routes.draw do
  get 'crawl/get_page'

  root to: 'top#index'

  get 'top/index'
  get 'top/crawl'

  namespace :api, { format: 'json' } do
    resource :crawl do
      member do 
        get :get_page
      end
    end
  end


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
