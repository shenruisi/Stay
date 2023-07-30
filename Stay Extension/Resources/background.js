/* eslint-disable */
Date.prototype.dateFormat = function (fmt) {
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

let videoPageUrl = '';
let videoInfoList = [];
let videoLinkSet = new Set();
let matchAppScriptList = [];
let matchAppScriptConsole = [];
let gm_console = {};
let closeableTabs = {};
let xhrs = [];

async function getOKResponse(url, mimeType, origin) {
    const response = await fetch(url, {
      cache: 'force-cache',
      credentials: 'omit',
      referrer: origin
    });
    if (
      isSafari &&
        mimeType === 'text/css' &&
        (url.startsWith('safari-web-extension://') || url.startsWith('safari-extension://')) &&
        url.endsWith('.css')
    ) {
      return response;
    }
    if (mimeType && !response.headers.get('Content-Type').startsWith(mimeType)) {
      throw new Error(`Mime type mismatch when loading ${url}`);
    }
    if (!response.ok) {
      throw new Error(
        `Unable to load ${url} ${response.status} ${response.statusText}`
      );
    }
    return response;
  }
  async function loadAsDataURL(url, mimeType) {
    const response = await getOKResponse(url, mimeType);
    return await readResponseAsDataURL(response);
  }
  async function readResponseAsDataURL(response) {
    const blob = await response.blob();
    const dataURL = await new Promise((resolve) => {
      const reader = new FileReader();
      reader.onloadend = () => resolve(reader.result);
      reader.readAsDataURL(blob);
    });
    // console.log("dataURL------", dataURL)
    return dataURL;
  }
  async function loadAsText(url, mimeType, origin) {
    const response = await getOKResponse(url, mimeType, origin);
    return response.text();
  }
class LimitedCacheStorage {
    constructor() {
      this.bytesInUse = 0;
      this.records = new Map();
      this.alarmIsActive = false;
      browser.alarms.onAlarm.addListener(async (alarm) => {
        if (alarm.name === LimitedCacheStorage.ALARM_NAME) {
          this.alarmIsActive = false;
          this.removeExpiredRecords();
        }
      });
    }
    ensureAlarmIsScheduled() {
      if (!this.alarmIsActive) {
        browser.alarms.create(LimitedCacheStorage.ALARM_NAME, {
          delayInMinutes: 1
        });
        this.alarmIsActive = true;
      }
    }
    has(url) {
      return this.records.has(url);
    }
    get(url) {
      if (this.records.has(url)) {
        const record = this.records.get(url);
        record.expires = Date.now() + LimitedCacheStorage.TTL;
        this.records.delete(url);
        this.records.set(url, record);
        return record.value;
      }
      return null;
    }
    set(url, value) {
      this.ensureAlarmIsScheduled();
      const size = getStringSize(value);
      if (size > LimitedCacheStorage.QUOTA_BYTES) {
        return;
      }
      for (const [url, record] of this.records) {
        if (this.bytesInUse + size > LimitedCacheStorage.QUOTA_BYTES) {
          this.records.delete(url);
          this.bytesInUse -= record.size;
        } else {
          break;
        }
      }
      const expires = Date.now() + LimitedCacheStorage.TTL;
      this.records.set(url, { url, value, size, expires });
      this.bytesInUse += size;
    }
    removeExpiredRecords() {
      const now = Date.now();
      for (const [url, record] of this.records) {
        if (record.expires < now) {
          this.records.delete(url);
          this.bytesInUse -= record.size;
        } else {
          break;
        }
      }
      if (this.records.size !== 0) {
        this.ensureAlarmIsScheduled();
      }
    }
  }

  LimitedCacheStorage.QUOTA_BYTES =
    (navigator.deviceMemory || 4) * 16 * 1024 * 1024;
  LimitedCacheStorage.TTL = getDuration({ minutes: 10 });
  LimitedCacheStorage.ALARM_NAME = 'network';


  const caches = {
    'data-url': new LimitedCacheStorage(),
    'text': new LimitedCacheStorage()
  };
  const loaders = {
    'data-url': loadAsDataURL,
    'text': loadAsText
  };

  async function getUrlData({ url, responseType, mimeType, origin }) {
    const cache = caches[responseType];
    const load = loaders[responseType];
    if (cache.has(url)) {
      return cache.get(url);
    }
    const data = await load(url, mimeType, origin);
    cache.set(url, data);
    return data;
  }

  function getStringSize(value) {
    return value.length * 2;
  }


browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const requestFrom = request.from;
    const requestOperate = request.operate;
    if ("darkmode" == requestFrom) {
        if ("GET_STAY_AROUND" === request.operate){
            browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
                sendResponse({ body: response.body })
            });
        }
        else if ("FETCH_DARK_STAY" === request.operate){
            let isStayAround = window.localStorage.getItem("is_stay_around");
            let toggleStatus = window.localStorage.getItem("stay_dark_toggle_status") || "on";
            if(isStayAround && isStayAround !== "undefined" && isStayAround !== "null"){
                sendResponse({isStayAround: isStayAround, toggleStatus: toggleStatus})
            }else{
                sendResponse({body: ""})
            }
        }
        else if ("GIVEN_DARK_SETTING" === request.operate){
            let darkmodeSettingStr = request.darkmodeSettingStr
            // console.log("darkmodeSettingStr-------",darkmodeSettingStr);
            window.localStorage.setItem("stay_dark_mode_setting", darkmodeSettingStr);
            let darkmodeSetting = JSON.parse(darkmodeSettingStr)
            window.localStorage.setItem("is_stay_around", darkmodeSetting.isStayAround);
            window.localStorage.setItem("stay_dark_toggle_status", darkmodeSetting.toggleStatus);
        }
        return true;
    }
    else if ("bootstrap" == request.from || "iframe" == request.from) {
        if ("cs-fetch" == request.operate){
            const id = request.id;
            const sendRes = async (response) =>
                browser.tabs.sendMessage(sender.tab.id, {
                    type: "bg-fetch-response",
                    id,
                    ...response
                });
            if (isThunderbird) {
                if (request.data.url.startsWith("safari-web-extension://") || request.data.url.startsWith("safari-extension://") || request.data.url.startsWith("safari://")) {
                    sendRes({ data: null });
                    return;
                }
            }
            try {
                const { url, responseType, mimeType, origin } = request.data;
                getUrlData({ url, responseType, mimeType, origin }).then(response=>{
                    sendRes({ data: response });
                })
            } catch (err) {
                sendRes({
                    error: err && err.message ? err.message : err
                });
            }

            return true;
        }
        else if ("fetchScripts" == request.operate) {
            // console.log("background---fetchScripts request==", request);
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, url: request.url, digest: request.digest }, function (response) {
                // console.log("background--fetchScripts---response==",response);
                matchAppScriptList = response.body.scripts;
                if (request.digest == "no"){
                    if (matchAppScriptList.length > 0 && response.body.showBadge){
                        browser.browserAction.setBadgeText({text: matchAppScriptList.length.toString()});
                    }
                    else{
                        browser.browserAction.setBadgeText({text: ""});
                    }
                }
                // console.log("background--fetchScripts---matchAppScriptList==",matchAppScriptList);
                sendResponse({body: matchAppScriptList});
            });
            return true;
        }
        else if ("injectScript" == request.operate) {
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                // console.log("request.allFrames", request.allFrames);
                browser.tabs.executeScript(tabs[0].id, { code: request.code, allFrames: request.allFrames, runAt: request.runAt })
            });
            return true;
        }
        else if ("injectFile" == request.operate) {
            // console.log("background", "injectFile", request.file);
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.executeScript(tabs[0].id, { file: request.file, allFrames: request.allFrames, runAt: request.runAt })
            });
            return true;
        }
        else if ("setMatchedScripts" == request.operate) {
            matchAppScriptList = request.matchScripts;
            // console.log("setMatchedScripts request.matchScripts=", request.matchScripts)
            return true;
        }
    }
    else if ("gm-apis" == request.from) {
        if ("clear_GM_log" == request.operate) {
            // console.log("clear_GM_log, ", request);
            gm_console[request.uuid] = [];
        }
        else if ("GM_error" == request.operate) {
            // console.log("gm-apis GM_error, from exect catch, ", request);
            if (!gm_console[request.uuid]) {
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "error", time: new Date().dateFormat() });
            // console.log("GM_error=", gm_console);
        }
        else if ("GM_log" == request.operate) {
            // console.log("gm-apis GM_log");
            if (!gm_console[request.uuid]) {
                gm_console[request.uuid] = [];
            }
            gm_console[request.uuid].push({ msg: request.message, msgType: "log", time: new Date().dateFormat() });
            // console.log("GM_log=", gm_console);
            // sendResponse({ message: gm_console });
        }
        else if ("GM_getValue" == request.operate) {
            let type = request.type;
            let key = request.key;
            let defaultValue = request.defaultValue;
            if(type === "object"){
                defaultValue = JSON.parse(defaultValue);
            }
            let uuid = request.uuid;
            let localKey = uuid + "_" + key
            browser.storage.local.get(localKey, (res) => {
                // console.log("GM_getValue-------localKey=",localKey,",--------res=",res)
                if(res){
                    sendResponse(res[localKey]);
                }else{
                    browser.runtime.sendNativeMessage("application.id", { type: request.operate, key: key, defaultValue: defaultValue, uuid: uuid }, function (response) {
                        // console.log("GM_getValue---stay_app--response--------",response);
                        sendResponse(response?response.body:defaultValue);
                    });
                }
            });
            
            return true;
        }
        else if ("GM_setValue" == request.operate) {
            let type = request.type;
            let key = request.key;
            let value = request.value;
            if(type === "object" && value){
                value = JSON.parse(value);
            }
            let uuid = request.uuid;
            let defaultValue = {};
            let localKey = uuid + "_" + key
            defaultValue[localKey] = value
            // console.log("GM_setValue------defaultValue-----", defaultValue);
            browser.storage.local.set(defaultValue, (res) => {});
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, key: key, value: value, uuid: uuid }, function (response) {
                // console.log("GM_setValue------stay_app-----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_deleteValue" == request.operate) {
            let uuid = request.uuid;
            let key = request.key;
            let localKey = uuid + "_" + key
            browser.storage.local.remove(localKey, ()=>{})
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, key: key, uuid: uuid }, function (response) {
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_listValues" == request.operate) {
            let uuid = request.uuid;
            browser.storage.local.get(null, (res) => {
                // console.log("GM_listValues==background==", res);
                if(res){
                    let resp = {};
                    let respKeys = [];
                    Object.keys(res).forEach((localKey) => {
                        if(localKey.startsWith(uuid)){
                            // console.log("GM_listValues==background====localKey====", localKey);
                            let key = localKey.replace(uuid+"_", "");
                            resp[key] = res[localKey];
                            respKeys.push(key);
                        }
                    })
                    // console.log("GM_listValues==----background-------resp==", resp);
                    sendResponse({body:resp});
                    // sendResponse({body:respKeys});
                }else{
                    browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: uuid }, function (response) {
                        sendResponse(response?response:{body:{}});
                    });
                }
            })
            
            return true;
        }
        else if ("unsafeWindow" == request.operate) {
            // console.log("unsafeWindow bg-----", window.__restart_confirm_timeout, ",----", window._WWW_SRV_T);
            sendResponse({ unsafeWindow: window });
            return true;
        }
        else if ("GM_xmlhttpRequest" == request.operate) {
            let params = request.params;
            let xhrId = request.xhrId;
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
                    responseType: xhr.responseType,
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
                    responseState.status != 0) {
                    // console.log('api_create: error at onload, should not happen! -> retry :)')
                    return;
                }else{
                    if (responseState.responseType === "blob" && responseState.response) {
                        let downLoadUrl = window.URL.createObjectURL(responseState.response);
                        // console.log("GM_xmlhttpRequest.BG___reader,base64data--start-downLoadUrl=", downLoadUrl)
                        const reader = new FileReader();
                        reader.readAsDataURL(responseState.response);
                        reader.onloadend = function () {
                            let base64Data = reader.result;
                            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                                browser.tabs.sendMessage(tabs[0].id, 
                                    { from: "background", base64Data: base64Data, xhrId: xhrId, uuid: request.uuid, operate: "FETCH_BLOB_URL" }).then(
                                        (res) => {
                                            // console.log("FETCH_BLOB_URL---res---", res);
                                            if (xhrId === res.xhrId) {
                                                let type = responseState.response.type;
                                                responseState.response = {
                                                    blob: res.body.blob,
                                                    blobUrl: res.body.blobUrl,
                                                    data: base64Data,
                                                    type: type
                                                };
                                                sendResponse({ onload: responseState });
                                            }
                                        }
                                    );
                            });
                        };
                    }else{
                        sendResponse({ onload: responseState });
                    }
                }
                
            };
            var onerror = function () {
                var responseState = createState();
                if (responseState.readyState == 4 &&
                    responseState.status != 200 &&
                    responseState.status != 0) {
                    // console.log('api_create: error at onerror, should not happen! -> retry')
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
                xhr.withCredentials = (params.user && params.password);

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
                    // 设置cookie
                    // 在发送来自其他域的XMLHttpRequest请求之前，未设置withCredentials 为true，那么就不能为它自己的域设置cookie值。
                    // 而通过设置withCredentials 为true获得的第三方cookies，将会依旧享受同源策略，因此不能被通过document.cookie或者从头部相应请求的脚本等访问。
                    if (typeof (params.headers.cookie) !== 'undefined') {
                        xhr.withCredentials = true;
                    }
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
                sendResponse({ onerror: resp })
            }

            return true;
        }
        else if ("GM_getResourceText" == request.operate) {
            // console.log("BG-----GM_getResourceText-request-----", request);
            var url = "https://dump.ventero.de/greasemonkey/resource";/*json文件url*/
            url = request.url
            var reqXHR = new XMLHttpRequest();
            reqXHR.open("get", url, true);/*设置请求方法与路径*/
            reqXHR.responseType = "text";
            reqXHR.setRequestHeader("Content-Type", "text/plain; charset=x-user-defined");
            reqXHR.send();/*不发送数据到服务器*/
            reqXHR.onload = function () {/*XHR对象获取到返回信息后执行*/
                if (reqXHR.status == 200) {/*返回状态为200，即为数据获取成功*/
                    // console.log("BG-----GM_getResourceText---", reqXHR.responseText);
                    sendResponse({ body: reqXHR.responseText });
                }
            }
            return true;
        }
        else if ("GM_getResourceUrl" == request.operate) {
            let key = request.key;
            browser.runtime.sendNativeMessage("application.id", { type: request.operate,key, uuid: request.uuid }, function (response) {
                // console.log("-----background----GM_getResourceUrl--response--", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_getAllResourceText" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
                // console.log("GM_getAllResourceText----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("GM_getAllResourceUrl" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid }, function (response) {
                // console.log("GM_getAllResourceUrl----", response);
                sendResponse(response);
            });
            return true;
        }
        else if ("closeTab" == request.operate) {
            // console.log("bg closeTab ------");
            if (request.tabId && closeableTabs[request.tabId]) {
                browser.tabs.remove(request.tabId);
            }
            sendResponse({});
            return true;
        }
        else if ("openInTab" == request.operate) {
            // console.log("bg openInTab ------")
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
        else if (request.operate === "API_ADD_STYLE" || request.operate === "API_ADD_STYLE_SYNC") {
            const tabId = sender.tab.id;
            browser.tabs.insertCSS(tabId, { code: request.css }, () => {
                if (request.operate === "API_ADD_STYLE") sendResponse(request.css);
            });
            return true;
        }
        else if (request.operate === "HTTP_REQUEST_API_FROM_CREATE_TO_APP"){
            const details = request.details;
            const reqType = request.type;
            const xhrId = request.xhrId;
            console.log("HTTP_REQUEST_API_FROM_CREATE_TO_APP------", request)
            browser.runtime.sendNativeMessage("application.id", { type: "GM_xmlhttpRequest", details, uuid: request.uuid }, function (response) {
                console.log("GM_xmlhttpRequest----response---", response);
                let resp = response.body
                resp.response = resp.responseText;
                if (resp.responseType && resp.responseType === "arraybuffer" && resp) {
                    try {
                        const r = new Uint8Array(resp.data).buffer;
                        resp.response = r;
                    } catch (error) {
                        console.error("error parsing xhr arraybuffer response", error);
                    }
                    // blob responses had their data converted, convert it back to blob
                } else if (resp.responseType && resp.responseType === "blob") {
                    browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                        browser.tabs.sendMessage(tabs[0].id, 
                            { from: "background", base64Data: resp.data, xhrId, uuid: request.uuid, operate: "FETCH_BLOB_URL" }).then(
                                (res) => {
                                    // console.log("FETCH_BLOB_URL---res---", res);
                                    if (xhrId === res.xhrId) {
                                        let type = resp.type;
                                        resp.response = {
                                            blob: res.body.blob,
                                            blobUrl: res.body.blobUrl,
                                            data: resp.data,
                                            type: type
                                        };
                                        
                                        if(reqType !=="undefined" && reqType == "content"){
                                            sendResponse(resp);
                                        }else{
                                            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                                                browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "RESP_HTTP_REQUEST_API_FROM_CREATE_TO_APP", xhrId, response: resp });
                                            });
                                        }
                                    }
                                }
                            );
                    });
                }else{
                    // console.log("resp.response ===else==",resp )
                    if(reqType !=="undefined" && reqType == "content"){
                        sendResponse(resp);
                    }else{
                        browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                            browser.tabs.sendMessage(tabs[0].id, { from: "background", xhrId, operate: "RESP_HTTP_REQUEST_API_FROM_CREATE_TO_APP", response: resp });
                        });
                    }
                }
            });
            return true;
        }
        else if (request.operate === "API_XHR_FROM_BOOTSTRAP") {
            // https://jsonplaceholder.typicode.com/posts
            // get tab id and respond only to the content script that sent message
            const tab = sender.tab.id;
            const details = request.details;
            const method = details.method ? details.method : "GET";
            const user = details.user || null;
            const password = details.password || null;
            let body = details.data || null;
            if (body && details.binary) {
                const len = body.length;
                const arr = new Uint8Array(len);
                for (let i = 0; i < len; i++) {
                    arr[i] = body.charCodeAt(i);
                }
                body = new Blob([arr], { type: "text/plain" });
            }
            const xhr = new XMLHttpRequest();
            // push to global scoped array so it can be aborted
            xhrs.push({ xhr: xhr, xhrId: request.xhrId });
            xhr.withCredentials = (details.user && details.password);
            xhr.timeout = details.timeout || 0;
            if (details.overrideMimeType) xhr.overrideMimeType(details.overrideMimeType);
            xhrAddListeners(xhr, tab, request.uuid, request.xhrId, details);
            xhr.open(method, details.url, true, user, password);
            xhr.responseType = details.responseType || "";
            if (details.headers) {
                for (const key in details.headers) {
                    const val = details.headers[key];
                    xhr.setRequestHeader(key, val);
                }
            }
            xhr.send(body);
            // remove xhr from global scope when completed
            xhr.onloadend = progressEvent => xhrs = xhrs.filter(x => x.xhrId !== request.xhrId);
            // sendResponse({details: details});
            return true;
        } else if (request.operate === "API_XHR_ABORT_FROM_BOOTSTRAP") {
            // get the xhrId from request
            const xhrId = request.xhrId;
            const match = xhrs.find(x => x.xhrId === xhrId);
            if (match) {
                match.xhr.abort();
                // sendResponse(match);
            } else {
                console.log(`abort message recieved for ${xhrId}, but it couldn't be found`);
            }
            return true;
        } else if (request.operate === "REGISTER_MENU_COMMAND_CONTEXT"){
            // console.log("background----REGISTER_MENU_COMMAND_CONTEXT-------", request);
            let command_content = request.command_content
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from: "background", command_content: command_content, uuid: request.uuid, operate: "REGISTER_MENU_COMMAND_CONTEXT" });
            });
        } else if (request.operate === "UNREGISTER_MENU_COMMAND_CONTEXT") {
            // console.log("background----UNREGISTER_MENU_COMMAND_CONTEXT-------", request);
            let menuId = request.menuId
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from: "background", menuId: menuId, uuid: request.uuid, operate: "UNREGISTER_MENU_COMMAND_CONTEXT" });
            });
        }
    }
    else if ("popup" == request.from) {
        // console.log(request.from + " = " + request.operate);
        if ("fetchLog" == request.operate) {
            sendResponse({ body: gm_console });
        }
        else if ("cleanLog" == request.operate) {
            gm_console = [];
        } else if ("fetchMatchedScriptList" == request.operate) {
            // console.log("fetchMatchedScriptList--", request, matchAppScriptList)
            browser.runtime.sendMessage({ from: "background", operate: "fetchMatchedScripts" }, (response) => {
                matchAppScriptList = response.body;
                console.log("fetchMatchedScriptList---fetchMatchedScripts--", response, "-res--", response.body)
                sendResponse({ body: matchAppScriptList });
            })
        } else if ("setScriptActive" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid, active: request.active }, function (response) {
                sendResponse(response);
            });
        }
        else if ("setDisabledWebsites" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: request.uuid, disabledUrl: request.website, on: request.on }, function (response) {
                sendResponse(response);
            });
        }
        else if ("exeScriptManually" == request.operate) {
            browser.runtime.sendNativeMessage("application.id", { type: "fetchTheScript", uuid: request.uuid }, function (response) {
                browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "exeScriptManually", script: response.body });
                });
            });
        }
        else if ("fetchMatchedScriptLog" == request.operate) {
            // console.log("fetchMatchedScriptLog----matchAppScriptList=", matchAppScriptList);
            if (matchAppScriptList && matchAppScriptList.length > 0) {
                if (matchAppScriptConsole.length > 0) {
                    matchAppScriptConsole = [];
                }
                matchAppScriptList.forEach(item => {
                    let matchLog = {};
                    matchLog["name"] = item.name;
                    matchLog["uuid"] = item.uuid;
                    matchLog["logList"] = gm_console[item.uuid]
                    matchAppScriptConsole.push(matchLog);
                })
                // console.log("fetchMatchedScriptLog=", matchAppScriptConsole);
                sendResponse({ body: matchAppScriptConsole });
            } else {
                sendResponse({ body: [] });
            }
        }
        else if ("fetchRegisterMenuCommand" == request.operate) {
            // console.log("background--fetchRegisterMenuCommand---", request);
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from: "background", uuid: request.uuid, operate: "fetchRegisterMenuCommand" });
            });
        }
        else if ("execRegisterMenuCommand" == request.operate) {
            // console.log("background---execRegisterMenuCommand--", request);
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "execRegisterMenuCommand", id: request.id, uuid: request.uuid });
            });
            sendResponse({ body: [], id: request.id, uuid: request.uuid })
        }
        else if ("refreshTargetTabs" == request.operate){
            // console.log("background---refreshTargetTabs--", request);
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.reload(tabs[0].id);
            });
        }
        else if("fetchFolders" == request.operate){
            browser.runtime.sendNativeMessage("application.id", { type: "fetchFolders"}, function (response) {
                // console.log("fetchFolders-----response--",response)
                sendResponse({ body: response.body })
            });
        }
        else if("getLongPressStatus" == request.operate){
            let longPressStatus = 'on';
            browser.storage.local.get("long_press_status", (res) => {
                // console.log("getLongPressStatus-------long_press_status,--------res=",res)
                if(res && res["long_press_status"]){
                    longPressStatus = res["long_press_status"]
                }
                sendResponse({longPressStatus});
            });
        }
        else if("setLongPressStatus" == request.operate){
            let longPressStatus = request.longPressStatus;
            if(longPressStatus){
                let statusMap = {}
                statusMap.long_press_status = longPressStatus;
                browser.storage.local.set(statusMap, (res) => {
                    sendResponse(longPressStatus);
                });
            }
        }
        else if('fetchTagRules' == requestOperate){
            const url = request.url;
            // console.log('fetchTagRules----request', request)
            browser.runtime.sendNativeMessage("application.id", { type: "fetchTagRules", url }, function (response) {
                // console.log("fetchTagRules-------response=",response);
                let body = response&&response.body?response.body:{};
                sendResponse(body)
            });
        }
        else if('deleteTagRule' == requestOperate){
            const uuid = request.uuid;
            browser.runtime.sendNativeMessage("application.id", { type: "deleteTagRule", uuid }, function (response) {
                // console.log("deleteTagRule-------response=",response);
                let body = response&&response.body?response.body:{};
                sendResponse(body)
            });
        }
        else if('fetchTagStatus' == requestOperate){
            // console.log("fetchTagStatus-------request=",request);
            browser.runtime.sendNativeMessage("application.id", { type: "fetchTagStatus" }, function (response) {
                // console.log("fetchTagStatus-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('setTrustedSite' == requestOperate){
            const url = request.url;
            const on = request.on;
            console.log("trustedSite-------request=",request);
            browser.runtime.sendNativeMessage("application.id", { type: "setTrustedSite", url, on}, function (response) {
                // console.log("trustedSite-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('getTrustedSite' == requestOperate){
            console.log("getTrustedSite-------request=",request);
            const url = request.url
            browser.runtime.sendNativeMessage("application.id", { type: "getTrustedSite", url }, function (response) {
                // console.log("trustedSite-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('addDarkmodeTheme' == requestOperate){
            console.log("addDarkmodeTheme-------request=",request);
            const theme = request.theme
            browser.runtime.sendNativeMessage("application.id", { type: "dm_addTheme", theme }, function (response) {
                console.log("addDarkmodeTheme-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('getDarkmodeThemeList' == requestOperate){
            console.log("getDarkmodeThemeList-------request=",request);
            
            browser.runtime.sendNativeMessage("application.id", { type: "dm_themes"}, function (response) {
                console.log("getDarkmodeThemeList-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('deleteDarkmodeTheme' == requestOperate){
            console.log("deleteDarkmodeTheme-------request=",request);
            const theme = request.theme
            browser.runtime.sendNativeMessage("application.id", { type: "dm_deleteTheme", theme }, function (response) {
                console.log("deleteDarkmodeTheme-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }
        else if('modifyDarkmodeTheme' == requestOperate){
            console.log("modifyDarkmodeTheme-------request=",request);
            const theme = request.theme
            browser.runtime.sendNativeMessage("application.id", { type: "dm_modifyTheme", theme }, function (response) {
                console.log("modifyDarkmodeTheme-------response=",response);
                let body = response&&response.body?response.body:{}
                sendResponse(body)
            });
        }else if ("GET_STAY_AROUND" === requestOperate){
            browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
                // console.log("content_script-------response=",response);
                sendResponse({ body: response.body })
            });
        }
        return true;
    }else if ("content_script" == request.from){
        // console.log("content_script-------request=", request)
        if ("GET_STAY_AROUND" === request.operate){
            browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
                // console.log("content_script-------response=",response);
                sendResponse({ body: response.body })
            });
        }
        else if("getThreeFingerTapStatus" == request.operate){
            let threeFingerTapStatus = 'on';
            browser.storage.local.get("three_finger_tap_status", (res) => {
                // console.log("getThreeFingerTapStatus-------three_finger_tap_status--------res=",res)
                if(res && res["three_finger_tap_status"]){
                    threeFingerTapStatus = res["three_finger_tap_status"]
                }
                sendResponse({threeFingerTapStatus});
            });
        }
        else if("setThreeFingerTapStatus" == request.operate){
            let threeFingerTapStatus = request.threeFingerTapStatus;
            // console.log('setThreeFingerTapStatus-------', threeFingerTapStatus);
            let type = request.type;
            if(threeFingerTapStatus){
                let statusMap = {}
                statusMap.three_finger_tap_status = threeFingerTapStatus;
                browser.storage.local.set(statusMap, (res) => {
                    sendResponse(threeFingerTapStatus);
                });
            }
        }
        return true;
    }
    else if ("sniffer" == request.from){
        if ("VIDEO_INFO_PUSH" == request.operate) {
            // console.log("VIDEO_INFO_PUSH-------",request)
            if(request.videoLinkSet && request.videoLinkSet.size){
                videoLinkSet = request.videoLinkSet
                videoPageUrl= request.videoPageUrl
                browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "VIDEO_INFO_PUSH", videoPageUrl, videoLinkSet});
                });
            }
            if(request.videoInfoList && request.videoInfoList.length){
                videoInfoList = request.videoInfoList
                videoPageUrl = request.videoPageUrl
                browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "VIDEO_INFO_PUSH",  videoPageUrl, videoInfoList});
                });
            }
        }
        else if ("GET_STAY_AROUND" === request.operate){
            browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
                sendResponse({ body: response.body })
            });
        }
        else if ("fetchYoutubeDecodeFun" === request.operate){
            let path = request.pathUuid;
            let location = request.pathUrl;
            // console.log('fetchYoutubeDecodeFun----path=',path, ",location=",location)
            browser.runtime.sendNativeMessage("application.id", { type: "yt_element", path, location}, function (response) {
                // console.log('fetchYoutubeDecodeFun----', response)
                let decodeFunObj = {};
                if(response && response.body){
                    decodeFunObj.decodeFunStr = response.body.code;
                    decodeFunObj.decodeSpeedFunStr = response.body.n_code;
                    decodeFunObj.status = response.body.status_code;
                }
                // console.log('fetchYoutubeDecodeFun---decodeFunObj-----', decodeFunObj)
                sendResponse({decodeFunObj})
            });
        }
        else if ("saveYoutubeDecodeFun" === request.operate){
            let path = request.pathUuid;
            let code = request.randomFunStr || '';
            let n_code = request.randomSpeedFunStr || '';
            console.log('saveYoutubeDecodeFun----path=',path, ",code=",code,",n_code=",n_code)
            browser.runtime.sendNativeMessage("application.id", { type: "yt_element_ci", path, code, n_code}, function (response) {
                // console.log('saveYoutubeDecodeFun----', response)
                sendResponse({ decodeFun: '' })
            });
        }
        else if("POST_AUDIO_RECORD" === requestOperate){
            let recording = request.recording;
            browser.runtime.sendNativeMessage("application.id", { type: "ST_speechToText", data: recording}, function (response) {
                // console.log('POST_AUDIO_RECORD----', response)
                sendResponse({ text: response.body })
            });
        }
        else if("PUSH_IFRAME_VIDEO_INFO_TO_BG" === requestOperate){
            let videoReact = request.videoReact;
            let iframeVideoInfo = request.iframeVideoInfo;
            browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                browser.tabs.sendMessage(tabs[0].id, { from: "background", operate: "PUSH_IFRAME_VIDEO_INFO_TO_PARENT", iframeVideoInfo, videoReact});
            });
            sendResponse({ text: 'background already received video info of iframe' })
        }
        return true;
    }else if ("adblock" == request.from){
        // console.log("content_script-------request=", request)
        if ("sendSelectorToHandler" === request.operate){
            const selector = request.selector;
            const url = request.url;
            const urlList = request.urlList;
            console.log("adblock----ADB_tag_ad---request-----",selector, urlList);
            browser.runtime.sendNativeMessage("application.id", { type: "ADB_tag_ad", selector, urls: urlList }, function (response) {
                console.log("adblock----ADB_tag_ad---response=",response);
                sendResponse({ body: response.body })
            });
        }
        else if ("GET_IF_CAN_TAG" === request.operate){
            console.log("adblock----GET_IF_CAN_TAG---request-----",request);
            browser.runtime.sendNativeMessage("application.id", { type: "canTagAd" }, function (response) {
                console.log("adblock----GET_IF_CAN_TAG---response=",response);
                sendResponse({ body: response.body })
            });
        }
        return true;
    }
});


