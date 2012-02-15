require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink do
  subject { Hoodwink::RequestInterceptor.instance }

  let(:fish_endpoint) { "http://localhost.localdomain/fish" }
  let(:fowl_endpoint) { "http://localhost.localdomain/fowl" }
  let(:beast_endpoint) { "http://localhost.localdomain/beast" }

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

  describe "#mock_resource" do
    before {
      subject.mock_resource fish_endpoint
    }

    let(:responder) { subject.responders[fish_endpoint] }
    let(:http) { Net::HTTP.new("localhost.localdomain") }

    shared_examples "a mocked resource" do |mimetype, extension|
      it "should intercept index GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
        responder.should_receive(:response_for).once.and_return(:body => {})
        headers = mimetype.nil? ? {} : {"Accept" => mimetype}
        http.get("/fish#{extension}", headers)
      end

      it "should intercept index POST requests with #{mimetype}" do
        responder.should_receive(:response_for).once.and_return(:body => {})
        headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
        http.post("/fish#{extension}", "", headers)
      end

      it "should intercept resource GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
        responder.should_receive(:response_for).once.and_return(:body => {})
        headers = mimetype.nil? ? {} : {"Accept" => mimetype}
        http.get("/fish/1#{extension}", headers)
      end

      it "should intercept resource PUT requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
        responder.should_receive(:response_for).once.and_return(:body => {})
        headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
        http.put("/fish/1#{extension}", "", headers)
      end

      it "should intercept resource DELETE requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
        responder.should_receive(:response_for).once.and_return(:body => {})
        headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
        http.delete("/fish/1#{extension}", headers)
      end

    end

    it_behaves_like "a mocked resource", nil,                ".json"
    it_behaves_like "a mocked resource", "*/*",              ".json"
    it_behaves_like "a mocked resource", "application/json", ".json"
    it_behaves_like "a mocked resource", "application/json", ""

    it_behaves_like "a mocked resource", nil,                ".xml"
    it_behaves_like "a mocked resource", "*/*",              ".xml"
    it_behaves_like "a mocked resource", "application/xml",  ".xml"
    it_behaves_like "a mocked resource", "application/xml",  ""
  end

end
