# -*- coding: utf-8 -*-
require 'rubygems'
require 'capybara'
require 'capybara/dsl'
require 'capybara-webkit'
require 'rspec'
require 'capybara/rspec'

$:.push '.'

module Spider
  class StandardAndPoors
    include Capybara::DSL
    def initialize
      Capybara.run_server = false
      Capybara.current_driver = :webkit
      Capybara.app_host = "http://www.standardandpoors.com"
      Capybara.default_wait_time = 20
      @row_index = 1
      #@session = Capybara::Session.new(:selenium)
    end

    def set_callback(callable)
      @callback = callable
    end

    def search
      visit('/en_US/web/guest/home')
      # use value attr
      click_link 'Login'
=begin
      @session.within("//form[@id='loginForm']") do
        @session.fill_in "username", :with => 'peacock.bright@gmail.com'
        @session.fill_in "password", :with => "56tyGHbn"
      end
      @session.click_button "Log In"
=end
      # use name attr
      fill_in "username", :with => 'peacock.bright@gmail.com'
      fill_in "password", :with => "56tyGHbn"
      #Capybara.default_wait_time = 60
      # use value attr
      click_button "Log In"
      #page.execute_script "validateLogin(document.loginForm, 'http://www.standardandpoors.com/en_US/c/portal/login?p_l_id=10180','')"
      #page.execute_script "submitenter(this,event)"
      #Capybara.default_wait_time = 60
      #save_page
      # login
      find('a[href="/c/portal/logout"]')

      all('a[id="search-type-ISIN"]').each do |isin|
        #a = h3.find("a")
        puts "#{isin.text}  =>  #{isin[:href]}"
        isin.click
=begin
        if a[:href] =~ /url\?q=(?<href>.*)&sa=/
          puts "#{h3.text}  =>  #{$~[:href]}"
        end
=end
      end
      find('a[href="/c/portal/logout"]')
      all('li.active a[id="search-type-ISIN"]').each do |isin|
        #a = h3.find("a")
        puts "#{isin.text}  =>  #{isin[:href]}"
        fill_in "q", :with => "USP3772NHK11"
        click_button "Find"
      end
      #            searchTerm.setValueAttribute("USP3772NHK11");

      save_page
    end
  end
end

def puts_callback(array)
  puts "this is in callback"
  #n = 0
=begin
  array.each do |title, link|
    puts "#{title}\t#{link}"
  end
=end
end

puts Time.now
spider = Spider::StandardAndPoors.new
spider.set_callback(method(:puts_callback))
spider.search
puts Time.now
