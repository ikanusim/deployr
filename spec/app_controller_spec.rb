require File.dirname(__FILE__) + '/spec_helper'

describe "Deployer" do
  include Rack::Test::Methods

  def app
    @app ||= Sinatra::Application
  end

  describe "App Controller" do

    describe "GET action" do

      it "should be available" do
        get '/'
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "text/html"
        last_response.body == "last deployed commit"
      end
    end

    describe "POST /" do

      it "should be available" do
        post '/'
        last_response.should be_ok
        last_response.headers["Content-Type"].should == "text/html"
      end
    end
    
  end
end

