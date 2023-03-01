require './lib/helpers/http/http.rb'

class GFClient

  def initialize(token:nil, guest:false)
    @token = token
    @isGuest = guest
    @accDetails = nil

    @isGuest = false if @token
    test_token_validity unless @isGuest
  end

  def get_server(parse:false)
    server_url = "https://api.gofile.io/getServer"
    HTTPHelper.get(server_url, parse)
  end

  def create_folder(parent_id:nil, folder_name:, parsed:false)
    raise "Guest accounts cannot create folders! Did you mean to upload a file instead?" if @isGuest
    post_folder_url = "https://api.gofile.io/createFolder"
    
    parent_id = @accDetails["data"]["rootFolder"] unless parent_id
    folder_data = {
      "parentFolderId" => parent_id,
      "folderName" => folder_name,
      "token" => @token
    }

    ret = HTTPHelper.put(post_folder_url, folder_data, parsed)
    
    puts ret
    ret
  end

  private

  # Will return account details
  # Example:
  # {
  #   "status": "ok",
  #   "data": {
  #     "token": "ivlW1ZSGn2Y4AoADbCHUjllj2cO9m3WM",
  #     "email": "email@domain.tld",
  #     "tier": "standard",
  #     "rootFolder": "2aecea58-84e6-420d-b2b9-68b4add8418d",
  #     "foldersCount": 4,
  #     "filesCount": 20,
  #     "totalSize": 67653500,
  #     "totalDownloadCount": 1
  #   }
  # }
  def test_token_validity
    account_details_url = "https://api.gofile.io/getAccountDetails?token=#{@token}"
    details = HTTPHelper.get(account_details_url, true)   
    
    @accDetails = details
  end
end