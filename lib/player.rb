module TennisStats
  class Player
    attr_reader :name
    
    def initialize(name = nil)
      @name = name
    end
    
    def to_s
      name
    end
  end
end
