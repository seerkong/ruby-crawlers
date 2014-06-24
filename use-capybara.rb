# -*- coding: utf-8 -*-
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'writeexcel'
$:.push '.'
#$:.each { |d| puts d }
require 'capybara_spider'

def puts_callback(array)
  puts "this is in callback"
  #n = 0
  array.each do |title, link|
    puts "#{title}\t#{link}"
  end
end

def excel_callback(array)
  puts "in excel callback"
  n = 2 + $excel_row_num
  array.each do |title, link|
    # 下面的第一个参数是列号，0表示A列，第二个参数表示行号
    $worksheet.write("A#{n}", [
      title,
      link
      ])
    n += 1
  end
  $excel_row_num += array.size
end


=begin
$workbook = WriteExcel.new('query_search_result.xls');
$worksheet = $workbook.add_worksheet
$worksheet.write(0, 0, 'Text')
$worksheet.write(0, 1, 'link')
$excel_row_num = 0
=end

#spider = Spider::YellowPages.new
#spider = Spider::Google.new
spider = Spider::Baidu.new
spider.set_callback(method(:puts_callback))
#spider.set_callback(method(:excel_callback))
#spider.search
spider.search_to_page(2, "I love Ruby!")


#$workbook.close
