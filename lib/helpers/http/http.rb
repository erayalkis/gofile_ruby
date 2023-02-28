require 'uri'
require 'net/http'

class HTTPHelper

  def self.get(url)
    url = URI(url) unless url.class == URI::Generic
    res = Net::HTTP.get_response(url)

    puts res.body
  end

end