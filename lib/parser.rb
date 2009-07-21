class Parser
  attr_reader :players, :matches

  def initialize(filename)
    @filename      = filename
    @matches       = []
    @players       = {}
    @current_match = nil
    @current_set   = nil
    @current_game  = nil
  end
  
  ##
  # Get a data structure representing all matches contained in the data file.
  #
  def matches
    parse
  end
  
  
  protected # -----------------------------------------------------------------
  
  ##
  # Parse the data file: transform into an array of Match objects.
  #
  def parse
    File.read(@filename).each do |line|

      # parse DATE
      if m = line.match(/^DATE: ([0-9\-]+)/)
        @matches << @current_match if @current_match # finished processing; save match
        @current_match = Match.new(m[1])

      # parse PLAYER
      elsif m = line.match(/^PLAYER: (.+)/)
        m = m[1].split(/,\w*/)
        p = Player.new(m[0], m[1].strip)
        @current_match.add_player(p)
        @players[m[0]] = p # add to player lookup table

      # parse SET
      elsif m = line.match(/^SET: (\d)/)
        @current_set = Set.new()
        @current_match.add_set @current_set
      
      # parse GAME
      elsif m = line.match(/^GAME: (\w)/)
        @current_game = Game.new(players[m[1]])
        @current_set.add_game @current_game
      
      # parse POINT
      elsif m = line.match(/^(\d)(\w)(\w?)/)
        @current_point = Point.new(players[m[2]], m[1], m[3])
        @current_game.add_point @current_point
      end
    end
    @matches << @current_match if @current_match # save last match

    return @matches
  end
end
