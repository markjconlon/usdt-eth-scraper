Rails.application.routes.draw do
  get 'trades/index'

  get 'trades/show'

  post 'trades/check_trades'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
