require "active_support/core_ext/object"
require "active_support/core_ext/string"
require "active_support/core_ext/class"
require "active_resource"
require "webmock"
require "addressable/uri"
require "supermodel"
require "hoodwink/version"
#require "hoodwink/rails"

module Hoodwink

  autoload :RequestInterceptor, "hoodwink/request_interceptor"
  autoload :ResourceResponder,  "hoodwink/resource_responder"
  autoload :DataStore,          "hoodwink/data_store"
  autoload :Models,             "hoodwink/data_store"
  autoload :DataStoreProxy,     "hoodwink/data_store_proxy"
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

  # Raised when Hoodwink cannot find a given model
  class ModelUnknown < HoodwinkError ; end

  
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
    datastore.clear!
  end

  # TODO: only reload if files have changed
  def self.reload
    reset
    find_mocks
    find_data
  end

  def self.mock_resource(resource_url, resource_name=nil, &block)
    interceptor.mock_resource(resource_url, resource_name, &block)
  end

  class << self
    # An Array of strings specifying locations that should be searched for
    # data definitions. By default, Hoodwink will attempt to require
    # "hoodwink/data".
    attr_accessor :data_file_paths

    # An Array of strings specifying locations that should be searched for
    # mock definitions. By default, Hoodwink will attempt to require
    # "hoodwink/mocks".
    attr_accessor :mock_file_paths
  end

  self.data_file_paths = %w(hoodwink/data)
  self.mock_file_paths = %w(hoodwink/mocks)

  def self.find_data #:nodoc:
    load_files(Array.wrap(data_file_paths))
  end

  def self.find_mocks #:nodoc:
    load_files(Array.wrap(mock_file_paths))
  end

  private

  def self.load_files(root_paths) #:nodoc:
    absolute_root_paths = root_paths.map {|path| File.expand_path(path) }
    absolute_root_paths.uniq.each do |path|
      if File.directory? path
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          load file
        end
      else
        load("#{path}") if File.file?("#{path}")
        load("#{path}.rb") if File.file?("#{path}.rb")
      end
    end
  end
end
