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
      return body_for_html if format == "html"
      data.send("to_#{format}", :root => root)
    end

    # GET    "/fish.json",   {}, [@fish, @fish]
    # POST   "/fish.json",   {}, @fish, 201, "Location" => "/fish/1.json"
    # GET    "/fish/1.json", {}, @fish
    # PUT    "/fish/1.json", {}, nil, 204
    # DELETE "/fish/1.json", {}, nil, 200
    def response_for(raw_request)
      request = Request.new(raw_request, resource_path)

      case [request.request_type, request.method]

      when [:collection, :get]
        response_format = request.response_format
        # find_all(resource_name)
        response_body = format_as(response_format, @resource_name.singularize, find_all)
        response_for_get(response_body, response_format)

      # TODO: rename data
      when [:collection, :post]
        posted_resource = request.resource
        # create(resource_name, hash)
        new_resource = @datastore.create(resource_name, posted_resource)
        resource_location = "#{resource_path}/#{new_resource.id}"
        response_format = request.response_format
        response_body = format_as(response_format, @resource_name.singularize, new_resource)
        response_for_nonget(request, resource_location, response_body)

      # TODO: rename data
      when [:resource, :get]
        resource = find(request.resource_id)
        response_body = format_as(request.response_format, @resource_name.singularize, resource)
        response_for_get(response_body, request.response_format)

      when [:resource, :put]
        resource = request.resource
        resource_id = request.resource_id
        resource_location = "#{resource_path}/#{resource_id}"
        # update(resource_name, id, hash)
        update(resource_id, resource)
        response_for_nonget(request, resource_location, nil)

      when [:resource, :delete]
        resource_location = resource_path
        # delete(resource_name, id)
        delete(request.resource_id)
        response_format = request.response_format
        response_for_nonget(request, resource_location, nil)

      else
        raise UnableToHandleRequest, "Could not handle request for #{request.method} on #{path}"
      end

    rescue RecordNotFound
      response_for_404
    end

    def find_all
      @datastore.find_all(@resource_name)
    end

    def find(id)
      @datastore.find(@resource_name, id)
    end

    def create(resource)
      @datastore.create(@resource_name, resource_hash)
    end

    def update(id, resource_hash)
      find(id).update_attributes(resource_hash)
    end

    def delete(id)
      find(id).destroy
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
    def response_for_nonget(request, resource_location, response_body)
      if request.url_format || (request.method == :delete && request.headers["Accept"])
        headers = { "Location" => resource_location }
        headers.merge!("Content-Type" => MIMETYPES_BY_FORMAT[request.response_format]) if request.method != :delete
        { :body => response_body,
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

    def body_for_html
      %{<html><body>Hi from hoodwink! Rails would normally return HTML here...</body></html>}
    end

    def body_for_redirect(url)
      %{<html><body>You are being <a href="#{url}">redirected</a>.</body></html>}
    end

  end
end
