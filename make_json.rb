# coding: utf-8

require 'csv'
require 'json'

# 佐賀県路線バスオープンデータ
DATA_DIR        = 'saga-current'
TRIPS_FILE      = '/trips.txt'
STOP_TIMES_FILE = '/stop_times.txt'

# 路線ID
ROUTE_ID = [
    '300017160',  # からつ号・博多→宝当桟橋
    '300030290',  # からつ号・福岡空港→宝当桟橋
    '300030510',  # いまり号・博多→伊万里
    '300030530',  # いまり号・福岡空港→伊万里
    '300032160',  # からつ号・博多→唐津城入口
]

# 停留所ID
STATION_ID = {
    'tenjin' => '3602370-00',  # 西鉄天神高速バスターミナル
    'hakata' => '3606002-00',  # 博多バスターミナル
    'fukdom' => '3606199-01',  # 福岡空港国内線
}


# 運行便抽出
trip_list = []

CSV.foreach(__dir__ + '/' + DATA_DIR + TRIPS_FILE, liberal_parsing: true) do |row|
    if (ROUTE_ID.include?(row[0]))
        trip_list.push(row[2])
    end
end


# 停留所別出発時刻抽出
