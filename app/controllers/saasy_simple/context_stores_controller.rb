module SaasySimple
  class ContextStoresController < ActionController::API
    include ActionController::MimeResponds

    before_action only: [:activate, :deactivate, :change] do 
      check_secure_call
    end


    def activate
      body_json = JSON.parse(request.body.read)
      ActiveRecord::Base.transaction do
        body_json["events"].each  do |event|
          payload = event["data"]
          token = payload["subscription"]
          user_id = payload.try(:[],'tags').try(:[], 'fllcastsUserUuid')

          raise "Account id not found in the payload: #{payload}" if user_id.nil?

          SaasySimple.config.model.context_stores_activate(token, user_id, payload)
        end
      end

      render :json=> {}, :status=> 200
    end

    def deactivate
      raise "Complex Stores called deactivate"
      # SaasySimple.config.model.deactivate( params['token'], params['id'], params )
    end

    protected
    def check_secure_call
      body = request.body.read
      server_encoded_secret = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), SaasySimple.config.secret, body)).strip()
      if server_encoded_secret != request.headers["X-FS-Signature"]
        render :text=>"", :status=> :unauthorized
      end
    end
  end

end
