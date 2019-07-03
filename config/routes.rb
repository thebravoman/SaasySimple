SaasySimple::Engine.routes.draw do
  post "subscriptions/activate",   :controller => 'subscriptions', :action => 'activate'
  get  "subscriptions/billing",    :controller => 'subscriptions', :action => 'billing'
  post "subscriptions/deactivate", :controller => 'subscriptions', :action => 'deactivate'
  post "subscriptions/change", :controller => 'subscriptions', :action => 'change'

  post "context_stores/activate",   :controller => 'context_stores', :action => 'activate'
  get  "context_stores/billing",    :controller => 'context_stores', :action => 'billing'
  post "context_stores/deactivate", :controller => 'context_stores', :action => 'deactivate'
  post "context_stores/update", :controller => 'context_stores', :action => 'update'

  post "orders/complete", :controller=>"orders", :action=>"complete"
  
end
