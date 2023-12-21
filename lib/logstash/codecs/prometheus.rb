# encoding: utf-8
require "logstash/codecs/base"
require "logstash/codecs/line"
require 'json'

class LogStash::Codecs::Prometheus < LogStash::Codecs::Base
  config_name "prometheus"

  public
  def register
    @lines = LogStash::Codecs::Line.new
  end

  public
  def decode(data)
    data = "#{data}\n" unless data.match(/\n$/)
    help_dict = {}
    type_dict = {}
    @lines.decode(data) do |event|

      begin
        message = event.get("message")

        #puts 'Processing Message: ' + message

        if message.start_with?("#")
          if metamatch = message.match(/^# (TYPE|HELP) ([a-zA-Z_:][a-zA-Z0-9_:]*)+ (.+)$/)
            if metamatch.captures[0] == "HELP"
              #puts 'Found Help: ' + metamatch.captures[1] + ' ' + metamatch.captures[2]
              help_dict[metamatch.captures[1]] = metamatch.captures[2]
            elsif metamatch.captures[0] == "TYPE"
              #puts 'Found Type: ' + metamatch.captures[1] + ' ' + metamatch.captures[2]
              type_dict[metamatch.captures[1]] = metamatch.captures[2]
            end
          end
          next
        end

        name = nil
        dimensions = nil
        value = nil

        if partsmatch = message.match(/^([a-zA-Z0-9_:]+)\{((?:[^}\\]|\\.)*)\}\s+(.*)$/)
          name = partsmatch.captures[0].strip
          dimension_string = partsmatch.captures[1].strip
          value = partsmatch.captures[2].strip
          #puts 'Found metric with dimension: ' + name + "/" + dimension_string + "/" + value

          dimensions = parse_dimension_string?(dimension_string)
          #puts 'Parsed dimensions: ' + dimensions.to_json
        elsif partsmatch = message.match(/^([a-zA-Z0-9_:]+)\s+(.*)$/)
          name = partsmatch.captures[0].strip
          value = partsmatch.captures[1].strip
          #puts 'Found metric without dimension: ' + name + "/" + value
        end

        metric = {}
        metric['name'] = name unless name.nil?
        metric['value'] = value.to_f unless value.nil?
        metric['type'] = type_dict[name] unless type_dict[name].nil?
        metric['help'] = help_dict[name] unless help_dict[name].nil?
        metric['dimensions'] = dimensions unless help_dict[name].nil?

        #puts 'Metric: ' + metric.to_json

        yield LogStash::Event.new(metric)
      rescue => e
        puts 'Error: ' + e.message
        #e.backtrace.each { |line| puts line }
      end
    end
  end

  public
  def encode(event)
    @on_event.call(event, event.to_json)
  end

end

def parse_dimension_string?(string)
  kvps = string.scan(/([a-zA-Z0-9_:]+)\=\"((?:[^"\\]|\\.)*)\"/)
  #puts 'scanned kvps: ' + kvps.to_json
  kvpmap = {}
  kvps.each do |kvp| 
    kvpmap[kvp[0]] = kvp[1]
  end
  return kvpmap
rescue => e
  puts 'Error parsing dimension string: ' + e.message
  #puts 'Error parsing dimension string (orginal): ' + string
  #puts 'Error parsing dimension string (trimmed): ' + string.gsub(/[\s]*\,?[\s]*\}$/, "}")
  return nil
end