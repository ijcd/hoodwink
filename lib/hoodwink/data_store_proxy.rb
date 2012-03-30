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

    def filter_by(model)
      model
    end
    
    def segments
      request.segment_params
    end

    def find_all
      @datastore.find_all(@resource_name).select{|m| filter_by(m)}
    end

    # TODO: perhaps find() should use find_all()
    def find(id)
      found = @datastore.find(@resource_name, id)
      filter_by(found) ? found : nil
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
