require './lib/gofile_ruby/http_helper.rb'

describe HTTPHelper do
    describe ".get" do
        it "should successfully make a get request" do
            res = HTTPHelper.get("https://httpbin.org")
        end
    end
end