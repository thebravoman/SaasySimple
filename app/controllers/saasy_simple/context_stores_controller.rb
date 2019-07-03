module SaasySimple
  class ContextStoresController < ActionController::API
    include ActionController::MimeResponds

    before_action only: [:activate, :deactivate, :update] do
      check_secure_call
      @payload = JSON.parse(request.body.read)
    end

    def activate
      SaasySimple.config.model.context_stores_handle_payload(@payload)
      render json: {}, status: 200
    end

    def update
      SaasySimple.config.model.context_stores_handle_payload(@payload)
      render json: {}, status: 200
    end

    def deactivate
      SaasySimple.config.model.context_stores_handle_payload(@payload)
      render json: {}, status: 200
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
