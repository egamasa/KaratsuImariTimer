# coding: utf-8

require 'csv'
require 'json'

# 佐賀県路線バスオープンデータ
DATA_DIR        = 'saga-2022-04-01'
TRIPS_FILE      = '/trips.txt'
STOP_TIMES_FILE = '/stop_times.txt'
CALENDAR_FILE   = '/calendar_dates.txt'

# 路線ID
ROUTE_ID = [
    '17160',  # からつ号・博多→宝当桟橋
    '30290',  # からつ号・福岡空港→宝当桟橋
    '34900',  # いまり号・博多→伊万里
    '34920',  # いまり号・福岡空港→伊万里
    '32160',  # からつ号・博多→唐津城入口
]

# 系統番号<=>行先
ROUTE_DEST = {
    '17160' => '唐津（宝当桟橋）',
    '30290' => '唐津（宝当桟橋）',
    '34900' => '山本・北波多・伊万里',
    '34920' => '山本・北波多・伊万里',
    '32160' => '唐津（唐津城入口）',
}

# 停留所ID
STATION_ID = {
    'tenjin' => '3602370-00',  # 西鉄天神高速バスターミナル
    'hakata' => '3606002-00',  # 博多バスターミナル
    'fukdom' => '3606199-01',  # 福岡空港国内線
}

#
SERVICE_ID = {
    '3_平日' => 'weekday',
    '3_土曜' => 'saturday',
    '3_日祝' => 'holiday',
}


def makeJson(list, station)
    weekday  = []
    saturday = []
    holiday  = []

    list.each do |trip|
        # 系統番号=>行先
        route = ''
        dest = ''
        if (trip[0].match(/17160/))
            route = 'karatsu'
            dest = ROUTE_DEST['17160']
        elsif (trip[0].match(/30290/))
            route = 'karatsu'
            dest = ROUTE_DEST['30290']
        elsif (trip[0].match(/34900/))
            route = 'imari'
            dest = ROUTE_DEST['34900']
        elsif (trip[0].match(/34920/))
            route = 'imari'
            dest = ROUTE_DEST['34920']
        elsif (trip[0].match(/32160/))
            route = 'karatsu'
            dest = ROUTE_DEST['32160']
        else
        end

        trip_data = {
            "depTime" => trip[2],
            "route" => route,
            "dest" => dest
        }

        # 運行ダイヤ振り分け
        if (trip[0].match(/3_平日/))
            # weekday.push({trip[2], route, dest})
            weekday.push(trip_data)
        elsif (trip[0].match(/3_土曜/))
            # saturday.push({trip[2], route, dest})
            saturday.push(trip_data)
        elsif (trip[0].match(/3_日祝/))
            # holiday.push({trip[2], route, dest])
            holiday.push(trip_data)
        else
        end
    end

    # 出発時刻でソート
    weekday.sort_by! {|trip| trip['depTime']}
    saturday.sort_by! {|trip| trip['depTime']}
    holiday.sort_by! {|trip| trip['depTime']}

    # JSONファイル出力処理
    File.open('./json/' + station + '_weekday.json', 'w') { |file|
        file.puts(JSON.generate(weekday))
    }
    File.open('./json/' + station + '_saturday.json', 'w') { |file|
        file.puts(JSON.generate(saturday))
    }
    File.open('./json/' + station + '_holiday.json', 'w') { |file|
        file.puts(JSON.generate(holiday))
    }

end


# 運行便抽出
trip_list = []

CSV.foreach(__dir__ + '/' + DATA_DIR + TRIPS_FILE, liberal_parsing: true) do |row|
    if (ROUTE_ID.include?(row[2].slice(/\d{5}$/)))
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

# ダイヤ種別
exception_date = {
    'weekday'  => [],
    'saturday' => [],
    'holiday'  => [],
}

CSV.foreach(__dir__ + '/' + DATA_DIR + CALENDAR_FILE, liberal_parsing: true) do |row|
    if (SERVICE_ID.has_key?(row[0]))
        exception_date[SERVICE_ID[row[0]]].push(row[1])
    end
end

File.open('./json/exception_date.json', 'w') { |file|
    file.puts(JSON.generate(exception_date))
}
