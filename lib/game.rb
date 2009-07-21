class Game
  attr_reader :points, :server
  attr_accessor :set
  
  def initialize(server)
    @server = server
    @points = []
  end
  
  def winner
    @points.group_by{ |i| i.winner }.to_a.sort_by{ |i| i[1].size }.last[0]
  end
  
  def add_point(point)
    @points << point
    point.game = self
  end
end

