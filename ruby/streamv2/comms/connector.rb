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

  def self.get_hmac_secret
    r = nil
    begin
      # First look in the environment
      r = ENV.fetch('HMAC_SECRET')
      if r.nil?
        p "hmac_secret set via the environment"
      end
    rescue KeyError
      p "no hmac_secret in the environment"
      # Look in the .hmac file in the project root

      hmac_path = "#{Dir.pwd}/.hmac"
      if File.exists? hmac_path
        r = File.read(hmac_path).gsub("\n", '')
      else
        abort("No HMAC_SECRET found")
      end
    end

    r
  end
end
