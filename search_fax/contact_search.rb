#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
$:.push('.')
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'cgi'
require 'writeexcel'
require "awesome_print"

module ContactSearch
  class Company
    def initialize
      @company_re = /Company|Inc|Co\.|Corporation|Corp.|group|office/i
      @company_name_posible_re = /Solutions|Services|Associates/
      @company_node_re = /strong|h1|h2|h3/
      @re = %r([+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4})
      @faxre = %r/(fax.*[+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4})|([+]?(\((\d){3}\)|(\d){3})[ -\.]?(\d){3}[ -\.]?(\d){4}.*fax)/i
      @email_re = /^(\w)+(\.\w+)*@(\w)+((\.\w{2,3}){1,3})$/
    end

    def set_callback(callable)
      @callback = callable
    end

    # main method to call this module
    def extact(url)
      puts "searching: " + url
      site_company_name = ""
      page_result = Array.new

      begin
        linkpage = Nokogiri::HTML(open(url))
      rescue => e # Nokogiri::HTML::SyntaxError => e
        puts "caught exception: #{e}"
        # if caught redirection forbidden, redirect
        # caught exception: redirection forbidden: https://www.google.com.hk/url?q=http://www.iaconstruction.com/contact.html&sa=U&ei=6t94U_ejN8iB8gXf6IL4BQ&ved=0CCcQFjAB&usg=AFQjCNEOslamBAwSgbQeh89-BsaNJbZ-Pg -> http://www.iaconstruction.com/contact.html
        if e.to_s =~ /-> (.*)$/
          # $& contains the ->
          url = $1.to_s
          puts "redirect to:" + url
          linkpage = Nokogiri::HTML(open(url))
        end
      end

      #linkpage = Nokogiri::HTML(File.open(url))
      if linkpage.class == NilClass
        return page_result
      end
      base_node = linkpage.at_css("body")
      if base_node.class == NilClass
        return page_result
      end
      base_node.traverse do |node|
        if node.text?# && (node.parent.name == "p")
          # node.parent node.child node.children node.next node.previous
          begin
            if node.text =~ @re
              puts "----search a block:  " + $&

              search_category(node, $&)

              if @block_result != {}
                page_result.push(@block_result)
              end
              #puts @block_result.to_s if @block_result != {}
            end

            # get the web site footer to see the comany name if any
            if node.text =~ /(Copyright|©)\s+\d{4}?\s?(?<company>.*)/
              site_company_name = $~['company'].gsub(/\t|, All Rights Reserved/, '')
              puts "site_company_name:" + site_company_name
            end
          rescue => e # ArgumentError?
            puts "caught exception arount search_category: #{e}"
          end
        end
      end
      # TODO tranverse the page result array, and add the url to the hash
      # if the size is 1 or 2, and company name is not found
      # set it site_company_name
      # else use unkown?
      page_result.each do |block_result|
        block_result['source'] = url
        if block_result['company'] == ''# && page_result.size < 3
          if site_company_name != ''
            block_result['company'] = site_company_name
          else
            # let the website's name as the company name
            if url =~ /\/\/(.*?).([A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)/
              site_name = $1 + "." + $2
              block_result['company'] = site_name
            end
          end
        end
      end
      #@callback.call(page_result)
      ap page_result

      return page_result
    end

    # identify the block type and the block parent node path
    # **AND** get the fax number
    def search_category(node, fax_or_tel)
      @block_result = Hash.new
      @node_pair = Array.new #['', '', ''] # node.name, node.text, node.path.to_s
      puts "node.text:" + node.text

      #if node.previous { puts "previous:" + node.previous.inner_html }
      if node.text.index(/fax/i)
        @block_result['fax'] = fax_or_tel
        data_block = node.parent
        #puts node.text
        identify_type_search_block(data_block, node.path.to_s)
      elsif node.previous && node.previous.inner_html.index(/fax/i) && !node.previous.inner_html.index(@re)
        # previous node have fax, and no other fax numbers
        @block_result['fax'] = fax_or_tel
        data_block = node.parent.parent
        identify_type_search_block(data_block, node.path.to_s)
=begin
      elsif node.previous == nil &&  node.parent.parent.inner_html && node.parent.parent.inner_html.index(/#{Regexp.escape(fax_or_tel)}/)
        # UGLY when node.parent.parent like
        # Tel:  <span class="telephone">(877) 222-5066</span><br>Fax: <span class="faxNumber">(877) 222-5067</span>
        @block_result['fax'] = fax_or_tel
        data_block = node.parent.parent
        identify_type_search_block(data_block, node.path.to_s)
=end
      end
    end

    # identify if is the block is sepreated by hr
    # try two times, first search the data_block node
    # then search the data_block
    def identify_type_search_block(data_block, key_node_path)
      block_type = :div
      # find the parent node
      if data_block.path =~ /.*tbody/
        block_type = :table
        data_block = data_block.at_xpath($&)
      else
        # identify if is a <hr> type
        tmp = data_block
        10.times do
          if tmp.class == NilClass
            break
          end
          if tmp.previous && tmp.previous.name == 'hr'
            data_block = data_block.parent
            block_type = :hr
            break
          end
          tmp = tmp.previous
        end

        # the last 10 times search cannot find hr
        if block_type == :div
          tmp = data_block.parent
          10.times do
            if tmp.class == NilClass
              break
            end
            if tmp.previous && tmp.previous.name == 'hr'
              block_type = :hr
              data_block = data_block.parent.parent
              break
            end
            tmp = tmp.previous
          end
        end
      end
      search_block(data_block, block_type, key_node_path)
    end

    # search the block around the fax num
    def search_block(parent, block_type, node_path)
      # init nodepair and begin sequen search
      traverse_parent(parent, block_type)
      sequen_result = sequen_search
      back_result = back_search(block_type, node_path)
      #puts "sequen:" + sequen_result[1].to_s + " => " + sequen_result[0]
      #puts "backwards:" + back_result[1].to_s + " => " + back_result[0]
      if block_type != :table
        # the backwards search result has a higher priority
        company = sequen_result[1] > back_result[1] ? sequen_result[0] : back_result[0]
        @block_result['company'] = company
      end
    end

    # get all the nodes info of the block
    def traverse_parent(parent_node, block_type)
      if parent_node
        #puts parent_node.path
        parent_node.traverse { |node|
          #puts "nodename:" + node.name + ", nodetext:" + node.text
          @node_pair.push([node.name, node.text, node.path.to_s])

          ################
          # hooks
          ###############
          # hook 1 if type is table, directly get company name from table
          # if the block is a table, the first text may be the company name
          # so set the weight = 1
          hook_table_company(block_type, node.name, node.text)
        }
      end
    end

    # search sequencely and generate the children nodes of this parent
    def sequen_search
      if @node_pair
        @node_pair.each do |node_name, node_text|
          judge_result = judge_company(node_name, node_text)
          if judge_result[1] >= 0
            return judge_result
          end
        end
      end
      return ['', 0]
    end

    def back_search(block_type, key_path)
      if @node_pair
        # search from the back
        # IMPORTENT: don't know why the nokogiri tranverse's last node
        # is the all text in this parent, to ignore this, minus 1 here
        i = @node_pair.length - 1

        start_flag = false
        while (i > 0)
          i -= 1
          # start search at the key node
          if @node_pair[i][2] != key_path && !start_flag
            #puts "excaped "+ @node_pair[i][1]
            next
          elsif @node_pair[i][2] == key_path
            #puts "excaped "+ @node_pair[i][1]
            #puts "start back search,path:" + @node_pair[i][2]
            start_flag = true
            next # already know the fax num, so don't need to scan this item
          end
          # stop search if meet the <hr>
          if block_type == :hr && @node_pair[i][0] == 'hr'
            #puts "stoped back_search because of found a hr tag"
            break
          end

          ###########################
          # hooks area
          #######################
          # hook 1 get the telephone number
          hook_backsearch_tel(@node_pair[i][0], @node_pair[i][1], @node_pair[i-1])
          # hook 2 get the email
          hook_backsearch_email(@node_pair[i][1])

          # main hook: get the company
          judge_result = judge_company(@node_pair[i][0], @node_pair[i][1])
          if judge_result[1] > 0
            return judge_result
          end
        end
      end
      return ['', 0]
    end

    # judget the posibility of one node
    def judge_company(node_name, node_text)
      #if node_text =~ /Danella Associates/
      #  puts "debug:node_name=>" + node_name + ";node_text=>" + node_text
      #end
      weight = 0
      # if matched some key words, ignore
      if node_text =~ /address|phone|fax|tel:/i
        return ['', 0]
      end

      if node_text =~ @re || node_text =~ @email_re
        return ['', 0]
      end
      if node_text =~ @company_re
        #puts "must: " + node.text
        return [node_text, 2]
      end
      if node_text =~ @company_name_posible_re
        weight += 0.5
      end
      if node_name =~ @company_node_re
        weight += 0.5
      end

      if weight > 0
        #puts "posible: " + node.text
        return [node_text, weight]
      end
      return ['', 0]
    end

    def hook_table_company(block_type, node_name, node_text)
      if !@block_result['company'] && block_type == :table && node_name == 'text' && node_text.index(/\w+/)
        #puts "posible in table: " + node_text
        @block_result['company'] = node_text
        #return [node_text, 1]
      end
    end

    def hook_backsearch_tel(node_name, node_text, previous_node)
      if  node_name == 'text' && node_text =~ @re && !node_text.index(/fax/i)
        tel_num = node_text[@re]
        if node_name.index(/toll|tel|phone|ph:/i)
          #puts "matched tel cate 1 " + "name:" + node_name + "text:" + node_text
          @block_result['tel'] = tel_num
        elsif !@block_result['tel'] && previous_node && !previous_node[0].index(@re)
          #puts "matched tel cate 2 " + "name:" + node_name + "text:" + node_text
          @block_result['tel'] = tel_num
        end
      end
    end

    def hook_backsearch_email(node_text)
      if node_text =~ @email_re
        #puts "matched email"
        @block_result['email'] = $&
      end
    end
  end
end

=begin

def excel_callback(array)
  puts "in excel callback"
  n = 2 + $excel_row_num
  array.each do |hash|
    if !hash.has_key?('tel')
      hash['tel'] = ''
    end
    if !hash.has_key?('email')
      hash['email'] = ''
    end
    if !hash.has_key?('company')
      hash['company'] = ''
    end
    # 下面的第一个参数是列号，0表示A列，第二个参数表示行号
    $worksheet.write("A#{n}", [
      hash['company'],
      hash['fax'],
      hash['tel'],
      hash['email'],
      hash['source']
    ])
    n += 1
  end
  $excel_row_num += array.size
end

$workbook = WriteExcel.new('Construction_FL_result.xls');
$worksheet = $workbook.add_worksheet
$worksheet.write(0, 0, 'company')
$worksheet.write(0, 1, 'fax')
$worksheet.write(0, 1, 'tel')
$worksheet.write(0, 1, 'email')
$worksheet.write(0, 1, 'source')
$excel_row_num = 0

extractor = ContactSearch::Company.new
localfiles = [

  'danella.html',
  'constructionmaterialsltd.html',
  'daytonachamber.html',
  'regional-office-contacts.html',
  'tradesmeninternational.html',
  'coastal.html',

  'garney.html'
]
localfiles.each do |file|
  counter = 0
  page_result = extractor.extact(file)
  if page_result.size == 0
    counter += 1
  end
  if counter >= 20
    break
  end
  #excel_callback(page_result)
end
#$workbook.close
=end