# -*- coding: utf-8 -*-
$:.push('.')
require 'nokogiri'
require 'open-uri'
require 'uri'

module Spider
  class NoWorksheetException < RuntimeError
  end

  class NoDbException < RuntimeError
  end
  class Baidu
    def initialize(callable)
      @website = "http://www.baidu.com/s?wd="
      @row_index = 1
      @callback = callable
      @page_num = 0
      @logfile = File.new("logfile.html", "w")
    end

    def search
      keyword = URI.escape("I love Ruby")
      search_url = @website + keyword + "&pn=" + @page_num.to_s
      puts search_url
=begin
      file = open(search_url)
      file.each_line do |line|
        @logfile.puts line
      end

      doc = Nokogiri::HTML(file)
=end
      doc = Nokogiri::HTML(open(search_url,  {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                         }))
      result = Array.new
      doc.search('//h3').each do |para|
        puts "=== Found a web link ==="
        para.search('a').each do |a|
          puts "#{a.inner_html}\t=>\t#{a.attributes['href']}"
          result.push([a.inner_html, a.attributes['href']])
          end
      end
      puts result.length
      result.each do |text, href|
        puts "#{text}\t=>\t#{href}"
      end
      @logfile.close
    end


    def export_page_info(doc)
      puts current_url
      result = Array.new
      doc.search('//div[@class="result c-container"]/h3').each do |para|
        puts "=== Found a web link ==="
        h3 = para.search('a')

        result.push([h3.inner_html, h3.attributes['href']])
        
        @row_index += 1
      end
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      page_index = 0
      search_url = @website + keyword + "&pn=" + (page_index * 10).to_s

      file = open(search_url)
      doc = Nokogiri::HTML(file)
      export_page_info(doc)

      while page_index < page_num - 1
        page_index += 1
        search_url = @website + keyword + "&pn=" + (page_index * 10).to_s
        export_page_info(Nokogiri::HTML(open(search_url)))
      end
    end
  end
end