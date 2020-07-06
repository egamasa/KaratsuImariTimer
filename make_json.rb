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

# 系統番号<=>行先
ROUTE_DEST = {
    '17160' => '唐津（宝当桟橋）',
    '30290' => '唐津（宝当桟橋）',
    '30510' => '山本・北波多・伊万里',
    '30530' => '山本・北波多・伊万里',
    '32160' => '唐津（唐津城入口）',
}

# 停留所ID
STATION_ID = {
    'tenjin' => '3602370-00',  # 西鉄天神高速バスターミナル
    'hakata' => '3606002-00',  # 博多バスターミナル
    'fukdom' => '3606199-01',  # 福岡空港国内線
}


def makeJson(list, station)
    weekday  = []
    saturday = []
    holiday  = []

    list.each do |trip|
        # 系統番号=>行先
        dest = ''
        if (trip[0].match(/17160/))
            dest = ROUTE_DEST['17160']
        elsif (trip[0].match(/30290/))
            dest = ROUTE_DEST['30290']
        elsif (trip[0].match(/30510/))
            dest = ROUTE_DEST['30510']
        elsif (trip[0].match(/30530/))
            dest = ROUTE_DEST['30530']
        elsif (trip[0].match(/32160/))
            dest = ROUTE_DEST['32160']
        else
        end

        # 運行ダイヤ振り分け
        if (trip[0].match(/3_平日/))
            weekday.push([trip[2], dest])
        elsif (trip[0].match(/3_土曜/))
            saturday.push([trip[2], dest])
        elsif (trip[0].match(/3_日祝/))
            holiday.push([trip[2], dest])
        else
        end
    end

    # 出発時刻でソート
    weekday.sort_by! {|trip| trip[0]}
    saturday.sort_by! {|trip| trip[0]}
    holiday.sort_by! {|trip| trip[0]}

    # TODO: JSONファイル出力処理

end

# 運行便抽出
trip_list = []

CSV.foreach(__dir__ + '/' + DATA_DIR + TRIPS_FILE, liberal_parsing: true) do |row|
    if (ROUTE_ID.include?(row[0]))
        trip_list.push(row[2])
    end
end

# 停留所別出発便抽出
tenjin = []
hakata = []
fukdom = []

CSV.foreach(__dir__ + '/' + DATA_DIR + STOP_TIMES_FILE, liberal_parsing: true) do |row|
    if (trip_list.include?(row[0]))
        if (STATION_ID['tenjin'] == row[3])
            tenjin.push(row)
        elsif (STATION_ID['hakata'] == row[3])
            hakata.push(row)
        elsif (STATION_ID['fukdom'] == row[3])
            fukdom.push(row)
        else
        end
    end
end

# 停留所・曜日別JSON出力
makeJson(tenjin, 'tenjin')
makeJson(hakata, 'hakata')
makeJson(fukdom, 'fukdom')
