require 'digest/md5'
require 'open-uri'

module SaasySimple
  class OrdersController < SaasyController
    
    before_action only: [:complete] do 
      check_secure_call
    end

    def complete
       SaasySimple.config.model.order_complete( params['token'], params['id'] )
    end
    
  end
end
