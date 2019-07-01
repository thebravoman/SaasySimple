module SaasySimple
  class ContextStoresController < ActionController::API
    include ActionController::MimeResponds

    before_action only: [:activate, :deactivate, :change] do 
      check_secure_call
    end

    def get_user_id_from payload
      user_id = payload.try(:[],'tags').try(:[], 'fllcastsUserUuid')
      raise "Account id not found in the payload: #{payload}" if user_id.nil?

      user_id
    end

    def order_completed event
      payload = event["data"]
      user_id = get_user_id_from(payload)
      # invoiceUrl : "https://axle.onfastspring.com/account/order/AXL190628-4729-45305/invoice"
      # payload["invoiceUrl"]

      # reference : "AXL190628-4729-45305"
      # payload["reference"]

      # email of account of purchase
      # payload["account"]["contact"]["email"]
      # payload["account"]["contact"]["first"] -> firstName
      # payload["account"]["contact"]["last"] -> lastName
      # account id and fastspring url for user
      # payload["account"]["account"]
      # payload["account"]["url"] ->  "https://axle.onfastspring.com/account"
      payload["items"].each do |order_item|
        next if order_item.include?("subscription")
        token = payload["reference"] + "-FLLCasts-PO-#{SecureRandom.hex(6)}"
        order_item["live"] = payload["live"]
        # Maybe state should be purchase_order. And we know that it is po
        order_item["state"] = "active"
        # This is the next period date. Which will be set automatically,
        number_of_months = order_item["product"].split("-")[2].to_i
        order_item["nextInSeconds"] = (Time.at(payload["changedInSeconds"]) + number_of_months.months).to_i

        # This is needed so the PO subscription will end. Because
        # Fastspring won't send a notification our way.
        order_item["SubscriptionEndDate"] = order_item["nextInSeconds"]

        # Other infomation we will need in the future.
        # invoice url:
        SaasySimple.config.model.context_stores_activate(token, user_id, order_item)
      end
    end

    def subscription_activated event
      payload = event["data"]
      token = payload["subscription"]
      user_id = get_user_id_from(payload)

      SaasySimple.config.model.context_stores_activate(token, user_id, payload)
    end

    def activate
      body = request.body.read
      body_json = JSON.parse(body)
      ActiveRecord::Base.transaction do
        body_json["events"].each  do |event|
          self.send(event["type"].gsub(".","_"), event)
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
