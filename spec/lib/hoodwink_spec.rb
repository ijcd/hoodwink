require File.join(File.dirname(__FILE__), '../spec_helper.rb')

require 'active_resource'

describe Hoodwink do
  before { 
    Hoodwink.disable_net_connect!
    Hoodwink.reset 
  }

  # describe "before any mocking is done" do
  #   it "should mock a resource" do
  #     Hoodwink.mock_resource "http://localhost.localdomain/fish"
  #     assert { Hoodwink.mocks.include? "http://localhost.localdomain/fish" }
  #   end

  #   it "should mock a few resources" do
  #     Hoodwink.mock_resource "http://localhost.localdomain/fish"
  #     Hoodwink.mock_resource "http://localhost.localdomain/fowl"
  #     Hoodwink.mock_resource "http://localhost.localdomain/beast"
  #     assert { Hoodwink.mocks.include? "http://localhost.localdomain/fish" }
  #     assert { Hoodwink.mocks.include? "http://localhost.localdomain/fowl" }
  #     assert { Hoodwink.mocks.include? "http://localhost.localdomain/beast" }
  #   end

  # end

  # describe "when mocks are present" do
  #   before {
  #     Hoodwink.mock_resource "http://localhost.localdomain/fish"
  #     Hoodwink.mock_resource "http://localhost.localdomain/fowl"
  #     Hoodwink.mock_resource "http://localhost.localdomain/beast"
  #   }

  #   it "should reset all mocks" do
  #     Hoodwink.reset
  #     assert { Hoodwink.mocks.empty? }
  #   end

  #   it "should reset WebMock" do
  #     WebMock.should_receive(:reset!)
  #     Hoodwink.reset
  #   end
  # end

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
