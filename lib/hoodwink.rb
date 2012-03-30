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

  def self.debug?
    ENV['HOODWINK_DEBUG']
  end

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
    reset_mocks
    reset_datastore
  end

  def self.reset_mocks
    interceptor.reset
  end

  def self.reset_datastore
    datastore.clear!
  end

  def self.banner(msg)
    puts "=" * 80
    puts msg
    puts "=" * 80
  end

  # only reloads if files have changed
  def self.reload(&block)
    if data_changed?
      banner "DATA CHANGED"
      reload!(&block)
    elsif mocks_changed?
      banner "MOCKS CHANGED"
      reset_mocks
      find_mocks
    end
  end

  # unconditionally reloads everything
  def self.reload!
    reset
    yield if block_given?
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

  def self.find_data
    @last_data_load = Time.now
    load_files(data_file_paths)
  end

  def self.find_mocks
    @last_mock_load = Time.now
    load_files(mock_file_paths)
  end

  def self.mocks_changed?
    @last_mock_load ||= Time.new(0)
    @last_mock_load < collect_files(mock_file_paths).map{|f| File.stat(f).mtime}.max 
  end

  # TODO: externalize dependency on FactoryGirl paths here (pass them in from tne initializer)
  def self.data_changed?
    @last_data_load ||= Time.new(0)
    @last_data_load < (collect_files(data_file_paths) + collect_files(FactoryGirl.definition_file_paths)).map{|f| File.stat(f).mtime}.max 
  end

  private

  def self.load_files(root_paths)
    collect_files(root_paths).each {|f| 
      banner "LOADING: #{f}"
      load(f)
    }
  end

  def self.absolute_paths(paths)
    Array.wrap(paths).map {|path| File.expand_path(path) }
  end

  def self.collect_files(root_paths)
    @files = []
    absolute_root_paths = absolute_paths(root_paths)
    absolute_root_paths.uniq.each do |path|
      if File.directory?(path)
        Dir[File.join(path, '**', '*.rb')].sort.each do |file|
          @files << file
        end
      else
        @files << (path)         if File.file?(path)
        @files << (path + ".rb") if File.file?(path + ".rb")
      end
    end
    @files
  end

end
