require './lib/helpers/http/http.rb'

class GFClient

  def initialize(token:nil, guest:false)
    @token = token
    @isGuest = guest
    @accDetails = nil

    @isGuest = false if @token
    test_token_validity unless @isGuest
  end

  def get_server
    server_url = "https://api.gofile.io/getServer"
    HTTPHelper.get(server_url)
  end

  def upload_file(file:, folder_id: nil)
    raise "Guests cannot specify folder ID!" if @isGuest && folder_id

    best_server = get_server()["data"]["server"]
    upload_url = "https://#{best_server}.gofile.io/uploadFile"

    body = [["file", file]]
    body << ["folderId", folder_id] if folder_id && !@isGuest
    body << ["token", @token] if !@isGuest

    ret = HTTPHelper.post_multipart_data(upload_url, body)
    puts ret

    ret
  end

  def create_folder(parent_id:nil, folder_name:)
    raise "Guest accounts cannot create folders! Did you mean to upload a file instead?" if @isGuest
    post_folder_url = "https://api.gofile.io/createFolder"
    
    parent_id = @accDetails["data"]["rootFolder"] unless parent_id
    folder_data = {
      "parentFolderId" => parent_id,
      "folderName" => folder_name,
      "token" => @token
    }

    ret = HTTPHelper.put(post_folder_url, folder_data)
    
    puts ret
    ret
  end

  # Gets the children of a specific folder
  # Defaults to root folder if parent is not provided
  def get_children(parent:nil)
    raise "Guests cannot use the #get_children method!" if @isGuest
    parent = @accDetails["data"]["rootFolder"] if !parent

    content_url = "https://api.gofile.io/getContent?contentId=#{parent}&token=#{@token}"
    ret = HTTPHelper.get(content_url)

    ret
  end

  # Sets the options for a specific folder
  # Takes an option string and a matching value:
  # public: Boolean
  # password: String
  # description: String
  # expire: Unix Timestamp
  # tags: String (String of comma separated tags, Eg. "tag1,tag2,tag3")
  def set_folder_option(folder_id:, option:, value:)
    options_url = "https://api.gofile.io/setFolderOption"

    body = {
      "option": option,
      "value": value,
      "folderId": folder_id,
      "token": @token
    }
    ret = HTTPHelper.put(options_url, body)
    puts ret 

    ret
  end

  # Copies one or multiple contents to destination folder
  # Destination ID: String
  # Contents ID: String (String of comma separated ID's, Eg. "id1,id2,id3")
  def copy_content(destination_id:, contents_id:)
    copy_url = "https://api.gofile.io/copyContent"

    body = {
      "contentsId": contents_id,
      "folderIdDest": destination_id,
      "token": @token
    }

    ret = HTTPHelper.put(copy_url, body)
    puts ret

    ret
  end

  # Delete one or multiple contents
  # Contents Id: String (String of comma separated ID's, Eg. "id1,id2,id3")
  def delete_content(contents_id:)
    delete_url = "https://api.gofile.io/deleteContent"

    body = {
      "contentsId": contents_id,
      "token": @token
    }

    ret = HTTPHelper.delete(delete_url, body)
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
    details = HTTPHelper.get(account_details_url)   
    
    @accDetails = details
  end
end