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
      name = sym.to_s.classify
      if klass = @models[name]
        klass
      else
        klass = "Hoodwink::Models::#{name}".constantize
        klass.delete_all # clear out this model since it's the first time we've seen it.
        @models[name] = klass
      end
    rescue NameError
      klass = Class.new(SuperModel::Base)
      Hoodwink::Models.const_set(name, klass)
      retry
    end
    
    def find(name, id)
      id = Integer(id) rescue id
      model_for(name).find(id)
    rescue SuperModel::UnknownRecord => e
      raise RecordNotFound, e.message
    end

    def find_all(name)
      model_for(name).all
    end

    def create(name, params={})
      params.stringify_keys!
      model_for(name).create(params)
    end

    def create!(name, params={})
      params.stringify_keys!
      model_for(name).create!(params)
    end

    def update(name, params={})
      params.stringify_keys!
    end

    def delete(name, params={})
      params.stringify_keys!
    end

    def clear!
      @models.values.each {|m| m.delete_all }
    end

    def inspect
      @buf = []
      @models.each do |name, model|
        models = model.all
        @buf << "#{name} (#{models.count}):"
        models.each do |m|
          @buf << "  #{m.inspect}"
        end
      end
      @buf.join("\n")
    end

  end
end
