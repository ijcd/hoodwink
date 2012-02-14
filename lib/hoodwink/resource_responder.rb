module Hoodwink
  class ResourceResponder
    attr_reader :resource_path
    attr_reader :resource_name
    attr_reader :resource_factory

    SUPPORTED_FORMATS = {
      "xml" => "application/xml",
      "json" => "application/json"
    }
    
    def initialize(resource_path, resource_factory)
      @resource_path = resource_path
      @resource_name = %r{/(.*)}.match(resource_path)[1]
      @resource_factory = resource_factory
    end

    # GET    "/fish.json",   {}, [@fish, @fish]
    # POST   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
    # GET    "/fish/1.json", {}, @fish
    # PUT    "/fish/1.json", {}, nil, 204
    # DELETE "/fish/1.json", {}, nil, 200
    def response_for(request)
      onefish_json = @resource_factory.create.to_json(:root => @resource_name.singularize)
      twofish_json = (1..3).map{@resource_factory.create}.to_json(:root => @resource_name.pluralize)

      collection_re = %r{#{resource_path}\.(?<format>.*)}
      resource_re   = %r{#{resource_path}/(?<id>[^.]+).(?<format>.*)}

      # collection requests
      if match = (request.uri.to_s.match(collection_re))
        case request.method
        when :get
          {:body => twofish_json}
        when :post
          resource_id = 1
          resource_location = "#{resource_path}/#{resource_id}.#{match[:format]}"
          {:body => onefish_json, :status => 201, :headers => {"Location" => resource_location}}
        end

        # resource request
      elsif match = (request.uri.to_s.match(resource_re))
        case request.method
        when :get
          {:body => onefish_json}
        when :put
          {:body => nil, :status => 204}
        when :delete
          {:body => nil}
        end

      else
        raise "Unable to respond to request #{request}"
      end
    end

  end
end
