#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), '../lib/cassiopee')
require 'optparse'
require 'logger'
 
options = {}
 
optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: cassie.rb [options]"
 
   options[:verbose] = false
   opts.on( '-v', '--verbose', 'Output more information' ) do
     options[:verbose] = true
   end

   options[:filter] = nil
   opts.on( '-f', '--filter FILTER', 'Filter matches between min and max positions ex. 100-150' ) do |filter|
	options[:filter] = filter
   end

   options[:file] = nil
   opts.on( '-i', '--index FILE', 'File to index' ) do |file|
        options[:file] = file 
   end

   options[:fpattern] = nil
   opts.on( '--fpattern FILE', 'File with pattern' ) do |file|
        options[:fpattern] = file
   end

   options[:pattern] = nil
   opts.on( '-p', '--pattern PATTERN', 'Search pattern' ) do |file|
        options[:pattern] = file
   end

   options[:store] = nil
   opts.on( '-s', '--store FILE', 'Store index to file' ) do |file|
        options[:store] = file
   end

   options[:name] = nil
   opts.on( '-n', '--name NAME', 'name of index, default [crawler]' ) do |name|
        options[:name] = name
   end

   options[:exact] = false
   opts.on( '-x', '--exact', 'Do exact search (default)' ) do
        options[:exact] = true
   end

   options[:error] = 0
   opts.on( '-m', '--hamming ERROR', 'Maximum number of error to search with Hamming distance' ) do |error|
        options[:error] = error
   end

   opts.on( '-e', '--edit ERROR', 'Maximum number of error to search with edit(levenshtein) distance' ) do |error|
        options[:error] = error * (-1)
   end


   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end

end

  optparse.parse!

  if(options[:file]==nil)
    puts "Error, input file is missing, use -h option for usage"
    exit
  elif(options[:verbose])
    puts "Input sequence: " << options[:file].to_s 
  end

  if(options[:fpattern]==nil && options[:pattern]==nil)
    puts "Error, pattern is missing, use -h option for usage"
    exit
  end


 if(options[:error]==0)
   options[:exact] = true
 end


crawler = Cassiopee::Crawler.new
crawler.setLogLevel(Logger::INFO)
if(options[:store])
crawler.use_store = true
end
if(options[:name]!=nil)
crawler.file_suffix = options[:name]
end
if(options[:filter]!=nil)
positions = options[:filter].split('-')
crawler.filter_position(positions[0],positions[1])
end

# String to index
crawler.indexFile(options[:file])

matches = nil

if(options[:fpattern]==nil)
	pattern = options[:pattern]
else
	pattern = ''
	file = File.new(options[:fpattern], "r")
        while (line = file.gets)
        	input = line.downcase.chomp
		pattern << input
        end
	file.close
	if(pattern.length==0)
		puts "Error pattern file is empty"
		exit 
        end
end

  if(options[:verbose])
    puts "Search pattern " << pattern
  end

if(options[:exact])
        puts "Search exact" unless !options[:verbose]
	matches = crawler.searchExact(pattern)
else
        puts "Search approximate" unless !options[:verbose]
	matches = crawler.searchApproximate(pattern,options[:errors])
end

# Go through matches
while((match = crawler.next())!=nil)
  puts "Match: " << match.inspect
end
