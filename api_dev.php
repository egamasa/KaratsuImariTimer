<?php
// 開発用APIモック（固定値出力）

$DEP_LIST = [
    'tenjin' => '西鉄天神高速バスターミナル【５番】',
    'hakata' => '博多バスターミナル【3F・32番】',
    'fukdom' => '福岡空港国内線【北・15番】'
];

$DAY_LIST = [
    'weekday'  => '平日',
    'saturday' => '土曜',
    'holiday'  => '日祝'
];

if (!isset($_GET['dep'])) {
    http_response_code(400);
    echo '[400] Invalid Parameter.';
    exit();
}

$day = array_rand($DAY_LIST);


$json = [];
$json['dep'] = $DEP_LIST[$_GET['dep']];
$json['day'] = $DAY_LIST[$day];

$json['trip'] = [
    [
        'route' => 'karatsu',
        'for'   => '唐津（宝当桟橋）',
        'time'  => '2020/07/06 20:45:00'
    ],
    [
        'route' => 'imari',
        'for'   => '山本・北波多・伊万里',
        'time'  => '2020/07/06 21:15:00'
    ],
    null
];

http_response_code(200);
header('Content-Type: application/json; charset=UTF-8');
header("Access-Control-Allow-Origin: *");

echo json_encode($json, JSON_UNESCAPED_UNICODE);

exit();
