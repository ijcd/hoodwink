module Hoodwink

  class ResourceResponder
    attr_reader :resource_path
    attr_reader :resource_name
    attr_reader :datastore

    def initialize(resource_path, resource_name, datastore)
      @resource_path = resource_path
      @resource_name = resource_name.to_s
      @datastore = datastore
    end

    def format_as(format, root, data)
      data.send("to_#{format}", :root => root)
    end

    # TODO: test with AR that expects and doesn't expect roots
    def response_body_for_all(response_format)
      return body_for_html if response_format == "html"
      data = @datastore.find_all(@resource_name)
      format_as(response_format, @resource_name.singularize, data)
    end

    def response_body_for_id(response_format, resource_id)
      return body_for_html if response_format == "html"
      format_as(response_format, @resource_name.singularize, @datastore.find(@resource_name, resource_id))
    end

    def body_for_html
      %{<html><body>Hi from hoodwink! Rails would normally return HTML here...</body></html>}
    end

    def body_for_redirect(url)
      %{<html><body>You are being <a href="#{url}">redirected</a>.</body></html>}
    end

    # GET    "/fish.json",   {}, [@fish, @fish]
    # POST   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
    # GET    "/fish/1.json", {}, @fish
    # PUT    "/fish/1.json", {}, nil, 204
    # DELETE "/fish/1.json", {}, nil, 200
    def response_for(raw_request)
      request = Request.new(raw_request, resource_path)

      # collection request
      if request.collection_request?
        response_for_collection(request)

      # resource request
      elsif request.resource_request?
        response_for_resource(request)
      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{request.path}"
      end

    rescue RecordNotFound
      response_for_404
    end

    # TODO: move request and many methods dealing with it out into EnhancedRequest
    # TODO: move resource and many methods dealing with it out into EnhancedResource
    def response_for_collection(request)
      case request.method
      when :get
        response_format = request.response_format
        response_body = response_body_for_all(response_format)
        response_for_get(response_body, response_format)
      when :post
        posted_resource = request.resource
        new_resource = datastore.create(resource_name, posted_resource)
        resource_location = "#{resource_path}/#{new_resource.id}"
        response_format = request.response_format
        response_for_nonget(request, resource_location, new_resource)
      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{path}"
      end
    end

    def response_for_resource(request)
      case request.method
      when :get
        response_body = response_body_for_id(request.response_format, request.resource_id)
        response_for_get(response_body, request.response_format)
      when :put
        resource = request.resource
        resource_id = request.resource_id
        resource_location = "#{resource_path}/#{resource_id}"
        datastore.update(resource_name, resource_id, resource)
        response_for_nonget(request, resource_location, nil)
      when :delete
        resource_location = resource_path
        datastore.delete(resource_name, request.resource_id)
        response_format = request.response_format
        response_for_nonget(request, resource_location, nil)
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
    def response_for_nonget(request, resource_location, resource)
      if request.url_format || (request.method == :delete && request.headers["Accept"])
        headers = { "Location" => resource_location }
        headers.merge!("Content-Type" => MIMETYPES_BY_FORMAT[request.response_format]) if request.method != :delete
        body = resource ? response_body_for_id(request.response_format, resource.id) : nil
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
