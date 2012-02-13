require "hoodwink/version"

module Hoodwink

  class << self
    include WebMock::API
  end

  def self.allow_net_connect!
    WebMock.allow_net_connect!
  end

  def self.disable_net_connect!
    WebMock.disable_net_connect!
  end

  def self.mocks
    @mocks ||= []
  end

  def self.reset
    @mocks = []
    WebMock.reset!
  end

  def self.mock_resource(resource_url, *formats)
    mocks << resource_url

    # create or find resource responder
    resource_uri = Addressable::URI.parse(resource_url)
    resource_path = resource_uri.path
    resource_host = resource_uri.host
    responder = ResourceResponder.new(resource_uri.path)

    # wire requests to the responder
    ResourceResponder::SUPPORTED_FORMATS.each do |format, mimetype|

      collection_re = %r{^http(s)?://#{resource_host}#{resource_path}.#{format}}
      resource_re   = %r{^http(s)?://#{resource_host}#{resource_path}/([^.]+).#{format}}

      # INDEX
      # mock.get    "/fish.json", {}, [@fish, @fish]
      stub_request(:get, collection_re)
        .with(:headers => {'Accept'=>mimetype})
        .to_return {|request| responder.response_for(request) }
      
      # POST
      # mock.post   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
      stub_request(:post, collection_re)
        .with(:headers => {'Content-Type'=>mimetype})
        .to_return {|request| responder.response_for(request) }

      # GET
      # mock.get    "/fish/1.json", {}, @fish
      stub_request(:get, resource_re)
        .with(:headers => {'Accept'=>mimetype})
        .to_return {|request| responder.response_for(request) }

      # PUT
      # mock.put    "/fish/1.json", {}, nil, 204
      stub_request(:put, resource_re)
        .with(:headers => {'Content-Type'=>mimetype})
        .to_return {|request| responder.response_for(request) }

      # DELETE
      # mock.delete "/fish/1.json", {}, nil, 200
      stub_request(:delete, resource_re)
        .with(:headers => {'Accept'=>mimetype})
        .to_return {|request| responder.response_for(request) }

    end

  end
end

