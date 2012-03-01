require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink do
  subject { 
    samples = (1..3).map {|i| Hoodwink::Resource.new(i) }
    sample = samples.first
    datastore = double("datastore", 
                       :find_all => samples,
                       :find => sample,
                       :create => sample,
                       :update => sample,
                       :delete => {})
    Hoodwink::ResourceResponder.new("/fowl", :fowl, datastore)
  }

  let(:body_xml)  { %{<fowl><color>red</color></fowl>} }
  let(:body_json) { %{{"fowl":{"color":"red"}}} }
  let(:found)     { double("found") }
  let(:ds_proxy)  { double("found") }

  describe "#format_as" do
    it "should format as json" do
      data = {}
      data.should_receive("to_json").with(:root => "fowl").once
      subject.format_as("json", "fowl", data)
    end

    it "should format as xml" do
      data = {}
      data.should_receive("to_xml").with(:root => "fowl").once
      subject.format_as("xml", "fowl", data)
    end
  end

  # TODO: setup tests to run against actual Rails/ActiveResource to compare values
  describe "#response_for" do
    before(:all) { RawRequest = Struct.new("Request", :method, :uri, :body, :headers) }

    let(:response) { subject.response_for(request) }

    #                                            accept/
    #              method   resource   extension content-type ==>    code content-type        location
    test_cases = [
                  [:get,    :index,    nil,      nil,                200, "text/html",        nil],
                  [:get,    :index,    nil,      "application/json", 200, "application/json", nil],
                  [:get,    :index,    nil,      "application/xml",  200, "application/xml",  nil],
                  [:get,    :index,    :json,    nil,                200, "application/json", nil],
                  [:get,    :index,    :json,    "application/json", 200, "application/json", nil],
                  [:get,    :index,    :json,    "application/xml",  200, "application/json", nil],
                  [:get,    :index,    :xml,     nil,                200, "application/xml",  nil],
                  [:get,    :index,    :xml,     "application/json", 200, "application/xml",  nil],
                  [:get,    :index,    :xml,     "application/xml",  200, "application/xml",  nil],
                  
                  #[:post,  :index,    nil,      nil,                200, "text/html",        nil],
                  [:post,   :index,    nil,      "application/json", 302, nil,                "/fowl/1"],
                  [:post,   :index,    nil,      "application/xml",  302, nil,                "/fowl/1"],
                  #[:post,  :index,    :json,    nil,                200, "application/json", nil],
                  [:post,   :index,    :json,    "application/json", 201, "application/json", %r{/fowl/\d+}],
                  [:post,   :index,    :json,    "application/xml",  201, "application/json", %r{/fowl/\d+}],
                  #[:post,  :index,    :xml,     nil,                200, "application/xml",  nil],
                  [:post,   :index,    :xml,     "application/json", 201, "application/xml",  %r{/fowl/\d+}],
                  [:post,   :index,    :xml,     "application/xml",  201, "application/xml",  %r{/fowl/\d+}],
                  
                  [:get,    :resource, nil,      nil,                200, "text/html",        nil],
                  [:get,    :resource, nil,      "application/json", 200, "application/json", nil],
                  [:get,    :resource, nil,      "application/xml",  200, "application/xml",  nil],
                  [:get,    :resource, :json,    nil,                200, "application/json", nil],
                  [:get,    :resource, :json,    "application/json", 200, "application/json", nil],
                  [:get,    :resource, :json,    "application/xml",  200, "application/json", nil],
                  [:get,    :resource, :xml,     nil,                200, "application/xml",  nil],
                  [:get,    :resource, :xml,     "application/json", 200, "application/xml",  nil],
                  [:get,    :resource, :xml,     "application/xml",  200, "application/xml",  nil],
                  
                  #[:put,   :resource, nil,      nil,                200, "text/html",        nil],
                  [:put,    :resource, nil,      "application/json", 302, nil,                "/fowl/1"],
                  [:put,    :resource, nil,      "application/xml",  302, nil,                "/fowl/1"],
                  #[:put,   :resource, :json,    nil,                200, "application/json", nil],
                  [:put,    :resource, :json,    "application/json", 204, "application/json", %r{/fowl/\d+}],
                  [:put,    :resource, :json,    "application/xml",  204, "application/json", %r{/fowl/\d+}],
                  #[:put,   :resource, :xml,     nil,                200, "application/xml",  nil],
                  [:put,    :resource, :xml,     "application/json", 204, "application/xml",  %r{/fowl/\d+}],
                  [:put,    :resource, :xml,     "application/xml",  204, "application/xml",  %r{/fowl/\d+}],
                  
                  [:delete, :resource, nil,      nil,                302, nil,                "/fowl"],
                  [:delete, :resource, nil,      "application/json", 204, nil,                "/fowl"],
                  [:delete, :resource, nil,      "application/xml",  204, nil,                "/fowl"],
                  [:delete, :resource, :json,    nil,                204, nil,                "/fowl"],
                  [:delete, :resource, :json,    "application/json", 204, nil,                "/fowl"],
                  [:delete, :resource, :json,    "application/xml",  204, nil,                "/fowl"],
                  [:delete, :resource, :xml,     nil,                204, nil,                "/fowl"],
                  [:delete, :resource, :xml,     "application/json", 204, nil,                "/fowl"],
                  [:delete, :resource, :xml,     "application/xml",  204, nil,                "/fowl"],
                 ]

    test_cases.each do |method, resource_type, extension, request_content_type, response_code, response_content_type, response_location|

      describe "#{method.upcase} on #{resource_type} with extension '#{extension}' and content type '#{request_content_type}'" do
        
        let(:request) {
          if resource_type == :index
            url = ["http://localhost.localdomain/fowl", extension].compact.join(".")
          else
            url = ["http://localhost.localdomain/fowl/1", extension].compact.join(".")
          end

          case method
          when :post, :put
            headers = request_content_type.nil? ? {} : {"Content-Type" => request_content_type}
            body = (Hoodwink::SUPPORTED_FORMATS[request_content_type] == "xml") ? body_xml : body_json
          else
            headers = request_content_type.nil? ? {} : {"Accept" => request_content_type}
            body = nil
          end

          RawRequest.new(method, URI.parse(url), body, headers)
        }

        it "should return status #{response_code}" do
          assert { response[:status] == response_code }
        end

        it "should have response header 'Content-Type' of '#{response_content_type}'" do
          assert { response[:headers]["Content-Type"] == response_content_type }
        end

        it "should have response header 'Location' that matches '#{response_location.pretty_inspect.strip}'" do
          assert { 
            location = response[:headers]["Location"] 
            if response_location
              location.match(response_location)
            else
              location.nil?
            end
          }
        end

        case [method, resource_type]
        when [:get, :index]
          it "should call datastore.find_all at some point" do
            subject.datastore.should_receive(:find_all)
            response
          end unless (extension.nil? && request_content_type.nil?)

        when [:post, :index]
          it "should call datastore.create at some point" do
            subject.datastore.should_receive(:create)
            response
          end

        when [:get, :resource]
          it "should call datastore.find at some point" do
            subject.datastore.should_receive(:find)
            response
          end unless (extension.nil? && request_content_type.nil?)

        when [:put, :resource]
          it "should call datastore.update at some point" do
            Hoodwink::DataStoreProxy.stub!(:new).and_return(ds_proxy)
            ds_proxy.should_receive(:update).with(anything(), anything()).exactly(:once)
            response
          end

        when [:delete, :resource]
          it "should call datastore.delete at some point" do
            Hoodwink::DataStoreProxy.stub!(:new).and_return(ds_proxy)
            ds_proxy.should_receive(:delete).with(anything()).exactly(:once)
            response
          end

        end
      end

    end

  end
end

