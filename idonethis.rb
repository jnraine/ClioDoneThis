#!/usr/bin/env ruby

require 'httparty'
require 'json'
require 'rubygems'
require 'cgi'

class IDoneThis
  include HTTParty
  base_uri "https://idonethis.com/api/v0.1"

  def initialize(token = ENV['IDONETHIS_API_KEY'])
    @token = token
  end

  def headers
    { "Authorization" => "Token #{@token}", "Content-Type" => "application/json" }
  end

  def teams
    self.class.get("/teams/", headers: headers)
  end

  def dones(query = {})
    self.class.get("/dones/", query: query, headers: headers)
  end
  
  def done(text, date = Date.today)
    response = self.class.post("/dones/", body: { raw_text: text, team: 'clio-product-team', done_date: date }.to_json, headers: headers)
    if response.success?
      puts "\e[32m Done posted!"
    else
      puts "\e[31m Done failed!"
    end
  end
end

class IDoneThisHack
  include HTTParty
  base_uri 'https://idonethis.com/api/v3'

  def initialize(token = ENV['IDONETHIS_API_KEY'])
    @token = token
  end

  def delete_header
    eval(ENV['IDONETHIS_DELETE_COOKIE'])  
  end

  def delete_done(id)                                        
    self.class.delete("/done/#{id}/", headers: delete_header )
  end

  def comment_header
    eval(ENV['IDONETHIS_COMMENT_COOKIE'])  
  end
  
  def comment_done(id, message)
    json_req = { 
      action: "submit-comment",
      done_id: id,
      short_name: "clio-product-team",
      text: "#{message}",
      username: ENV['IDONETHIS_USERNAME']
    }.to_json

    response = self.class.post("/team/clio-product-team/feedback/done/#{ENV['IDONETHIS_USERNAME']}/#{id}/", body: json_req, headers: comment_header)
    if response.success?
      puts "\e[32m Done commented!"
    else
      puts "\e[31m Comment fail!"
    end
  end
  
  def uncomment_done(id)
    json_req = { 
      action: "delete-comment",
      "comment-id" => id,
      short_name: "clio-product-team",
      username: ENV['IDONETHIS_USERNAME']
    }.to_json

    response = self.class.post("/team/clio-product-team/feedback/done/#{ENV['IDONETHIS_USERNAME']}/#{id}/", body: json_req, headers: comment_header)
    if response.success?
      puts "\e[32m Comment undid!"
    else
      puts "\e[31m Comment undo fail!"
    end
  end

  def like_done(id, like = true)
    json_req = { 
      action: "#{"un" if !like}like",
      done_id: id,
      short_name: "clio-product-team",
      username: ENV['IDONETHIS_USERNAME']
    }.to_json

    response = self.class.post("/team/clio-product-team/feedback/done/#{ENV['IDONETHIS_USERNAME']}/#{id}/", body: json_req, headers: comment_header)
    if response.success?
      puts "\e[32m Done #{"un" if !like}liked!"
    else
      puts "\e[31m Like fail!"
    end
  end
end

client = IDoneThis.new
hackityhack = IDoneThisHack.new

def get_dones(args = [])
  client = IDoneThis.new

  puts "\e[33m Getting dones ..."
  date = Date.today.to_s 
  if args.length > 0
    owners = args[1].split(',')
  else
    owners = [ENV['IDONETHIS_USERNAME']]
  end

  if args.length > 2 
    offset = Integer(args[2]) rescue false
    date = (Date.today + offset).to_s if offset
    date = args[2] == 'yesterday' ? (Date.today - 1).to_s : Date.parse(args[2]).to_s unless offset
  end
  owner = ""
  count = 0
  loops = 0
  i = 1
  dones = false
  params = { done_date: date }
  while count == 0 do
    count = 100
    loops = loops + 1
    params = params.merge({ page_size: "#{count}", page: "#{loops}" } )
    params.merge({ owner: owner }) unless owner.empty?
    client.dones(params)["results"].each do |done|
      if done["owner"] != owner
        owner = done["owner"]
        puts "\e[33m  \e[44m #{owner} \e[0m" if owners.empty? || owners.include?(owner)
        i = 1
      end
      if owners.empty? || owners.include?(owner)
        dones = true
        puts "\e[34m #{done['id']}: \e[32m #{CGI.unescapeHTML(done['markedup_text'].gsub( %r{</?[^>]+?>}, '' ))}"
        puts "     \e[36m Likes: #{done['likes'].length} #{(done['likes'].map { |like| like['user'] })}" if done['likes'].length > 0
        if done['comments'].length > 0
          puts "     \e[35m Comments:"
          done['comments'].each do |comment|
            puts "       \e[33m #{comment['user']}:\e[36m #{CGI.unescapeHTML(comment['markedup_text'].gsub( %r{</?[^>]+?>}, '' ))} #{"\e[31m(" + comment['id'].to_s + ")" if comment['user'] == ENV['IDONETHIS_USERNAME']}"
          end
        end
      end
      i = i + 1
      count = count - 1
    end
  end
  
  puts "\e[31m No Dones :'(" if !dones
  puts "\e[0m"
  Kernel.abort()
end

if __FILE__ == $PROGRAM_NAME
    if ARGV[0] and ARGV[0] == '--get_dones'
      get_dones(ARGV)
    end

    if ARGV[0] and ARGV[0] == '--delete_done'
      puts "\e[33m Deleting done ..."
      date = Date.today.to_s
      
      if ARGV.length <= 1
       puts "\e[31m Missing ID."
       puts "\e[0m"
       Kernel.abort()
      end
      res = hackityhack.delete_done(ARGV[1])
      message = res.empty? ? "\e[32m Done deleted." : "\e[31m #{res['message']}"
      puts "#{message} \e[0m"
      get_dones()
    end

    if ARGV[0] and ARGV[0] == '--post_done'
      puts "\e[33m Posting done..."
      client.done(ARGV[1])
      get_dones()
      puts "\e[0m "
    end
    
    if ARGV[0] and ARGV[0] == '--comment_done'
      puts "\e[33m Commenting done..."
      hackityhack.comment_done(ARGV[1], ARGV[2])
      puts "\e[0m "
    end
    
    if ARGV[0] and ARGV[0] == '--uncomment_done'
      puts "\e[33m Uncommenting done..."
      hackityhack.uncomment_done(ARGV[1])
      puts "\e[0m "
    end
    
    if ARGV[0] and ARGV[0] == '--like_done'
      puts "\e[33m Liking done..."
      hackityhack.like_done(ARGV[1])
      puts "\e[0m "
    end
    
    if ARGV[0] and ARGV[0] == '--unlike_done'
      puts "\e[33m Unliking done..."
      hackityhack.like_done(ARGV[1],false)
      puts "\e[0m "
    end
end