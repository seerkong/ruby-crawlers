#!/usr/bin/evn ruby
# encoding: UTF-8
$:.push('.')
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'iconv'
require 'capybara_spider'

module CrawlAll
  class Taobao
    def initialize(url_queue, stdout_mutex)
      @stdout_mutex = stdout_mutex
      @downloaded_url = Hash.new
      @url_queue = SizedQueue.new(1500)
      @spider = Spider::Taobao.new
      @should_stop = false
      @queue_empty_timeout = 0
      #@spider.set_callback(method(:puts_callback))
      @spider.set_callback lambda { |array|
        array.each do |title, href|
          #sync_puts "#{title}\t=>\t#{href}"
          @url_queue.push(href)
        end
      }
    end
    def sync_puts(str)
      @stdout_mutex.synchronize {
        puts str
        $stdout.flush
      }
    end
    # 1st part: BFS to find links
    # producer thread
    def start_search(url)
      @starttime = Time.now      # visit the page and read the page.
      # start timer thread
=begin
      timer = Thread.new { 
        while @queue_empty_timeout < 30
          sleep 1
          @queue_empty_timeout += 1
          sync_puts "time tick :#{@queue_empty_timeout}"
        end
      }
=end
      # add the urls into a queue
      # start producer thread
      
      #Thread.new {
        #search_page_use_hpricot(url)
        search_page_use_capybara(url)
      #}

      

      # start consumer thread
      #consumer = Thread.new {
        #consume_loop
      #}
    end

    # the things to be searched should also place here
    def search_page_use_hpricot(url)
      # do something and put the new urls into the queue
      doc = Hpricot(open(url,{
        'User-Agent' => 'Mozilla/5.0 (compatible; MSIE 6.0; Windows NT 5.0)'
        }))
      converter = Iconv.new('utf-8', 'GBK')
      doc.search('a').each do |a|
        # a.inner_html.force_encoding('utf-8') is useless
        begin
          sync_puts "#{converter.iconv(a.inner_html)} => #{a.attributes['href']}"
        rescue ArgumentError
          sync_puts "ArgumentError!!!"
        end
      end
    end

    def search_page_use_capybara(url)
      # do something and put the new urls into the queue
      @spider.visit_page(url)
      #@spider.search
    end
    
    # consumer loop
    def consume_loop
      loop do
        if (@queue_empty_timeout > 25)#@should_stop == true || \
          #(@queue_empty_timeout > 25)# && @url_queue.size == 0)
          # stop consumer thread
          sync_puts "exit consume_loop ing"
          endtime = Time.now
          sync_puts endtime - @starttime
          break
        else
          # new a thread to do the things below
          #Thread.new {
            sync_puts "timeout:#{@queue_empty_timeout}"
            get_and_search_url
          #}
        end
      end
      exit
    end

    # useless
    def join_all
      main = Thread.main
      current = Thread.current
      all = Thread.list
      # Now call join on each thread
      all.each { |t| t.join unless t == current or t == main }
    end

    # 2nd part: get urls in page and convert to hash code
    # get a url in the queue, and make the downloaded tag to be true in a hash
    def get_and_search_url
      #Thread.new {
      # 1 get a head of the queue
      url = @url_queue.shift
      sync_puts url
      # 2 search the url
      if url = nil || filtered?(url)
        return
      end

      sync_puts "##new a thread and search the url"
      #search_page_use_hpricot(url)
      search_page_use_capybara(url)

      # set the if downloaded flag to be true
      @downloaded_url["#{url.hash}"] = true
      sync_puts "##new search url thread end"
      #}
    end

    # 3rd part: use the hash code to judge whether the url is downloaded
    def downloaded?(url)
      @downloaded_url["#{url.hash}"]
    end
    
    # filter
    def filtered?(url)
      # if return true, don't search the page
      # else search it
      if downloaded?(url)
        sync_puts "\n---this page has downloaded!\n"
        return true
      elsif url =~ /tmall/
        return true
      else
        return false
      end
    end

    # stop search
    def stop_search
      @should_stop = true
    end
  end
end

# test code
sized_queue = SizedQueue.new(20)
stdout_mutex = Mutex.new
consumer_threads = []
producer_threads = []

crawler = CrawlAll::Taobao.new(sized_queue, stdout_mutex)

crawler.start_search('http://list.taobao.com/itemlist/nvzhuang2011a.htm?cat=16&isprepay=1&viewIndex=1&fl=Shangpml&style=grid&md=5221&isnew=2&olu=yes&user_type=0&random=false&sd=1&as=0&commend=all&atype=b&q=%E6%98%A5&same_info=1&src_t=home&smc=1&tid=0&_input_charset=utf-8')
