<p align="center" width="100%">
    <img width="33%" src="./logo.png">
</p>

<h3 align="center">gofile_ruby</h3>

  <p align="center">
    A Ruby wrapper for the GoFile API.
    <br />
    <a href="https://erayalkis.github.io/gofile_ruby"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/erayalkis/gofile_ruby/issues">Report Bug</a>
    ·
    <a href="https://github.com/erayalkis/gofile_ruby/issues">Request Feature</a>
  </p>

# About gofile_ruby:
`gofile_ruby` is a simple, zero-dependency, developer friendly wrapper for the [GoFile API](https://gofile.io/api).

## Features:
- Logging into an account with an API token.
- Retrieving a folder/file. *
- Updating folder/file details.
- Copying files/folders across folders. *
- Uploading files.
- Deleting files.

> **Warning**
>
> The endpoints for retrieving content details and copying content is only available to users with a GoFile Premium account.
> For this reason, testing for the aforementioned endpoints is minimal, and they might be unstable.
> If you wish to help this project improve, you can start by opening an issue [here](https://github.com/erayalkis/gofile_ruby/issues/new).

# Quick Start

## Installation

To install the latest release:

```
gem install gofile_ruby
```

## Usage

Logging in and receiving a token with a guest account:
```ruby
    require 'gofile_ruby'

    # ... (unrelated code)

    # Creates a GFClient in guest mode with @has_token set to false
    # You can omit the `guest` argument when creating a GFClient instance, 
        # as it defaults to a guest account when no token is provided
    client = GFClient.new(guest: true)

    # The GFClient instance is now in guest mode,
        # and will require you to upload a file before you can access most other endpoints.
    # This is because guest accounts do not get their token until they upload a file, 
        # and most endpoints require a token.
    file = File.open('./path/to/file')

    # `res` will now contain a `guestToken` property.
    # `gofile_ruby` will now save this token and uses it in any further API calls.
    res = client.upload_file(file: file)

    file_two = File.open('./path/to/second/file')

    # This upload call will now use the token retrieved from the first call.
    res = client.upload_file(file: file_two)
```

Logging in with an API token:
```ruby
    require 'gofile_ruby'

    # ...

    client = GFClient.new(token: 'randomapitoken123456789')
```

Uploading a file:
```ruby
    require 'gofile_ruby'
    
    # ...

    # Creates a guest account
    client = GFClient.new

    file = File.open("./path/to/file")

    # A response object that contains data about the uploaded file (if successful) 
    res = client.upload_file(file: file)
```

Setting folder properties:
```ruby
    require 'gofile_ruby'
    
    # ...

    client = GFClient.new(token: 'randomapitoken123456789')

    folder_id = 'examplefolderid'

    client.set_folder_option(folder_id: folder_id, option: 'public', value: true)
    client.set_folder_option(folder_id: folder_id, option: 'public', value: false)
    client.set_folder_option(folder_id: folder_id, option: 'password', value: 'password123')
    client.set_folder_option(folder_id: folder_id, option: 'description', value: 'I am a description')
    client.set_folder_option(folder_id: folder_id, option: 'expire', value: 1678647468)
    client.set_folder_option(folder_id: folder_id, option: 'tags', value: 'tag1,tag2,tag3,tag4,tag5')
```

Setting folder properties with a hash:
```ruby
    require 'gofile_ruby'

    gf = GFClient.new(token: 'randomapitoken123456789')

    folder_id = 'examplefolderid'
    options = {
        password: 'password123',
        description: 'This is a description'        
    }

    # The #set_options_hash calls the #set_folder_option for each key-value pair in the options hash
    gf.set_options_hash(folder_id: folder_id, options: options)

    # To make error catching possible, #set_options_hash accepts a block and yields each response object into it
    gf.set_options_hash(folder_id: folder_id, options: options) { |res| puts res }
```

Deleting content:
```ruby
    require 'gofile_ruby'
    
    # ...

    client = GFClient.new(token: 'randomapitoken123456789')

    contents = 'contentid1,contentid2,contentid3,contentid4'

    res = client.delete_content(contents_id: contents)
```

> **Warning**
>
> The methods shown below are premium only and untested.
>

Retrieving children:
```ruby
    require 'gofile_ruby'
    
    # ...

    client = GFClient.new(token: 'randomapitoken123456789')
    
    parent_id = 'parentid123'

    res = client.get_children(parent_id: parent_id)
```

Copying content:
```ruby
    require 'gofile_ruby'
    
    # ...

    client = GFClient.new(token: 'randomapitoken123456789')
    
    contents = 'contentid1,contentid2,contentid3,contentid4'
    destination = 'destinationid'

    res = client.copy_content(contents_id: contents, destination_id: destination)
```

Check out the [documentation](https://erayalkis.github.io/gofile_ruby/) for more details.

# License

Licensed under the [MIT License](https://github.com/erayalkis/gofile_ruby/blob/main/LICENSE)
