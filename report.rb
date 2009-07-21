##
# Tennis Stats: Report
# Extremely simple stat tracking for tennis.
#
# Copyright (c) 2009 Alex Reisner. (MIT license)
#
require 'tennis_stats'
#require 'rubygems'; require 'ruby-debug'; debugger

puts ""

# gather command-line argument
filename = ARGV[0]

# make sure data file specified
if filename.nil?
  puts "Usage: ruby tennis_stats.rb [datafile]"
  puts ""
  exit
end

# parse and report
matches = TennisStats::Parser.new(filename).matches
matches.each{ |m| m.report }


