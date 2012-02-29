require "active_support/core_ext/object"
require "active_support/core_ext/string"
require "active_support/core_ext/class"
require "active_resource"
require "webmock"
require "supermodel"

require "hoodwink/version"

module Hoodwink

  autoload :RequestInterceptor, "hoodwink/request_interceptor"
  autoload :ResourceResponder,  "hoodwink/resource_responder"
  autoload :DataStore,          "hoodwink/data_store"
  autoload :Resource,           "hoodwink/resource"
  autoload :Request,            "hoodwink/request"

  SUPPORTED_FORMATS = {
    "application/xml"  => "xml",
    "application/json" => "json",
    "text/html"        => "html"
  }

  MIMETYPES_BY_FORMAT = SUPPORTED_FORMATS.invert

  # Generic Hoodwink exception class
  class HoodwinkError < StandardError ; end

  # Raised when Hoodwink cannot find record by given id
  class RecordNotFound < HoodwinkError ; end

  # Raised when Hoodwink receives a request it cannot handle
  class UnableToHandleRequest < HoodwinkError ; end
  
  def self.interceptor
    RequestInterceptor.instance
  end

  def self.datastore
    interceptor.datastore
  end

  # TODO: can we allow/disallow from a regexp?
  def self.allow_net_connect!(*args)
    interceptor.allow_net_connect!(*args)
  end

  # TODO: WebMock.disable_net_connect!(:allow => "www.example.org:8080")
  def self.disable_net_connect!(*args)
    interceptor.disable_net_connect!(*args)
  end

  def self.reset
    interceptor.reset
  end

  def self.mock_resource(resource_url, resource_name=nil, &block)
    interceptor.mock_resource(resource_url, resource_name, &block)
  end

  def self.create(model_name, records={})
    model_name = model_name.to_s.singularize.to_sym
    datastore.create model_name, records
  end

end
