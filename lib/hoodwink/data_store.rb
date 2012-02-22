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

module Hoodwink
  module Models
    # we'll stuff SuperModels into here
  end

  class DataStore

    def initialize
      @models = {}
    end

    # lookup the SuperModel, retry after creating if not found
    def model_for(sym)
      name = sym.to_s.classify
      "Hoodwink::Models::#{name}".constantize
    rescue NameError
      klass = Class.new(SuperModel::Base)
      @models[sym] = Hoodwink::Models.const_set(name, klass)
      retry
    end
    
    def find(name, id)
      id = id.to_s
      model_for(name).find(id)
    end

    def find_all(name)
      model_for(name).all
    end

    def create(name, params)
      params["id"] = params["id"].to_s if params["id"]
      params[:id] = params[:id].to_s if params[:id]
      model_for(name).create(params)
    end

    def update(name, params)
    end

    def delete(name, params)
    end

    def clear
      @models.values.each {|m| m.clear }
    end
  end
end
