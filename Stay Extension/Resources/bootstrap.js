/**
 Main entrance of Stay
 1. Fetch inject scripts from SafariWebExtensionHandler
 2. Use @match, @include, @exclude to match the correct script with the url.
 
 content.js passing message to background.js or popup.js using browser.runtime.sendMessage.
 popup.js passing message to background.js using browser.runtime.sendMessage.
 background.js passing message to content.js using browser.tabs.sendMessage.
 popup.js passing message to content.js should sendMessage to background.js first.
 */
console.log("bootstrap inject");
var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;

let RMC_CONTEXT = [];
let id = "";

const $_res = (name) => {
    return browser.runtime.getURL(name);
}

const $_uri = (url) => {
    let a = document.createElement("a");
    a.href = url;
    return a;
}

//https://stackoverflow.com/questions/26246601/wildcard-string-comparison-in-javascript
//Short code
function matchRule(str, rule) {
  var escapeRegex = (str) => str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
  return new RegExp("^" + rule.split("*").map(escapeRegex).join(".*") + "$").test(str);
}


const $_matchesCheck = (userLibraryScript,url) => {
    let matched = false;
    let matchPatternInBlock;
    userLibraryScript.matches.forEach((match)=>{ //check matches
        let matchPattern = new window.MatchPattern(match);
        if (matchPattern.doMatch(url)){
            matched = true;
            matchPatternInBlock = matchPattern;
        }
    });
    if (matched){
        for (var i = 0; i < userLibraryScript.includes.length; i++){
            matched = matchRule(url.href, userLibraryScript.includes[i]);
            // console.log("matchRule",url.href,userLibraryScript.includes[i],matched);
            if (matched) break;
        }
        
        for (var i = 0; i < userLibraryScript.excludes.length; i++){
            matched = !matchRule(url.href, userLibraryScript.excludes[i]);
            if (!matched) break;
        }
        
    }
    return matched;
}

const $_injectRequiredInPage = (name,content) =>{
    console.log("require "+name+" inject page");
    if (document.readyState === "loading") {
        document.addEventListener("readystatechange", function() {
            if (document.readyState === "interactive") {
                var scriptTag = document.createElement('script');
                scriptTag.type = 'text/javascript';
                scriptTag.id = "Stay_Required_Inject_JS_"+name;
                scriptTag.appendChild(document.createTextNode(content));
                document.body.appendChild(scriptTag);
            }
        });
    } else {
        var scriptTag = document.createElement('script');
        scriptTag.type = 'text/javascript';
        scriptTag.id = "Stay_Required_Inject_JS_"+name;
        scriptTag.appendChild(document.createTextNode(content));
        document.body.appendChild(scriptTag);
    }
}

const $_injectInPage = (script) => {
    console.log("inject page");
    var scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.id = "Stay_Inject_JS_"+script.uuid;
    scriptTag.appendChild(document.createTextNode(script.content));
    document.body.appendChild(scriptTag);
}

const $_injectInPageWithTiming = (script, runAt) => {
    if (runAt === "document_start") {
        if (document.readyState === "loading") {
            document.addEventListener("readystatechange", function() {
                if (document.readyState === "interactive") {
                    $_injectInPage(script);
                }
            });
        } else {
            $_injectInPage(script);
        }
    } else if (runAt === "document_end") {
        if (document.readyState !== "loading") {
            $_injectInPage(script);
        } else {
            document.addEventListener("DOMContentLoaded", function() {
                $_injectInPage(script);
            });
        }
    } else if (runAt === "document_idle" || runAt === "document_body") {
        if (document.readyState === "complete") {
            $_injectInPage(script);
        } else {
            document.addEventListener("readystatechange", function(e) {
                if (document.readyState === "complete") {
                    $_injectInPage(script);
                }
            });
        }
    }
}

