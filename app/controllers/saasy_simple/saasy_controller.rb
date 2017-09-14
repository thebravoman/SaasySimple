module SaasySimple
	class SaasyController < ApplicationController
		
		protected
		def check_secure_call
			if !(Digest::MD5.hexdigest(params["security_data"] + SaasySimple.config.secret) == params["security_hash"])
        render :text=>"", :status=>:unauthorize
			end
		end
	end

end
