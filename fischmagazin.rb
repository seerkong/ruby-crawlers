#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'writeexcel'
module Spider
    class Fischmagazin

    def initialize
      @app_host = "http://www.fischmagazin.de"
      @website = "http://www.fischmagazin.de/"
      @row_index = 1
      @page_num = 0
      @doc
    end
    def set_callback(callable)
      @callback = callable
    end

    def search
      puts Time.now
      doc = Hpricot(open('http://www.fischmagazin.de/liste-Bereich-Seafood.htm', {
                           'User-Agent' => 'Mozilla/5.0 (compatible; MSIE 6.0; Windows NT 5.0)'
                           }))
      result = Array.new
      doc.search('//tr[@class=tabellenhervorhebung || @valign="top"]').each do |para|
      #doc.search('//tbody/tr').each do |para|
        stadt = String.new
        land = String.new
        link = String.new
        firmenname = String.new

        para.search('a').each do |a|
          firmenname = a.inner_html
          link = "http://www.fischmagazin.de/" + a.attributes['href']
        end
        count = 0
        para.search('td').each do |td|
          if count == 0 || count == 1
            puts "skip the first td as a link"
            count += 1
            next
          end
          if count == 2 # statd
            stadt = td.inner_html
            count += 1
          elsif count == 3 # land
            land = td.inner_html
            count += 1
          end
        end

        hash = {
          :firmenname => firmenname,
          :link => link,
          :stadt => stadt,
          :land => land
        }
        puts hash
        result.push(hash)
      end
      @callback.call(result)
      #puts result
    end
  end
end

def excel_callback(array)
  n = 2
  array.each do |hash|
    # 下面的第一个参数是列号，0表示A列，第二个参数表示行号
    $worksheet.write("A#{n}", [
      hash[:firmenname],
      hash[:link],
      hash[:stadt],
      hash[:land],
      ])
    n += 1
  end
end

workbook = WriteExcel.new('fischmagazin_result.xls');
$worksheet = workbook.add_worksheet
headings = %w{Firmenname Link Stadt Land}

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

spider = Spider::Fischmagazin.new
spider.set_callback(method(:excel_callback))
spider.search
workbook.close