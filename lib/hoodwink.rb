require "active_support/core_ext/string"
require "active_support/core_ext/class"
require "webmock"
require "factory_girl"
require "supermodel"

require "hoodwink/version"

module Hoodwink

  autoload :RequestInterceptor, "hoodwink/request_interceptor"
  autoload :ResourceFactory,    "hoodwink/resource_factory"
  autoload :ResourceResponder,  "hoodwink/resource_responder"
  autoload :DataStore,          "hoodwink/data_store"
  
  def self.interceptor
    RequestInterceptor.instance
  end

  def self.allow_net_connect!
    interceptor.allow_net_connect!
  end

  def self.disable_net_connect!
    interceptor.disable_net_connect!
  end

  def self.reset
    interceptor.reset
  end

  def self.mock_resource(resource_url)
    interceptor.mock_resource(resource_url)
  end

end
