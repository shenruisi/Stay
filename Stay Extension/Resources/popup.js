var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;





//var chrome = browser || chrome;
//console.log("popup",browser);

const $setText = (selector,value) => {
    document.querySelector(selector).textContent = value;
};

//var browser = __b;
//var chrome = __b;
window.addEventListener('DOMContentLoaded', () => {
    
    
    
    document.querySelector(".placeholder").style.display = "block";
    document.querySelector(".tableview").style.display = "none";
    browser.runtime.sendMessage({ from: "popup", operate: "fetchAppList" },(response)=>{
        if (response.body.length > 0){
            document.querySelector(".placeholder").style.display = "none";
            document.querySelector(".tableview").style.display = "block";
            let app = response.body[0];
            $setText(".title",app.title);
            console.log("title",app.title);
            document.querySelector(".icon").src = app.icon;
            if (app.url.length){
                document.querySelector(".cell").addEventListener("click",function (event) {
                    window.open(app.url);
                });
            }
        }
    });
//    browser.runtime.sendMessage({ from: "popup", operate: "fetchAppList" }).then((response) => {
//        if (response.body.length > 0){
//            document.querySelector(".placeholder").style.display = "none";
//            document.querySelector(".tableview").style.display = "block";
//            let app = response.body[0];
//            $setText(".title",app.title);
//            console.log("title",app.title);
//            document.querySelector(".icon").src = app.icon;
//            if (app.url.length){
//                document.querySelector(".cell").addEventListener("click",function (event) {
//                    window.open(app.url);
//                });
//            }
//        }
//    });
});
