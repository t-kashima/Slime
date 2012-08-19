

if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(
        function (pos) {
            $.post('/user_geo',
                   {
                       lat: pos.coords.latitude,
                       lon: pos.coords.longitude
                   },
                   function(res) {
                       if (res['json'] === undefined) {
                           alert(res);
                       } else {
                           for (var key in res['json']) {
                               var table = document.querySelector('table');
                               var user = res['json'][key];
                               table.innerHTML += '<tr><td>' + user.user_name + '</td><td>' + user.class + '</td><td>' +
                                   '<a href="/follow?id=' + user.user_name + '&class=' + user.class + '">touch</a></td>'
                           }
                       }

                   }
            );
            var location = '<li>latitude:' + pos.coords.latitude + '</li>';
            location += '<li>longitude:' + pos.coords.longitude + '</li>';
            var element_location = document.querySelector('#location');
            element_location.innerHTML = location;
        },
        function (error) {
            var message = "";

            switch (error.code) {
                // 位置情報が取得できない場合
            case error.POSITION_UNAVAILABLE:
                message = "位置情報の取得ができませんでした。";
                break;

                // Geolocationの使用が許可されない場合
            case error.PERMISSION_DENIED:
                message = "位置情報取得の使用許可がされませんでした。";
                break;
                // タイムアウトした場合
            case error.PERMISSION_DENIED_TIMEOUT:
                message = "位置情報取得中にタイムアウトしました。";
                break;
            }
            window.alert(message);
        }
    );
} else {
    window.alert('Can\'t use your Browser');
}

