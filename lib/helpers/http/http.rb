require 'uri'
require 'net/http'
require 'json'

class HTTPHelper

  def self.get(url, parse:false)
    url = URI(url) unless url.class == URI::Generic
    res = Net::HTTP.get_response(url)
    
    ret = res.body
    ret = JSON.parse(ret) if parse

    ret
  end
end