#!/usr/bin/env ruby
require 'redis'
require_relative '../config'

def main
  config = load_config[:redis]
  redis_host = config[:host] || '127.0.0.1'
  redis_port = config[:port] || '6379'
  redis_conn = Redis.new(host: redis_host, port: redis_port)
  config[:metrics].each do |metric|
    metric_value = redis_conn.send(metric[:cmd], metric[:args])
    taglist = ''
    metric[:tags].each do |tag,value|
      taglist += "#{tag}=#{value} "
    end if metric[:tags]
    puts "redis.#{metric[:name]}  #{Time.now.to_i} #{metric_value} #{taglist}" if metric_value
  end
end

main
