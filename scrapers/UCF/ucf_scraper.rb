#!/usr/bin/ruby
require 'open-uri'

def parse_for_emails(source_seg)
  emails = File.open("ucf_emails.txt", 'a')

  source_seg.scan(/mailto:[a-z0-9._%-]+@[a-z0-9.]+.edu/i) { |w|
    emails.write(w[7..w.length] + "\n")
    puts w[7..w.length]
  }

  emails.close
end


def recurse_new_alphabet(current_str)
  #Search a-z
  ("a".."z").each{ |letter| 
    puts "Searching: #{current_str}#{letter}"
    new_url = @@SRC_URL + current_str + letter
    begin
      source = open(new_url).read
    rescue
      puts "Search restriction. Waiting 10 minutes."
      sleep(600)
      source = open(new_url).read
    end

    if not source.index(/narrowing/).nil? 
      puts "Too many entries"
      recurse_new_alphabet(current_str+letter)
    else 
      parse_for_emails(source)
    end
  }

  if(current_str[-1] != "+")
    #Search space == '+'
    puts "Searching: #{current_str}+"
    new_url = @@SRC_URL + current_str + "+"
    begin
      source = open(new_url).read
    rescue
      puts "Search restriction. Waiting 10 minutes."
      sleep(600)
      source = open(new_url).read
    end

    if not source.index(/narrowing/).nil? 
      puts "Too many entries"
      recurse_new_alphabet(current_str+"+")
    else 
      parse_for_emails(source)
    end

  end

end

#Main
@@SRC_URL = "http://www.ucf.edu/phonebook/?phonebook-search-query="
#count = 1;

puts "UCF Scraper"

("a".."z").each{ |letter| 
  recurse_new_alphabet(letter)
}
# source = open(@@SRC_URL).read


# log = File.open("log.txt", "w")
# log.write(source)
# log.close

# parse_for_emails(source)
