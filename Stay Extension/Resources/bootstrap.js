var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;

const $_res = (name) => {
    return browser.runtime.getURL(name);
}

const $_uri = (url) => {
    let a = document.createElement("a");
    a.href = url;
    return a;
}

var __stay = {};

//function GM_listValues(){
//    return new Promise((resolve,reject) => {
//        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid:"123" }, (response) => {
//            resolve(response.body);
//        });
//    });
//}
//
//function GM_deleteValue(key){
//    return new Promise((resolve,reject) => {
//        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid:"123" }, (response) => {
//            resolve(response.body);
//        });
//    });
//}
//
//function GM_setValue(key,value){
//    return new Promise((resolve,reject) => {
//        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid:"123" }, (response) => {
//            resolve(response.body);
//        });
//    });
//}
//
//function GM_getValue(key,defaultValue){
//    return new Promise((resolve,reject) => {
//        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid:"123" }, (response) => {
//            resolve(response.body);
//        });
//    });
//}
//async function f1() {
//    await GM_setValue("foo",{a:1,b:2});
//    await GM_getValue("foo","1");
//    await GM_listValues();
//    await GM_deleteValue("foo");
//    var a = await GM_getValue("foo");
//    console.log(a);
////    console.log(b);
//}
//
//f1();

async function start(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts" }, (response) => {
        let injectedVendor = new Set();
        let activeScripts = JSON.parse(response.body);
        let injectScripts = [];
        activeScripts.forEach((activeScript)=>{
            console.log(activeScript);
            activeScript.matches.forEach((match)=>{
                let matchPattern = new window.MatchPattern(match);
                if (matchPattern.doMatch(new URL(location.href))){
                    injectScripts.push(activeScript);
                }
            });
        });
        
        injectScripts.forEach((script) => {
            if (script.requireUrls.length > 0){
                script.requireUrls.forEach((url)=>{
                    if (injectedVendor.has(url)) return;
                    injectedVendor.add(url);
                    browser.runtime.sendMessage({
                        from: "bootstrap",
                        operate: "injectFile",
                        file:$_res($_uri(url).pathname.substring(1)),
                        allFrames:true,
                        runAt:"document_start"
                    });
                    
                });
            }
            browser.runtime.sendMessage({
                from: "bootstrap",
                operate: "injectScript",
                code:script.content,
                allFrames:!script.noFrames,
                runAt:"document_"+script.runAt
            });
        });
        
        console.log(injectScripts);
        
    });
}

start();
