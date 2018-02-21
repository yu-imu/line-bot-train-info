class LinebotController < ApplicationController
  require 'redis'
  require "date"
  include ReplyApi
  KEY_PARAMS = "686a4253703557777952514863563554316a75444a50346e6f5836696648374f754d43776835354a627041"

  def callback
    body = request.body.read
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          repley_text = event.message['text']
          if repley_text.include?("駅")
            set_station(repley_text)
          end
          # 実際に使うコードを書いていこう！
           if @deparature_str && @destination_str
             request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourse?APIKEY=#{KEY_PARAMS}&from=#{@deparature_str}&to=#{@destination_str}")
             arr = []
             station = get_json(request_url)
             time_table = station["ResultSet"]["Course"][0]["Route"]["Line"]
             stations = station["ResultSet"]["Course"][0]["Route"]["Point"]

             stations.zip(time_table).each do |station, table|
               st_name = station["Station"]["Name"]
               date = table ? table["ArrivalState"]["Datetime"]["text"] : nil
               if date
                 date = date.to_time.strftime("%m/%d %H:%M")
               end
               train_direction = table ? table["Name"] : "(着)"
               arr << "#{st_name}駅#{date}#{train_direction}"
             end
              repley_text = arr.join("→")
           end
          message = {
            type: 'text',
            text: repley_text
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    }
    head :ok
  end

  def set_station(get_station)
    get_station.match(/.*駅/)
    get_station = get_station[0, get_station.length-1]
    cache_station = Redis.current.get 'station'
    # 駅というッワードを含む場合
    if cache_station.nil?
      Redis.current.set("station", get_station)
    else
      @deparature_str = cache_station
      @destination_str = get_station
      Redis.current.flushdb
    end
  end
end
