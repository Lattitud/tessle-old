#!/usr/bin/ruby
require 'set'


s1 = Set.new
#Make unique
File.open("ucf_emails.txt", "r").each_line do |line|
  s1.add(line.downcase)
end

#Reenter
s1.each do |ele|
  emails = File.open("ucf_emails_nodups1.txt", 'a')
  emails.write(ele)
  emails.close
end