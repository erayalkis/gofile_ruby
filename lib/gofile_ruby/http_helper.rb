require 'uri'
require 'net/http'
require 'json'

# A module for simplifying HTTP requests
module HTTPHelper
  # Makes a GET request to the specified URL.
  #
  # If the given URL is a string, it gets converted to a URI.
  # @param [String, URI] url The URL for the request.
  def self.get(url)
    url = URI(url) unless url.class == URI::Generic
    res = Net::HTTP.get_response(url)
    
    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  # POSTs the data as a form to the specified URL.
  #
  # If the given URL is a string, it gets converted to a URI.
  # @param [String, URI] url The URL for the request.
  # @param [Hash] data The data for the post request.
  def self.post_form(url, data)
    raise "No form data provided!" unless data
    url = URI(url) unless url.class == URI::Generic

    res = Net::HTTP.post_form(url, data)
    
    ret = res.body
    ret = JSON.parse(ret)

    ret
  end

  # Takes an array of arrays and POSTs them as multipart form data to the specified URL.
  #
  # If the given URL is a string, it gets converted to a URI.
  # @param [String, URI] url The URL for the request.
  # @param [Array<Array<String, T>>] data The data for the post request.
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

  # Makes a PUT request to the specified URL.
  #
  # If the given URL is a string, it gets converted to a URI.
  # @param [String, URI] url The URL for the request.
  # @param [Array<Array<String, T>>] data The data for the post request.
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

  # Makes a DELETE request to the specified URL.
  #
  # If the given URL is a string, it gets converted to a URI.
  # @param [String, URI] url The URL for the request.
  # @param [Array<Array<String, T>>] data The data for the post request.
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