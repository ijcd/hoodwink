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

    def mock_resource(resource_url, resource_name=nil, &block_extension)
      # guess resource_name from url if not given
      unless resource_name
        resource_uri = URI.parse(resource_url)        
        m = %r{^.*(/(?<resource_name>.*?))$}.match(resource_uri.path)
        resource_name = m[:resource_name]
      end

      # setup DataStoreProxy with extension methods if necessary
      if block_extension
        if Module === block_extension 
          extension_module = block_extension
        else
          extension_module = Module.new(&block_extension)
        end
        datastore_proxy_class = Class.new(DataStoreProxy) do
          include extension_module
        end
      end

      # take any segments out of the path
      segments = resource_uri.path.scan(%r{(?!/)[^/]+})
      segment_res = segments.map do |s|
        if s.match(/:(?<var>.+)/) 
          "(?<#{$~[:var]}>[^/]+)"
        else
          s
        end
      end
      resource_path_re = "/" + segment_res.join("/")

      # create a resource responder
      responder = ResourceResponder.new(resource_path_re, resource_name.singularize, datastore, datastore_proxy_class)

      # store the responder
      responders[resource_url] = responder

      # wire requests to the responder
      SUPPORTED_FORMATS.each do |mimetype, extension|
        stub_request_for(responder, resource_uri, resource_path_re, "*/*",    ".#{extension}")
        stub_request_for(responder, resource_uri, resource_path_re, mimetype, ".#{extension}")
        stub_request_for(responder, resource_uri, resource_path_re, mimetype, "")
      end
    end

    private

    def stub_request_for(responder, resource_uri, resource_path_re, mimetype, extension)
      resource_host = resource_uri.host
      resource_port = [nil, 80].include?(resource_uri.port) ? "": ":#{resource_uri.port}"

      # TODO: add tests for username/password
      # TODO: add tests for port
      # TODO: add tests for port :80 same as nil
      collection_re = %r{^https?://(.*@)?#{resource_host}#{resource_port}#{resource_path_re}#{extension}(\?(?<params>.*))?$} 
      resource_re =   %r{^https?://(.*@)?#{resource_host}#{resource_port}#{resource_path_re}/([^./]+)#{extension}(\?(?<params>.*))?$}

      response = Proc.new do |raw_request| 
        request = Request.new(raw_request, resource_path_re)
        responder.response_for(request)#.tap {|r| pp r}
      end

      # INDEX
      # mock.get    "/fish.json", {}, [@fish, @fish]
      stub_request(:get, collection_re).to_return(response)
      
      # POST
      # mock.post   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
      stub_request(:post, collection_re).to_return(response)

      # GET
      # mock.get    "/fish/1.json", {}, @fish
      stub_request(:get, resource_re).to_return(response)

      # PUT
      # mock.put    "/fish/1.json", {}, nil, 204
      stub_request(:put, resource_re).to_return(response)

      # DELETE
      # mock.delete "/fish/1.json", {}, nil, 200
      stub_request(:delete, resource_re).to_return(response)
    end
  end

end
