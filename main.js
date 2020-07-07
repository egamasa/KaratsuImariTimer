// APIアクセス
function selectSta(station) {
  dispLoad();
  depTimes = [];

  fetch(`https://bustimer.orangeliner.net/apiv1.php?sta=${station}`)
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
  document.getElementById('staName').innerHTML = json.station;

  let dia = ''
  if (json.diaType == 'weekday') {
    dia += '<span class="badge badge-success">';
  } else if (json.diaType == 'saturday') {
    dia += '<span class="badge badge-primary">';
  } else if (json.diaType == 'holiday') {
    dia += '<span class="badge badge-danger">';
  }
  document.getElementById('diaInfo').innerHTML = `${dia}${json.diaTypeName} ダイヤ</span>`;

  for (i = 0; i < json.trips.length; i++) {
    if (json.trips[i]) {
      let tripInfo = '';
      if (json.trips[i].route == 'karatsu') {
        tripInfo = '<h5><span class="badge badge-success">';
      } else if (json.trips[i].route == 'imari') {
        tripInfo = '<h5><span class="badge badge-warning">';
      }
      document.getElementById(`tripInfo${i}`).innerHTML = `${tripInfo}${json.trips[i].routeName}</span>&nbsp${json.trips[i].dest}</h5>`;

      let depTime = new Date(json.trips[i].depTime);
      document.getElementById(`tripDep${i}`).innerHTML = `${depTime.getHours()} : ${depTime.getMinutes().toString().padStart(2, '0')} 発`;

      depTimes[i] = json.trips[i].depTime;

    } else {
      document.getElementById(`tripInfo${i}`).innerHTML = 'データがありません';
      document.getElementById(`tripDep${i}`).innerHTML = '-- : --';
      document.getElementById(`tripTimer${i}`).innerHTML = '';
    }
  }

  dispSuccess();
  setInterval(calculateTime, 1000);
}

// カウントダウン
function calculateTime() {
  let currentTime = new Date();

  for (i = 0; i < depTimes.length; i++) {
    let departureTime = new Date(depTimes[i]);
    let remainTime = departureTime - currentTime;
    let outputElement = document.getElementById(`tripTimer${i}`);
    let oneDay = 24 * 60 * 60 * 1000;
    let h = 0;
    let m = 0;
    let s = 0;

    if (currentTime < departureTime) {
      h = Math.floor((remainTime % oneDay) / (60 * 60 * 1000));
      m = Math.floor((remainTime % oneDay) / (60 * 1000)) % 60;
      s = Math.floor((remainTime % oneDay) / 1000) % 60 % 60;

      if (h == 0) {
        outputElement.innerHTML = `あと ${m} 分 ${s} 秒`;
      } else {
        outputElement.innerHTML = `あと ${h} 時間 ${m} 分 ${s} 秒`;
      }
    } else {
      outputElement = '出発済み';
    }
  }
}


// 表示制御
function dispLoad() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('tripInfo').style.display = 'none';
  document.getElementById('loadingIcon').style.display = 'block';
  document.getElementById('fetchError').style.display = 'none';
  document.getElementById('trips').style.display = 'none';
  document.getElementById('tripTimer0').innerHTML = '読み込み中...';
  document.getElementById('tripTimer1').innerHTML = '読み込み中...';
  document.getElementById('tripTimer2').innerHTML = '読み込み中...';
}

function dispSuccess() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('tripInfo').style.display = 'block';
  document.getElementById('loadingIcon').style.display = 'none';
  document.getElementById('fetchError').style.display = 'none';
  document.getElementById('trips').style.display = 'block';
}

function dispError() {
  document.getElementById('initMsg').style.display = 'none';
  document.getElementById('tripInfo').style.display = 'none';
  document.getElementById('loadingIcon').style.display = 'none';
  document.getElementById('fetchError').style.display = 'block';
  document.getElementById('trips').style.display = 'none';
}
