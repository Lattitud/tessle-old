require 'set'


s1 = Set.new
#Make unique
File.open("mit_emails.txt", "r").each_line do |line|
  s1.add(line.downcase)
end

#Reenter
s1.each do |ele|
  emails = File.open("mit_emails_nodups.txt", 'a')
  emails.write(ele)
  emails.close
end