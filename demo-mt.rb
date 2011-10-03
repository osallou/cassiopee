require File.join(File.dirname(__FILE__), 'lib/cassiopee-mt')
require 'logger'

# Instanciate a new crawler
crawler = CassiopeeMt::CrawlerMt.new
crawler.setLogLevel(Logger::INFO)
crawler.maxthread=3
#crawler.use_store = true

# String to index
crawler.indexString('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiisallou salluiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii')
# Search pattern in indexed string
crawler.searchExact('llo')

# Go through matches
while((match = crawler.next())!=nil)
  puts "got an exact  match " << match.inspect
end

crawler.clear()

crawler.searchApproximate('llo',1)

# Go through matches
while((match = crawler.next())!=nil)
  puts "got an approximate  match " << match.inspect
end
