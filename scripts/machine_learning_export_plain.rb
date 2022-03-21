# ruby machine_learning_export_01.rb SUGAR_USD S5 /Users/Kobus/Desktop

require 'oanda_api_v20'

now         = Time.now.utc
instrument  = ARGV[0] || 'SUGAR_USD'
granularity = ARGV[1] || 'S5'
path        = ARGV[2] || '/Users/Kobus/Desktop'

file    = File.new("#{path}/001_#{instrument}_#{granularity}_#{now.year}-#{now.month}-#{now.day}.csv", 'w+')
client  = OandaApiV20.new(access_token: '', practice: true)
candles = client.instrument(instrument).candles(count: 5000, granularity: granularity).show

file.write "year,month,day,week_day,hour,minute,second,open,high,low,close\n"

candles['candles'].each do |candle|
  next unless candle['complete']
  date = Time.parse(candle['time'])
  year, month, day, week_day, hour, minute, second = date.year, date.month, date.day, date.wday, date.hour, date.min, date.sec
  file.write "#{year},#{month},#{day},#{week_day},#{hour},#{minute},#{second},#{candle['mid']['o']},#{candle['mid']['h']},#{candle['mid']['l']},#{candle['mid']['c']}\n"
end

file.close
