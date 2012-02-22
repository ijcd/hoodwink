require File.join(File.dirname(__FILE__), '../spec_helper.rb')

require 'active_resource'

describe Hoodwink do

  describe "when mocking ActiveResource" do
    before(:all) { 
      class TestFish < ActiveResource::Base; self.site = "http://localhost.localdomain/"; self.element_name = "fish" ; end 
    }

    before(:each) { 
      Hoodwink.interceptor.datastore.clear
      Hoodwink.mock_resource "http://localhost.localdomain/fish"
      Hoodwink.interceptor.datastore.create(:fish, :id => 1)
    }

    it "should work with ActiveResource requests" do
      TestFish.find(:all)
      TestFish.find(:all, :params => {:color => "Blue"})
      TestFish.find(1)
      TestFish.find(1, :params => {:color => "Blue"})
      TestFish.create
      TestFish.create(:name => :fred, :params => {:color => "Blue"})
      TestFish.find(1).save
      TestFish.find(1).destroy
    end

    describe "when working with a collection" do
      it "should return a list of resources on a GET" do
        assert { TestFish.find(:all).all?{|f| TestFish === f} }
      end

      it "should return a list of resources on a GET with params" do
        assert { TestFish.find(:all, :params => {:color => "Blue"}).all?{|f| TestFish === f} }
      end

      it "should return a resource on a POST" do
        assert { TestFish === TestFish.create }
      end

      it "should return a resource on a POST with params" do
        assert { TestFish === TestFish.create(:params => {:color => "Blue"}) }
      end
    end

    describe "when working with a resource" do
      it "should return a resource on a GET" do
        assert { TestFish === TestFish.find(1)}
      end

      it "should return a resource on a GET with params" do
        assert { TestFish === TestFish.find(1, :params => {:color => "Blue"}) }
      end

      it "should respond to a PUT to a resource" do
        assert { TestFish.find(1).save }
      end

      it "should respond to a DELETE" do
        assert { TestFish.delete(1) }
      end
    end
  end

end
