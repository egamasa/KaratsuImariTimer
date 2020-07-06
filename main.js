// APIアクセス
function selectedDep(value) {
  dispLoad();

  // fetch('https://bustimer.orangeliner.net/apiv1.php?dep=' + value.toString())
  fetch('https://bustimer.orangeliner.net/api_dev.php?dep=' + value.toString())
    .then(function(response) {
      return response.json();
    })
    .then(function(data) {
      loadSuccess(data);
    })
    .catch(function(err) {
      dispError();
    });
}

// 取得データ表示
function loadSuccess(json) {
    document.getElementById('depName').innerHTML = json.dep;

    let diaDay = ''
    if (json.day == '平日') {
      diaDay += '<span class="badge badge-success">';
    } else if (json.day == '土曜') {
      diaDay += '<span class="badge badge-primary">';
    } else if (json.day == '日祝') {
      diaDay += '<span class="badge badge-danger">';
    }
    document.getElementById('day').innerHTML = diaDay + json.day + ' ダイヤ </span>';

    for (i = 0; i < json.trip.length; i++) {
      if (json.trip[i]) {
        let tripFor = '';
        if (json.trip[i].route == 'karatsu') {
          tripFor = '<h5><span class="badge badge-success">からつ</span>';
        } else if (json.trip[i].route == 'imari') {
          tripFor = '<h5><span class="badge badge-warning">いまり</span>';
        }
        document.getElementById("tripInfo" + i).innerHTML = tripFor + '&nbsp' + json.trip[i].for + '</h5>';

        let depTime = new Date(json.trip[i].time);
        document.getElementById("tripDep" + i).innerHTML = depTime.getHours() + ' : ' + depTime.getMinutes() + ' 発';

        let myTimer = new Timer(json.trip[i].time, 'tripTimer' + i);
        myTimer.countDown();

      } else {
        document.getElementById("tripInfo" + i).innerHTML = 'データがありません';
        document.getElementById("tripDep" + i).innerHTML = '-- : --';
      }
    }

    dispSuccess();
}

// カウントダウン
let Timer = function(depTime, outputElement) {
  this.depTime = depTime;
  this.outputElement = outputElement;
};

Timer.prototype.countDown = function() {
  let depTime = new Date(this.depTime);
  let oneDay = 24 * 60 * 60 * 1000;
  let countDownTimer = document.getElementById(this.outputElement);
  let currentTimeCD = new Date();
  let untilStartTime = new Date();
  let h = 0;
  let m = 0;
  let s = 0;

  setInterval(calculateTime, 1000);

  function calculateTime() {
    currentTimeCD = new Date();
    untilStartTime = depTime - currentTimeCD;

    if (currentTimeCD < depTime) {
      h = Math.floor((untilStartTime % oneDay) / (60 * 60 * 1000));
      m = Math.floor((untilStartTime % oneDay) / (60 * 1000)) % 60;
      s = Math.floor((untilStartTime % oneDay) / 1000) % 60 % 60;
    }

    showTime();
  }

  function showTime() {
    if (currentTimeCD < depTime) {
      countDownTimer.innerHTML = 'あと ' + h + ' 時間 ' + m + ' 分 ' + s + ' 秒';
    } else {
      countDownTimer.innerHTML = '出発済み';
    }
  }
}

// 表示制御
function dispLoad() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('depInfo').style.display = 'none';
  document.getElementById('loadingIcon').style.display = 'block';
  document.getElementById('fetchError').style.display = 'none';
  document.getElementById('trips').style.display = 'none';
}

function dispSuccess() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('depInfo').style.display = 'block';
  document.getElementById('loadingIcon').style.display = 'none';
  document.getElementById('fetchError').style.display = 'none';
  document.getElementById('trips').style.display = 'block';
}

function dispError() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('depInfo').style.display = 'none';
  document.getElementById('loadingIcon').style.display = 'none';
  document.getElementById('fetchError').style.display = 'block';
  document.getElementById('trips').style.display = 'none';
}
