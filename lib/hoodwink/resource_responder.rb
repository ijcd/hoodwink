module Hoodwink
  class ResourceResponder
    attr_reader :resource_path
    attr_reader :resource_name
    attr_reader :datastore

    SUPPORTED_FORMATS = {
      "xml" => "application/xml",
      "json" => "application/json"
    }
    
    def initialize(resource_path, datastore)
      @resource_path = resource_path
      @resource_name = %r{/(.*)}.match(resource_path)[1]
      @datastore = datastore
    end

    def format_as(format, root, data)
      data.send("to_#{format}", :root => root)
    end

    def response_body_for_all(format)
      format_as(format, @resource_name.pluralize, @datastore.find_all(@resource_name))
    end

    def response_body_for_id(format, id)
      format_as(format, @resource_name.singularize, @datastore.find(@resource_name, id))
    end

    # GET    "/fish.json",   {}, [@fish, @fish]
    # POST   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
    # GET    "/fish/1.json", {}, @fish
    # PUT    "/fish/1.json", {}, nil, 204
    # DELETE "/fish/1.json", {}, nil, 200
    def response_for(request)
      path = request.uri.path
      collection_re = %r{#{resource_path}\.(?<format>.*)}
      resource_re   = %r{#{resource_path}/(?<id>[^.]+).(?<format>.*)}

      # collection requests
      if match = (path.match(collection_re))
        case request.method
        when :get
          {:body => response_body_for_all(match[:format])}
        when :post
          resource_id = 1
          resource_location = "#{resource_path}/#{resource_id}.#{match[:format]}"
          { :body => response_body_for_id(match[:format], resource_id), 
            :status => 201, 
            :headers => {"Location" => resource_location}
          }
        end

        # resource request
      elsif match = (path.to_s.match(resource_re))
        case request.method
        when :get
          {:body => response_body_for_id(match[:format], match[:id])}
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
