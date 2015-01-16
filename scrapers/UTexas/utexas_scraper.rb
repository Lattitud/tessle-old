#!/usr/bin/ruby
require 'open-uri'

def parse_for_emails(source_seg)
  emails = File.open("utexas_emails.txt", 'a')

  source_seg.scan(/mailto:[a-z0-9._%-]+@[a-z0-9.]+.edu/i) { |w|
    emails.write(w[7..w.length] + "\n")
    puts w[7..w.length]
  }

  emails.close
end


def traverse_matches(source_seg)
  source_seg.scan(/index.php\?[a-z0-9._%-=&;]+/i) { |w|
    begin
      #puts w
      source = open(@@SRC_BASE + w.gsub('&amp;', '&')).read
    rescue
      puts "Search restriction. Waiting 10 minutes."
      sleep(600)
      source = open(@@SRC_BASE + w).read
    end

    parse_for_emails(source)
  }
end


def recurse_new_alphabet(current_str)
  ("a".."z").each{ |letter| 
    puts "Searching: *#{letter}#{current_str}"
    new_url = @@SRC_URL1 + letter + current_str + @@SRC_URL2
    begin
      source = open(new_url).read
    rescue
      puts "Search restriction. Waiting 10 minutes."
      sleep(600)
      source = open(new_url).read
    end

    if not source.index(/not specific enough/).nil? 
      puts "Too many entries"
      recurse_new_alphabet(letter+current_str)
    else
      source_seg = source[source.index('<div id="results">')..source.length]

      if not source_seg.index("mailto:").nil?
        puts "Number of results: 1"
        parse_for_emails(source_seg)
      else

        source_seg = source_seg[source_seg.index(/[0-9]+ Result/)..source_seg.index("</div>")]
        num_matches = source_seg[0..source_seg.index(" ")-1]
        puts "Number of results: #{num_matches}"
        if num_matches.to_i == 0

        else
          traverse_matches(source_seg)
        end

      end

    end
  }
end

#Main
@@SRC_BASE = "https://www.utexas.edu/directory/"
@@SRC_URL1 = "https://www.utexas.edu/directory/index.php?q=*"
@@SRC_URL2 = "&scope=student&submit=Search"
#count = 1;

puts "UTexas Scraper"

("a".."z").each{ |letter| 
  recurse_new_alphabet(letter)
}
# source = open(@@SRC_URL).read


# log = File.open("log.txt", "w")
# log.write(source)
# log.close

# parse_for_emails(source)
