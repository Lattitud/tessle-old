#!/usr/bin/ruby
require 'watir-webdriver'

def parse_for_emails(source_seg)
  emails = File.open("ucla_emails.txt", 'a')

  source_seg.scan(/mailto:[a-z0-9._%-]+/i) { |w|
    emails.write(w[7..w.length].gsub('%40', '@') + "\n")
    puts w[7..w.length].gsub('%40', '@')
  }

  emails.close
end


def recurse_new_alphabet(current_str)
  ("a".."z").each{ |letter| 
    puts "Searching: #{current_str}#{letter}*"
    new_str = current_str + letter + '*'
    #new_str = "*ball"

    loop_bool = true

    while(loop_bool)
      @@b.text_field(:id => 'q').set new_str
      @@b.button(:class => 'directory-submit-button').click
      @@counter += 1

      if @@counter == 11
        puts "Sleeping 1 minute to prevent downtime"
        sleep(60)
        @@counter = 0
      end

      results_src = @@b.div(:id => 'results-wrapper')

      if results_src.exists?
        parse_for_emails(results_src.html)
        loop_bool = false
      else
        #Too many results or no results (move on)
        results_txt = @@b.div(:class => 'pexit').text
        if results_txt.index("ERROR")
          puts "Search restriction. Waiting 5 minutes"
          sleep(301)
        elsif not results_txt.index(/250/).nil?
          recurse_new_alphabet(current_str + letter)
          loop_bool = false
        else
          #No Results
          loop_bool = false
        end

      end

    end
    # log = File.open("log.txt", "a")
    # log.write(@@b.div(:id => 'results-wrapper').html)
    # log.close
  }
end

#Main
@@SRC_URL = "http://www.directory.ucla.edu/search.php"
@@counter = 0
@@b = Watir::Browser.new
puts "UCLA Scraper"

@@b.goto @@SRC_URL

("l".."z").each{ |letter| 
  recurse_new_alphabet(letter)
}

# recurse_new_alphabet("k")

# source = open(@@SRC_URL).read


# log = File.open("log.txt", "w")
# log.write(source)
# log.close

# parse_for_emails(source)
