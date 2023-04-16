Rails.application.routes.draw do
  root 'incidents#index'

  post 'slack/rootly' => 'slack#rootly'
  get 'auth/slack/callback', to: 'auth#slack_callback'
end
