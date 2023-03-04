require './lib/gofile_ruby/http_helper.rb'

# A wrapper for the GoFile API, containing methods for each available endpoint.
#
# @see https://gofile.io/api
class GFClient

  attr_reader :account_details
  # Creates a new instance of the GFClient class.
  # @param [String] token The API token for your GoFile account
  # @param [Boolean] guest A boolean value indicating whether or not guest mode should be enabled
  def initialize(token:nil, guest:false)
    # The GoFile API token, defaults to nil if none is provided.
    @token = token
    # A GFClient instance that is in guest mode (where no token is provided) will set @has_token to false, and @is_guest to true. 
    # The @has_token instance variable will be set to true after the user acquires a guest account token by uploading a file in guest mode.
    @has_token = !@token.nil?
    # Instance variable for tracking if the client is using a guest account or not
    @is_guest = guest

    # Account details, initially set to `nil` until the user calls the `#authenticate` method
    @account_details = nil

    # The root folder returned by the `#upload_file` method when called in guest mode (without a token).
    # Gets set after a guest account uploads their first file.
    # Is used only when uploading files as a guest.
    @guest_upload_destination = nil
    # Final checks to ensure the user doesn't try anything odd. (Eg. passing in a token while also setting guest mode to true)
    validate_guest_mode
  end

  # Retreives the best available server for uploading files
  #
  # Example response:
  #
  #  "status": "ok",
  #  "data": {
  #    "server": "store1"
  #  }
  #
  # @return [Hash] response The response object.
  def get_server
    server_url = "https://api.gofile.io/getServer"
    HTTPHelper.get(server_url)
  end

  # Uploads a file to the given destination folder.
  #
  # If using guest mode, you cannot specify a folder ID when uploading your first file.
  #
  # If you're uploading multiple files, you have to use the parent ID along with the token from the response object in your subsequent uploads.
  #
  # To get around this issue, gofile_ruby saves the newly returned token and parent ID after your first upload.
  #
  # This means that you can call the #upload_file method multiple times without having to deal with authentication.
  #
  # Example response:
  #  "status": "ok",
  #   "data": {
  #     "guestToken": "a939kv5b43c03192imatoken2949"
  #     "downloadPage": "https://gofile.io/d/Z19n9a",
  #     "code": "Z19n9a",
  #     "parentFolder": "3dbc2f87-4c1e-4a81-badc-af004e61a5b4",
  #     "fileId": "4991e6d7-5217-46ae-af3d-c9174adae924",
  #     "fileName": "example.mp4",
  #     "md5": "10c918b1d01aea85864ee65d9e0c2305"
  #   }
  # @param [File] file The file that will be uploaded to GoFile
  # @param [String] folder_id The ID for the parent folder. Will default to the root folder if none is provided.
  # @return [Hash] response The response object.
  def upload_file(file:, folder_id: nil)
    raise "Guests cannot specify folder ID before their first upload!" if folder_id && @is_guest

    best_server = get_server()["data"]["server"]
    upload_url = "https://#{best_server}.gofile.io/uploadFile"

    body = [["file", file]]
    body << ["token", @token] if @has_token

    # If user inputs a folder_id while they have a token
    if folder_id && @has_token
      # add the ID to the body of the request
      body << ["folderId", folder_id]
    # If the user has uploaded a file as a guest, and a folder id hasn't been provided, use the folder ID returned from the first file upload
    elsif @guest_upload_destination && !folder_id
      body << ["folderId", @guest_upload_destination]
    end
  
    ret = HTTPHelper.post_multipart_data(upload_url, body)
    save_guest_acc_details(ret) if @has_token
  
    ret
  end

  # Creates a folder with the given folder name and parent ID.
  # If a parent ID is not provided, it default to the root folder.
  #
  # When using guest mode, you cannot call this method until you've uploaded a file first, as the guest token and root folder ID won't be available.
  #
  # Example response:
  #   "status": "ok",
  #   "data": {
  #
  #   }
  # @param [String] parent_id The ID of the parent folder
  # @param [String] folder_name The name of the folder that will be created
  # @return [Hash] response The response object.
  def create_folder(parent_id:nil, folder_name:)
    raise "Cannot create folders without a token! Please upload a file first!" unless @has_token
    raise "Cannot use root folder without authenticating first" unless @account_details

    post_folder_url = "https://api.gofile.io/createFolder"
    
    parent_id = @account_details["data"]["rootFolder"] unless parent_id
    folder_data = {
      "parentFolderId" => parent_id,
      "folderName" => folder_name,
      "token" => @token
    }

    ret = HTTPHelper.put(post_folder_url, folder_data)
    
    ret
  end

  # Gets the children of a specific folder.
  #
  # Defaults to root folder if a parent ID is not provided.
  #
  # Response example:
  #   "status": "ok",
  #   "data": {
  #     "isOwner": true,
  #     "id": "3dbc2f87-4c1e-4a81-badc-af004e61a5b4",
  #     "type": "folder",
  #     "name": "Z19n9a",
  #     "parentFolder": "3241d27a-f7e1-4158-bc75-73d057eff5fa",
  #     "code": "Z19n9a",
  #     "createTime": 1648229689,
  #     "public": true,
  #     "childs": [
  #       "4991e6d7-5217-46ae-af3d-c9174adae924"
  #     ],
  #     "totalDownloadCount": 0,
  #     "totalSize": 9840497,
  #     "contents": {
  #       "4991e6d7-5217-46ae-af3d-c9174adae924": {
  #         "id": "4991e6d7-5217-46ae-af3d-c9174adae924",
  #         "type": "file",
  #         "name": "example.mp4",
  #         "parentFolder": "3dbc2f87-4c1e-4a81-badc-af004e61a5b4",
  #         "createTime": 1648229689,
  #         "size": 9840497,
  #         "downloadCount": 0,
  #         "md5": "10c918b1d01aea85864ee65d9e0c2305",
  #         "mimetype": "video/mp4",
  #         "serverChoosen": "store4",
  #         "directLink": "https://store4.gofile.io/download/direct/4991e6d7-5217-46ae-af3d-c9174adae924/example.mp4",
  #         "link": "https://store4.gofile.io/download/4991e6d7-5217-46ae-af3d-c9174adae924/example.mp4"
  #       }
  #     }
  #   }
  # @param [String] parent_id The ID of the parent folder.
  # @return [Hash] response The response object.
  # @note This method is premium only! You will not be able to use it unless you have a premium account!
  # @todo This method will be tested at a later time due to it being a premium-only endpoint.
  def get_children(parent_id:nil)
    raise "Cannot use the #get_children method without a token!" if !@has_token

    parent = @account_details["data"]["rootFolder"] if !parent

    content_url = "https://api.gofile.io/getContent?contentId=#{parent}&token=#{@token}"
    ret = HTTPHelper.get(content_url)

    ret
  end

  # Sets the options for a specific folder.
  #
  # The expected option and value types are listed below.
  #
  # public: Boolean
  #
  # password: String
  #
  # description: String
  #
  # expire: Unix Timestamp
  #
  # tags: String (String of comma separated tags, Eg. "tag1,tag2,tag3")
  #
  # Response example:
  #   "status": "ok",
  #   "data": {}
  # @param [String] folder_id The ID of the target folder.
  # @param [String] option The option that you wish to set. Can be "public", "password", "description", "expire" or "tags"
  # @param [String] value The matching value for the option parameter
  # @return [Hash] response The response object.
  def set_folder_option(folder_id:, option:, value:)
    options_url = "https://api.gofile.io/setFolderOption"

    body = {
      "option": option,
      "value": value,
      "folderId": folder_id,
      "token": @token
    }
    ret = HTTPHelper.put(options_url, body)

    ret
  end

  # Copies one or multiple contents to destination folder.
  #
  # Destination ID: String
  #
  # Contents ID: String A string of comma separated content ID's. ("id1,id2,id3")
  # Response example:
  #
  #   "status": "ok",
  #   "data": {}
  # @param [String] destination_id The ID for the folder where the contents will be copied to.
  # @param [String] contents_id: A string of comma separated content ID's. ("id1,id2,id3")
  # @return [Hash] response The response object.
  # @note This method is premium only! You will not be able to use it unless you have a premium account!
  # @todo This method will be tested at a later time due to it being a premium-only endpoint.
  def copy_content(destination_id:, contents_id:)
    copy_url = "https://api.gofile.io/copyContent"

    body = {
      "contentsId": contents_id,
      "folderIdDest": destination_id,
      "token": @token
    }

    ret = HTTPHelper.put(copy_url, body)

    ret
  end

  # Delete one or multiple contents.
  #
  # Response example:
  #   "status": "ok",
  #   "data": {}
  # @param [String] contents_id A string of comma separated content ID's. ("id1,id2,id3")
  # @return [Hash] response The response object.
  def delete_content(contents_id:)
    delete_url = "https://api.gofile.io/deleteContent"

    body = {
      "contentsId": contents_id,
      "token": @token
    }

    ret = HTTPHelper.delete(delete_url, body)

    ret
  end

  # Will return the details of the current account.
  #
  # Response example:
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
  # @return [Hash] response The response object.
  def get_account_details
    account_details_url = "https://api.gofile.io/getAccountDetails?token=#{@token}"
    details = HTTPHelper.get(account_details_url)   

    details
  end

  # Calls the #get_account_details method and saves it to the @account_details instance variable
  #
  # Response is same as #get_account_details method
  #
  # @return [Hash] response The response object.
  def authenticate
    acc_deatils = get_account_details
    @account_details = acc_deatils
  end

  def is_guest?
    @is_guest
  end

  private

  # Takes the response object from a upload and saves the new guest accounts details for further use
  def save_guest_acc_details(uploadResponse)
    # If user is a guest,
    # After uploading, take the newly returned guest token
    guest_token = uploadResponse["data"]["guestToken"]
    # And the newly created root folder,
    new_root_folder = uploadResponse["data"]["parentFolder"]
    @has_token = false
    @guest_upload_destination = new_root_folder
    @token = guest_token
    # And check the tokens validity, saving the users details into @account_details afterwards
    get_account_details
  end

  def validate_guest_mode
    # Automatically set guest mode if user doesn't provide any input
    if !@has_token && !@is_guest
      @is_guest = true
    end
    # If user tries inputting a token while also enabling guest mode, switch guest mode off
    if @has_token && @is_guest
      @token = nil
      @has_token = false
    end
  end
end