SaasySimple::Engine.routes.draw do
  post "subscriptions/activate",   :controller => 'subscriptions', :action => 'activate'
  get  "subscriptions/billing",    :controller => 'subscriptions', :action => 'billing'
  post "subscriptions/deactivate", :controller => 'subscriptions', :action => 'deactivate'
  post "subscriptions/change", :controller => 'subscriptions', :action => 'change'

  post "orders/complete", :controller=>"orders", :action=>"complete"
  
end
