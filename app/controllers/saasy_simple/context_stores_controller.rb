module SaasySimple
  class ContextStoresController < ActionController::API
  include ActionController::MimeResponds

    before_action only: [:activate, :deactivate, :change] do 
      check_secure_call
    end


    def activate
      events_data = JSON.parse(request.body.read)["events"]
      raise "Events data has more than one event: #{events_data}" if events_data.count > 1
      subscription_data = events_data[0]["data"]
      payload = subscription_data
      token = payload["subscription"]
      user_id = payload['tags']['fllcastsUserUuid']
      
      unless user_id
        raise "Account id not found in the payload: #{payload}"
      end

      SaasySimple.config.model.context_stores_activate(token, user_id, payload)
    end

    def deactivate
      raise "Complex Stores called deactivate"
      # SaasySimple.config.model.deactivate( params['token'], params['id'], params )
    end

    protected
    def check_secure_call
      server_encoded_secret = Base64.encode64(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, request.body.read)).strip()
      if server_encoded_secret != request.params["HTTP_X_FS_SIGNATURE"]
        render :text=>"", :status=>:unauthorize
      end
    end
  end

end
