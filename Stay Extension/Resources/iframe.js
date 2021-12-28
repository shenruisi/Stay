/**
 Extension internal iframe, prevent from app jumping.
 */
const $_res = (name) => {
    return browser.runtime.getURL(name);
}

const $getQueryVariable = (variable) => {
    console.log("getQueryVariable");
    var query = window.location.search.substring(1);
    console.log(query);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
        if(pair[0] == variable){console.log("find url",pair[1]); return pair[1];}
    }
    return "";
}


document.querySelector("iframe").src = decodeURIComponent($getQueryVariable('url'));
