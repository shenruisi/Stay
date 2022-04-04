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
let closeableTabs = {};

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
        else if ("unsafeWindow" == request.operate){
            console.log("unsafeWindow bg-----", window.__restart_confirm_timeout, ",----", window._WWW_SRV_T);
            sendResponse({ unsafeWindow: window });
            return true;
        }
        else if ("GM_xmlhttpRequest" == request.operate){
            let params = request.params
            let xhr = new XMLHttpRequest();
            var createState = function () {
                var rh = '';
                var fu = params.url;
                if (xhr.readyState > 2) {
                    rh = xhr.getAllResponseHeaders();
                    if (xhr.readyState == 4) {
                        if (rh) {
                            rh = rh.replace(/TM-finalURL\: .*[\r\n]{1,2}/, '');
                        }
                        var fi = xhr.getResponseHeader('TM-finalURL');
                        if (fi) fu = fi;
                    }
                }
                var o = {
                    readyState: xhr.readyState,
                    responseHeaders: rh,
                    finalUrl: fu,
                    status: (xhr.readyState == 4 ? xhr.status : 0),
                    statusText: (xhr.readyState == 4 ? xhr.statusText : '')
                };
                if (xhr.readyState == 4) {
                    if (!xhr.responseType || xhr.responseType == '') {
                        o.responseXML = (xhr.responseXML ? escape(xhr.responseXML) : null);
                        o.responseText = xhr.responseText;
                        o.response = xhr.response;
                    } else {
                        o.responseXML = null;
                        o.responseText = null;
                        o.response = xhr.response;
                    }
                } else {
                    o.responseXML = null;
                    o.responseText = '';
                    o.response = null;
                }
                return o;
            };
            var onload = function () {
                var responseState = createState();
                if (responseState.readyState == 4 &&
                    responseState.status != 200 &&
                    responseState.status != 0 ) {
                    console.log('api_create: error at onload, should not happen! -> retry :)')
                    return;
                }
                sendResponse({ onload: responseState });
            };
            var onerror = function () {
                var responseState = createState();
                if (responseState.readyState == 4 &&
                    responseState.status != 200 &&
                    responseState.status != 0) {
                    console.log('api_create: error at onerror, should not happen! -> retry')
                    sendResponse({ onerror: responseState });
                }
               
            };

            var onreadystatechange = function (c) {
                var responseState = createState();
                let onreadychange = params.onreadystatechange;
                if (onreadychange) {
                    try {
                        if (c.lengthComputable || c.totalSize > 0) {
                            responseState.progress = { total: c.total, totalSize: c.totalSize };
                        } else {
                            var t = Number(getStringBetweenTags(responseState.responseHeaders, 'Content-Length:', '\n').trim());
                            // var t = 2;
                            var l = xhr.responseText ? xhr.responseText.length : 0;
                            if (t > 0) {
                                responseState.progress = { total: l, totalSize: t };
                            }
                        }
                    } catch (e) { }
                    onreadychange(responseState);
                    sendResponse({ onreadystatechange: responseState })
                }
            };

            var getStringBetweenTags = function (source, tag1, tag2) {
                var b = source.search(escapeForRegExp(tag1));
                if (b == -1) {
                    return '';
                }
                if (!tag2) {
                    return source.substr(b + tag1.length);
                }
                var e = source.substr(b + tag1.length).search(escapeForRegExp(tag2));

                if (e == -1) {
                    return '';
                }
                return source.substr(b + tag1.length, e);
            };
            var escapeForRegExpURL = function (str, more) {
                if (more == undefined) more = [];
                var re = new RegExp('(\\' + ['/', '.', '+', '?', '|', '(', ')', '[', ']', '{', '}', '\\'].concat(more).join('|\\') + ')', 'g');
                return str.replace(re, '\\$1');
            };

            var escapeForRegExp = function (str) {
                return escapeForRegExpURL(str, ['*']);
            };

            try {
                // method：HTTP 请求方法，必须参数，值包括 POST、GET 和 HEAD，大小写不敏感。
                // url：请求的 URL 字符串，必须参数，大部分浏览器仅支持同源请求。
                // async：指定请求是否为异步方式，默认为 true。如果为 false，当状态改变时会立即调用 onreadystatechange 属性指定的回调函数。
                let asyncT = true;
                if (typeof params.async !== "undefined") {
                    asyncT = params.async;
                }
                let method = "GET";
                if (typeof params.method !== "undefined") {
                    method = params.method;
                }
                // username：可选参数，如果服务器需要验证，该参数指定用户名，如果未指定，当服务器需要验证时，会弹出验证窗口。

                if (typeof params.user !== "undefined" && typeof params.password !== "undefined") {
                    xhr.open(method, params.url, asyncT, params.user, params.password); // 建立连接
                } else {
                    xhr.open(method, params.url, asyncT); // 建立连接
                }

                // 超时时间，单位是毫秒
                if (typeof params.timeout !== "undefined") {
                    xhr.timeout = params.timeout;
                }
                // 设置HTTP请求头部的方法。此方法必须在  open() 方法和 send()   之间调用 
                if (params.headers && JSON.stringify(params.headers) != '{}') {
                    Object.keys(params.headers).forEach((key) => {
                        var p = key;
                        if (key.toLowerCase() == 'user-agent' || key.toLowerCase() == 'referer') {
                            let id = ((new Date()).getTime() + Math.floor(Math.random() * 6121983 + 1)).toString();
                            let prefix = "TM_" + id + '_';
                            p = prefix + key;
                            return;
                        }
                        xhr.setRequestHeader(p, params.headers[key]);
                    });
                }
                if (typeof (params.overrideMimeType) !== 'undefined') {
                    xhr.overrideMimeType(params.overrideMimeType);
                }
                if (typeof (params.responseType) !== 'undefined') {
                    xhr.responseType = params.responseType;
                } 
                if (typeof (params.nocache) !== 'undefined') {
                    xhr.setRequestHeader('Cache-Control', 'no-cache');
                }
                // 设置cookie
                // 在发送来自其他域的XMLHttpRequest请求之前，未设置withCredentials 为true，那么就不能为它自己的域设置cookie值。
                // 而通过设置withCredentials 为true获得的第三方cookies，将会依旧享受同源策略，因此不能被通过document.cookie或者从头部相应请求的脚本等访问。
                if (typeof (params.cookie) !== 'undefined') {
                    xhr.withCredentials = true;
                    // xhr.setRequestHeader('Cookie', params.cookie);
                }
                xhr.ontimeout = function (e) {
                    console.error('Timeout!!')
                    if (params.ontimeout) {
                        params.ontimeout(e)
                    }
                }
                xhr.onload = onload;
                xhr.onerror = onerror;
                xhr.onreadystatechange = onreadystatechange;
                // 可以使用 send() 方法发送请求
                if (typeof (params.data) !== 'undefined') {
                    xhr.send(params.data);
                } else {
                    xhr.send();
                }
                // if (!body && params.binary) {
                //     xhr.send(params.binary.getBlob('text/plain'));
                // }else{
                //     xhr.send(body);
                // }
            } catch (error) {
                console.log('xhr: error: ', error);
                var resp = {
                    responseXML: '',
                    responseText: '',
                    response: null,
                    readyState: 4,
                    responseHeaders: '',
                    status: 403,
                    statusText: 'Forbidden'
                };
                // params.onerror(resp);
                sendResponse({ onerror: resp})
            }

            return true;
        }
        else if ("GM_getResourceText" == request.operate) {
            // browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
            //     console.log("GM_getResourceText----", response);
            //     sendResponse(response);
            // });
            var url = "https://dump.ventero.de/greasemonkey/resource";/*json文件url*/
            var url = request.url
            var reqXHR = new XMLHttpRequest();
            reqXHR.open("get", url, true);/*设置请求方法与路径*/
            reqXHR.responseType = "text";
            reqXHR.setRequestHeader("Content-Type", "text/plain; charset=x-user-defined");
            reqXHR.send();/*不发送数据到服务器*/
            reqXHR.onload = function () {/*XHR对象获取到返回信息后执行*/
                if (reqXHR.status == 200) {/*返回状态为200，即为数据获取成功*/
                    console.log("BG-----GM_getResourceText---", reqXHR.responseText);
                    sendResponse({ body: reqXHR.responseText});
                }
            }
            return true;
        }
        else if ("GM_getResourceUrl" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
                console.log("GM_getResourceUrl----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_getAllResourceText" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
                console.log("GM_getAllResourceText----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_getAllResourceUrl" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
                console.log("GM_getAllResourceUrl----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("closeTab" == request.operate){
            console.log("bg closeTab ------");
            if (request.tabId && closeableTabs[request.tabId]) {
                browser.tabs.remove(request.tabId);
            }
            sendResponse({});
            return true;
        }
        else if ("openInTab" == request.operate){
            console.log("bg openInTab ------")
            var done = function (tab) {
                closeableTabs[tab.id] = true;
                sendResponse({ tabId: tab.id });
            }
            var s = ['active'];
            var o = { url: request.url };
            if (request.options) {
                for (var n = 0; n < s.length; n++) {
                    if (request.options[s[n]] !== undefined) {
                        o[s[n]] = request.options[s[n]];
                    }
                }
                if (request.options.insert) {
                    o.index = sender.tab.index + 1;
                }
            }
            browser.tabs.create(o, done);
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
