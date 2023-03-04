require "gofile_ruby"
require "./env.rb"

describe "GFClient" do

    let(:token) { ENV['GOFILE_TOKEN'] }

    it "should initialize a guest client without throwing errors" do 
        expect { gf = GFClient.new }.not_to raise_error
    end

    it "should initialize a client with a token without throwing errors" do
        raise "No GoFile token provided!" if token.nil?

        expect { gf = GFClient.new(token:"testtoken123") }.not_to raise_error
    end

    it "should override to guest mode if a token is provided in guest mode" do
        expect( GFClient.new(guest: true, token: "testtoken123").is_guest? ).to be true
    end

    it "should default to guest mode when no input is provided" do
        expect( GFClient.new.is_guest? ).to be true
    end
end