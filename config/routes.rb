Rails.application.routes.draw do
  root 'incidents#index'

  post 'slack/rootly' => 'slack#rootly'
end