function xhrHandleEvent(e, xhr, tab, id, xhrId) {
    const name = `RESP_API_XHR_BG_${e.type.toUpperCase()}`;
    const x = {
        readyState: xhr.readyState,
        response: xhr.response,
        responseHeaders: xhr.getAllResponseHeaders(),
        responseType: xhr.responseType,
        responseURL: xhr.responseURL,
        status: xhr.status,
        statusText: xhr.statusText,
        timeout: xhr.timeout,
        withCredentials: xhr.withCredentials
    };
    // only include responseText when applicable
    if (["", "text"].includes(xhr.responseType)) x.responseText = xhr.responseText;
    // convert data if response is arraybuffer so sendMessage can pass it
    if (xhr.responseType === "arraybuffer") {
        const arr = Array.from(new Uint8Array(xhr.response));
        x.response = arr;
    }
    // convert data if response is blob so sendMessage can pass it
    if (xhr.responseType === "blob") {
        const reader = new FileReader();
        reader.readAsDataURL(xhr.response);
        reader.onloadend = function () {
            const base64data = reader.result;
            // console.log("window.URL.createObjectURL(xhr.response)=", window.URL.createObjectURL(xhr.response), ",base64data---", base64data)
            x.response = {
                data: base64data,
                type: xhr.response.type
            };
            browser.tabs.sendMessage(tab, { operate: name, uuid:id, id: id, xhrId: xhrId, response: x });
        };
    }
    // blob response will execute its own sendMessage call
    if (xhr.responseType !== "blob") {
        browser.tabs.sendMessage(tab, { operate: name, uuid: id, id: id, xhrId: xhrId, response: x });
    }
}

function xhrAddListeners(xhr, tab, id, xhrId, details) {
    if (details.onabort) {
        xhr.addEventListener("abort", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onerror) {
        xhr.addEventListener("error", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onload) {
        xhr.addEventListener("load", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onloadend) {
        xhr.addEventListener("loadend", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onloadstart) {
        xhr.addEventListener("loadstart", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onprogress) {
        xhr.addEventListener("progress", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.onreadystatechange) {
        xhr.addEventListener("readystatechange", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
    if (details.ontimeout) {
        xhr.addEventListener("timeout", e => xhrHandleEvent(e, xhr, tab, id, xhrId));
    }
}


