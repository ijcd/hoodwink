module Hoodwink

  class ResourceResponder
    attr_reader :resource_path
    attr_reader :resource_name
    attr_reader :datastore

    SUPPORTED_FORMATS = {
      "application/xml"  => "xml",
      "application/json" => "json",
      "text/html"        => "html"
    }

    MIMETYPES_BY_FORMAT = SUPPORTED_FORMATS.invert

    def initialize(resource_path, resource_name, datastore)
      @resource_path = resource_path
      @resource_name = resource_name.to_s
      @datastore = datastore
    end

    def format_as(format, root, data)
      data.send("to_#{format}", :root => root)
    end

    def response_body_for_all(format)
      return body_for_html if format == "html"
      data = @datastore.find_all(@resource_name)
      format_as(format, @resource_name.pluralize, data)
    end

    def response_body_for_id(format, id)
      return body_for_html if format == "html"
      format_as(format, @resource_name.singularize, @datastore.find(@resource_name, id))
    end

    def body_for_html
      %{<html><body>Hi from hoodwink! Rails would normally return HTML here...</body></html>}
    end

    def body_for_redirect(url)
      %{<html><body>You are being <a href="#{url}">redirected</a>.</body></html>}
    end

    # POST/PUT requests to Rails prefer Content-Type header to url_format
    def request_format_for_request(request, extension)
      SUPPORTED_FORMATS[request.headers["Content-Type"]] || extension || nil
    end

    # GET requests to Rails prefer url_format to Accept header
    # Rails seems to default to HTML
    def response_format_for_get(headers, url_format)
      url_format || SUPPORTED_FORMATS[headers["Accept"]] || "html"
    end

    def response_format_for_nonget(headers, url_format)
      url_format || SUPPORTED_FORMATS[headers["Accept"]]
    end

    def parse_resource(request, request_body_content_type)
      format = ActiveResource::Formats[request_body_content_type.to_sym]
      format.decode(request.body)
    end

    # GET    "/fish.json",   {}, [@fish, @fish]
    # POST   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
    # GET    "/fish/1.json", {}, @fish
    # PUT    "/fish/1.json", {}, nil, 204
    # DELETE "/fish/1.json", {}, nil, 200
    def response_for(request)
      path = request.uri.path
      collection_re = %r{^#{resource_path}(\.(?<url_format>.*))?$}
      resource_re   = %r{^#{resource_path}/(?<id>[^.]+)(.(?<url_format>.*))?$}

      # collection requests
      if match = (path.match(collection_re))
        url_format = match[:url_format]
        request_body_content_type = request_format_for_request(request, url_format)
        response_for_collection(request, url_format, request_body_content_type)
      # resource request
      elsif match = (path.to_s.match(resource_re))
        url_format = match[:url_format]
        request_body_content_type = request_format_for_request(request, url_format) 
        resource_id = match[:id]
        response_for_resource(request, url_format, request_body_content_type, resource_id)
      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{path}"
      end
    rescue RecordNotFound
      response_for_404
    end

    # TODO: move request and many methods dealing with it out into EnhancedRequest
    # TODO: move resource and many methods dealing with it out into EnhancedResource
    def response_for_collection(request, url_format, request_body_content_type)
      case request.method
      when :get
        response_format = response_format_for_get(request.headers, url_format)
        response_body = response_body_for_all(response_format)
        response_for_get(response_body, response_format)
      when :post
        posted_resource = parse_resource(request, request_body_content_type)
        new_resource = datastore.create("fish", posted_resource)
        resource_location = "#{resource_path}/#{new_resource.id}"
        response_format = response_format_for_nonget(request.headers, url_format)
        response_for_nonget(request, url_format, response_format, resource_location, new_resource)
      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{path}"
      end
    end

    def response_for_resource(request, url_format, request_body_content_type, resource_id)
      case request.method
      when :get
        response_format = response_format_for_get(request.headers, url_format)
        response_body = response_body_for_id(response_format, resource_id)
        response_for_get(response_body, response_format)
      when :put
        resource = parse_resource(request, request_body_content_type)
        resource_location = "#{resource_path}/#{resource_id}"
        datastore.update("fish", resource_id, resource)
        response_format = response_format_for_nonget(request.headers, url_format)
        response_for_nonget(request, url_format, response_format, resource_location, nil)
      when :delete
        resource_location = resource_path
        datastore.delete("fish", resource_id)
        response_format = response_format_for_nonget(request.headers, url_format)
        response_for_nonget(request, url_format, response_format, resource_location, nil)
      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{path}"
      end
    end

    def response_for_404
      { :body    => %{<html><body>404: Not Found</body></html>},
        :status  => 404
      }
    end

    def response_for_get(response_body, response_format)
      { :body    => response_body,
        :status  => 200,
        :headers => {"Content-Type" => MIMETYPES_BY_FORMAT[response_format]}
      }
    end

    # POST /cars   Content-Type:xml -> 302, else normal 201 response (this is what Rails 3.2 does)
    # PUT  /cars/1 Content-Type:xml -> 302, else normal 204 response (this is what Rails 3.2 does)
    def response_for_nonget(request, url_format, response_format, resource_location, resource)
      if url_format || (request.method == :delete && request.headers["Accept"])
        headers = { "Location" => resource_location }
        headers.merge!("Content-Type" => MIMETYPES_BY_FORMAT[response_format]) if request.method != :delete
        body = resource ? response_body_for_id(response_format, resource.id) : nil
        { :body => body, 
          :status => (request.method == :post) ? 201 : 204,
          :headers => headers
        }
      else
        { :body => body_for_redirect(resource_location),
          :status => 302,
          :headers => { "Location" => resource_location }
        }
      end
    end

  end
end
