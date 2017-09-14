require 'digest/md5'
require 'open-uri'

module SaasySimple
  class SubscriptionsController < ApplicationController

    before_action only: [:activate, :deactivate] do 
      check_secure_call
    end

    def activate
      SaasySimple.config.model.activate( params['token'], params['id'] )
    end

    def billing
      return unless current_user
      if current_user.status == 'active'
        subscription = SaasySimple.subscription(current_user)
        redirect_to subscription['customerUrl']
      else
        redirect_to SaasySimple.signup(SaasySimple.config.url,current_user)
      end
    end

    def deactivate
      SaasySimple.config.model.deactivate( params['token'], params['id'] )
    end
  end
end
