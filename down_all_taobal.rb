#!/usr/bin/evn ruby
# encoding: UTF-8
$:.push('.')
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'iconv'
require 'thread'

class Consumer
  @@count = 0
  def initialize(queue, stdout_mutex, downloaded_url)
    @queue = queue
    @stdout_mutex = stdout_mutex
    @mutex    = Mutex.new
    @downloaded_url = downloaded_url
  end
  def sync_puts(str)
      @stdout_mutex.synchronize {
        puts str
        $stdout.flush
      }
    end
  def downloaded?(url)
      @downloaded_url["#{url.hash}"]
    end
    
    # filter
    def filtered?(url)
      # if return true, don't search the page
      # else search it
      if downloaded?(url)
        sync_puts "\n--#{rand(20)}-this page has downloaded!#{url}\n"
        return true
      elsif !(url =~ /taobao/)
        sync_puts "\n--#{rand(20)}- has filterd!#{url}\n"
        return true
      else
        return false
      end
    end
  def consume
    @mutex.synchronize do
      url = @queue.pop
      if url != nil && !filtered?(url)
      @@count += 1
      @downloaded_url["#{url.hash}"] = true
      sync_puts "#{@@count}------#{@queue.size}-------------Product #{url} consumed."
      search_page_use_hpricot(url)
    end
    end
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
        if a.attributes['href'] != nil && !filtered?(a.attributes['href'])
          #sync_puts "#{converter.iconv(a.inner_html)} => #{a.attributes['href']}"
          @queue.push(a.attributes['href'])
        end
      rescue ArgumentError
        sync_puts "ArgumentError!!!"
      end
    end
  end
end

class Producer
  def initialize(queue, stdout_mutex)
    @stdout_mutex = stdout_mutex
    @queue = queue
  end
  def sync_puts(str)
      @stdout_mutex.synchronize {
        puts str
        $stdout.flush
      }
    end

  def produce(url)
    sync_puts "searching the link in #{url}"
    search_page_use_hpricot(url)
    #product = rand(20)
    #@queue.push(product)
    #sync_puts "Product #{product} produced."
  end

  # the things to be searched should also place here
  def search_page_use_hpricot(url)
    sync_puts "searching the link in #{url}"
    # do something and put the new urls into the queue
    doc = Hpricot(open(url,{
      'User-Agent' => 'Mozilla/5.0 (compatible; MSIE 6.0; Windows NT 5.0)'
      }))
    converter = Iconv.new('utf-8', 'GBK')
    doc.search('a').each do |a|
      # a.inner_html.force_encoding('utf-8') is useless
      begin
        #sync_puts "#{converter.iconv(a.inner_html)} => #{a.attributes['href']}"
        @queue.push(a.attributes['href'])
      rescue ArgumentError
        sync_puts "ArgumentError!!!"
      end
    end
  end
end

sized_queue = SizedQueue.new(50000)
stdout_mutex = Mutex.new
downloaded_url = Hash.new
consumer_threads = []
producer_threads = []
start_url = 'http://list.taobao.com/itemlist/nvzhuang2011a.htm?cat=16&isprepay=1&viewIndex=1&fl=Shangpml&style=grid&md=5221&isnew=2&olu=yes&user_type=0&random=false&sd=1&as=0&commend=all&atype=b&q=%E6%98%A5&same_info=1&src_t=home&smc=1&tid=0&_input_charset=utf-8'
#start_url = 'http://www.solagirl.net'
#start_url = 'http://www.cangqionglongqi.com'
num = 0
  producer_threads << Thread.new {
    producer = Producer.new(sized_queue, stdout_mutex)
    producer.produce(start_url)
  }
sleep 5
100.times {
  consumer_threads << Thread.new {
    consumer = Consumer.new(sized_queue, stdout_mutex, downloaded_url)
    while sized_queue.size > 0
      consumer.consume
    end
  }
  num += 1
}

producer_threads.each { |thread| thread.join }
consumer_threads.each { |thread| thread.join }
#consumer_threads[0].join
puts sized_queue.size
puts producer_threads.size