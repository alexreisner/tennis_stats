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
require 'lib/parser'

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

# parse and report
matches = Parser.new(filename).matches
matches.each{ |m| m.report }


