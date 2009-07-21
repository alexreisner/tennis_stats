module TennisStats
  class Point
    attr_reader :winner, :faults, :special
    attr_accessor :game
    
    def initialize(winner, faults = 0, special = nil)
      @winner = winner
      @faults = faults.to_i
      @special = special
    end
    
    def to_s
      "#{winner.name} (#{faults} faults)"
    end
    
    def server
      game.server
    end
  end
end
