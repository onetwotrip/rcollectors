#!/usr/bin/env ruby
require 'redis'
require 'yaml'
require_relative 'common.rb'

def symbolize_keys(hash)
  hash.inject({}){|result, (key, value)|
    new_key = case key
              when String then key.to_sym
              else key
              end
    new_value = case value
                when Hash then symbolize_keys(value)
                when Array then value.map{ |v| v.is_a?(Hash) ? symbolize_keys(v) : v }
                else value
                end
    result[new_key] = new_value
    result
  }
end

def load_config()
  return symbolize_keys(YAML.load_file('/etc/scollector/collectors/config.yml'))
end

def main()
  config = load_config()[:redis]
  redis_host = config[:host] || '127.0.0.1'
  redis_port = config[:port] || '6379'
  redis_conn = Redis.new(host: redis_host, port: redis_port)
  config[:metrics].each do |metric|
    metric_value = redis_conn.send(metric[:cmd],metric[:args])
    taglist = ''
    metric[:tags].each do |tag,value|
      taglist += "#{tag}=#{value} "
    end if metric[:tags]
    puts "redis.#{metric[:name]}  #{Time.now.to_i} #{metric_value} #{taglist}" if metric_value
  end
end

main()
