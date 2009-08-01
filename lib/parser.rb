require 'date'

module TennisStats

  class Parser

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
        if filename_or_text.is_a?(String) and !File.exist?(filename_or_text)
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
    # Get a data structure representing all matches
    # contained in the data file.
    #
    def matches
      parse
    end
    
    
    private # ---------------------------------------------------------------
    
    ##
    # Parse the data file: transform into an array of Match objects.
    #
    def parse
      @line_count = 0
      @text.each do |line|
        @line_count += 1
        case line
        
          when /^DATE: ?(.*)/
            save_current_match
            parse_date($1)

          when /^PLAYER: ?(.*)/
            parse_player($1)

          when /^SET/
            parse_set
        
          when /^GAME: ?(.*)/
            parse_game($1)
        
          when /^(\d\w\w?)/
            parse_point($1)
        end
      end
      
      save_current_match
      return @matches
    end
    
    ##
    # Add the current match to the @matches array. Do this whenever we finish
    # parsing a match.
    #
    def save_current_match
      @matches << @current_match if @current_match
    end
    
    ##
    # Parse a DATE line. Returns a Match object.
    #
    def parse_date(text)
      begin
        @current_match = Match.new( Date.parse(text.strip) )
      rescue ArgumentError
        parse_error "Invalid date format: please use YYYY-MM-DD."
      end
    end
    
    ##
    # Parse a PLAYER line. Adds a Player to the current Match.
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
    # Parse a SET line. Adds a new Set to the current Match.
    #
    def parse_set
      @current_set = Set.new
      @current_match.add_set @current_set
    end
    
    ##
    # Parse a GAME line. Adds a new game to the current Set.
    #
    def parse_game(text)
      p = @current_match.player(text)
      if p.nil?
        parse_error "Player not found (abbreviation: #{text.strip})."
      end
      @current_game = Game.new(p)
      @current_set.add_game @current_game
    end
    
    ##
    # Parse a point. Adds a new Point to the current Game.
    #
    def parse_point(text)
      m = text.match(/^(\d)(\w)(\w?)/)
      unless [0, 1, 2].include?(m[1].to_i)
        parse_error "Invalid number of faults: must be 0, 1, or 2."
      end
      p = @current_match.player(m[2])
      if p.nil?
        parse_error "Player not found (abbreviation: #{text.strip})."
      end
      unless ["", "A", "U", "W"].include?(m[3])
        parse_error "Invalid point description: must be blank, A, U, or W."
      end
      @current_point = Point.new(p, m[1], m[3])
      @current_game.add_point @current_point
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
