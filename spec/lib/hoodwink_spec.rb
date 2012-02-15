require File.join(File.dirname(__FILE__), '../spec_helper.rb')

require 'active_resource'

describe Hoodwink do
  let(:fish_endpoint) { "http://localhost.localdomain/fish" }
  let(:fowl_endpoint) { "http://localhost.localdomain/fowl" }
  let(:beast_endpoint) { "http://localhost.localdomain/beast" }

  before { 
    Hoodwink.disable_net_connect!
    Hoodwink.reset 
  }

  describe "before any mocking is done" do
    it "should mock a resource" do
      Hoodwink.mock_resource fish_endpoint
      assert { Hoodwink.interceptor.responders.keys.include? fish_endpoint }
    end

    it "should mock a few resources" do
      Hoodwink.mock_resource fish_endpoint
      Hoodwink.mock_resource fowl_endpoint
      Hoodwink.mock_resource beast_endpoint
      assert { Hoodwink.interceptor.responders.keys.include? fish_endpoint }
      assert { Hoodwink.interceptor.responders.keys.include? fowl_endpoint }
      assert { Hoodwink.interceptor.responders.keys.include? beast_endpoint }
    end

  end

  describe "when mocks are present" do
    before {
      Hoodwink.mock_resource fish_endpoint
      Hoodwink.mock_resource fowl_endpoint
      Hoodwink.mock_resource beast_endpoint
    }

    it "should reset all responders" do
      Hoodwink.reset
      assert { Hoodwink.interceptor.responders.empty? }
    end

    it "should reset WebMock" do
      WebMock.should_receive(:reset!)
      Hoodwink.reset
    end
  end

  describe "a mocked resource" do
    before(:all) { class Fish < ActiveResource::Base; self.site = "http://localhost.localdomain/" ; end }
    before(:each) { Hoodwink.mock_resource "http://localhost.localdomain/fish" }

    it "should respond to ActiveResrouce requests" do
      Fish.find(:all)
      Fish.find(:all, :params => {:color => "Blue"})
      Fish.find(1)
      Fish.find(1, :params => {:color => "Blue"})
      Fish.create
      Fish.create(:name => :fred, :params => {:color => "Blue"})
      Fish.find(1).save
      Fish.find(1).destroy
    end

    describe "when working with a collection" do
      it "should return a list of resources on a GET" do
        assert { Fish.find(:all).all?{|f| Fish === f} }
      end

      it "should return a list of resources on a GET with params" do
        assert { Fish.find(:all, :params => {:color => "Blue"}).all?{|f| Fish === f} }
      end

      it "should return a resource on a POST" do
        assert { Fish === Fish.create }
      end

      it "should return a resource on a POST with params" do
        assert { Fish === Fish.create(:params => {:color => "Blue"}) }
      end
    end

    describe "when working with a resource" do
      it "should return a resource on a GET" do
        assert { Fish === Fish.find(1)}
      end

      it "should return a resource on a GET with params" do
        assert { Fish === Fish.find(1, :params => {:color => "Blue"}) }
      end

      it "should respond to a PUT to a resource" do
        assert { Fish.find(1).save }
      end

      it "should respond to a DELETE" do
        assert { Fish.delete(1) }
      end
    end
  end

end
