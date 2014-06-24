#!/usr/bin/env ruby
# save the image in a web page
# image source: http://imgsrc.baidu.com/forum/pic/item/296532b30f2442a7f1e4030bd343ad4bd013026e.jpg
# it can be downloaded by using command:
# curl -O http://imgsrc.baidu.com/forum/pic/item/296532b30f2442a7f1e4030bd343ad4bd013026e.jpg
require 'open-uri'

src = "http://imgsrc.baidu.com/forum/pic/item/296532b30f2442a7f1e4030bd343ad4bd013026e.jpg"
img = open(src) {|f| f.read}

open("2.jpg", "wb") { |file|
  file.write(img)
}


for i in 1..10
  uri= "http://www.369hi.com/images/default/logo" + i.to_s + ".gif"
  data=open(uri){|f|f.read}
  open("logo" + i.to_s + ".gif","wb"){|f|f.write(data)}
end

# another method using net/http
require 'net/http'
Net::HTTP.start("imgsrc.baidu.com") { |http|
  resp = http.get("/forum/pic/item/296532b30f2442a7f1e4030bd343ad4bd013026e.jpg")
  open("4.jpg", "wb") { |file|
    file.write(resp.body)
  }
}