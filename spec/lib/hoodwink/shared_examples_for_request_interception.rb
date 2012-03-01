shared_examples "for a mocked resource with mimetype and extension" do |mimetype, extension|
  it "should intercept index GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
    responder.should_receive(:response_for).once.and_return(:body => {})
    headers = mimetype.nil? ? {} : {"Accept" => mimetype}
    http.get("#{resource_path}#{extension}", headers)
  end

  it "should intercept index POST requests with #{mimetype}" do
    responder.should_receive(:response_for).once.and_return(:body => {})
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    http.post("#{resource_path}#{extension}", "", headers)
  end

  it "should intercept resource GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
    responder.should_receive(:response_for).once.and_return(:body => {})
    headers = mimetype.nil? ? {} : {"Accept" => mimetype}
    http.get("#{resource_path}/1#{extension}", headers)
  end

  it "should intercept resource PUT requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
    responder.should_receive(:response_for).once.and_return(:body => {})
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    http.put("#{resource_path}/1#{extension}", "", headers)
  end

  it "should intercept resource DELETE requests with extension \"#{extension}\" and mimetype #{mimetype.inspect}" do
    responder.should_receive(:response_for).once.and_return(:body => {})
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    http.delete("#{resource_path}/1#{extension}", headers)
  end

  ## longer URLs ##

  it "should NOT intercept index GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect} for longer urls that submatch" do
    responder.should_not_receive(:response_for)
    headers = mimetype.nil? ? {} : {"Accept" => mimetype}
    expect { http.get("#{resource_path}#{extension}/foo", headers) }.should raise_error(WebMock::NetConnectNotAllowedError)
  end unless extension

  it "should NOT intercept index POST requests with #{mimetype} for longer urls that submatch" do
    responder.should_not_receive(:response_for)
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    expect { http.post("#{resource_path}#{extension}/foo", "", headers) }.should raise_error(WebMock::NetConnectNotAllowedError)
  end

  it "should NOT intercept resource GET requests with extension \"#{extension}\" and mimetype #{mimetype.inspect} for longer urls that submatch" do
    responder.should_not_receive(:response_for)
    headers = mimetype.nil? ? {} : {"Accept" => mimetype}
    expect { http.get("#{resource_path}/1#{extension}/foo", headers) }.should raise_error(WebMock::NetConnectNotAllowedError)
  end

  it "should NOT intercept resource PUT requests with extension \"#{extension}\" and mimetype #{mimetype.inspect} for longer urls that submatch" do
    responder.should_not_receive(:response_for)
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    expect { http.put("#{resource_path}/1#{extension}/foo", "", headers) }.should raise_error(WebMock::NetConnectNotAllowedError)
  end

  it "should NOT intercept resource DELETE requests with extension \"#{extension}\" and mimetype #{mimetype.inspect} for longer urls that submatch" do
    responder.should_not_receive(:response_for)
    headers = mimetype.nil? ? {} : {"Content-Type" => mimetype}
    expect { http.delete("#{resource_path}/1#{extension}/foo", headers) }.should raise_error(WebMock::NetConnectNotAllowedError)
  end
end

shared_examples "for a mocked resource" do |mimetype, extension|
  include_examples "for a mocked resource with mimetype and extension", nil,                ".json"
  include_examples "for a mocked resource with mimetype and extension", "*/*",              ".json"
  include_examples "for a mocked resource with mimetype and extension", "application/json", ".json"
  include_examples "for a mocked resource with mimetype and extension", "application/json", ""
  
  include_examples "for a mocked resource with mimetype and extension", nil,                ".xml"
  include_examples "for a mocked resource with mimetype and extension", "*/*",              ".xml"
  include_examples "for a mocked resource with mimetype and extension", "application/xml",  ".xml"
  include_examples "for a mocked resource with mimetype and extension", "application/xml",  ""
end

