module Datasets
  class Whatever
    def initialize
      puts "this is a bunch of uncovered code"
    end

    def foo(param)
      param = param * 10
      param * rand(100)
    end
  end
end
