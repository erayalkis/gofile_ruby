require 'uri'
require 'net/http'
require 'json'

class HTTPHelper
  def self.get(url, parse)
    url = URI(url) unless url.class == URI::Generic
    res = Net::HTTP.get_response(url)
    
    puts res.code
    ret = res.body
    ret = JSON.parse(ret) if parse

    ret
  end

  def self.post_form(url, data, parse)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    res = Net::HTTP.post_form(url, data)
    
    puts res.code
    ret = res.body
    ret = JSON.parse(ret) if parse

    ret
  end

  def self.put(url, data, parse)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Put.new(url, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    req.body = URI::encode_www_form(data)

    res = http.request(req)

    ret = res.body
    ret = JSON.parse(ret) if parse

    ret
  end
end