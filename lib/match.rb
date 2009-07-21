class Match
  attr_reader :sets, :date, :players
  
  def initialize(date = nil)
    @date    = date
    @sets    = []
    @players = []
  end

  def winner
    @sets.group_by{ |i| i.winner }.to_a.sort_by{ |i| i[1].size }.last[0]
  end
  
  def loser
    @players.detect{ |p| p != winner }
  end
  
  def add_player(player)
    @players << player
  end
  
  def add_set(set)
    @sets << set
    set.match = self
  end
  
  def final_score
    sets.map{ |s| s.final_score(winner) }.join(', ')
  end
  
  def points
    sets.collect{ |s| s.points }.flatten
  end
  
  def points_won_by(player)
    points.select{ |p| p.winner == player }.size
  end
  
  def aces_by(player)
    points.select{ |p| p.winner == player and p.special == "A" }.size
  end

  def double_faults_by(player)
    points.select{ |p| p.server == player and p.faults == 2 }.size
  end

  def unforced_errors_by(player)
    points.select{ |p| p.winner != player and p.special == "U" }.size
  end

  def winners_by(player)
    points.select{ |p| p.winner == player and p.special == "W" }.size
  end

  def first_serve_percentage_by(player)
    s = points.select{ |p| p.server == player and p.faults == 0 }.size
    t = points.select{ |p| p.server == player }.size
    (s.to_f * 100 / t.to_f).round.to_s + "%"
  end

  def first_serve_points_won_by(player)
    s = points.select{ |p| p.server == player and p.winner == player and p.faults == 0 }.size
    t = points.select{ |p| p.server == player and p.faults == 0 }.size
    (s.to_f * 100 / t.to_f).round.to_s + "%"
  end
  
  def report
    puts "Match on #{@date}: #{winner.name} def #{loser.name} (#{final_score})"
    puts ""
    %w[
      points_won
      winners
      unforced_errors
      double_faults
      aces
      first_serve_percentage
      first_serve_points_won
      
    ].each do |stat|
      print stat.upcase.gsub('_', ' ').ljust(28)
      print players.map{ |player|
        "#{player.name} #{send("#{stat}_by", player).to_s.rjust(3)}"
      }.join('        ')
      puts ""
    end
    puts ""
  end
end

