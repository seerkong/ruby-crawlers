module DataSpider
  class Wuba
    def initialize
      @app_host = "http://cc.58.com"
      @website = "http://cc.58.com/zufang/"
      @row_index = 1
      @page_num = 0
      @doc
    end

    def set_callback(callable)
      @callback = callable
    end

    def search
      puts Time.now
      doc = Hpricot(open('http://cc.58.com/zufang', {
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
    
    # the search list page
    def export_page_info(doc, say = true)
      puts Time.now
      doc.search('//tr').each do |para|

        result = Array.new
        para.search('a[@class="t"]').each do |a|
          result.push([a.inner_html, a.attributes['href']])
          if a.attributes['href'] =~ /cc.58.com/
            puts "#{a.inner_html}\t#{a.attributes['href']}"
            get_phone_num(a.attributes['href'])
            if say == true
              `say #{a.inner_html}`
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
    
    # get the phone number from a page link
    def get_phone_num(url)
      puts "get_phone_num:#{url}"
      doc = Hpricot(open(url, {
        'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
      }))
      # extract the name of this page
      if name = doc.search('.suUl li span a').to_a[2]
        puts name.inner_text.gsub(/\s*(\w*)/, '\1') # do |name|
      end
      #  puts "the name of this people: #{name.inner_html}"
      #end
      doc.search('.shenfen').each do |shenfen|
        puts "the shenfen of this people: #{shenfen.inner_html}"
      end
      # extract the phone number of this page
      # the phone number is a image file, so should extract the info from the page
      #doc.search('div[@id="movebar"]/ul/li/span/img').each do |content|
      doc.search('.suUl li img').each do |img|
        puts "the image source#{img.attributes['src']}"
      end
    end

    def loop_search
      #loop do
      puts Time.now
      doc = Hpricot(open('http://cc.58.com/zufang', {
        'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.1; Windows NT 5.1; SV1)'
      }))
      export_page_info(doc, false)
      while @has_next_doc
        @has_next_doc = false
        export_page_info(@next_doc, false)
      end
      #sleep(60 * 20)
      #break
      #end
    end
  end
end