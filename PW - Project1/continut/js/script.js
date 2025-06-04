var e_date, e_url, e_geo, e_browser, e_os;

var onload = function(){
    e_date = document.getElementById("current_date");
    e_url = document.getElementById("current_url");
    e_geo = document.getElementById("current_geo");
    e_browser = document.getElementById("current_browser");
    e_os = document.getElementById("current_os");

    update_date();
    setInterval(update_date, 1000);

    e_url.innerHTML = window.location.href;

    navigator.geolocation.getCurrentPosition(function(loc){
        e_geo.innerHTML = ("Latitudine (" + loc.coords.latitude + ") Longitudine: (" + loc.coords.longitude + ")" + " Meters (~" + loc.coords.accuracy + ")");
    }, function(){//error
        e_geo.innerHTML = "Nu ati permis accesul.";
    });

    var ua = navigator.userAgent;
    var os_ver = ua.split(" (")[1].split(";")[0];
	var browser_name = ua;
    e_browser.innerHTML = browser_name;
    e_os.innerHTML = os_ver;
};

var update_date = function(){
    var new_date = new Date();
    e_date.innerHTML = new_date;
};

var draw = function(ev){
    var canvas = ev.srcElement;
    var x = ev.offsetX, y = ev.offsetY;
    if (!draw.firstClickDone) {
        draw.firstX = x;
        draw.firstY = y;
    } else {
        var ctx = canvas.getContext("2d");
        ctx.fillStyle = (draw.chosenColor || "#000000");
        ctx.fillRect(draw.firstX, draw.firstY, x - draw.firstX, y - draw.firstY);
    }
    draw.firstClickDone = !draw.firstClickDone;
};

var input_color_callback = function(ev){
    var el = ev.target;
    var new_color = el.value;
    draw.chosenColor = new_color;
};

var add_table_row = function(ev) {
    var pozitie = parseInt(document.getElementById("what_row").value);
    var culoare = document.getElementById("what_row_bg").value;
    var text = document.getElementById("what_row_text").value;

    var tabel = document.getElementById("editable_table");
    var nrCol = tabel.rows[0].cells.length;
    var newRand = tabel.insertRow(pozitie);

    for (var i = 0; i < nrCol; i++) {
        var cell = newRand.insertCell(i);
        cell.innerHTML = text;
        cell.setAttribute("style", "background-color: " + culoare + ";");
    }
};

var add_table_col = function(ev) {
    var pozitie = parseInt(document.getElementById("what_row").value);
    var culoare = document.getElementById("what_row_bg").value;
    var text = document.getElementById("what_row_text").value;

    var tabel = document.getElementById("editable_table");

    for (var i = 0; i < tabel.rows.length; i++) {
        var rand = tabel.rows[i];
        var cell = rand.insertCell(pozitie);
        cell.innerHTML = text;
        cell.setAttribute("style", "background-color: " + culoare + ";");
    }
};


onload();