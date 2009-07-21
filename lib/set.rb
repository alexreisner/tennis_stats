class Set
  attr_reader :games
  attr_accessor :match
  
  def initialize
    @games = []
  end

  def winner
    games.group_by{ |i| i.winner }.to_a.sort_by{ |i| i[1].size }.last[0]
  end
  
  def add_game(game)
    @games << game
    game.set = self
  end
  
  def final_score(player = winner)
    g = games.group_by{ |i| i.winner }
    other = g.keys.detect{ |i| i != player }
    "#{g[player].size}-#{g[other].size}"
  end
  
  def points
    games.collect{ |g| g.points }.flatten
  end
end

