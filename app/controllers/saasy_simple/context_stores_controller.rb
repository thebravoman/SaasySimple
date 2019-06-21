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
      body = request.body.read
      server_encoded_secret1 = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, body)).strip()
      server_encoded_secret2 = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, body))
      server_encoded_secret3 = Base64.encode64(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, body)).strip()
      server_encoded_secret4 = Base64.encode64(OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, body))
      
      Rails.logger.info("server_encoded_secret1: #{server_encoded_secret1}")
      Rails.logger.info("server_encoded_secret2: #{server_encoded_secret2}")
      Rails.logger.info("server_encoded_secret3: #{server_encoded_secret3}")
      Rails.logger.info("server_encoded_secret4: #{server_encoded_secret4}")

      Rails.logger.info("request_params_x_fs_signature: #{request.headers["X-FS-Signature"]}")
      Rails.logger.info("request.body: #{body}")
      if server_encoded_secret1 != request.headers["X-FS-Signature"]
        render :text=>"", :status=> :unauthorized
      end
    end
  end

end
