##
# Tennis Stats
# Extremely simple stat tracking for tennis.
#
# Copyright (c) 2009 Alex Reisner. (MIT license)
#
require 'lib/player'
require 'lib/point'
require 'lib/game'
require 'lib/set'
require 'lib/match'

# gather command-line argument
filename = ARGV[0]
puts ""

# make sure data file specified
if filename.nil?
  puts "Usage: ruby tennis_stats.rb [datafile]"
  puts ""
  exit
end

# make sure file exists
unless File.exist?(filename)
  puts "Data file '#{filename}' not found"
  puts ""
  exit
end

# start parsing data file
matches = []
players = {}
current_match = nil
current_set = nil
current_game = nil

File.read(filename).each do |line|

  if m = line.match(/^DATE: ([0-9\-]+)/)
    matches << current_match if current_match # finished processing; save match
    current_match = Match.new(m[1])

  elsif m = line.match(/^PLAYER: (.+)/)
    m = m[1].split(/,\w*/)
    p = Player.new(m[0], m[1].strip)
    current_match.add_player(p)
    players[m[0]] = p # add to player lookup table

  elsif m = line.match(/^SET: (\d)/)
    current_set = Set.new()
    current_match.add_set current_set
  
  elsif m = line.match(/^GAME: (\w)/)
    current_game = Game.new(players[m[1]])
    current_set.add_game current_game
    
  elsif m = line.match(/^(\d)(\w)(\w?)/)
    current_point = Point.new(players[m[2]], m[1], m[3])
    current_game.add_point current_point
  end
end
matches << current_match if current_match # save last match

matches.last.report

puts ""

