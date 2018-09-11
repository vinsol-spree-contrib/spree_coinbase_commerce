Spree::Core::Engine.add_routes do
  get '/coinbase/redirect', :to => "coinbase#redirect", :as => :coinbase_redirect
  post '/coinbase/callback', :to => "coinbase#callback", :as => :coinbase_callback
end
