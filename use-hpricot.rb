#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.push('/Users/peacock/ruby/crawler')
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'sqlite3'
require 'writeexcel'
require 'hpricot_spider'


def puts_callback(array)
  puts "this is in callback"
  #n = 0
  array.each do |hash|
    puts "#{hash[:title]}\t#{hash[:link]}"
    puts "#{hash[:price]}\t#{hash[:showroom]}\t#{hash[:publish_date]}"
  end
end

def excel_callback(array)
  n = 2
  array.each do |hash|
    # 下面的第一个参数是列号，0表示A列，第二个参数表示行号
    $worksheet.write("A#{n}", [
      hash[:title],
      hash[:link],
      hash[:price],
      hash[:showroom],
      hash[:publish_date]
      ])
    n += 1
  end
end

def sqlite3_callback(array)
  puts "this is in callback"
  # begin transation
  $db.transaction # :deferred by default
  #n = 0
  array.each do |hash|
    #puts "#{hash[:title]}\t#{hash[:link]}"
    #puts "#{hash[:price]}\t#{hash[:showroom]}\t#{hash[:publish_date]}"
    add_item(hash[:title], hash[:link], hash[:price],
             hash[:showroom], hash[:publish_date])
  end
  $db.commit
end

def disconnect_sqlite
  $db.close
end

def create_table
  puts "creating 58 table"
  $db.execute <<SQLCREATE
    CREATE TABLE wuba (
    id integer primary key,
    title varchar(50),
    link varchar(50),
    price varchar(50),
    showroom varchar(50),
    publish_date varchar(50))
SQLCREATE
end

def add_item(title, link, price, showroom, publish_date)
  $db.execute("INSERT INTO wuba (title, link, price, showroom, publish_date) VALUES (?,?,?,?,?)",
              title, link, price, showroom, publish_date)
end

def find_item
  result = $db.execute("SELECT * FROM wuba")
  unless result
    puts "No result found"
  end
  puts result
end

#spider = Spider::Google.new
#spider = Spider::Baidu.new
spider = Spider::Wuba.new

#spider = Spider::YellowPages.new

#spider.set_callback(method(:puts_callback))
#spider.search
spider.loop_search
=begin
$db = SQLite3::Database.new('wuba.db')
#$db.result_as_hash = true

create_table
spider.set_callback(method(:sqlite3_callback))
spider.search
#spider.loop_search
find_item

disconnect_sqlite
=end
=begin
# use excel for output format
spider.set_callback(method(:excel_callback))
workbook = WriteExcel.new('search_result.xls');
$worksheet = workbook.add_worksheet
headings = %w{Title Link Price Room Publish_Date}

bold_format = workbook.add_format(:bold => 1)
heading_format  = workbook.add_format(
                                :bold    => 1,
                                :color   => 'blue',
                                :bg_color    => 50,
                                :size    => 16,
                                :merge   => 1,
                                :align  => 'vcenter'
                              )
                              

$worksheet.write_row('A1', headings, heading_format)
$worksheet.set_column('A:A', 20, bold_format) # 第二个参数的数字代表的是表格的宽度
$worksheet.set_column('B:B', 40)
$worksheet.set_column('C:C', 10)
$worksheet.set_column('D:D', 15)
$worksheet.set_column('E:E', 20)

spider.search

$worksheet.autofilter('A1:D51')
workbook.close
=end
