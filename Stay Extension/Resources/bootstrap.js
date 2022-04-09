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
        if (userLibraryScript.includes.length > 0){
            userLibraryScript.includes.forEach((include)=>{
                if (matchPatternInBlock.doMatch(include)) {
                    matched = matchRule(url.href, include);
                }
            });
        }
        
        userLibraryScript.excludes.forEach((exclude)=>{
            if (matchPatternInBlock.doMatch(exclude)) {
                matched = !matchRule(url.href, exclude);
            }
        });
    }
    
    return matched;
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
    } else if (runAt === "document_idle") {
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

//let injectScripts = []
(function(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts" }, (response) => {
        let injectedVendor = new Set();
        let userLibraryScripts = JSON.parse(response.body);
        let injectScripts = [];
        userLibraryScripts.forEach((userLibraryScript)=>{
            console.log(userLibraryScript);
            
            if ($_matchesCheck(userLibraryScript,new URL(location.href))){
                injectScripts.push(userLibraryScript);
            }
        });
        
        injectScripts.forEach((script) => {
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
                        script.requireCodes.forEach((urlCodeDic)=>{
                            if (urlCodeDic.url == url){
                                browser.runtime.sendMessage({
                                    from: "bootstrap",
                                    operate: "injectScript",
                                    code:urlCodeDic.code,
                                    allFrames:true,
                                    runAt:"document_start"
                                });
                            }
                        });
                    }
                });
            }
            
            if (script.active){ //inject active script
                console.log("injectScript",script.content);
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
                
        browser.runtime.sendMessage({
            from: "bootstrap",
            operate: "setMatchedScripts",
            matchScripts: injectScripts
        });
    });
    window.addEventListener('message', (e) => {
        if (!e || !e.data || !e.data.name) return;
        const id = e.data.id;
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
        else if ("BROWSER_ADD_LISTENER" === name) {
            let __RMC_CONTEXT = e.data.rmc_context;
            browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
                if (request.from == "background" && request.operate == "fetchRegisterMenuCommand") {
                    browser.runtime.sendMessage({ from: "content", data: __RMC_CONTEXT, uuid: _uuid, operate: "giveRegisterMenuCommand" });
                }
                else if (request.from == "background" && request.operate == "execRegisterMenuCommand" && request.uuid == _uuid) {
                    console.log(__RMC_CONTEXT[request.id]);
                    __RMC_CONTEXT[request.id]["commandFunc"]();
                }
                else if (request.operate.startsWith("RESP_API_XHR_BG_")) {
                    // only respond to messages on the correct content script
                    if (request.id !== uid) return;
                    const resp = request.response;
                    const n = name.replace("_BG_", "_CS_");
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
                                window.postMessage({ name: n, response: resp, id: request.id, xhrId: request.xhrId });
                            });
                    }
                    // blob response will execute its own postMessage call
                    if (request.response.responseType !== "blob") {
                        window.postMessage({ name: n, response: resp, id: request.id, xhrId: request.xhrId });
                    }
                }
                return true;
            });
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
                const resp = response === `undefined--${pid}` ? undefined : response;
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
        else if ("API_OPEN_IN_TAB" === name) {
            var url = e.data.url;
            var options = e.data.options;
            var tabId = null;
            var close = function () {
                if (tabId === null) {
                    // re-schedule, cause tabId is null
                    window.setTimeout(close, 500);
                } else if (tabId > 0) {
                    browser.runtime.sendMessage({ from: "gm-apis", operate: "closeTab", tabId: tabId, id: _uuid }, resp);
                    tabId = undefined;
                } else {
                    console.log("env: attempt to close already closed tab!");
                }
            };
            var resp = function (response) {
                // console.log("GM_openInTab response---", response)
                tabId = response.tabId;
                response.close = close;
                window.postMessage({ id: id, pid: pid, name: "RESP_OPEN_IN_TAB", response: response });
            };
            if (url && url.search(/^\/\//) == 0) {
                url = location.protocol + url;
            }
            message.operate = "openInTab";
            message.options = options;
            browser.runtime.sendMessage(message, resp);
        }
        else if (name === "API_XHR_INJ") {
            message.operate = "API_XHR_CS";
            message.detail = e.data.details
            message.xhrId = e.data.xhrId
            browser.runtime.sendMessage(message, response => {
                window.postMessage({ id: id, name: "RESP_API_XHR_CS", response: response, xhrId: e.data.xhrId });
            });
        } else if (name === "API_XHR_ABORT_INJ") {
            message.operate = "API_XHR_ABORT_CS";
            message.xhrId = e.data.xhrId
            browser.runtime.sendMessage(message);
        }
        else if (name.startsWith("RESP_API_XHR_BG_")) {
            // only respond to messages on the correct content script
            if (request.id !== uid) return;
            const resp = request.response;
            const n = name.replace("_BG_", "_CS_");
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
                        window.postMessage({ name: n, response: resp, id: request.id, xhrId: request.xhrId });
                    });
            }
            // blob response will execute its own postMessage call
            if (request.response.responseType !== "blob") {
                window.postMessage({ name: n, response: resp, id: request.id, xhrId: request.xhrId });
            }
        }

    })
    
})();

//start();
