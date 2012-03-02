module Hoodwink
  class Request
    attr_reader :raw_request
    attr_reader :resource_path_re

    def initialize(raw_request, resource_path_re)
      @raw_request   = raw_request
      @resource_path_re = resource_path_re

      @collection_re = %r{^#{resource_path_re}(\.(?<url_format>.*))?$}
      @resource_re   = %r{^#{resource_path_re}/(?<id>[^.]+)(.(?<url_format>.*))?$}
    end

    def path
      raw_request.uri.path
    end

    def method
      raw_request.method
    end

    def uri
      raw_request.uri
    end

    def headers
      raw_request.headers
    end

    def body
      raw_request.body
    end

    def url_format
      match = (path.match(@collection_re) || path.to_s.match(@resource_re))
      match[:url_format]
    end

    def collection_request?
      path.match(@collection_re)
    end

    def resource_request?
      path.match(@resource_re)
    end

    def segment_params
      Request.extract_segment_params(path, resource_path_re)
    end

    def request_type
      return :collection if collection_request?
      return :resource if resource_request?
      nil
    end

    def body_content_type
      SUPPORTED_FORMATS[headers["Content-Type"]] || url_format || nil
    end

    def response_format
      if method == :get
        url_format || SUPPORTED_FORMATS[headers["Accept"]] || "html"
      else
        url_format || SUPPORTED_FORMATS[headers["Accept"]]
      end
    end

    def resource
      return "" unless body_content_type
      format = ActiveResource::Formats[body_content_type.to_sym]
      format.decode(body)
    end

    def resource_id
      if match = resource_request?
        match[:id]
      else
        nil
      end
    end

    def self.path_to_segments_re(path)
      segments_to_re(path_to_segments(path))
    end
    
    def self.path_to_segments(path)
      path.scan(%r{(?!/)[^/]+})
    end

    def self.segments_to_re(segments)
      Regexp.new(["", 
                  segments.map do |s|
                    if s.match(/:(?<var>.+)/) 
                      "(?<#{$~[:var]}>[^/]+)"
                    else
                      s
                    end
                  end
                 ].join("/")
               )
    end

    def self.extract_segment_params(path, path_re)
      if m = path.match(path_re)
        HashWithIndifferentAccess[m.names.zip(m.captures)]
      else
        {}
      end
    end

  end
end
