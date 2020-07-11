require 'jwt'
require_relative '../util/logging'

class Connector

  def initialize(ss, hs)
    @shared_secret = ss
    @hmac_secret = hs
    @streamserver = nil
  end

  def streamserver_is?(hosthdr)
    hosthdr == @streamserver
  end

  def set_hmac_secret(hs)
    @hmac_secret = hs
  end

  def set_streamserver?(hosthdr, token)
    ret = false
    begin
      if @streamserver.nil?
        Log.log.info "Stream server connected from #{hosthdr}"
        decoded_token = JWT.decode token, @hmac_secret, true, { algorithm: 'HS256' }
        pass = decoded_token[0]['data']
        Log.log.info "pass: #{pass}"
        Log.log.info "hmac_secret: #{@hmac_secret}"
        if pass == @shared_secret
            puts 'Shared secret is OK!'
            Log.log.info "Stream server successfully verified from #{hosthdr}"
            @streamserver = hosthdr #TODO something else?
            ret = true
        else
          Log.log.error "Extraneous connection from #{hosthdr}"
          ret = false
        end
      end
    rescue JWT::VerificationError => e
      Log.log.error e
      Log.log.error "Verification from #{hosthdr} failed"
      ret = false
    end
    ret
  end
end
