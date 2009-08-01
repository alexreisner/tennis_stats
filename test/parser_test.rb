require 'test_helper'

##
# Test specific TennisStats::Parser methods like parse_player and parse_point.
# Mock objects are set up for players Borg ("B") and Lendl ("L").
#
class ParserTest < Test::Unit::TestCase
  
  def test_date_parse
    assert_parse_ok    :date, "2009-07-08"
    assert_parse_ok    :date, "Jan 12, 2009"
    assert_parse_error :date, "2009"
    assert_parse_error :date, "6v6v6v"
  end

  def test_player_parse
    assert_parse_ok    :player, "M, John McEnroe"
    assert_parse_error :player, "John McEnroe"      # missing handle
    assert_parse_error :player, "MAC, John McEnroe" # bad handle
  end

  def test_set_parse
    # not much to test
  end

  def test_game_parse
    assert_parse_ok    :game, "L"
    assert_parse_error :game, "Z" # invalid server
  end

  def test_point_parse
    assert_parse_ok    :point, "1B"
    assert_parse_ok    :point, "1BW"
    assert_parse_ok    :point, "0LA"
    assert_parse_error :point, "1Z"  # bad player
    assert_parse_error :point, "1LZ" # bad description
    assert_parse_error :point, "3B"  # too many faults
  end
  
  def test_parse_from_file
    assert_raises TennisStats::ParseError do
      TennisStats::Parser.new("#{fixtures_path}/does_not_exist")
    end
    p = TennisStats::Parser.new("#{fixtures_path}/will_vs_alex")
    assert_equal 1, p.matches.size
  end
  
  
  private # -----------------------------------------------------------------
  
  def fixtures_path
    File.join(File.dirname(__FILE__), "fixtures")
  end
  
  ##
  # Assert that a given line is parsed without incident.
  #
  def assert_parse_ok(type, line)
    assert_nothing_raised do
      assert parser_with_mocks(type).send("parse_#{type}", line)
    end
  end
  
  ##
  # Assert that a given line causes a ParseError.
  #
  def assert_parse_error(type, line)
    assert_raises TennisStats::ParseError do
      parser_with_mocks(type).send("parse_#{type}", line)
    end
  end

  ##
  # Get a new Parser objects with mocks set up.
  #
  def parser_with_mocks(type)
    parser = TennisStats::Parser.new([])
    mocks_required(type).each{ |m| setup_mocks(parser, m) }
    parser
  end
  
  ##
  # Get an array of mock objects to set up before the given type of test.
  #
  def mocks_required(type)
    { :date   => [],
      :player => [:match],
      :set    => [:match, :players],
      :game   => [:match, :players, :set],
      :point  => [:match, :players, :set, :game] }[type]
  end
  
  ##
  # Set up mock objects of the given type.
  #
  def setup_mocks(parser, type)
    case type

    when :match
      parser.instance_variable_set "@current_match", TennisStats::Match.new

    when :players
      parser.instance_variable_get("@current_match").add_player("L", lendl)
      parser.instance_variable_get("@current_match").add_player("B", borg)
    
    when :set
      parser.instance_variable_set "@current_set", TennisStats::Set.new
    
    when :game
      parser.instance_variable_set "@current_game", TennisStats::Game.new(lendl)
    end
  end
  
  ##
  # Get an Ivan Lendl Player object.
  #
  def lendl
    return @lendl if defined?(@lendl)
    @lendl = TennisStats::Player.new("Ivan Lendl")
  end
  
  ##
  # Get a Bjorn Borg Player object.
  #
  def borg
    return @borg if defined?(@borg)
    @borg = TennisStats::Player.new("Bjorn Borg")
  end
end
