require 'uri'
require 'net/http'
require 'json'

class HTTPHelper
  def self.get(url)
    puts url

    url = URI(url) unless url.class == URI::Generic
    res = Net::HTTP.get_response(url)
    
    puts res.code
    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  def self.post_form(url, data)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    res = Net::HTTP.post_form(url, data)
    
    puts res.code
    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  def self.post_multipart_data(url, data)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(url)
    req.set_form data, 'multipart/form-data'

    res = http.request(req)

    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  def self.put(url, data)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Put.new(url, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    req.body = URI::encode_www_form(data)

    res = http.request(req)

    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  def self.delete(url, data)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Delete.new(url, { 'Content-Type' => 'application/x-www-form-urlencoded' })
    req.body = URI::encode_www_form(data)

    res = http.request(req)

    ret = res.body
    ret = JSON.parse(ret)

    ret
  end
end