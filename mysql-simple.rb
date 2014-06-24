require 'rubygems'
require 'mysql'

# connect to a mysql database 'test' on the local machine
# using username of 'root' with no password
db = Mysql.connect('localhost', 'root', '', 'test')

# perform an arbitrary SQL query
db.autocommit(false)
db.query("INSERT INTO people (name, age) VALUES ('Chrisa', 22)")
db.commit
# perform a query that returns data
begin
  query = db.query('SELECT * FROM people')
  puts "There were #{query.num_rows} rows returned"
  query.each_hash do |h|
    puts h.inspect
  end
rescue
  puts db.errno
  puts db.error
end

# close the connection cleanly
db.close