require "gofile_ruby"
require "./env.rb"

describe GFClient do
    let(:token) { ENV['GOFILE_TOKEN'] }
    
    # Wait 1 second before each test to avoid triggering the rate limiter
    # In the future, as the amount of tests will grow, this can be applied only to specific tests to avoid waiting minutes for the tests to finish running
    before(:each) do
        sleep 1
    end

    describe "#new" do
        it "should initialize a guest client without throwing errors" do 
            expect { gf = GFClient.new }.not_to raise_error
        end

        it "should initialize a token client without throwing errors" do
            raise "No GoFile token provided!" if token.nil?

            expect { gf = GFClient.new(token: token) }.not_to raise_error
        end

        it "should default to guest mode if a token is provided alongside the guest option" do
            expect( GFClient.new(guest: true, token: "testtoken123").is_guest? ).to be true
        end

        it "should default to guest mode when no input is provided" do
            expect( GFClient.new.is_guest? ).to be true
        end
    end

    describe "#authenticate" do
        it "should return the account details after authentication" do
            gf = GFClient.new(token: token)
            res = gf.authenticate

            expect(res["status"]).to eq "ok"
            expect(res["data"].keys.count).to be > 0 
        end

        it "should return an error response when the token is invalid" do
            gf = GFClient.new(token: "invalidtoken123")
            res = gf.authenticate

            expect(res["status"]).to eq "error-auth"
            expect(res["data"].keys.count).to be 0
        end

        it "should return an error response when called in guest mode" do
            gf = GFClient.new
            res = gf.authenticate

            expect(res["status"]).to eq "error-auth"
            expect(res["data"].keys.count).to be 0
        end
    end

    describe "#get_server" do
        it "should return the best available server" do
            gf = GFClient.new
            res = gf.get_server

            expect(res["data"]["server"]).to match /store/
        end
    end

    describe "#create_folder" do
        it "should raise an error when used without a token" do
            expect { GFClient.new.create_folder(folder_name: "test folder") }.to raise_error(RuntimeError)
        end

        it "should raise an error when a folder name isn't given" do
            expect { GFClient.new(token: token).create_folder }.to raise_error(ArgumentError)
        end

        it "should create a folder without returning an error response" do
            gf = GFClient.new(token: token)
            gf.authenticate
            res = gf.create_folder(folder_name: "test folder")

            expect(res["status"]).to eq "ok"
            expect(res["data"]["id"]).not_to be nil
        end

        it "should create a folder under the correct parent folder when a parent ID is given" do
            gf = GFClient.new(token: token)
            gf.authenticate
            
            first_folder = gf.create_folder(folder_name: "folder-one")
            second_folder = gf.create_folder(folder_name: "folder-two", parent_id: first_folder["data"]["id"])

            puts first_folder
            expect(first_folder["status"]).to eq "ok"
            expect(second_folder["status"]).to eq "ok"
            expect(second_folder["data"]["parentFolder"]).to eq first_folder["data"]["id"]
        end
    end

    describe "#get_children" do
        # The #get_children method currently cannot be tested as it is a premium-only endpoint.
    end

    describe "#copy_content" do
        # The #copy_content method currently cannot be tested as it is a premium-only endpoint.
    end

    describe "#delete_content" do
        it "should raise an error when called without any arguments" do
            gf = GFClient.new(token: token)
            gf.authenticate

            expect { gf.delete_content }.to raise_error(ArgumentError)
        end

        it "should return an error response when an invalid ID is given" do
            gf = GFClient.new(token: token)
            gf.authenticate

            res = gf.delete_content(contents_id: "invalidid123")

            expect(res["status"]).to eq "error-wrongContent"
        end

        it "should delete content successfully without returning an error response" do
            gf = GFClient.new(token: token)
            gf.authenticate

            dummy_folder = gf.create_folder(folder_name: "dummy folder")
            res = gf.delete_content(contents_id: dummy_folder["data"]["id"])

            expect(res["status"]).to eq "ok"
            expect(res["data"].keys.count).to be > 0
        end
    end

    describe "#set_folder_option" do
        it "should raise an error when any of the arguments are missing" do
            gf = GFClient.new(token: token)
            expect { gf.set_folder_option(folder_id: "randomfolder123") }.to raise_error(ArgumentError)
            expect { gf.set_folder_option(option: "folderoption") }.to raise_error(ArgumentError)
            expect { gf.set_folder_option(folder_id: "randomfolder123", option: "folderoption") }.to raise_error(ArgumentError)
            expect { gf.set_folder_option(option: "folderoption", value: "optionvalue") }.to raise_error(ArgumentError)
            expect { gf.set_folder_option(value: "optionvalue") }.to raise_error(ArgumentError)
            expect { gf.set_folder_option(folder_id: "randomfolder123", value: "optionvalue") }.to raise_error(ArgumentError)
        end

        it "should return an error response when an invalid ID is given" do
            gf = GFClient.new(token: token)
            gf.authenticate

            res = gf.set_folder_option(folder_id: "invalidid123", option: "password", value: "12345insecurepassword")

            expect(res["status"]).to eq "error-wrongFolder"
        end

        it "should update folder option successfully without returning an error response" do
            gf = GFClient.new(token: token)
            gf.authenticate

            dummy_folder = gf.create_folder(folder_name: "dummy folder")
            res = gf.set_folder_option(folder_id: dummy_folder["data"]["id"], option: "password", value: "12345insecurepassword")

            expect(res["status"]).to eq "ok"
        end

        describe "set_options_hash" do
            it "should raise an error when any of the arguments are missing" do
                gf = GFClient.new

                expect { gf.set_options_hash(folder_id: "testid123") }.to raise_error(ArgumentError)
                expect { gf.set_options_hash(options_hash: { "password": "123", "expiry": 9999999999 }) }.to raise_error(ArgumentError)
            end

            it "should raise an error when an invalid option is given" do
                gf = GFClient.new(token: token)
                gf.authenticate

                options_hash = {
                    "nonexistentsetting": "12345",
                }

                dummy_folder_id = gf.create_folder(folder_name: "Test Folder")["data"]["id"]
                gf.set_options_hash(folder_id: dummy_folder_id, options_hash: options_hash) { |res| expect(res["status"]).to eq "error-noOption" }
            end

            it "should successfully set all given options" do
                gf = GFClient.new(token: token)
                
                gf.authenticate

                options_hash = {
                    "password": "12345",
                    "description": "test description"
                }

                dummy_folder_id = gf.create_folder(folder_name: "Test Folder")["data"]["id"]

                gf.set_options_hash(folder_id: dummy_folder_id, options_hash: options_hash) { |res| expect(res["status"]).to eq "ok" }
            end
        end
    end

    describe "#upload_file" do
        it "should raise an error when a file isn't provided" do
            gf = GFClient.new(token: token)

            expect { gf.upload_file }.to raise_error(ArgumentError)
        end

        it "should upload the file successfully when called with a normal account" do
            gf = GFClient.new(token: token)
            file = File.open("./spec/lib/cooking_raccoon.jfif", "r")
            res = gf.upload_file(file: file)

            expect(res["status"]).to eq "ok"
            expect(res["data"]["fileId"]).not_to be nil
        end

        it "should upload the file successfully and return a guest token when called with a guest account" do
            gf = GFClient.new
            file = File.open("./spec/lib/cooking_raccoon.jfif", "r")
            res = gf.upload_file(file: file)

            expect(res["status"]).to eq "ok"
            expect(res["data"]["fileId"]).not_to be nil
            expect(res["data"]["guestToken"]).not_to be nil
        end

        it "should upload the file successfully under the correct parent when a parent ID is given" do
            gf = GFClient.new(token: token)
            gf.authenticate

            dummy_folder = gf.create_folder(folder_name: "parent folder")

            file = File.open("./spec/lib/cooking_raccoon.jfif", "r")
            res = gf.upload_file(file: file, folder_id: dummy_folder["data"]["id"])

            expect(res["status"]).to eq "ok"
            expect(res["data"]["fileId"]).not_to be nil
            expect(res["data"]["parentFolder"]).to eq dummy_folder["data"]["id"]
        end
    end
end