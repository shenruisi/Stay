//var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
//var browser = __b;

let matchAppScriptList=[];
let matchAppScriptConsole = [];
let gm_console = {};
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    if ("popup" == request.from && "fetchAppList" == request.operate){
//        sendResponse({ body: appJumpList });
//    }
//    else if ("content" == request.from && "saveAppList" == request.operate){
//        appJumpList = request.data;
//        console.log("appJumpList",appJumpList);
//    }
    
    if ("bootstrap" == request.from || "iframe" == request.from){
        if ("fetchScripts" == request.operate){
            console.log("background","fetchScripts");
            browser.runtime.sendNativeMessage("application.id", {type:request.operate}, function(response) {
                console.log("background","fetchScripts",response);
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
            return true;
        }
    }
    else if ("gm-apis" == request.from){
        if ("GM_error" == request.operate){
            console.log("gm-apis GM_error, from exect catch, ",request);
            if (gm_console[request.uuid] == null){
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "error"});
            console.log("GM_error=",gm_console);
        }
        if ("GM_log" == request.operate){
            console.log("gm-apis GM_log");
            if (gm_console[request.uuid] == null){
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "log" });
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
        if ("fetchLog" == request.operate){
            sendResponse({ body: gm_console });
        }
        else if ("cleanLog" == request.operate){
            gm_console = [];
        }else if ("fetchMatchedScriptList" == request.operate){
            sendResponse({ body: matchAppScriptList });
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
        return true;
    }
    
});
