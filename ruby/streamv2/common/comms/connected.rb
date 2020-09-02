require_relative '../util/config'
require_relative 'connector'

module Connected

  @@connector = Connector.new(
    MP3S::Config::Misc::SHARED_SECRET,
    Connector.get_hmac_secret
  )

  def allowed(request)
    remote_ip = request.env['HTTP_HOST']
    ret = true
    if !@@connector.streamserver_is?(remote_ip)
      unless request.path_info.start_with? '/pass/'
        puts 'Remote IP mispatch! Denying request.'
        Log.log.error "Remote IP not streamserver! #{@remote_ip}"
        ret = false
      end
    end
    ret
  end

  def set_streamserver?(request, token)
    @@connector.set_streamserver?(request.env['HTTP_HOST'], token)
  end

end
