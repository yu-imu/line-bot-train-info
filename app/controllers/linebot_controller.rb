class LinebotController < ApplicationController
  require 'redis'
  require "date"
  include ReplyApi
  include AnalysisWords
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
          if repley_text == "前のダイア"
            save_data = Redis.current.get 'past_rquest'
            request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/courseEdit?assignInstruction=AutoPrevious&serializeData=#{save_data}&APIKEY=#{KEY_PARAMS}")
            repley_text = get_station_info(request_url)
          elsif repley_text == "次のダイア"
            save_data = Redis.current.get 'past_rquest'
            request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/courseEdit?assignInstruction=AutoNext&serializeData=#{save_data}&APIKEY=#{KEY_PARAMS}")
            repley_text = get_station_info(request_url)
          elsif repley_text.include?("駅")
            set_station(repley_text)
           if @deparature_str && @destination_str
             request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourse?APIKEY=#{KEY_PARAMS}&from=#{@deparature_str}&to=#{@destination_str}")
             repley_text = get_stations_info(request_url)
             # userAgentを実装したい。
             message = {
               type: "template",
               altText: repley_text,
               template: {
                   type: "confirm",
                   text: repley_text,
                   actions: [
                       {
                         type: "message",
                         label: "前のダイア",
                         text: "前のダイア"
                       },
                       {
                         type: "message",
                         label: "次のダイア",
                         text: "次のダイア"
                       }
                   ]
               }
             }
            client.reply_message(event['replyToken'], message)
           else
             repley_text = "２つめの駅を入力するぺこ"
           end
         else
           repley_text = "駅名を入力するぺこ"
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

  def get_station_info(request_url)
    station = get_json(request_url)
    arr = []
    if station.nil?
      repley_text = "お探しのダイアは見つからなかったぺこ"
    else
      time_table = station["ResultSet"]["Course"]["Route"]["Line"]
      stations = station["ResultSet"]["Course"]["Route"]["Point"]
      request_url = station["ResultSet"]["Course"]["SerializeData"]
      stations.zip(time_table).each do |station, table|
        st_name = station["Station"]["Name"]
        date = table ? table["ArrivalState"]["Datetime"]["text"] : nil
        if date
          date = date.to_time.strftime("%m/%d %H:%M")
        end
        train_direction = table ? table["Name"] : "(着)"
        arr << "#{st_name}駅#{date}#{train_direction}"
        repley_text = arr.join("→")
      end
    end
    return repley_text
  end

  def get_stations_info(request_url)
    station = get_json(request_url)
    arr = []
    if station.nil?
      repley_text = "お探しの駅は見つからなかったぺこ"
    else
      time_table = station["ResultSet"]["Course"][0]["Route"]["Line"]
      stations = station["ResultSet"]["Course"][0]["Route"]["Point"]
      request_url = station["ResultSet"]["Course"][0]["SerializeData"]
      Redis.current.set("past_rquest", request_url)
      stations.zip(time_table).each do |station, table|
        st_name = station["Station"]["Name"]
        date = table ? table["ArrivalState"]["Datetime"]["text"] : nil
        if date
          date = date.to_time.strftime("%m/%d %H:%M")
        end
        train_direction = table ? table["Name"] : "(着)"
        arr << "#{st_name}駅#{date}#{train_direction}"
        repley_text = arr.join("→")
      end
    end
    return repley_text
  end

  def set_station(get_station)
    # 形態素解析
    get_stations = classify_word(get_station)
    from_station = get_stations[0].to_s
    to_station = get_stations[1].to_s
    cache_station = Redis.current.get 'station'# １つめの駅をキャッシュしてある。

    if to_station.empty? && !cache_station
      from_station_name = from_station[0, from_station.length-1] # 駅処理
      Redis.current.set("station", from_station_name)
    elsif cache_station.present?
      from_station_name = from_station[0, from_station.length-1]
      @deparature_str = cache_station
      @destination_str = from_station_name # ２つめに入力したやつ
      Redis.current.flushdb
    else
      from_station_name = from_station[0, from_station.length-1] # 駅処理
      to_station_name = to_station[0, to_station.length-1]
      @deparature_str = from_station_name
      @destination_str = to_station_name
    end
  end
end
