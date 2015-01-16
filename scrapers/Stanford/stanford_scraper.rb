#!/usr/bin/ruby
require 'watir-webdriver'

def parse_for_emails(source_seg)
  emails = File.open("stanford_emails.txt", 'a')

  source_seg.scan(/mailto:[A-Za-z0-9._%-]+@stanford.edu/) { |w|
    emails.write(w[7..w.length] + "\n")
    #puts w[7..w.length]
  }

  emails.close
end

def recurse_new_alphabet(current_str, space_bool)
  ("a".."z").each{ |letter| 
    puts "Searching: #{current_str}#{letter}*"
    new_str = current_str + letter + '*'
    #new_str = "*ball"

    loop_bool = true

    while(loop_bool)
      @@b.text_field(:id => 'search_string').set new_str
      l = @@b.link :text => 'show more options'
      l.click
      @@b.select_list(:id => 'affilfilter').select 'University students & postdocs'
      @@b.button(:name => 'btnG').click

      # @@counter += 1

      # if @@counter == 11
      #   puts "Sleeping 1 minute to prevent downtime"
      #   sleep(60)
      #   @@counter = 0
      # end
      no_results = @@b.div(:class => 'noresults')

      if no_results.exists?
        puts "No results"
        loop_bool = false
      else
        results_src = @@b.div(:id => 'ResultsHead')

        if results_src.html.index('+')
          puts "Too many results"
          recurse_new_alphabet(current_str + letter, true)
        else 
          # Search through each link and scrape emails
          
        end
      end      

      # if results_src.exists?
      #   parse_for_emails(results_src.html)
      #   loop_bool = false
      # else
      #   #Too many results or no results (move on)
      #   results_txt = @@b.div(:class => 'pexit').text
      #   if results_txt.index("ERROR")
      #     puts "Search restriction. Waiting 5 minutes"
      #     sleep(301)
      #   elsif not results_txt.index(/250/).nil?
      #     recurse_new_alphabet(current_str + letter)
      #     loop_bool = false
      #   else
      #     #No Results
      #     loop_bool = false
      #   end

      # end

    end
    # log = File.open("log.txt", "a")
    # log.write(@@b.div(:id => 'results-wrapper').html)
    # log.close
  }
end

#Main
@@SRC_URL = "https://stanfordwho.stanford.edu/SWApp"
# @@counter = 0
@@b = Watir::Browser.new
puts "Stanford Scraper"

@@b.goto @@SRC_URL

("a".."z").each{ |letter1| 
  ("a".."z").each{ |letter2| 
    recurse_new_alphabet(letter1 + letter2, false)
  }
}
# recurse_new_alphabet("ez")

# source = open(@@SRC_URL).read


# log = File.open("log.txt", "w")
# log.write(source)
# log.close

# parse_for_emails(source)
