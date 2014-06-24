# -*- coding: utf-8 -*-
require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'rspec'
require 'capybara/rspec'

module Spider
  class NoWorksheetException < RuntimeError
  end
  class NoDbException < RuntimeError
  end
  class Base
    def initialize(out_to_mode, worksheet, db)
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      begin
        @row_index = 1
        case out_to_mode
        when :screen
          @callback = lambda { |text, href|
            puts "#{text}\t#{href}"
          }
        when :excel
          raise NoWorksheetException, "worksheet shouldn't be nil" if worksheet == nil
          @worksheet = worksheet
          @callback = lambda { |text, href|
            @worksheet.write(@row_index, 0, text)
            @worksheet.write(@row_index, 1, href)
          }

        when :db
          raise NoDbException, "db shouldn't be nil" if db == nil
          @db = db
          @callback = lambda { |text, href|
          }
        end
      rescue => e
        puts e.class
        exit
      end
    end
  end

  class Google
    include Capybara::DSL
    def initialize
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.app_host = "http://www.google.com.hk/"
      @row_index = 1
    end

    def set_callback(callable)
      @callback = callable
    end

    def search
      visit('/')
      # use name attr
      fill_in "q", :with => ARGV[0] || "I love Ruby!"
      # use value attr
      click_button "Google 搜索"
      all(:xpath, '//li[@class="g"]/h3').each do |h3|
        a = h3.find("a")
        #puts "#{h3.text}  =>  #{a[:href]}"

        if a[:href] =~ /url\?q=(?<href>.*)&sa=/
          puts "#{h3.text}  =>  #{$~[:href]}"
        end

      end
    end
    def export_page_info
      puts current_url
      #all("li.g h3").each do |h3|
      result = Array.new
      all(:xpath, '//li[@class="g"]/h3').each do |h3|
        a = h3.find("a")
        #@callback.call(h3.text, a[:href])
        #@row_index += 1

        if a[:href] =~ /url\?q=(?<href>.*)&sa=/
          #puts "#{h3.text}  =>  #{$~[:href]}"
          result.push([h3.text, $~[:href]])
          @row_index += 1
        end
      end
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      visit('/')
      fill_in "q", :with => keyword # use name attr
      click_button "Google 搜索" # use value attr
      export_page_info       # to be changed to adjust mode
      page_index = 1
      while page_index < page_num
        click_link "下一页"
        export_page_info
        page_index += 1
      end
    end
  end

  # Search infomations in baidu
  class Baidu
    include Capybara::DSL

    def initialize
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.app_host = "http://www.baidu.com/"
      @row_index = 1

    end

    def set_callback(callable)
      @callback = callable
    end
    
    def search
      visit('/')
      fill_in "wd", :with => "I love Ruby!"
      click_button "百度一下"
      #visit('http://www.baidu.com/#wd=codeigniter&rsv_bp=0&tn=baidu&rsv_spt=3&ie=utf-8&rsv_sug3=9&rsv_sug4=191&rsv_sug1=9&rsv_sug2=0&inputT=4')
      #all(:xpath, '//div[@id="1"]').each do |tools| # id为页面中百度的条目编号
      all(:xpath, '//div[@class="result c-container"]/h3').each do |tools|
      #all(:xpath, '//div[@id="content_left"]').each do |tools|
      #all(:xpath, '//div[@class="c-tools"]').each do |tools|
        #puts tools
        #data-tools = tools["data-tools"]
        #puts " #{tools["data-tools"]}"
        a = tools.find("a")
        puts "#{tools.text} = > #{a[:href]}\n"
      end
    end

    def export_page_info
      puts current_url
      result = Array.new
      all(:xpath, '//div[@class="result c-container"]/h3').each do |tools|
        a = tools.find("a")
        result.push([tools.text, a[:href]])
        @row_index += 1
      end
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      visit('/')
      fill_in "wd", :with => keyword
      click_button "百度一下"
      export_page_info
      page_index = 1
      while page_index < page_num
        click_link "下一页>"
        export_page_info
        page_index += 1
      end
    end
  end

  # Search infomations in taobao
  class Taobao
    include Capybara::DSL

    def initialize
      Capybara.run_server = true
      Capybara.current_driver = :webkit
      Capybara.app_host = "http://www.taobao.com/"
      @row_index = 1

    end

    def set_callback(callable)
      @callback = callable
    end
    
    def search
      visit('/')
      #visit('http://list.taobao.com/itemlist/nvzhuang2011a.htm?cat=16&isprepay=1&user_type=0&sd=1&random=false&as=0&viewIndex=1&commend=all&atype=b&fl=Shangpml&style=grid&md=5221&q=%E6%98%A5&same_info=1&olu=yes&isnew=2&smc=1&tid=0&_input_charset=utf-8')
      fill_in "q", :with => "ruby"
      find(:xpath, '//button[@class="btn-search"]').click
      save_page
=begin
      begin
      all(:xpath, '//div/ul/li[@class="item"]/div[@class="info"]/ul[@class="clearfix"]/li[@class="title"]/a').each do |tools|
        puts "#{tools["title"]} => #{tools["href"]}"
      end
    rescue
    end
