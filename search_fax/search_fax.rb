# -*- coding: utf-8 -*-
$:.push('.')
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'useragents'
require 'contact_search'

def excel_callback(array)
  puts "in excel callback"
  n = 2 + $excel_row_num
  array.each do |hash|
    if !hash.has_key?('tel')
      hash['tel'] = ''
    end
    if !hash.has_key?('email')
      hash['email'] = ''
    end
    if !hash.has_key?('company')
      hash['company'] = ''
    end
    # 下面的第一个参数是列号，0表示A列，第二个参数表示行号
    $worksheet.write("A#{n}", [
      hash['company'],
      hash['fax'],
      hash['tel'],
      hash['email'],
      hash['source']
    ])
    n += 1
  end
  $excel_row_num += array.size
end

$workbook = WriteExcel.new('Construction_FL_result.xls');
$worksheet = $workbook.add_worksheet
$worksheet.write(0, 0, 'company')
$worksheet.write(0, 1, 'fax')
$worksheet.write(0, 1, 'tel')
$worksheet.write(0, 1, 'email')
$worksheet.write(0, 1, 'source')
$excel_row_num = 0

extractor = ContactSearch::Company.new
=begin
localfiles.each do |file|
  counter = 0
  page_result = extractor.extact(file)
  if page_result.size == 0
    counter += 1
  end
  if counter >= 20
    break
  end
  excel_callback(page_result)
end
=end

# #################
# test cases for this regex:
# (727) 733-9816
# 925.935.1700
# 954-360-7726
# (386)673-7055
# (305) 348 6255
# pdf file http://www.dot.state.fl.us/construction/contact/Training/DCTAList.pdf
@re = %r([+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4})
@faxre = %r/(fax.*[+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4})|([+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4}.*fax)/i

@google_url = "https://www.google.com.hk/search?q="
@google_base = "https://www.google.com.hk"
#File.open("cat.txt").readlines.each do |line|
["Construction"].each do |line|
  #["Florida", "Pennsylvania"].each do |location| # FL, PA
  ["Florida"].each do |location| # FL, PA
    flag = ""
    s = CGI.escape("fax " + line + " " + location)
    sleep 10 + rand(3)
    google_href = @google_url + s
    puts google_href
    has_next_href = false
    google_searched_page = 0
    begin
      begin # google may block
        doc = Nokogiri::HTML(open(google_href, {
          'User-Agent' => UserAgents.rand()}))
      rescue => e
        puts "caught an exception while getting next google page: #{e}"
        $workbook.close
        break
      end
      counter = 0
      begin
        doc.xpath('//li[@class="g"]').each do |item|
          #puts item.content
          snap = item.at_xpath('.//div[@class="s"]').content.gsub(/<\/?em>/,"")
          if snap =~ /FAX|fax|Fax/ # have fax keyword
            puts "find fax keyword"
            fax = snap[/[+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4}/]
            puts fax
            #@downloaded_fax["#{fax.hash}"] = true
            # get the page url, and search the page
            itemurl = item.at_xpath('.//h3/a[@target="_blank"]')['href']#.gsub(/\/url\?q=/, "")
            puts "item url:" + itemurl
            if itemurl[0] == '/' # /url?q
              itemurl = @google_base + itemurl
            end
            page_result = extractor.extact(itemurl)
            if page_result.size == 0
              counter += 1
            else
              counter = 0
            end
            if counter >= 10
              puts "continued 10 pages no result"
              break
            end
            excel_callback(page_result)

          end
        end
      rescue => e
        puts "caught an exception while scanning google page: #{e}"
      end
      # judge if has a next page link
      begin
        doc.search('//td/a[@id="pnnext"]').each do |next_link|
          puts "=== has a next link ==="
          #puts next_link['href']
          google_href = @google_base + next_link['href']
          has_next_href = true
        end
      rescue => e
        puts "caught an exception while searching the next page: #{e}"
      end
      STDOUT.flush
      google_searched_page += 1
      puts google_searched_page.to_s
    end while has_next_href && google_searched_page < 100
  end
end

$workbook.close