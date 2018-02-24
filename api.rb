require 'net/http'
require 'uri'
require 'json'
require "date"
require "pry"
KEY_PARAMS = "686a4253703557777952514863563554316a75444a50346e6f5836696648374f754d43776835354a627041"

def get_json(location, limit = 10)
  raise ArgumentError, 'too many HTTP redirects' if limit == 0
  uri = URI.parse(location)
  begin
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.open_timeout = 5
      http.read_timeout = 10
      http.get(uri.request_uri)
    end
    case response
    when Net::HTTPSuccess
      json = response.body
      JSON.parse(json)
    when Net::HTTPRedirection
      location = response['location']
      warn "redirected to #{location}"
      get_json(location, limit - 1)
    else
      puts [uri.to_s, response.value].join(" : ")
      # handle error
    end
  rescue => e
    puts [uri.to_s, e.class, e].join(" : ")
    # handle error
  end
end

# mecabで形態素分析する
def station_info(request_url,i = 0)
  arr = []
  station = get_json(request_url)

  time_table = station["ResultSet"]["Course"][i]["Route"]["Line"]
  stations = station["ResultSet"]["Course"][i]["Route"]["Point"]
  @save_data = station["ResultSet"]["Course"][i]["SerializeData"]
  stations.zip(time_table).each do |station, table|
    st_name = station["Station"]["Name"]
    date = table ? table["ArrivalState"]["Datetime"]["text"] : nil
    train_direction = table ? table["Name"] : "到着"
    arr << "#{st_name}駅->#{date}#{train_direction}"
  end
  p arr
end
deparature_str = "鷺沼"
destination_str = "横浜"
station_info(URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourse?APIKEY=#{KEY_PARAMS}&from=#{deparature_str}&to=#{destination_str}"))
station_info(URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/searchCourse?APIKEY=#{KEY_PARAMS}&from=#{deparature_str}&to=#{destination_str}"), 1)
# 前の時刻表
request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/courseEdit?assignInstruction=AutoPrevious&serializeData=#{@save_data}&APIKEY=#{KEY_PARAMS}")
# 次の時刻表
request_url = URI.escape("https://api.apigw.smt.docomo.ne.jp/ekispertCorp/v1/courseEdit?assignInstruction=AutoNext&serializeData=#{@save_data}&APIKEY=#{KEY_PARAMS}")

#これを2 or 3とか変えていけばいいのでは？