=end
    end

    def visit_page(url)
      #Capybara.default_wait_time = 20
      visit(url)
      save_page
      #puts "page saved"
      # 使用javascript代码实现翻页，也可直接window.scrollTo(0,10000)
      #page.execute_script "window.scrollBy(0,10000)"
      export_page_info
    end

    def export_page_info
      puts current_url
      result = Array.new

      #page.should have_xpath('li/a[@class="J_AtpLog"')
      #page.should have_selector(:xpath, '//table/tr')
      #all(:xpath, '//a').each do |tools|
      all(:xpath, '//div/ul/li[@class="item"]/div[@class="info"]/ul[@class="clearfix"]/li[@class="title"]/a').each do |tools|
        puts "#{tools["title"]} => #{tools["href"]}"
        #a = tools.find('div[2]/ul/li[3]/a')
        if tools["href"] =~ /http/
          result.push(['link', tools["href"]])
          @row_index += 1
        end
        #result.push([tools["title"], tools["href"]])
        #@row_index += 1
      end
      puts @row_index
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      visit('/')
      fill_in "q", :with => keyword
      click_button "搜索"
      export_page_info
      page_index = 1
      while page_index < page_num
        click_link "下一页>"
        export_page_info
        page_index += 1
      end
    end
  end

  class YellowPages < Base
    include Capybara::DSL

    def initialize
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.app_host = "http://www.yellowpages.com/"
      @row_index = 1

    end

    def set_callback(callable)
      @callback = callable
    end
    
    def search
      visit('/')
      #fill_in "search_terms", :with => ARGV[0] || "Coffee"
      #fill_in "geo_location_terms", :with => ARGV[1] || "Los Angeles, CA"
      #click_button "Search"
      visit('http://www.yellowpages.com/los-angeles-ca/coffee?g=Los+Angeles%2C+CA')
      puts "pressed search"
      save_page
      puts "saved the pages"
      all(:xpath, '//div[@class="business-container-inner"]').each do |container|
        puts "business-name:"
        #menu_link = container.find(:xpath, 'h3/div/a[@class="menu-link"]')
        #puts "menu-link:#{menu_link.text}\nhref:#{menu_link[:href]}"
        # restaurant name and url link
        #result = container.find(:xpath, 'a[@class="url  mip-link"]')
        #puts "restaurant:#{result.text}\nhref:#{result[:href]}"
        container.find(:xpath, 'h3/div/a').each do |result|
          puts "restaurant:#{result.text}\nclass:#{result[:class]}\nhref:#{result[:href]}"
        end
        # location
        loc = container.find(:xpath, 'span[@class="street-address"]').text
        loc += container.find(:xpath, 'span[@class="locality"]').text
        loc += container.find(:xpath, 'span[@class="city-state"]').text
        loc += container.find(:xpath, 'span[@class="region"]').text
        loc += " " + container.find(:xpath, 'span[@class="postal-code"]').text
        puts loc
        # business phone- search class "business-phone phone", "additional-phones"
        phone = container.find(:xpath, 'span[@class="business-phone phone"]').text
        puts phone
        additionnal_phones = container.find(:xpath, 'span[@class="additional-phones"]').text
        # website
        website = container.find(:xpath, 'div[@class="info-business-additional"]/ul/li[@class="website-feature"/a[@class="track-visit-website"]')[:href]
        puts website
        # coupon配给卷
        coupon = container.find(:xpath, 'div[@class="info-business-additional"]/ul/li[@class="coupon-feature"/a[@class="track-coupon coupon-link"]')[:href]
        puts coupon
        # directions
        directions = container.find(:xpath, 'div[@class="info-business-additional"]/ul/li[@class="map-feature"/a[@class="track-map-it"]')[:href]
        puts directions
        # more info
        more_info = container.find(:xpath, 'div[@class="info-business-additional"]/ul/li[@class="more_info-feature"/a[@class="track-more-info"]')[:href]
        puts more_info
      end
    end

    def export_page_info
      puts current_url
      result = Array.new
      all(:xpath, '//div[@class="result c-container"]/h3').each do |tools|
        a = tools.find("a")
        result.push([tools.text, a[:href]])
        @row_index += 1
      end
      @callback.call(result)
    end

    def search_to_page(page_num, keyword)
      visit('/')
      fill_in "search_terms", :with => ARGV[0] || "Coffee"
      fill_in "geo_location_terms", :with => ARGV[1] || "Los Angeles, CA"
      click_button "Search"

      export_page_info
      page_index = 1
      while page_index < page_num
        click_link "Next"
        export_page_info
        page_index += 1
      end
    end
  end

  class Tmall
  end
  class JD
  end
end

#######################
# codes for test
#########################
#Capybara.run_server = false
#Capybara.current_driver = :webkit
#Capybara.app_host = "http://www.google.com.hk/"
#Capybara.app_host = "http://www.baidu.com/"

#spider = Spider::Google.new
#spider = Spider::Baidu.new
#spider.search
#spider.search_to_page(2)
=begin
workbook = WriteExcel.new('search_result.xls');
worksheet = workbook.add_worksheet
worksheet.write(0, 0, 'Text')
worksheet.write(0, 1, 'link')
spider.search_to_page_write_to_excel(3, worksheet)
workbook.close
=end
