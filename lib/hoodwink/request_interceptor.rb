module Hoodwink
  class RequestInterceptor
    include Singleton
    include WebMock::API

    def allow_net_connect!
      WebMock.allow_net_connect!
    end

    def disable_net_connect!
      WebMock.disable_net_connect!
    end

    def responders
      @responders ||= {}
    end

    def reset
      WebMock.reset!
      responders.clear
    end

    def datastore
      @datastore ||= DataStore.new
    end

    def mock_resource(resource_url, resource_name=nil)
      # guess resource_name from url if not given
      unless resource_name
        resource_uri = URI.parse(resource_url)        
        m = %r{^.*(/(?<resource_name>.*?))$}.match(resource_uri.path)
        resource_name = m[:resource_name]
      end

      # TODO: figure our plural/singular for resource_name
      # create a resource responder
      responder = ResourceResponder.new(resource_uri.path, resource_name.singularize, datastore)

      # store the responder
      responders[resource_url] = responder

      # wire requests to the responder
      ResourceResponder::SUPPORTED_FORMATS.each do |mimetype, format|
        stub_request_for(responder, resource_uri, "*/*",    ".#{format}")
        stub_request_for(responder, resource_uri, mimetype, ".#{format}")
        stub_request_for(responder, resource_uri, mimetype, "")
      end
    end

    private

    def stub_request_for(responder, resource_uri, mimetype, extension)
      resource_path = resource_uri.path
      resource_host = resource_uri.host
      resource_port = resource_uri.port.nil? ? "": ":#{resource_uri.port}"

      # TODO: add tests for username/password
      # TODO: add tests for port
      # TODO: add tests for port :80 same as nil
      collection_re = %r{ ^                       # anchored
                          https?://               # scheme (http/https)
                          (.*@)?                  # optional username/password
                          #{resource_host}        # host
                          #{resource_port}        # port
                          #{resource_path}        # path
                          #{extension}            # extension
                          (\?(?<params>.*))?      # optional params
                          $                       # anchored
                        }x

      resource_re =   %r{ ^                       # anchored
                          https?://               # scheme (http/https)
                          (.*@)?                  # optional username/password
                          #{resource_host}        # host
                          #{resource_port}        # port
                          #{resource_path}        # path
                          /([^./]+)               # id (no dots or forward slashes)
                          #{extension}            # extension
                          (\?(?<params>.*))?      # optional params
                          $                       # anchored
                        }x

      content_type_hash = mimetype.empty?

      # INDEX
      # mock.get    "/fish.json", {}, [@fish, @fish]
      stub_request(:get, collection_re)
        .to_return {|request| responder.response_for(request) }
      
      # POST
      # mock.post   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
      stub_request(:post, collection_re)
        .to_return {|request| responder.response_for(request) }

      # GET
      # mock.get    "/fish/1.json", {}, @fish
      stub_request(:get, resource_re)
        .to_return {|request| responder.response_for(request) }

      # PUT
      # mock.put    "/fish/1.json", {}, nil, 204
      stub_request(:put, resource_re)
        .to_return {|request| responder.response_for(request) }

      # DELETE
      # mock.delete "/fish/1.json", {}, nil, 200
      stub_request(:delete, resource_re)
        .to_return {|request| responder.response_for(request) }
    end
  end

end