let matchedScripts;
(function(){
    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        let operate = request.operate;
        if (request.from == "background" && "fetchRegisterMenuCommand" === operate) {
            browser.runtime.sendMessage({ from: "content", data: RMC_CONTEXT, uuid: id, operate: "giveRegisterMenuCommand" });
        }
        else if (request.from == "background" && "execRegisterMenuCommand" === operate && request.uuid == id) {
            let menuId = request.id; 
            window.postMessage({ name: "execRegisterMenuCommand", menuId: menuId, id: id });
        }
        else if (request.from == "background" && "exeScriptManually" === operate){
            let targetScript;
            for (var i=0; i < matchedScripts.length; i++){
                if (matchedScripts[i].uuid == request.uuid){
                    targetScript = matchedScripts[i];
                    break;
                }
            }
            
            if (targetScript){
                if (targetScript.requireUrls.length > 0){
                    targetScript.requireUrls.forEach((url)=>{
                        if (injectedVendor.has(url)) return;
                        injectedVendor.add(url);
                        if (url.startsWith('stay://')){
                            browser.runtime.sendMessage({
                                from: "bootstrap",
                                operate: "injectFile",
                                file:$_res($_uri(url).pathname.substring(1)),
                                allFrames:true,
                                runAt:"document_start"
                            });
                        }
                        else{
                            var pageInject = script.installType === "page";
                            console.log("pageInject---",pageInject)
                            targetScript.requireCodes.forEach((urlCodeDic)=>{
                                if (urlCodeDic.url == url){
                                    if (pageInject){
                                        $_injectRequiredInPage(urlCodeDic.name,urlCodeDic.code);
                                    }
                                    else{
                                        browser.runtime.sendMessage({
                                            from: "bootstrap",
                                            operate: "injectScript",
                                            code:urlCodeDic.code,
                                            allFrames:true,
                                            runAt:"document_start"
                                        });
                                    }
                                    
                                }
                            });
                        }
                    });
                }
                
                if (targetScript.installType === "page"){
                    console.log("Manually page inject");
                    $_injectInPageWithTiming(targetScript,"document_start");
                }
                else{
                    console.log("Manually content inject");
                    browser.runtime.sendMessage({
                        from: "bootstrap",
                        operate: "injectScript",
                        code:targetScript.content,
                        allFrames:!targetScript.noFrames,
                        runAt:"document_start"
                    });
                }
            }
        }
        else if (operate.startsWith("RESP_API_XHR_BG_")) {
            // only respond to messages on the correct content script
            if (request.id !== id) return;
            const resp = request.response;
            const name = operate.replace("_BG_", "_TO_CREATE_");
            // arraybuffer responses had their data converted, convert it back to arraybuffer
            if (request.response.responseType === "arraybuffer" && resp.response) {
                try {
                    const r = new Uint8Array(resp.response).buffer;
                    resp.response = r;
                } catch (error) {
                    console.error("error parsing xhr arraybuffer response", error);
                }
                // blob responses had their data converted, convert it back to blob
            } else if (request.response.responseType === "blob" && resp.response && resp.response.data) {
                fetch(request.response.response.data)
                    .then(res => res.blob())
                    .then(b => {
                        resp.response = b;
                        window.postMessage({ name: name, response: resp, id: request.id, xhrId: request.xhrId });
                    });
            }
            // blob response will execute its own postMessage call
            if (request.response.responseType !== "blob") {
                window.postMessage({ name: name, response: resp, id: request.id, xhrId: request.xhrId });
            }
        }
        return true;
    });
    
    browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts", url: location.href, digest: "no"}, (response) => {
        let injectedVendor = new Set();
