<?php
// KaratsuImariTimer API v1

$SCHEDULE_FILE = [
    'tenjin' => [
        'weekday'  => './json/tenjin_weekday.json',
        'saturday' => './json/tenjin_saturday.json',
        'holiday'  => './json/tenjin_holiday.json'
    ],
    'hakata' => [
        'weekday'  => './json/hakata_weekday.json',
        'saturday' => './json/hakata_saturday.json',
        'holiday'  => './json/hakata_holiday.json'
    ],
    'fukdom' => [
        'weekday'  => './json/fukdom_weekday.json',
        'saturday' => './json/fukdom_saturday.json',
        'holiday'  => './json/fukdom_holiday.json'
    ]
];

$EXCEPTION_DATE_FILE = './json/exception_date.json';

$STATION_LIST = [
    'tenjin' => '西鉄天神高速バスターミナル【５番】',
    'hakata' => '博多バスターミナル【3F・32番】',
    'fukdom' => '福岡空港国内線【北・15番】'
];

$DIA_TYPE_LIST = [
    0 => 'holiday',
    1 => 'weekday',
    2 => 'weekday',
    3 => 'weekday',
    4 => 'weekday',
    5 => 'weekday',
    6 => 'saturday'
];

$DIA_TYPE_NAME = [
    'weekday'  => '平日',
    'saturday' => '土曜',
    'holiday'  => '日祝'
];

$ROUTE_NAME = [
    'karatsu' => 'からつ号',
    'imari'   => 'いまり号'
];


if (!isset($_GET['sta'])) {
    http_response_code(400);
    echo '[400] Invalid Parameter.';
    exit();
}


$response = [];

$response['station'] = $STATION_LIST[$_GET['sta']];


// ダイヤ種別判定
$now_time = new Datetime('now');

$exception_date_data = file_get_contents($EXCEPTION_DATE_FILE);
$exception_date = json_decode($exception_date_data, true);

date_default_timezone_set('Asia/Tokyo');

$dia_type = '';
foreach ($exception_date as $key => $date_list) {
    if (in_array($now_time->format('Ymd'), $date_list)) {
        $dia_type = $key;
    }
}
if (!$dia_type) {
    $dia_type = $DIA_TYPE_LIST[$now_time->format('w')];
}

$response['diaType'] = $dia_type;
$response['diaTypeName'] = $DIA_TYPE_NAME[$dia_type];


// 発車時刻データ抽出
$schedule_data = file_get_contents($SCHEDULE_FILE[$_GET['sta']][$dia_type]);
$schedule = json_decode($schedule_data, true);

$count = 0;
foreach ($schedule as $trip) {
    $dep_time = new Datetime($now_time->format('Y-m-d ').$trip['depTime']);

    if (($dep_time->format('U')) - ($now_time->format('U')) > 30) {
        $response['trips'][$count] = $trip;
        $response['trips'][$count]['depTime'] = $dep_time->format('Y/m/d H:i:s');
        $response['trips'][$count]['routeName'] = $ROUTE_NAME[$trip['route']];
        $count++;
    }
    if ($count > 4) {
        break;
    }
}

// 5件に満たない場合はNULLで埋める
if ($count < 5) {
    foreach (range($count, 4) as $i) {
        $response['trips'][$i] = NULL;
    }
}


http_response_code(200);
header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");

echo json_encode($response, JSON_UNESCAPED_UNICODE);

exit();
