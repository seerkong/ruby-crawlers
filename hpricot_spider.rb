#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.push('.')
require 'rubygems'
require 'open-uri'
require 'hpricot'
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

      doc = Hpricot(file)
=end
      doc = Hpricot(open(search_url,  {
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
      doc = Hpricot(file)
      export_page_info(doc)

      while page_index < page_num - 1
        page_index += 1
        search_url = @website + keyword + "&pn=" + (page_index * 10).to_s
        export_page_info(Hpricot(open(search_url)))
      end
    end
  end

  class Google
    def initialize
      @website = "https://www.google.com.hk/#q="
      @row_index = 1
      @page_num = 0
      @logfile = File.new("logfile.html", "w")
    end
    def set_callback(callable)
      @callback = callable
    end
    def search
      keyword = URI.escape("I love Ruby")
      search_url = @website + keyword + "&pn=" + @page_num.to_s
=begin
      file = open(search_url)
      file.each_line do |line|
        @logfile.puts line
      end

      doc = Hpricot(file)
=end
      doc = Hpricot(open('http://www.google.com.hk/search?newwindow=1&safe=strict&site=&source=hp&q=I+love+Ruby%21&btnG=Google+%E6%90%9C%E7%B4%A2', {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                         }))
      result = Array.new
      doc.search('//li[@class="g"]/h3').each do |para|
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
      doc.search('//li[@class="g"]/h3').each do |para|
        puts "=== Found a web link ==="
        para.search('a').each do |a|
          puts "#{a.inner_html}\t=>\t#{a.attributes['href']}"
          result.push([a.inner_html, a.attributes['href']])
          @row_index += 1
        end
      end
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      page_index = 0
      search_url = @website + keyword + "&pn=" + (page_index * 10).to_s

      file = open(search_url)
      doc = Hpricot(file)
      export_page_info(doc)

      while page_index < page_num - 1
        page_index += 1
        search_url = @website + keyword + "&pn=" + (page_index * 10).to_s
        export_page_info(Hpricot(open(search_url)))
      end
    end
  end

  class Wuba
    def initialize
      @app_host = "http://cc.58.com"
      @website = "http://cc.58.com/nanguan/zufang/"
      @row_index = 1
      @page_num = 0
      @doc
    end
    def set_callback(callable)
      @callback = callable
    end
    def search
      puts Time.now
      doc = Hpricot(open('http://bj.58.com/chuzu/b10/?final=1&key=%2525u5929%2525u901A%2525u82D1&searchtype=3&sourcetype=5', {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                           }))
      result = Array.new
      doc.search('//tr').each do |para|
        price = (para/'b[@class="pri"]').inner_html
        title = String.new
        link = String.new
        para.search('a[@class="t"]').each do |a|
          title = a.inner_html
          link = a.attributes['href']
        end
        # 有时这里提取出来的是
        next if title == ''
        showroom = (para/'span[@class="showroom"]').inner_html
        # 因为这里发布日期的xpath也是td.tc与其他的有重复所以使用循环获取最后一个
        publish_date = String.new
        para.search('td[@class="tc"]').each do |td|
          publish_date = td.inner_html
        end

        hash = {
          :title => title,
          :link => link,
          :price => price,
          :showroom => showroom,
          :publish_date => publish_date
        }
        result.push(hash)
      end
      @callback.call(result)
      #puts result
    end

    def export_page_info(doc, say = true)
      puts Time.now
      doc.search('//tr').each do |para|

        result = Array.new
        para.search('a[@class="t"]').each do |a|
          result.push([a.inner_html, a.attributes['href']])
        end

        showroom = String.new
        para.search('span[@class="showroom"]').each do |b|
          showroom = b.inner_html
        end

        publish_date = String.new
        para.search('td[@class="tc"]').each do |td|
          publish_date = td.inner_html
        end

        pri = (para/'b[@class="pri"]')
        if pri.inner_html.to_i < 1600  && publish_date =~ /今天|小时|06-2/ #&& showroom =~ /2室|两室|/
          puts "=== Found a room ==="
          result.each do |title, link|
            puts "#{title}\t=>\t#{publish_date}\t=>\t#{link}"
            puts "#{pri.inner_html}"
            if say == true
              `say #{title}`
              `say #{pri.inner_html}`
            end
          end
        end
      end
      doc.search('//div/a[@class="next"]').each do |next_link|
        puts "=== has a next link ==="
        #puts next_link['href']
        @next_doc = Hpricot(open(@app_host + next_link['href'], {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                                 }))
        @has_next_doc = true
      end
    end

    def loop_search
      loop do
        puts Time.now
        doc = Hpricot(open('http://bj.58.com/chuzu/b10/?final=1&key=%2525u5929%2525u901A%2525u82D1&searchtype=3&sourcetype=5', {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                           }))
        export_page_info(doc)
        while @has_next_doc
          @has_next_doc = false
          export_page_info(@next_doc)
        end
        sleep(60 * 20)
        #break
      end
    end
  end

  # YellowPages searches
  class YellowPages
    def initialize
      @app_host = "http://www.yellowpages.com"
      @website = "http://www.yellowpages.com/"
      @row_index = 1
      @page_num = 0
      @doc
    end
    def set_callback(callable)
      @callback = callable
    end
    def search
      puts Time.now
      doc = Hpricot(open('http://www.yellowpages.com/los-angeles-ca/coffe?g=Los+Angeles%2C+CA', {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                           }))
      result = Array.new
      doc.search('//div[@class="business-container-inner"]').each do |para|
        puts "== Found a paragraph =="
        # yellowpages.com restaurant and link
        restaurant = String.new
        link = String.new
        para.search('a[@class="url "]').each do |a|
          restaurant = a.inner_html
          link = a.attributes['href']
        end
        puts restaurant
        puts link

        hash = {
          :restaurant => restaurant,
          :link => link,
        }
        result.push(hash)

      end
      puts result.size
    end


    def export_page_info(doc)
      puts Time.now
      result = Array.new
      doc.search('//tr').each do |para|
        # yellowpages.com restaurant and link
        restaurant = String.new
        link = String.new
        para.search('a[@class="url "]').each do |a|
          restaurant = a.inner_html
          link = a.attributes['href']
        end
        #puts (para/'a[@class="url "]').attributes['class']

        addr = (para/'span[@class="listing-address adr').inner_html
        puts restaurant
        puts link
        puts addr
        hash = {
          :restaurant => restaurant,
          :addr => addr,
        }
        result.push(hash)
      end
      puts result.size
      @callback.call(result)

      # judge if has a next link
      doc.search('//div/a[@class="next"]').each do |next_link|
        puts "=== has a next link ==="
        #puts next_link['href']
        @next_doc = Hpricot(open(@app_host + next_link['href'], {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                                 }))
        @has_next_doc = true
      end
    end

    def loop_search
      puts Time.now
      doc = Hpricot(open('http://cc.58.com/nanguan/zufang/?final=1&searchtype=3&key=%2525u6E05%2525u6CB3%2525u574A&sourcetype=5', {
                           'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
                           }))
      export_page_info(doc)
      while @has_next_doc
        @has_next_doc = false
        export_page_info(@next_doc)
      end
    end
  end
end
