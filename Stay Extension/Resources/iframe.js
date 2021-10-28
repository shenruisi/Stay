const $getQueryVariable = (variable) => {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
        if(pair[0] == variable){return pair[1];}
    }
    return "";
}

const $inject = (path) => {
    if (!path || path.length == 0) return;
    browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        browser.tabs.executeScript(tabs[0].id, { file: path, allFrames: true, runAt: "document_start"});
    });
};

let jsList = decodeURIComponent($getQueryVariable('js')).split(",");
console.log(jsList);
for (var i = 0; i < jsList.length; i++){
    $inject(jsList[i]);
}
document.querySelector("iframe").src = decodeURIComponent($getQueryVariable('url'));
                       

