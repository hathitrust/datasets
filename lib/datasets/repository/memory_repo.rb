module Datasets
  class MemoryRepo < Hash
    alias_method :save, :[]=
    alias_method :find, :[]
  end
end
