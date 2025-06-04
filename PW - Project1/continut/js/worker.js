onmessage = function(e){
    var data = e.data;
    console.log("[worker] receive msg:", data);
    var result = data;
    postMessage(result);
};