//var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
//var browser = __b;

let matchAppScriptList=[];
let gm_console = {};
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    if ("popup" == request.from && "fetchAppList" == request.operate){
//        sendResponse({ body: appJumpList });
//    }
//    else if ("content" == request.from && "saveAppList" == request.operate){
//        appJumpList = request.data;
//        console.log("appJumpList",appJumpList);
//    }
    
    if ("bootstrap" == request.from){
        if ("fetchScripts" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate}, function(response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("injectScript" == request.operate){
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.executeScript(tabs[0].id, { code: request.code, allFrames: request.allFrames, runAt: request.runAt })
            });
            return true;
        }
        else if ("injectFile" == request.operate){
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.executeScript(tabs[0].id, { file: request.file, allFrames: request.allFrames, runAt: request.runAt })
            });
            return true;
        }
        else if ("setMatchScripts" == request.operate){
            matchAppScriptList = request.matchScripts;
            return true;
        }
    }
    else if ("gm-apis" == request.from){
        if ("GM_log" == request.operate){
            if (gm_console[request.uuid] == null){
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push(request.message);
            console.log(gm_console);
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
        }else if ("fetchMatchScriptList" == request.operate){
            sendResponse({ body: matchAppScriptList });
        }else if ("setScriptActive" == request.operate){
            browser.runtime.sendNativeMessage("application.id", {type:request.operate}, function(response) {
                sendResponse(response);
            });
            
        }
        return true;
    }
    
});
