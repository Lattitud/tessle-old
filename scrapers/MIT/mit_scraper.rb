#!/usr/bin/ruby
require 'open-uri'

def parse_for_emails(source_seg)
  emails = File.open("mit_emails.txt", 'a')

  source_seg.scan(/mailto:[a-z0-9._%-]+@[a-z0-9.]+.edu/i) { |w|
    emails.write(w[7..w.length] + "\n")
    puts w[7..w.length]
  }

  emails.close
end


def traverse_matches(source_seg)
  source_seg.scan(/alias[a-z0-9._%-]+/i) { |w|
    loop_bool = true

    while(loop_bool)
      begin
        source = open(@@SRC_BASE + w).read
        loop_bool = false
      rescue
        puts "Search restriction. Waiting 10 minutes."
        sleep(600)
      end
    end
    parse_for_emails(source)
  }
end


def recurse_new_alphabet(current_str)
  ("u".."z").each{ |letter| 
    puts "Searching: *#{letter}#{current_str}"
    new_url = @@SRC_URL + letter + current_str

    loop_bool = true

    while(loop_bool)
      begin
        source = open(@@SRC_BASE + w).read
        loop_bool = false
      rescue
        puts "Search restriction. Waiting 10 minutes."
        sleep(600)
      end
    end

    if not source.index(/Too many entries/).nil? 
      puts "Too many entries"
      recurse_new_alphabet(letter+current_str)
    else source.index(/[No0-9]+ match/)
      source_seg = source[source.index(/[No0-9]+ match/)..source.length]
      num_matches = source_seg[0..source_seg.index(" ")-1]
      puts "Number of matches: #{num_matches}"
      if num_matches == "No"

      elsif num_matches.to_i == 1
        parse_for_emails(source_seg)
      else
        source_seg = source_seg[0..source_seg.index(/<\/pre>/i)]
        traverse_matches(source_seg)
      end

    end
  }
end

#Main
@@SRC_BASE = "http://web.mit.edu/bin/cgicso?query="
@@SRC_URL = "http://web.mit.edu/bin/cgicso?options=general&query=*"
#count = 1;

puts "MIT Scraper"

# ("a".."z").each{ |letter| 
#   recurse_new_alphabet(letter)
# }
recurse_new_alphabet("ila")
# source = open(@@SRC_URL).read


# log = File.open("log.txt", "w")
# log.write(source)
# log.close

# parse_for_emails(source)
