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

  # TODO: break SuperModel out into an adapter so we can have other db types
  # TODO: use method_missing or delegation to send into SuperModel
  class DataStore
    attr_reader :models

    def initialize
      @models = {}
    end

    # lookup the SuperModel, retry after creating if not found
    def model_for(sym)
      model_name = sym.to_s.classify
      if klass = @models[model_name]
        klass
      else
        klass = "Hoodwink::Models::#{model_name}".constantize
        klass.delete_all # clear out this model since it's the first time we've seen it.
        @models[model_name] = klass
      end
    rescue NameError
      klass = Class.new(SuperModel::Base)
      Hoodwink::Models.const_set(model_name, klass)
      retry
    end
    
    def find(model_name, id)
      id = Integer(id) rescue id
      model_for(model_name).find(id)
    rescue SuperModel::UnknownRecord => e
      raise RecordNotFound, e.message
    end

    def find_all(model_name)
      model_for(model_name).all
    end

    #define model_name unless model_exists(model_name)
    #records = records.kind_of?(Array) ? records.map {|r| r.symbolize_keys} : records.symbolize_keys!
    def create(model_name, params={})
      params.stringify_keys!
      model_for(model_name).create(params)
    end

    def create!(model_name, params={})
      params.stringify_keys!
      model_for(model_name).create!(params)
    end

    def update(model_name, model_id, params={})
      params.stringify_keys!
    end

    def delete(model_name, model_id)
    end

    def clear!
      @models.values.each {|m| m.delete_all }
    end

    def inspect
      @buf = []
      @models.each do |model_name, model|
        models = model.all
        @buf << "#{model_name} (#{models.count}):"
        models.each do |m|
          @buf << "  #{m.inspect}"
        end
      end
      @buf.join("\n")
    end

  end
end
