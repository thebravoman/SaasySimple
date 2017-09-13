require 'digest/md5'
require 'open-uri'

module SaasySimple
  class OrdersController < ApplicationController
    def complete
      if Digest::MD5.hexdigest(params["security_data"] + SaasySimple.config.secret) == params["security_hash"]
        SaasySimple.config.model.order_complete( params['token'], params['id'] )
      end
    end
  end
end
