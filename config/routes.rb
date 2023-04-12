Rails.application.routes.draw do
  root 'incidents#index'

  post 'slack/declare' => 'slack#declare'
end
