# ruby machine_learning_export_averages.rb SUGAR_USD M1 X /Users/Kobus/Desktop/SUGAR_USD

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
file.write "hour_m_diff,m,l,k,hour_f_diff,f,e,d,c,b,a,hour,close,x\n"

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

for index in 300..candles.count
  i = index - 300

  m = average(candles[i..i + 59])         # 000..059
  l = average(candles[i..i + 119])        # 000..119
  k = average(candles[i..i + 179])        # 000..179

  f = average(candles[i + 180..i + 189])  # 180..189
  e = average(candles[i + 190..i + 199])  # 190..199
  d = average(candles[i + 200..i + 209])  # 200..209
  c = average(candles[i + 210..i + 219])  # 210..219
  b = average(candles[i + 220..i + 229])  # 220..229
  a = average(candles[i + 230..i + 239])  # 230..239

  close = candles[i + 239]['mid']['c']    # 239

  begin
    hour        = Time.parse(candles[i + 239]['time']).utc.hour
    hour_m_diff = time_difference(Time.parse(candles[i + 239]['time']).utc, Time.parse(candles[i]['time']).utc)
    hour_f_diff = time_difference(Time.parse(candles[i + 239]['time']).utc, Time.parse(candles[i + 180]['time']).utc)
  rescue ArgumentError, TypeError
    hour        = Time.at(candles[i + 239]['time'].to_f).utc.hour
    hour_m_diff = time_difference(Time.at(candles[i + 239]['time'].to_f).utc, Time.at(candles[i]['time'].to_f).utc)
    hour_f_diff = time_difference(Time.at(candles[i + 239]['time'].to_f).utc, Time.at(candles[i + 180]['time'].to_f).utc)
  end

  case target
  when 'X'
    x = average(candles[i + 240..i + 299]) # 240..299
  end

  file.write "#{hour_m_diff},#{m},#{l},#{k},#{hour_f_diff},#{f},#{e},#{d},#{c},#{b},#{a},#{hour},#{close},#{x}\n"
end

file.close
