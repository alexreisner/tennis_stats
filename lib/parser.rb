require 'date'

module TennisStats

  class Parser
    attr_reader :players, :matches

    ##
    # Initialize a new Parser object. Takes a filename or an array of lines.
    # If passing an array of lines, second parameter must be true.
    #
    def initialize(filename_or_text)

      # if text given...
      if filename_or_text.is_a?(Array)
        @text = filename_or_text
      
      # if filename given...
      else

        # if file doesn't exist...
        if filename_or_text.is_a?(String) and not File.exist?(filename_or_text)
          raise ParseError, "Data file '#{filename}' not found"

        # file exists...
        else
          @text = File.read(filename_or_text)
        end
      end

      @matches       = []
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
      @line_count = 0
      @text.each do |line|
        @line_count += 1

        # parse DATE
        if m = line.match(/^DATE: ?(.*)/)
          @matches << @current_match if @current_match # finished processing; save match
          @current_match = parse_date(m[1])

        # parse PLAYER
        elsif m = line.match(/^PLAYER: ?(.*)/)
          parse_player(m[1])

        # parse SET
        elsif m = line.match(/^SET/)
          @current_set = Set.new
          @current_match.add_set @current_set
        
        # parse GAME
        elsif m = line.match(/^GAME: ?(.*)/)
          @current_game = Game.new(@current_match.player(m[1]))
          @current_set.add_game @current_game
        
        # parse POINT
        elsif m = line.match(/^(\d)(\w)(\w?)/)
          p = @current_match.player(m[2])
          @current_point = Point.new(p, m[1], m[3])
          @current_game.add_point @current_point
        end
      end
      @matches << @current_match if @current_match # save last match

      return @matches
    end
    
    ##
    # Parse a DATE line. Returns a Match object.
    #
    def parse_date(text)
      begin
        Match.new Date.parse(text.strip)
      rescue ArgumentError
        parse_error "Invalid date format: please use YYYY-MM-DD."
      end
    end
    
    ##
    # Parse a PLAYER line. Returns a Player object.
    #
    def parse_player(text)
      a, n = text.split(/,\w*/, 2)
      if n.nil?
        parse_error "Invalid player format: please give a one-letter abbreviation and a full name."
      end
      unless a.strip.size == 1
        parse_error "Invalid player abbreviation: must be one letter."
      end
      p = Player.new(n.strip)
      @current_match.add_player(a.strip, p)
    end
    
    ##
    # Display a parse error and quit.
    #
    def parse_error(message)
      raise ParseError, "Parse error on line #{@line_count}: #{message}"
    end
  end

  class ParseError < StandardError; end
end