//        let userLibraryScripts = response.body; //JSON.parse(response.body);
//        console.log("response",response.body);
//        let injectScripts = [];
//        userLibraryScripts.forEach((userLibraryScript)=>{
//            console.log("script from library",userLibraryScript);
//            try {
//                if ($_matchesCheck(userLibraryScript,new URL(location.href))){
//                    console.log("userLibraryScript-", userLibraryScript)
//                    injectScripts.push(userLibraryScript);
//                }
//
//            } catch (error) {
//                console.error("￥_matchesCheck-----error", error)
//            }
//        });
        
        matchedScripts = response.body;
        
        console.log("matchedScripts-", matchedScripts)
        matchedScripts.forEach((script) => {
            if (script.requireUrls.length > 0 && script.active){
                script.requireUrls.forEach((url)=>{
                    if (injectedVendor.has(url)) return;
                    injectedVendor.add(url);
                    if (url.startsWith('stay://')){
                        browser.runtime.sendMessage({
                            from: "bootstrap",
                            operate: "injectFile",
                            file:$_res($_uri(url).pathname.substring(1)),
                            allFrames:true,
                            runAt:"document_start"
                        });
                    }
                    else{
                        var pageInject = script.installType === "page";
                        console.log("pageInject---",pageInject)
                        script.requireCodes.forEach((urlCodeDic)=>{
                            if (urlCodeDic.url == url){
                                if (pageInject){
                                    $_injectRequiredInPage(urlCodeDic.name,urlCodeDic.code);
                                }
                                else{
                                    browser.runtime.sendMessage({
                                        from: "bootstrap",
                                        operate: "injectScript",
                                        code:urlCodeDic.code,
                                        allFrames:true,
                                        runAt:"document_start"
                                    });
                                }
                                
                            }
                        });
                    }
                });
            }
            
            if (script.active){ //inject active script
                console.log("injectScript---",script.content);
                if (script.installType === "page"){
                    $_injectInPageWithTiming(script,"document_"+script.runAt);
                }
                else{
                    browser.runtime.sendMessage({
                        from: "bootstrap",
                        operate: "injectScript",
                        code:script.content,
                        allFrames:!script.noFrames,
                        runAt:"document_"+script.runAt
                    });
                }
                
            }
        });
    });
    window.addEventListener('message', (e) => {
        if (!e || !e.data || !e.data.name) return;
        id = e.data.id;
        const name = e.data.name;
        const pid = e.data.pid;
        let message = { from: "gm-apis", uuid: id };
        if (name === "API_LIST_VALUES") {
            message.operate = "GM_listValues";
            browser.runtime.sendMessage(message, (response) => {
                window.postMessage({ id: id, pid: pid, name: "RESP_LIST_VALUES", response: response });
            });

        }
        else if (name === "API_DELETE_VALUE") {
            message.operate = "GM_deleteValue";
            message.key = e.data.key;
            browser.runtime.sendMessage(message, (response) => {
                window.postMessage({ id: id, pid: pid, name: "RESP_DELETE_VALUE", response: response });
            });
        }
        else if ("API_LOG" === name) {
            message.message = e.data.message;
            message.operate = "GM_log";
            browser.runtime.sendMessage(message, (response) => {
                response.message = message;
                window.postMessage({ id: id, pid: pid, name: "RESP_LOG", response: response });
            });
        }
        else if ("API_CLEAR_LOG" === name) {
            message.operate = "clear_GM_log";
            browser.runtime.sendMessage(message);
        }
        else if ("REGISTER_MENU_COMMAND_CONTEXT" === name){
            let RMC_CONTEXT_STR = e.data.rmc_context;
            if (RMC_CONTEXT_STR && RMC_CONTEXT_STR != "[]"){
                RMC_CONTEXT = JSON.parse(RMC_CONTEXT_STR);
            }
        }
        else if ("UNREGISTER_MENU_COMMAND_CONTEXT" === name) {
            let RMC_CONTEXT_STR = e.data.rmc_context;
            if (RMC_CONTEXT_STR && RMC_CONTEXT_STR != "[]") {
                RMC_CONTEXT = JSON.parse(RMC_CONTEXT_STR);
            }
        }
        else if ("BROWSER_ADD_LISTENER" === name) {
            
        }
        else if (name === "API_ADD_STYLE") {
            try {
                message.operate = "API_ADD_STYLE";
                message.css = e.data.css;
                browser.runtime.sendMessage(message, response => {
                    window.postMessage({ id: id, pid: pid, name: "RESP_ADD_STYLE", response: response });
                });
            } catch (e) {
                console.log(e);
            }
        } else if (name === "API_ADD_STYLE_SYNC") {
            try {
                message.operate = "API_ADD_STYLE_SYNC";
                message.css = e.data.css;
                browser.runtime.sendMessage(message);
            } catch (e) {
                console.log(e);
            }
        }
        else if (name === "API_SET_VALUE" || name === "API_SET_VALUE_SYNC") {
            message.operate = "GM_setValue";
            message.key = e.data.key;
            message.value = e.data.value;
            browser.runtime.sendMessage(message, response => {
                if (name === "API_SET_VALUE") {
                    window.postMessage({ id: id, pid: pid, name: "RESP_SET_VALUE", response: response });
                }
            });
        }
        else if (name === "API_GET_VALUE" || name === "API_GET_VALUE_SYNC") {
            message.operate = "GM_getValue";
            message.defaultValue = e.data.defaultValue;
            message.key = e.data.key;
            browser.runtime.sendMessage(message, response => {
                const resp = response === `undefined` ? undefined : response;
                if (name === "API_GET_VALUE") {
                    window.postMessage({ id: id, pid: pid, name: "RESP_GET_VALUE", response: resp });
                }
            });
        }
        else if ("API_GET_ALL_REXOURCE_TEXT" === name) {
            message.operate = "GM_getAllResourceText";
            browser.runtime.sendMessage(message, (response) => {
                console.log("API_GET_ALL_REXOURCE_TEXT---", response);
                window.postMessage({ id: id, pid: pid, name: "RESP_GET_ALL_REXOURCE_TEXT", response: response });
            });
        }
        else if ("API_GET_REXOURCE_TEXT_SYNC" === name || "API_GET_REXOURCE_TEXT" === name) {
            message.operate = "GM_getResourceText";
            browser.runtime.sendMessage(message, (response) => {
                console.log("API_GET_REXOURCE_TEXT_SYNC---", response);
                if ("API_GET_REXOURCE_TEXT" === name) {
                    window.postMessage({ id: id, pid: pid, name: "RESP_GET_REXOURCE_TEXT", response: response });
                }
            });
        }
        else if ("API_GET_REXOURCE_URL" === name || "API_GET_REXOURCE_URL_SYNC" === name) {
            message.operate = "GM_getResourceUrl";
            message.key = e.data.key;
            browser.runtime.sendMessage(message, (response) => {
                console.log("API_GET_REXOURCE_TEXT_SYNC---", response);
                if ("API_GET_REXOURCE_URL" === name) {
                    window.postMessage({ id: id, pid: pid, name: "RESP_GET_REXOURCE_URL", response: response });
                }
            });
        }
        else if ("API_CLOSE_TAB" === name) {
            var tabId = e.data.tabId;
            message.tabId = tabId;
            message.operate = "closeTab";
            browser.runtime.sendMessage(message, (resp)=>{
                window.postMessage({ id: id, pid: pid, name: "RESP_CLOSE_TAB", response: resp });
            });
        }
        else if ("API_OPEN_IN_TAB" === name) {
            var url = e.data.url;
            var options = e.data.options;
            message.operate = "openInTab";
            message.options = options ? JSON.parse(options):{};
            message.url = url;
            browser.runtime.sendMessage(message, (response)=>{
                tabId = response.tabId;
                window.postMessage({ id: id, pid: pid, name: "RESP_OPEN_IN_TAB", tabId: tabId });
            });
        }
        else if (name === "API_XHR_FROM_CREATE") {
            message.operate = "API_XHR_FROM_BOOTSTRAP";
            message.details = JSON.parse(e.data.details)
            message.xhrId = e.data.xhrId
            browser.runtime.sendMessage(message);
        } else if (name === "API_XHR_ABORT_INJ_FROM_CREATE") {
            message.operate = "API_XHR_ABORT_FROM_BOOTSTRAP";
            message.xhrId = e.data.xhrId
            browser.runtime.sendMessage(message);
        }
    })
    
})();

//start();
