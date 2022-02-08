//var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
//var browser = __b;
Date.prototype.dateFormat = function(fmt) {
    fmt = fmt ? fmt : "YYYY-mm-dd HH:MM:SS"
    if (!this || typeof this == "undefined") {
        return ""
    }
    let ret;
    const opt = {
        "Y+": this.getFullYear().toString(),        // 年
        "m+": (this.getMonth() + 1).toString(),     // 月
        "d+": this.getDate().toString(),            // 日
        "H+": this.getHours().toString(),           // 时
        "M+": this.getMinutes().toString(),         // 分
        "S+": this.getSeconds().toString()          // 秒
        // 有其他格式化字符需求可以继续添加，必须转化成字符串
    };
    for (let k in opt) {
        ret = new RegExp("(" + k + ")").exec(fmt);
        if (ret) {
            fmt = fmt.replace(ret[1], (ret[1].length == 1) ? (opt[k]) : (opt[k].padStart(ret[1].length, "0")))
        };
    };
    return fmt;
}
let matchAppScriptList=[];
let matchAppScriptConsole = [];
let gm_console = {};

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    
    if ("bootstrap" == request.from || "iframe" == request.from){
        if ("fetchScripts" == request.operate){
            console.log("background---fetchScripts request==", request);
            browser.runtime.sendNativeMessage("application.id", {type:request.operate}, function(response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("injectScript" == request.operate){
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                console.log("request.allFrames",request.allFrames);
                browser.tabs.executeScript(tabs[0].id, { code: request.code, allFrames: request.allFrames, runAt: request.runAt })
            });
            return true;
        }
        else if ("injectFile" == request.operate){
            console.log("background","injectFile",request.file);
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.executeScript(tabs[0].id, { file: request.file, allFrames: request.allFrames , runAt: request.runAt})
            });
            return true;
        }
        else if ("setMatchedScripts" == request.operate){
            matchAppScriptList = request.matchScripts;
            console.log("setMatchedScripts request.matchScripts=",request.matchScripts)
            return true;
        }
    }
    else if ("gm-apis" == request.from){
        if ("clear_GM_log" == request.operate){
            console.log("clear_GM_log, ", request);
            gm_console[request.uuid] = [];
        }
        if ("GM_error" == request.operate){
            console.log("gm-apis GM_error, from exect catch, ",request);
            if (!gm_console[request.uuid]) {
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "error", time: new Date().dateFormat()});
            console.log("GM_error=",gm_console);
        }
        if ("GM_log" == request.operate){
            console.log("gm-apis GM_log");
            if (!gm_console[request.uuid]){
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "log", time: new Date().dateFormat() });
            console.log("GM_log=",gm_console);
        }
        else if ("GM_getValue" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate, key:request.key, defaultValue:request.defaultValue, uuid:request.uuid}, function(response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_setValue" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate, key:request.key, value:request.value, uuid:request.uuid}, function(response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_deleteValue" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate, key:request.key, uuid:request.uuid}, function(response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_listValues" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate, uuid:request.uuid}, function(response) {
                sendResponse(response);
            });
            return true;
        }
    }
    else if ("popup" == request.from){
        console.log(request.from + " " + request.operate);
        if ("fetchLog" == request.operate){
            sendResponse({ body: gm_console });
        }
        else if ("cleanLog" == request.operate){
            gm_console = [];
        }else if ("fetchMatchedScriptList" == request.operate){
            console.log("fetchMatchedScriptList--",request,matchAppScriptList)
            browser.runtime.sendMessage({ from: "background", operate: "fetchMatchedScripts" }, (response) => {
                            matchAppScriptList = response.body;
                            console.log("fetchMatchedScriptList---fetchMatchedScripts--",response,"-res--", response.body)
                            sendResponse({ body: matchAppScriptList });
                        })
        }else if ("setScriptActive" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate, uuid:request.uuid,active: request.active }, function(response) {
                sendResponse(response);
            });
            
        }else if ("fetchMatchedScriptLog" == request.operate){
            if(matchAppScriptList && matchAppScriptList.length>0){
                if(matchAppScriptConsole.length>0){
                    matchAppScriptConsole = [];
                }
                matchAppScriptList.forEach(item=>{
                    let matchLog = {};
                    matchLog["name"] = item.name;
                    matchLog["uuid"] = item.uuid;
                    matchLog["logList"] = gm_console[item.uuid]
                    matchAppScriptConsole.push(matchLog);
                })
                console.log("fetchMatchedScriptLog=", matchAppScriptConsole);
                sendResponse({ body: matchAppScriptConsole });
            }else{
                sendResponse({ body: [] });
            }
        }
        else if ("fetchRegisterMenuCommand" == request.operate){
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from : "background", operate: "fetchRegisterMenuCommand"});
            });
        }
        else if ("execRegisterMenuCommand" == request.operate){
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from : "background", operate: "execRegisterMenuCommand", id:request.id, uuid:request.uuid});
            });
        }
        return true;
    }
});
