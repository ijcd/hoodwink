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

end
