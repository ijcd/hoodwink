module Hoodwink
  class ResourceFactory
    attr_reader :resource_name

    def initialize(resource_name, &factory_block)
      @resource_name = resource_name
      @factory_block = factory_block
    end

    def create
      @factory_block.call
    end
  end
end
