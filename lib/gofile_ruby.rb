require './lib/helpers/http/http.rb'

class GFClient
  def self.test
    puts "This is a test message!"
  end

  def get_server(parse:false)
    target_url = "https://api.gofile.io/getServer"
    HTTPHelper.get(target_url, parse:parse)
  end
end