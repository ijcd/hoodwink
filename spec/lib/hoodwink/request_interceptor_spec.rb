require File.join(File.dirname(__FILE__), '../../spec_helper.rb')
require File.join(File.dirname(__FILE__), 'shared_examples_for_request_interception')

describe Hoodwink::RequestInterceptor do

  subject { Hoodwink::RequestInterceptor.instance }

  let(:http) { Net::HTTP.new("localhost.localdomain") }

  let(:fish_endpoint)      { "http://localhost.localdomain/fish"                            }
  let(:fowl_endpoint)      { "http://localhost.localdomain/fowl"                            }
  let(:beast_endpoint)     { "http://localhost.localdomain/beast"                           }
  let(:segmented_endpoint) { "http://localhost.localdomain/cats/:cat_id/dogs/:dog_id/fleas" }
  
  before { 
    subject.disable_net_connect!
    subject.reset 
  }

  describe "before any mocking is done" do
    it "should mock a resource" do
      subject.mock_resource fish_endpoint
      assert { subject.responders.keys.include? fish_endpoint }
    end

    it "should mock a few resources" do
      subject.mock_resource fish_endpoint
      subject.mock_resource fowl_endpoint
      subject.mock_resource beast_endpoint
      assert { subject.responders.keys.include? fish_endpoint }
      assert { subject.responders.keys.include? fowl_endpoint }
      assert { subject.responders.keys.include? beast_endpoint }
    end

  end

  describe "when interceptions are present" do
    before {
      subject.mock_resource fish_endpoint
      subject.mock_resource fowl_endpoint
      subject.mock_resource beast_endpoint
    }

    it "should reset all responders" do
      subject.reset
      assert { subject.responders.empty? }
    end

    it "should reset WebMock" do
      WebMock.should_receive(:reset!)
      subject.reset
    end
  end

  describe "#mock_resource without extensions" do
    context "a normal endpoint" do
      before { subject.mock_resource fish_endpoint }
      let(:resource_path) { "/fish" }
      let(:responder)     { subject.responders[fish_endpoint] }
      include_examples "for a mocked resource"
    end

    context "a segmented endpoint" do
      before { subject.mock_resource segmented_endpoint }
      let(:resource_path) { "/cats/25/dogs/34/fleas" }
      let(:responder)     { subject.responders[segmented_endpoint] }
      include_examples "for a mocked resource"
    end
  end

  describe "#mock_resource with extensions" do
    before(:all) { class ExpectedToRaise < StandardError ; end }

    context "a mocked resource with extensions" do
      before do
        subject.mock_resource fish_endpoint do
          def find_all ; raise ExpectedToRaise ; end
        end
      end
      let(:resource_path) { "/fish" }
      let(:responder)     { subject.responders[fish_endpoint] }
      include_examples "for a mocked resource"
    end

    it "GET on collection should use find_all to get the resource" do
      subject.mock_resource fish_endpoint do
        def find_all ; raise ExpectedToRaise ; end
      end
      expect { http.get("/fish") }.should raise_error(ExpectedToRaise)
    end

    it "POST on collection should use create(hash)" do
      subject.mock_resource fish_endpoint do
        def create(hash) ; raise ExpectedToRaise ; end
      end
      expect {http.post("/fish", {})}.should raise_error(ExpectedToRaise)
    end

    it "GET on resource should use find(id) to get the resource" do
      subject.mock_resource fish_endpoint do
        def find(id) ; raise ExpectedToRaise ; end
      end
      expect { http.get("/fish/1") }.should raise_error(ExpectedToRaise)
    end

    it "PUT on resource should call update(id, hash)" do
      subject.mock_resource fish_endpoint do
        def update(id, hash) ; raise ExpectedToRaise ; end
      end
      expect { http.put("/fish/1", {}) }.should raise_error(ExpectedToRaise)
    end

    it "PUT on resource should use find(id) to get the resource" do
      subject.mock_resource fish_endpoint do
        def find(id) ; raise ExpectedToRaise ; end
      end
      expect { http.put("/fish/1", "foo") }.should raise_error(ExpectedToRaise)
    end

    it "DELETE on resource should call delete(id)" do
      subject.mock_resource fish_endpoint do
        def delete(id) ; raise ExpectedToRaise ; end
      end
      expect { http.delete("/fish/1") }.should raise_error(ExpectedToRaise)
    end

    it "DELETE on resource should use find(id) to get the resource" do
      subject.mock_resource fish_endpoint do
        def find(id) ; raise ExpectedToRaise ; end
      end
      expect { http.delete("/fish/1") }.should raise_error(ExpectedToRaise)
    end
  end
end
