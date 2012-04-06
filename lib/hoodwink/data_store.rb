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
    def self.models
      @models ||= []
    end

    def self.reset!
      models.each do |model| 
        model.delete_all
        model_name = model.name.split('::').last
        #pp "Removing #{model.pretty_inspect}: #{model.object_id}"
        remove_const(model_name)
      end
      models.clear
    end

    # we'll stuff SuperModels into here (they'll pop into existence on reference
    def self.const_missing(name)
      model = const_set(name, Class.new(SuperModel::Base))
      models << model
      #pp "Loaded #{model.pretty_inspect}: #{model.object_id}"
      model
    end
  end

  # TODO: maybe hide datastore.create(:foo, ...) type methods using proxy models from const_set in Hoodwink::Models that already know about the datastore... then they just be refernce directly
  # TODO: break SuperModel out into an adapter so we can have other db types
  # TODO: use method_missing or delegation to send into SuperModel
  class DataStore

    # lookup the SuperModel, retry after creating if not found
    def model_for(sym)
      model_name = sym.to_s.classify
      model_full_name = "Hoodwink::Models::#{model_name}"
      if defined?(model_full_name.constantize)
        model_full_name.constantize
      else
        raise ModelUnknown, model_name
      end
    end
    
    # try as original, then as integer
    def find(model_name, id)
      begin
        model_for(model_name).find(id)
      rescue SuperModel::UnknownRecord => e
        id = Integer(id) rescue id
        model_for(model_name).find(id)
      end
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

    def delete(model_name, model_id)
    end

    def clear!
      Models.reset!
    end

    def inspect
      @buf = []
      Models.models.each do |model|
        records = model.all
        @buf << "#{model.name} (#{records.count}):"
        records.each do |r|
          @buf << "  #{r.inspect}"
        end
      end
      @buf.join("\n")
    end

  end
end
