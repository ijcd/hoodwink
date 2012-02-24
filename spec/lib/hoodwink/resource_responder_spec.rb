require File.join(File.dirname(__FILE__), '../../spec_helper.rb')

describe Hoodwink do
  subject { 
    datastore = double("datastore", :find_all => [{},{},{}], :find => {}, :create => {}, :update => {}, :delete => {})
    Hoodwink::ResourceResponder.new("/fowl", datastore)
  }

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

  describe "#response_body_for_all" do
    it "should use @datastore.find_all" do
      subject.datastore.should_receive(:find_all).with("fowl").once
      subject.response_body_for_all("json")
    end

    it "should format data as json" do
      subject.should_receive(:format_as).with("json", "fowls", anything()).once
      subject.response_body_for_all("json")
    end

    it "should format data as xml" do
      subject.should_receive(:format_as).with("xml", "fowls", anything()).once
      subject.response_body_for_all("xml")
    end
  end

  describe "#response_body_for_id" do
    it "should use @datastore.find" do
      subject.datastore.should_receive(:find).with("fowl", 1).once
      subject.response_body_for_id("json", 1)
    end

    it "should format data as json" do
      subject.should_receive(:format_as).with("json", "fowl", anything()).once
      subject.response_body_for_id("json", 1)
    end

    it "should format data as xml" do
      subject.should_receive(:format_as).with("xml", "fowl", anything()).once
      subject.response_body_for_id("xml", 1)
    end
  end

  # TODO: setup tests to run against actual Rails/ActiveResource to compare values
  describe "#response_for" do
    before(:all) { Request = Struct.new("Request", :method, :uri, :body, :headers) }

    let(:response) { subject.response_for(request) }

    #                                  accept/
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
          else
            headers = request_content_type.nil? ? {} : {"Accept" => request_content_type}
          end

          Request.new(method, URI.parse(url), nil, headers)
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
          it "should call datastore.find and datastore.save at some point" do
            subject.datastore.should_receive(:update)
            response
          end

        when [:delete, :resource]
          it "should call the datastore.find and datastore.delete at some point" do
            subject.datastore.should_receive(:delete)
            response
          end

        end
      end

    end

  end
end
