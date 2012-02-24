module Hoodwink
  class Resource < Hash
    def initialize(id)
      self.id = id
    end

    def method_missing(name, value = nil)
      name = name.to_s
      if name =~ /=$/
        self[name.sub(/=$/, '')] = value
      else
        return self[name]
      end
    end
  end
end
