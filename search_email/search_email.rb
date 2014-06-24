require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'

google_url = "http://www.google.com.hk/search?q="
["/Users/peacock/ruby/crawler/search_email/FIX_private_school.txt"].each do |name|
  File.open(name).readlines.each do |line|
    flag = ""
    s = CGI.escape(line+" email")
    puts s
    sleep 8+rand(3)
    begin
      doc = Nokogiri::HTML(open(google_url+s))
      doc.xpath('//li/div[@class="s"]').each do |link|
        email = link.content.gsub(/<\/?em>/,"")[/[a-z0-9!#\$%&'*+\/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+\/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)/]
        if email
          puts "#{name}_RESULT :   "+email
          File.open("#{name}".gsub("FIX","RESULT"),'w+') {|f| f.puts(email)}
          break
        end
        flag = email
      end
    rescue
      puts "has error occur!"
    end
    if !flag
      puts "#{name}_NOT FOUND :   "+line
      File.open("#{name}".gsub("FIX","NOT_FOUND"),'w+') {|f| f.puts(line) }
    end
    STDOUT.flush
  end
end  