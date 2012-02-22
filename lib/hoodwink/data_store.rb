    # FactoryGirl.define do
    #   factory :fish do
    #     sequence(:id)
    #     color { %w{red blue green yellow}.sample }
    #   end
    # end rescue nil

    # # create a resource factory
    # factory = ResourceFactory.new("fish") do
    #   FactoryGirl.build(:fish)
    # end

      # onefish_json = @resource_factory.create.to_json(:root => @resource_name.singularize)
      # twofish_json = (1..3).map{@resource_factory.create}.to_json(:root => @resource_name.pluralize)


module Hoodwink

  class Fish < SuperModel::Base ; end

  class DataStore
    def initialize
      Fish.create(:id => "1", :color => "Red")
    end

    def model(sym)
      "Hoodwink::#{sym.to_s.classify}".constantize
    end
    
    def find(name, id)
      id = id.to_s
      model(name).find(id)
    end

    def find_all(name)
      model(name).all
    end

    def create(*args)
    end

    def update(*args)
    end

    def delete(*args)
    end

  end
end
