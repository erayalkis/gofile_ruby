require './lib/gofile_ruby/http_helper.rb'

describe HTTPHelper do
    describe ".get" do
        it "should throw an error with invalid URL's" do
            expect { HTTPHelper.get("hppts://www.httpbin.org/get") }.to raise_error(ArgumentError)
        end
        
        it "should successfully make a get request" do
            res = HTTPHelper.get("https://httpbin.org/get")
        end
    end

    describe ".post_form" do
        it "should throw an error with invalid URL's" do
            expect { HTTPHelper.post_form("hppts://www.httpbin.org/post") }
        end

        it "should throw an error when no data is provided" do
            expect { HTTPHelper.post_form("https://www.httpbin.org/post") }.to raise_error(ArgumentError)
        end

        it "should successfully make a post request" do
            expect { HTTPHelper.post_form("https://www.httpbin.org/post", { data: "Hello" }) }.not_to raise_error
        end
    end

    describe ".post_multipart_data" do
        it "should throw an error with invalid URL's" do
            expect { HTTPHelper.post_multipart_data("hppts://www.httpbin.org/post") }.to raise_error(ArgumentError)
        end

        it "should throw an error when no data is provided" do
            expect { HTTPHelper.post_multipart_data("https://www.httpbin.org/post") }.to raise_error(ArgumentError)
        end

        it "should successfully make a post request" do
            expect { HTTPHelper.post_multipart_data("https://www.httpbin.org/post") }.not_to raise_error
        end
    end

    describe ".put" do
        it "should throw an error with invalid URL's" do
            expect { HTTPHelper.put("hppts://www.httpbin.org/put") }.to raise_error(ArgumentError)
        end

        it "should throw an error when no data is provided" do
            expect { HTTPHelper.put("https://www.httpbin.org/put") }.to raise_error(ArgumentError)
        end

        it "should successfully make a put request" do
            expect { HTTPHelper.put("https://www.httpbin.org/put") }.not_to raise_error

        end
    end

    describe ".delete" do
        it "should throw an error with invalid URL's" do
            expect { HTTPHelper.delete("hppts://www.httpbin.org/delete") }.to raise_error(ArgumentError)
        end

        it "should throw an error when no data is provided" do
            expect { HTTPHelper.delete("https://www.httpbin.org/delete") }.to raise_error(ArgumentError)
        end

        it "should successfully make a delete request" do
            expect { HTTPHelper.delete("https://www.httpbin.org/delete", { data: "Hello" }) }.not_to raise_error
        end
    end
end