# ruby machine_learning_export_averages_fibonacci.rb SUGAR_USD M1 X /Users/Kobus/Desktop/SUGAR_USD

# require 'oanda_api_v20'
require 'byebug'
require 'json'
require 'time'

def average(candles)
  sum = 0.0

  candles.each do |candle|
    sum += (candle['mid']['h'].to_f + candle['mid']['l'].to_f) / 2
  end

  (sum / candles.count).round(4)
end

# Round to the nearest 0.5
def time_difference(time_a, time_b)
  time_diff = time_b.to_f - time_a.to_f
  time_diff = time_diff / 60 / 60
  (time_diff * 2).round / 2.0
end

now         = Time.now.utc
instrument  = ARGV[0] || 'SUGAR_USD' # 'NATGAS_US', 'WTICO_USD', 'EUR_USD'
granularity = ARGV[1] || 'M1'
target      = ARGV[2] || 'X' # G, H, I, J, K, L, X, G-I
path_in     = ARGV[3] || "/Users/Kobus/Desktop/#{instrument}"
path_out    = ARGV[4] || '/Users/Kobus/Desktop'

candles = []

file = File.new("#{path_out}/#{now.year}-#{format('%02d', now.month)}-#{format('%02d', now.day)}_#{instrument}_#{granularity}_#{target}.csv", 'w+')
file.write "hour_j_diff,p_j,p_i,p_h,p_g,p_f,p_e,p_d,p_c,p_b,p_a,hour,close,p_x\n"

# client  = OandaApiV20.new(access_token: '', practice: true)
# candles = client.instrument(instrument).candles(count: 5000, granularity: granularity).show
# candles = candles['candles']

Dir.foreach(path_in) do |item|
  next if item == '.' || item == '..' || item == '.DS_Store'

  File.open("#{path_in}/#{item}").each do |line|
    candles << JSON.parse(line)['candles']
  end
end

candles.flatten!

for index in 204..candles.count
  i = index - 204

  p_j = average(candles[i..i + 164])       # 000..164
  p_i = average(candles[i + 62..i + 164])  # 062..164
  p_h = average(candles[i + 101..i + 164]) # 101..164
  p_g = average(candles[i + 125..i + 164]) # 125..164
  p_f = average(candles[i + 140..i + 164]) # 140..164
  p_e = average(candles[i + 149..i + 164]) # 149..164
  p_d = average(candles[i + 155..i + 164]) # 155..164
  p_c = average(candles[i + 158..i + 164]) # 158..164
  p_b = average(candles[i + 158..i + 161]) # 158..161
  p_a = average(candles[i + 161..i + 164]) # 161..164

  close = candles[i + 164]['mid']['c']     # 164

  begin
    hour        = Time.parse(candles[i + 164]['time']).utc.hour
    hour_j_diff = time_difference(Time.parse(candles[i + 164]['time']).utc, Time.parse(candles[i]['time']).utc)
  rescue ArgumentError, TypeError
    hour        = Time.at(candles[i + 164]['time'].to_f).utc.hour
    hour_j_diff = time_difference(Time.at(candles[i + 164]['time'].to_f).utc, Time.at(candles[i]['time'].to_f).utc)
  end

  case target
  when 'X'
    p_x = average(candles[i + 165..i + 203]) # 165..203
  end

  file.write "#{hour_j_diff},#{p_j},#{p_i},#{p_h},#{p_g},#{p_f},#{p_e},#{p_d},#{p_c},#{p_b},#{p_a},#{hour},#{close},#{p_x}\n"
end

file.close
