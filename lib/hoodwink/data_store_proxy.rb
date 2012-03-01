module Hoodwink
  class DataStoreProxy
    attr_reader :resource_name
    attr_reader :datastore
    attr_reader :request
   
    def initialize(resource_name, datastore, request)
      @resource_name = resource_name
      @datastore = datastore
      @request = request
    end

    def find_all
      @datastore.find_all(@resource_name)
    end

    def find(id)
      @datastore.find(@resource_name, id)
    end

    def create(resource_hash)
      @datastore.create(@resource_name, resource_hash)
    end

    def update(id, resource_hash)
      find(id).update_attributes(resource_hash)
    end

    def delete(id)
      find(id).destroy
    end
  end
end
