$:.push('/Users/peacock/ruby/crawler')
require 'rubygems'
require 'open-uri'
require 'hpricot'
require 'uri'
require 'sqlite3'
require 'writeexcel'
require 'dataspider'

def puts_callback(array)
  puts "this is in callback"
  #n = 0
  array.each do |hash|
    puts "#{hash[:title]}\t#{hash[:link]}"
    puts "#{hash[:price]}\t#{hash[:showroom]}\t#{hash[:publish_date]}"
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

spider = DataSpider::Wuba.new
spider.set_callback(method(:puts_callback))
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