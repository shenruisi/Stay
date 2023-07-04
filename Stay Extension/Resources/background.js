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
const userAgent =
    typeof navigator === "undefined"
        ? "some useragent"
        : navigator.userAgent.toLowerCase();
const isChromium =
        userAgent.includes("chrome") || userAgent.includes("chromium");
const isThunderbird = userAgent.includes("thunderbird");
const isSafari = userAgent.includes("safari") || isThunderbird;
// const userAgentData = navigator.userAgent;
const platform = navigator.platform;
const isMacOS = platform.toLowerCase().startsWith("mac");
const isCSSColorSchemePropSupported = (() => {
    if (typeof document === "undefined") {
        return false;
    }
    const el = document.createElement("div");
    el.setAttribute("style", "color-scheme: dark");
    return el.style && el.style.colorScheme === "dark";
})();
const isXMLHttpRequestSupported = typeof XMLHttpRequest === "function";
async function getOKResponse(url, mimeType, origin) {
    const response = await fetch(url, {
        cache: "force-cache",
        credentials: "omit",
        referrer: origin
    });
    if (
        isSafari &&
        mimeType === "text/css" &&
        (url.startsWith("safari-web-extension://") || url.startsWith("safari-extension://")) &&
        url.endsWith(".css")
    ) {
        return response;
    }
    if (
        mimeType &&
        !response.headers.get("Content-Type").startsWith(mimeType)
    ) {
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
function getDuration(time) {
    let duration = 0;
    if (time.seconds) {
        duration += time.seconds * 1000;
    }
    if (time.minutes) {
        duration += time.minutes * 60 * 1000;
    }
    if (time.hours) {
        duration += time.hours * 60 * 60 * 1000;
    }
    if (time.days) {
        duration += time.days * 24 * 60 * 60 * 1000;
    }
    return duration;
}
function getStringSize(value) {
    return value.length * 2;
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
LimitedCacheStorage.ALARM_NAME = "network";


const caches = {
    "data-url": new LimitedCacheStorage(),
    "text": new LimitedCacheStorage()
};
const loaders = {
    "data-url": loadAsDataURL,
    "text": loadAsText
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

function isIPV6(url) {
    const openingBracketIndex = url.indexOf("[");
    if (openingBracketIndex < 0) {
        return false;
    }
    const queryIndex = url.indexOf("?");
    if (queryIndex >= 0 && openingBracketIndex > queryIndex) {
        return false;
    }
    return true;
}
const ipV6HostRegex = /\[.*?\](\:\d+)?/;
function compareIPV6(firstURL, secondURL) {
    const firstHost = firstURL.match(ipV6HostRegex)[0];
    const secondHost = secondURL.match(ipV6HostRegex)[0];
    return firstHost === secondHost;
}

function getURLHostOrProtocol($url) {
    const url = new URL($url);
    if (url.host) {
        return url.host;
    } else if (url.protocol === "file:") {
        return url.pathname;
    }
    return url.protocol;
}
function compareURLPatterns(a, b) {
    return a.localeCompare(b);
}
function isURLInList(url, list) {
    for (let i = 0; i < list.length; i++) {
        if (isURLMatched(url, list[i])) {
            return true;
        }
    }
    return false;
}
function isURLMatched(url, urlTemplate) {
    const isFirstIPV6 = isIPV6(url);
    const isSecondIPV6 = isIPV6(urlTemplate);
    if (isFirstIPV6 && isSecondIPV6) {
        return compareIPV6(url, urlTemplate);
    } else if (!isFirstIPV6 && !isSecondIPV6) {
        const regex = createUrlRegex(urlTemplate);
        return Boolean(url.match(regex));
    }
    return false;
}
function createUrlRegex(urlTemplate) {
    urlTemplate = urlTemplate.trim();
    const exactBeginning = urlTemplate[0] === "^";
    const exactEnding = urlTemplate[urlTemplate.length - 1] === "$";
    urlTemplate = urlTemplate
        .replace(/^\^/, "")
        .replace(/\$$/, "")
        .replace(/^.*?\/{2,3}/, "")
        .replace(/\?.*$/, "")
        .replace(/\/$/, "");
    let slashIndex;
    let beforeSlash;
    let afterSlash;
    if ((slashIndex = urlTemplate.indexOf("/")) >= 0) {
        beforeSlash = urlTemplate.substring(0, slashIndex);
        afterSlash = urlTemplate.replace(/\$/g, "").substring(slashIndex);
    } else {
        beforeSlash = urlTemplate.replace(/\$/g, "");
    }
    let result = exactBeginning
        ? "^(.*?\\:\\/{2,3})?"
        : "^(.*?\\:\\/{2,3})?([^/]*?\\.)?";
    const hostParts = beforeSlash.split(".");
    result += "(";
    for (let i = 0; i < hostParts.length; i++) {
        if (hostParts[i] === "*") {
            hostParts[i] = "[^\\.\\/]+?";
        }
    }
    result += hostParts.join("\\.");
    result += ")";
    if (afterSlash) {
        result += "(";
        result += afterSlash.replace("/", "\\/");
        result += ")";
    }
    result += exactEnding ? "(\\/?(\\?[^/]*?)?)$" : "(\\/?.*?)$";
    return new RegExp(result, "i");
}
function isPDF(url) {
    if (url.includes(".pdf")) {
        if (url.includes("?")) {
            url = url.substring(0, url.lastIndexOf("?"));
        }
        if (url.includes("#")) {
            url = url.substring(0, url.lastIndexOf("#"));
        }
        if (
            (url.match(/(wikipedia|wikimedia).org/i) &&
                url.match(
                    /(wikipedia|wikimedia)\.org\/.*\/[a-z]+\:[^\:\/]+\.pdf/i
                )) ||
            (url.match(/timetravel\.mementoweb\.org\/reconstruct/i) &&
                url.match(/\.pdf$/i))
        ) {
            return false;
        }
        if (url.endsWith(".pdf")) {
            for (let i = url.length; i > 0; i--) {
                if (url[i] === "=") {
                    return false;
                } else if (url[i] === "/") {
                    return true;
                }
            }
        } else {
            return false;
        }
    }
    return false;
}
function isURLEnabled(
    url,
    userSettings,
    {isProtected, isInDarkList, isDarkThemeDetected}
) {
    if (isProtected && !userSettings.enableForProtectedPages) {
        return false;
    }
    if (isThunderbird) {
        return true;
    }
    if (isPDF(url)) {
        return userSettings.stay_enableForPDF;
    }
    const isURLInUserList = isURLInList(url, userSettings.siteListEnabled);
    const isURLInEnabledList = isURLInList(
        url,
        userSettings.siteListEnabled
    );
    if (userSettings.applyToListedOnly) {
        return isURLInEnabledList || isURLInUserList;
    }
    if (isURLInEnabledList) {
        return true;
    }
    if (
        isInDarkList ||
        (userSettings.stay_detectDarkTheme && isDarkThemeDetected)
    ) {
        return false;
    }
    return !isURLInUserList;
}
function isFullyQualifiedDomain(candidate) {
    return /^[a-z0-9.-]+$/.test(candidate);
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


/**
 * dark mode config
 * 
 * 
 */
(function () {
    "use strict";
    function parseSitesFixesConfig(text, options) {
        const sites = [];
        const blocks = text.replace(/\r/g, "").split(/^\s*={2,}\s*$/gm);
        blocks.forEach((block) => {
            const lines = block.split("\n");
            const commandIndices = [];
            lines.forEach((ln, i) => {
                if (ln.match(/^[A-Z]+(\s[A-Z]+){0,2}$/)) {
                    commandIndices.push(i);
                }
            });
            if (commandIndices.length === 0) {
                return;
            }
            const siteFix = {
                url: parseArray(lines.slice(0, commandIndices[0]).join("\n"))
            };
            commandIndices.forEach((commandIndex, i) => {
                const command = lines[commandIndex].trim();
                const valueText = lines
                    .slice(
                        commandIndex + 1,
                        i === commandIndices.length - 1
                            ? lines.length
                            : commandIndices[i + 1]
                    )
                    .join("\n");
                const prop = options.getCommandPropName(command);
                if (!prop) {
                    return;
                }
                const value = options.parseCommandValue(command, valueText);
                siteFix[prop] = value;
            });
            sites.push(siteFix);
        });
        return sites;
    }
    function parseSiteFixConfig(text, options, recordStart, recordEnd) {
        const block = text.substring(recordStart, recordEnd);
        return parseSitesFixesConfig(block, options)[0];
    }
    function getSitesFixesFor(url, text, index, options) {
        // console.log("getSitesFixesFor---text.size()===", text.length)
        const records = [];
        let recordIds = [];
        const domain = getDomain(url);

        for (const pattern of Object.keys(index.domainPatterns)) {
            if (isURLMatched(url, pattern)) {
                recordIds = recordIds.concat(index.domainPatterns[pattern]);
            }
        }
        const labels = domain.split(".");
        for (let i = 0; i < labels.length; i++) {
            const substring = labels.slice(i).join(".");
            if (index.domains[substring] && isURLMatched(url, substring)) {
                recordIds = recordIds.concat(index.domains[substring]);
            }
        }
        const set = new Set();
        for (const id of recordIds) {
            if (set.has(id)) {
                continue;
            }
            set.add(id);
            if (!index.cache[id]) {
                const [start, end] = decodeOffset(index.offsets, id);
                index.cache[id] = parseSiteFixConfig(text, options, start, end);
            }
            records.push(index.cache[id]);
        }
        return records;
    }
    const dynamicThemeFixesCommands = {
        "INVERT": "invert",
        "CSS": "css",
        "IGNORE INLINE STYLE": "ignoreInlineStyle",
        "IGNORE IMAGE ANALYSIS": "ignoreImageAnalysis"
    };
    function getDynamicThemeFixesFor(url, frameURL, text, index, enabledForPDF) {
        // console.log("getDynamicThemeFixesFor---text.size()===", text.length, text)
        const fixes = getSitesFixesFor(frameURL || url, text, index, {
            commands: Object.keys(dynamicThemeFixesCommands),
            getCommandPropName: (command) => dynamicThemeFixesCommands[command],
            parseCommandValue: (command, value) => {
                if (command === "CSS") {
                    return value.trim();
                }
                return parseArray(value);
            }
        });
        // console.log("getDynamicThemeFixesFor-------fixes----",fixes);
        if (fixes.length === 0 || fixes[0].url[0] !== "*") {
            return null;
        }
        const genericFix = fixes[0];
        // console.log("getDynamicThemeFixesFor-------genericFix.css----",genericFix.css);
        const common = {
            url: genericFix.url,
            invert: genericFix.invert || [],
            css: genericFix.css || "",
            ignoreInlineStyle: genericFix.ignoreInlineStyle || [],
            ignoreImageAnalysis: genericFix.ignoreImageAnalysis || []
        };
        if (enabledForPDF) {
            if (isChromium) {
                common.css +=
                    '\nembed[type="application/pdf"][src="about:blank"] { filter: invert(100%) contrast(90%); }';
            } else {
                common.css +=
                    '\nembed[type="application/pdf"] { filter: invert(100%) contrast(90%); }';
            }
        }
        const sortedBySpecificity = fixes
            .slice(1)
            .map((theme) => {
                return {
                    specificity: isURLInList(frameURL || url, theme.url)
                        ? theme.url[0].length
                        : 0,
                    theme
                };
            })
            .filter(({specificity}) => specificity > 0)
            .sort((a, b) => b.specificity - a.specificity);
        if (sortedBySpecificity.length === 0) {
            return common;
        }
        // console.log("getDynamicThemeFixesFor-------sortedBySpecificity----",sortedBySpecificity);
        const match = sortedBySpecificity[0].theme;
        return {
            url: match.url,
            invert: common.invert.concat(match.invert || []),
            css: [common.css, match.css].filter((s) => s).join("\n"),
            ignoreInlineStyle: common.ignoreInlineStyle.concat(
                match.ignoreInlineStyle || []
            ),
            ignoreImageAnalysis: common.ignoreImageAnalysis.concat(
                match.ignoreImageAnalysis || []
            )
        };
    }

    function getDomain(url) {
        try {
            return new URL(url).hostname.toLowerCase();
        } catch (error) {
            return url.split("/")[0].toLowerCase();
        }
    }

    var ThemeEngines = {
        cssFilter: "cssFilter",
        svgFilter: "svgFilter",
        staticTheme: "staticTheme",
        dynamicTheme: "dynamicTheme"
    };

    const DEFAULT_COLORS = {
        darkScheme: {
            background: "#181a1b",
            text: "#e8e6e3"
        },
        lightScheme: {
            background: "#dcdad7",
            text: "#181a1b"
        }
    };
    const DEFAULT_THEME = {
        mode: 1,
        brightness: 100,
        contrast: 100,
        grayscale: 0,
        sepia: 0,
        useFont: false,
        fontFamily: isMacOS ? "Helvetica Neue": "Segoe UI",
        textStroke: 0,
        engine: ThemeEngines.dynamicTheme,
        stylesheet: "",
        darkSchemeBackgroundColor: DEFAULT_COLORS.darkScheme.background,
        darkSchemeTextColor: DEFAULT_COLORS.darkScheme.text,
        lightSchemeBackgroundColor: DEFAULT_COLORS.lightScheme.background,
        lightSchemeTextColor: DEFAULT_COLORS.lightScheme.text,
        scrollbarColor: isMacOS ? "" : "auto",
        selectionColor: "auto",
        styleSystemControls: !isCSSColorSchemePropSupported,
        lightColorScheme: "Default",
        darkColorScheme: "Default",
        immediateModify: false
    };
    const DEFAULT_COLORSCHEME = {
        light: {
            Default: {
                backgroundColor: DEFAULT_COLORS.lightScheme.background,
                textColor: DEFAULT_COLORS.lightScheme.text
            }
        },
        dark: {
            Default: {
                backgroundColor: DEFAULT_COLORS.darkScheme.background,
                textColor: DEFAULT_COLORS.darkScheme.text
            }
        }
    };

    const DEFAULT_SETTINGS = {
        isStayAround: "",
        siteListDisabled: [],
        siteListEnabled:[], // 暂时没用
        toggleStatus:"auto", //on,off,auto
        // 当toggleStatus=auto的时候，automation默认等于time
        stay_automation: "system",
        // 当toggleStatus=auto的时候, 如果选择系统配色方案，又分为跟随系统的OnOff,还是Scheme（暗黑/明亮模式）
        stay_automationBehaviour: "Scheme",
        stay_syncSettings: true,
        auto_time: {
            activation: "18:00",
            deactivation: "9:00"
        },
        auto_location: {
            latitude: null,
            longitude: null
        },
        stay_theme: DEFAULT_THEME,
        stay_presets: [],
        stay_customThemes: [],
        stay_detectDarkTheme: false,
        stay_enableForPDF: true,
        currentTabUrl:"",
        frameUrl:"",
    };

    const CONFIG_URLs = {
        darkSites: {
            remote: "https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/dark-sites.config",
            local: "./config/dark-sites.config"
        },
        dynamicThemeFixes: {
            remote: "https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/dynamic-theme-fixes.config",
            local: "./config/dynamic-theme-fixes.config"
        },
        inversionFixes: {
            remote: "https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/inversion-fixes.config",
            local: "./config/inversion-fixes.config"
        },
        staticThemes: {
            remote: "https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/static-themes.config",
            local: "./config/static-themes.config"
        },
        colorSchemes: {
            remote: "https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/color-schemes.drconf",
            local: "./config/color-schemes.drconf"
        }
    };

    const SEPERATOR = "=".repeat(32);
    const backgroundPropertyLength = "background: ".length;
    const textPropertyLength = "text: ".length;
    const humanizeNumber = (number) => {
        if (number > 3) {
            return `${number}th`;
        }
        switch (number) {
            case 0:
                return "0";
            case 1:
                return "1st";
            case 2:
                return "2nd";
            case 3:
                return "3rd";
        }
    };
    const isValidHexColor = (color) => {
        return /^#([0-9a-fA-F]{3}){1,2}$/.test(color);
    };
    function ParseColorSchemeConfig(config) {
        const sections = config.split(`${SEPERATOR}\n\n`);
        const definedColorSchemeNames = new Set();
        let lastDefinedColorSchemeName = "";
        const definedColorSchemes = {
            light: {},
            dark: {}
        };
        let interrupt = false;
        let error = null;
        const throwError = (message) => {
            if (!interrupt) {
                interrupt = true;
                error = message;
            }
        };
        sections.forEach((section) => {
            if (interrupt) {
                return;
            }
            const lines = section.split("\n");
            const name = lines[0];
            if (!name) {
                throwError("No color scheme name was found.");
                return;
            }
            if (definedColorSchemeNames.has(name)) {
                throwError(
                    `The color scheme name "${name}" is already defined.`
                );
                return;
            }
            if (
                lastDefinedColorSchemeName &&
                lastDefinedColorSchemeName !== "Default" &&
                name.localeCompare(lastDefinedColorSchemeName) < 0
            ) {
                throwError(
                    `The color scheme name "${name}" is not in alphabetical order.`
                );
                return;
            }
            lastDefinedColorSchemeName = name;
            definedColorSchemeNames.add(name);
            if (lines[1]) {
                throwError(
                    `The second line of the color scheme "${name}" is not empty.`
                );
                return;
            }
            const checkVariant = (lineIndex, isSecondVariant) => {
                const variant = lines[lineIndex];
                if (!variant) {
                    throwError(
                        `The third line of the color scheme "${name}" is not defined.`
                    );
                    return;
                }
                if (
                    variant !== "LIGHT" &&
                    variant !== "DARK" &&
                    isSecondVariant &&
                    variant === "Light"
                ) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex
                        )} line of the color scheme "${name}" is not a valid variant.`
                    );
                    return;
                }
                const firstProperty = lines[lineIndex + 1];
                if (!firstProperty) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 1
                        )} line of the color scheme "${name}" is not defined.`
                    );
                    return;
                }
                if (!firstProperty.startsWith("background: ")) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 1
                        )} line of the color scheme "${name}" is not background-color property.`
                    );
                    return;
                }
                const backgroundColor = firstProperty.slice(
                    backgroundPropertyLength
                );
                if (!isValidHexColor(backgroundColor)) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 1
                        )} line of the color scheme "${name}" is not a valid hex color.`
                    );
                    return;
                }
                const secondProperty = lines[lineIndex + 2];
                if (!secondProperty) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 2
                        )} line of the color scheme "${name}" is not defined.`
                    );
                    return;
                }
                if (!secondProperty.startsWith("text: ")) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 2
                        )} line of the color scheme "${name}" is not text-color property.`
                    );
                    return;
                }
                const textColor = secondProperty.slice(textPropertyLength);
                if (!isValidHexColor(textColor)) {
                    throwError(
                        `The ${humanizeNumber(
                            lineIndex + 2
                        )} line of the color scheme "${name}" is not a valid hex color.`
                    );
                    return;
                }
                return {
                    backgroundColor,
                    textColor,
                    variant
                };
            };
            const firstVariant = checkVariant(2, false);
            const isFirstVariantLight = firstVariant.variant === "LIGHT";
            delete firstVariant.variant;
            if (interrupt) {
                return;
            }
            let secondVariant = null;
            let isSecondVariantLight = false;
            if (lines[6]) {
                secondVariant = checkVariant(6, true);
                isSecondVariantLight = secondVariant.variant === "LIGHT";
                delete secondVariant.variant;
                if (interrupt) {
                    return;
                }
                if (lines.length > 11 || lines[9] || lines[10]) {
                    throwError(
                        `The color scheme "${name}" doesn't end with 1 new line.`
                    );
                    return;
                }
            } else if (lines.length > 7) {
                throwError(
                    `The color scheme "${name}" doesn't end with 1 new line.`
                );
                return;
            }
            if (secondVariant) {
                if (isFirstVariantLight === isSecondVariantLight) {
                    throwError(
                        `The color scheme "${name}" has the same variant twice.`
                    );
                    return;
                }
                if (isFirstVariantLight) {
                    definedColorSchemes.light[name] = firstVariant;
                    definedColorSchemes.dark[name] = secondVariant;
                } else {
                    definedColorSchemes.light[name] = secondVariant;
                    definedColorSchemes.dark[name] = firstVariant;
                }
            } else if (isFirstVariantLight) {
                definedColorSchemes.light[name] = firstVariant;
            } else {
                definedColorSchemes.dark[name] = firstVariant;
            }
        });
        return {result: definedColorSchemes, error: error};
    }
    function parseArray(text) {
        return text
            .replace(/\r/g, "")
            .split("\n")
            .map((s) => s.trim())
            .filter((s) => s);
    }
    async function readText(params) {
        return new Promise((resolve, reject) => {
            if (isXMLHttpRequestSupported) {
                const request = new XMLHttpRequest();
                request.overrideMimeType("text/plain");
                request.open("GET", params.url, true);
                request.onload = () => {
                    if (request.status >= 200 && request.status < 300) {
                        resolve(request.responseText);
                    } else {
                        reject(
                            new Error(
                                `${request.status}: ${request.statusText}`
                            )
                        );
                    }
                };
                request.onerror = () =>
                    reject(
                        new Error(`${request.status}: ${request.statusText}`)
                    );
                if (params.timeout) {
                    request.timeout = params.timeout;
                    request.ontimeout = () =>
                        reject(
                            new Error("File loading stopped due to timeout")
                        );
                }
                request.send();
            } else if (isFetchSupported) {
                let abortController;
                let signal;
                let timedOut = false;
                if (params.timeout) {
                    abortController = new AbortController();
                    signal = abortController.signal;
                    setTimeout(() => {
                        abortController.abort();
                        timedOut = true;
                    }, params.timeout);
                }
                fetch(params.url, {signal})
                    .then((response) => {
                        if (response.status >= 200 && response.status < 300) {
                            resolve(response.text());
                        } else {
                            reject(
                                new Error(
                                    `${response.status}: ${response.statusText}`
                                )
                            );
                        }
                    })
                    .catch((error) => {
                        if (timedOut) {
                            reject(
                                new Error("File loading stopped due to timeout")
                            );
                        } else {
                            reject(error);
                        }
                    });
            } else {
                reject(
                    new Error(
                        `Neither XMLHttpRequest nor Fetch API are accessible!`
                    )
                );
            }
        });
    }
    const REMOTE_TIMEOUT_MS = getDuration({seconds: 10});
    class ConfigManager {
        constructor() {
            this.raw = {
                darkSites: null,
                dynamicThemeFixes: null,
                inversionFixes: null,
                staticThemes: null,
                colorSchemes: null
            };
            this.overrides = {
                darkSites: null,
                dynamicThemeFixes: null,
                inversionFixes: null,
                staticThemes: null
            };
        }
        async loadConfig({name, local, localURL, remoteURL}) {
            let $config;
            const loadLocal = async () => await readText({url: localURL});
            if (local) {
                $config = await loadLocal();
            } else {
                try {
                    $config = await readText({
                        url: `${remoteURL}?nocache=${Date.now()}`,
                        timeout: REMOTE_TIMEOUT_MS
                    });
                } catch (err) {
                    console.error(`${name} remote load error`, err);
                    $config = await loadLocal();
                }
            }
            return $config;
        }
        async loadColorSchemes({local}) {
            // let stayImg = browser.runtime.getURL("images/icon-256.png");
            const $config = await this.loadConfig({
                name: "Color Schemes",
                local,
                localURL: CONFIG_URLs.colorSchemes.local,
                remoteURL: CONFIG_URLs.colorSchemes.remote
            });
            this.raw.colorSchemes = $config;
            this.handleColorSchemes();
        }
        async loadDarkSites({local}) {
            const sites = await this.loadConfig({
                name: "Dark Sites",
                local,
                localURL: CONFIG_URLs.darkSites.local,
                remoteURL: CONFIG_URLs.darkSites.remote
            });
            this.raw.darkSites = sites;
            this.handleDarkSites();
        }
        async loadDynamicThemeFixes({local}) {
            const fixes = await this.loadConfig({
                name: "Dynamic Theme Fixes",
                local,
                localURL: CONFIG_URLs.dynamicThemeFixes.local,
                remoteURL: CONFIG_URLs.dynamicThemeFixes.remote
            });
            // console.log("loadDynamicThemeFixes-----",fixes.length, fixes);
            this.raw.dynamicThemeFixes = fixes;
            this.handleDynamicThemeFixes();
        }
        async loadInversionFixes({local}) {
            const fixes = await this.loadConfig({
                name: "Inversion Fixes",
                local,
                localURL: CONFIG_URLs.inversionFixes.local,
                remoteURL: CONFIG_URLs.inversionFixes.remote
            });
            this.raw.inversionFixes = fixes;
            this.handleInversionFixes();
        }
        async loadStaticThemes({local}) {
            const themes = await this.loadConfig({
                name: "Static Themes",
                local,
                localURL: CONFIG_URLs.staticThemes.local,
                remoteURL: CONFIG_URLs.staticThemes.remote
            });
            this.raw.staticThemes = themes;
            this.handleStaticThemes();
        }
        async load(config) {
            await Promise.all([
                this.loadColorSchemes(config),
                this.loadDarkSites(config),
                this.loadDynamicThemeFixes(config),
                this.loadInversionFixes(config),
                this.loadStaticThemes(config)
            ]).catch((err) => console.error("Fatality", err));
        }   
        handleColorSchemes() {
            const $config = this.raw.colorSchemes;
            const {result, error} = ParseColorSchemeConfig($config);
            if (error) {
                this.COLOR_SCHEMES_RAW = DEFAULT_COLORSCHEME;
                return;
            }
            this.COLOR_SCHEMES_RAW = result;
        }
        handleDarkSites() {
            const $sites = this.overrides.darkSites || this.raw.darkSites;
            this.DARK_SITES = parseArray($sites);
        }
        handleDynamicThemeFixes() {
            const $fixes =
                this.overrides.dynamicThemeFixes || this.raw.dynamicThemeFixes;
            this.DYNAMIC_THEME_FIXES_INDEX = indexSitesFixesConfig($fixes);
            // console.log("this.DYNAMIC_THEME_FIXES_INDEX-----", this.DYNAMIC_THEME_FIXES_INDEX);
            this.DYNAMIC_THEME_FIXES_RAW = $fixes;
        }
        handleInversionFixes() {
            const $fixes =
                this.overrides.inversionFixes || this.raw.inversionFixes;
            this.INVERSION_FIXES_INDEX = indexSitesFixesConfig($fixes);
            this.INVERSION_FIXES_RAW = $fixes;
        }
        handleStaticThemes() {
            const $themes =
                this.overrides.staticThemes || this.raw.staticThemes;
            this.STATIC_THEMES_INDEX = indexSitesFixesConfig($themes);
            this.STATIC_THEMES_RAW = $themes;
        }
    }
    function isFullyQualifiedDomain(candidate) {
        return /^[a-z0-9.-]+$/.test(candidate);
    }
    function encodeOffsets(offsets) {
        return offsets
            .map(([offset, length]) => {
                const stringOffset = offset.toString(36);
                const stringLength = length.toString(36);
                return (
                    "0".repeat(4 - stringOffset.length) +
                    stringOffset +
                    "0".repeat(3 - stringLength.length) +
                    stringLength
                );
            })
            .join("");
    }
    function decodeOffset(offsets, index) {
        const base = (4 + 3) * index;
        const offset = parseInt(offsets.substring(base + 0, base + 4), 36);
        const length = parseInt(offsets.substring(base + 4, base + 4 + 3), 36);
        return [offset, offset + length];
    }
    function indexSitesFixesConfig(text) {
        const domains = {};
        const domainPatterns = {};
        const offsets = [];
        function processBlock(recordStart, recordEnd, index) {
            const block = text.substring(recordStart, recordEnd);
            const lines = block.split("\n");
            const commandIndices = [];
            lines.forEach((ln, i) => {
                if (ln.match(/^[A-Z]+(\s[A-Z]+){0,2}$/)) {
                    commandIndices.push(i);
                }
            });
            if (commandIndices.length === 0) {
                return;
            }
            const urls = parseArray(
                lines.slice(0, commandIndices[0]).join("\n")
            );
            for (const url of urls) {
                const domain = getDomain(url);
                if (isFullyQualifiedDomain(domain)) {
                    if (!domains[domain]) {
                        domains[domain] = index;
                    } else if (
                        typeof domains[domain] === "number" &&
                        domains[domain] !== index
                    ) {
                        domains[domain] = [domains[domain], index];
                    } else if (
                        typeof domains[domain] === "object" &&
                        !domains[domain].includes(index)
                    ) {
                        domains[domain].push(index);
                    }
                    continue;
                }
                if (!domainPatterns[domain]) {
                    domainPatterns[domain] = index;
                } else if (
                    typeof domainPatterns[domain] === "number" &&
                    domainPatterns[domain] !== index
                ) {
                    domainPatterns[domain] = [domainPatterns[domain], index];
                } else if (
                    typeof domainPatterns[domain] === "object" &&
                    !domainPatterns[domain].includes(index)
                ) {
                    domainPatterns[domain].push(index);
                }
            }
            offsets.push([recordStart, recordEnd - recordStart]);
        }
        let recordStart = 0;
        const delimiterRegex = /^\s*={2,}\s*$/gm;
        let delimiter;
        let count = 0;
        while ((delimiter = delimiterRegex.exec(text))) {
            const nextDelimiterStart = delimiter.index;
            const nextDelimiterEnd = delimiter.index + delimiter[0].length;
            processBlock(recordStart, nextDelimiterStart, count);
            recordStart = nextDelimiterEnd;
            count++;
        }
        processBlock(recordStart, text.length, count);
        return {
            offsets: encodeOffsets(offsets),
            domains,
            domainPatterns,
            cache: {}
        };
    }
    async function readLocalStorage(defaults) {
        return new Promise((resolve) => {
            browser.storage.local.get(defaults, (local) => {
                // console.log("readLocalStorage--------------====defaults=",defaults, ",-----local=======", local);
                if (browser.runtime.lastError) {
                    console.error(browser.runtime.lastError.message);
                    resolve(defaults);
                    return;
                }
                resolve(local);
            });
        });
    }
    async function readSyncStorage(defaults) {
        return new Promise((resolve) => {
            browser.storage.sync.get(null, (sync) => {
                if (browser.runtime.lastError) {
                    console.error(browser.runtime.lastError.message);
                    resolve(null);
                    return;
                }
                for (const key in sync) {
                    if (!sync[key]) {
                        continue;
                    }
                    const metaKeysCount = sync[key].__meta_split_count;
                    if (!metaKeysCount) {
                        continue;
                    }
                    let string = "";
                    for (let i = 0; i < metaKeysCount; i++) {
                        string += sync[`${key}_${i.toString(36)}`];
                        delete sync[`${key}_${i.toString(36)}`];
                    }
                    try {
                        sync[key] = JSON.parse(string);
                    } catch (error) {
                        console.error(
                            `sync[${key}]: Could not parse record from sync storage: ${string}`
                        );
                        resolve(null);
                        return;
                    }
                }
                sync = {
                    ...defaults,
                    ...sync
                };
                resolve(sync);
            });
        });
    }
    function prepareSyncStorage(values) {
        for (const key in values) {
            const value = values[key];
            // console.log(value,",values---------", values)
            if( !value || typeof value == "undefined" ){
                continue;
            }
            const string = value && typeof value !== "undefined" ? JSON.stringify(value) : "";
            const totalLength = string.length + key.length;
            if (totalLength > browser.storage.sync.QUOTA_BYTES_PER_ITEM) {
                const maxLength = browser.storage.sync.QUOTA_BYTES_PER_ITEM - key.length - 1 - 2;
                const minimalKeysNeeded = Math.ceil(string.length / maxLength);
                for (let i = 0; i < minimalKeysNeeded; i++) {
                    values[`${key}_${i.toString(36)}`] = string.substring(
                        i * maxLength,
                        (i + 1) * maxLength
                    );
                }
                values[key] = {
                    __meta_split_count: minimalKeysNeeded
                };
            }
        }
        return values;
    }
    async function writeSyncStorage(values) {
        return new Promise(async (resolve, reject) => {
            const packaged = prepareSyncStorage(values);
            browser.storage.sync.set(packaged, () => {
                if (browser.runtime.lastError) {
                    reject(browser.runtime.lastError);
                    return;
                }
                resolve();
            });
        });
    }
    async function writeLocalStorage(values) {
        return new Promise(async (resolve) => {
            browser.storage.local.set(values, () => {
                resolve();
            });
        });
    }
    function getDurationInMinutes(time) {
        return getDuration(time) / 1000 / 60;
    }
    function getSunsetSunriseUTCTime(latitude, longitude, date) {
        const dec31 = Date.UTC(date.getUTCFullYear(), 0, 0, 0, 0, 0, 0);
        const oneDay = getDuration({days: 1});
        const dayOfYear = Math.floor((date.getTime() - dec31) / oneDay);
        const zenith = 90.83333333333333;
        const D2R = Math.PI / 180;
        const R2D = 180 / Math.PI;
        const lnHour = longitude / 15;
        function getTime(isSunrise) {
            const t = dayOfYear + ((isSunrise ? 6 : 18) - lnHour) / 24;
            const M = 0.9856 * t - 3.289;
            let L =
                M +
                1.916 * Math.sin(M * D2R) +
                0.02 * Math.sin(2 * M * D2R) +
                282.634;
            if (L > 360) {
                L -= 360;
            } else if (L < 0) {
                L += 360;
            }
            let RA = R2D * Math.atan(0.91764 * Math.tan(L * D2R));
            if (RA > 360) {
                RA -= 360;
            } else if (RA < 0) {
                RA += 360;
            }
            const Lquadrant = Math.floor(L / 90) * 90;
            const RAquadrant = Math.floor(RA / 90) * 90;
            RA += Lquadrant - RAquadrant;
            RA /= 15;
            const sinDec = 0.39782 * Math.sin(L * D2R);
            const cosDec = Math.cos(Math.asin(sinDec));
            const cosH =
                (Math.cos(zenith * D2R) - sinDec * Math.sin(latitude * D2R)) /
                (cosDec * Math.cos(latitude * D2R));
            if (cosH > 1) {
                return {
                    alwaysDay: false,
                    alwaysNight: true,
                    time: 0
                };
            } else if (cosH < -1) {
                return {
                    alwaysDay: true,
                    alwaysNight: false,
                    time: 0
                };
            }
            const H =
                (isSunrise
                    ? 360 - R2D * Math.acos(cosH)
                    : R2D * Math.acos(cosH)) / 15;
            const T = H + RA - 0.06571 * t - 6.622;
            let UT = T - lnHour;
            if (UT > 24) {
                UT -= 24;
            } else if (UT < 0) {
                UT += 24;
            }
            return {
                alwaysDay: false,
                alwaysNight: false,
                time: Math.round(UT * getDuration({hours: 1}))
            };
        }
        const sunriseTime = getTime(true);
        const sunsetTime = getTime(false);
        if (sunriseTime.alwaysDay || sunsetTime.alwaysDay) {
            return {
                alwaysDay: true
            };
        } else if (sunriseTime.alwaysNight || sunsetTime.alwaysNight) {
            return {
                alwaysNight: true
            };
        }
        return {
            sunriseTime: sunriseTime.time,
            sunsetTime: sunsetTime.time
        };
    }
    function isNightAtLocation(latitude, longitude, date = new Date()) {
        const time = getSunsetSunriseUTCTime(latitude, longitude, date);
        if (time.alwaysDay) {
            return false;
        } else if (time.alwaysNight) {
            return true;
        }
        const sunriseTime = time.sunriseTime;
        const sunsetTime = time.sunsetTime;
        const currentTime =
            date.getUTCHours() * getDuration({hours: 1}) +
            date.getUTCMinutes() * getDuration({minutes: 1}) +
            date.getUTCSeconds() * getDuration({seconds: 1}) +
            date.getUTCMilliseconds();
        return isInTimeIntervalUTC(sunsetTime, sunriseTime, currentTime);
    }
    function nextTimeChangeAtLocation(latitude, longitude, date = new Date()) {
        const time = getSunsetSunriseUTCTime(latitude, longitude, date);
        if (time.alwaysDay) {
            return date.getTime() + getDuration({days: 1});
        } else if (time.alwaysNight) {
            return date.getTime() + getDuration({days: 1});
        }
        const [firstTimeOnDay, lastTimeOnDay] =
            time.sunriseTime < time.sunsetTime
                ? [time.sunriseTime, time.sunsetTime]
                : [time.sunsetTime, time.sunriseTime];
        const currentTime =
            date.getUTCHours() * getDuration({hours: 1}) +
            date.getUTCMinutes() * getDuration({minutes: 1}) +
            date.getUTCSeconds() * getDuration({seconds: 1}) +
            date.getUTCMilliseconds();
        if (currentTime <= firstTimeOnDay) {
            return Date.UTC(
                date.getUTCFullYear(),
                date.getUTCMonth(),
                date.getUTCDate(),
                0,
                0,
                0,
                firstTimeOnDay
            );
        }
        if (currentTime <= lastTimeOnDay) {
            return Date.UTC(
                date.getUTCFullYear(),
                date.getUTCMonth(),
                date.getUTCDate(),
                0,
                0,
                0,
                lastTimeOnDay
            );
        }
        return Date.UTC(
            date.getUTCFullYear(),
            date.getUTCMonth(),
            date.getUTCDate() + 1,
            0,
            0,
            0,
            firstTimeOnDay
        );
    }
    function parse24HTime(time) {
        return time.split(":").map((x) => parseInt(x));
    }
    /**
     * 
     * @param {array} time1 
     * @param {array} time2 
     * @returns 0:时间一样，-1：同一天时间内，1：隔天区间
     */
    function compareTime(time1, time2) {
        if (time1[0] === time2[0] && time1[1] === time2[1]) {
            return 0;
        }
        if (
            time1[0] < time2[0] ||
            (time1[0] === time2[0] && time1[1] < time2[1])
        ) {
            return -1;
        }
        return 1;
    }
    function nextTimeInterval(time0, time1, date = new Date()) {
        const a = parse24HTime(time0);
        const b = parse24HTime(time1);
        const t = [date.getHours(), date.getMinutes()];
        if (compareTime(a, b) > 0) {
            return nextTimeInterval(time1, time0, date);
        }
        if (compareTime(a, b) === 0) {
            return null;
        }
        if (compareTime(t, a) < 0) {
            date.setHours(a[0]);
            date.setMinutes(a[1]);
            date.setSeconds(0);
            date.setMilliseconds(0);
            return date.getTime();
        }
        if (compareTime(t, b) < 0) {
            date.setHours(b[0]);
            date.setMinutes(b[1]);
            date.setSeconds(0);
            date.setMilliseconds(0);
            return date.getTime();
        }
        return new Date(
            date.getFullYear(),
            date.getMonth(),
            date.getDate() + 1,
            a[0],
            a[1]
        ).getTime();
    }
    /**
     * 判断预设自动时间是否到点
     * @param {date} time0  startTime
     * @param {date} time1  endTime
     * @param {date} date   currentTime
     * @returns true:到达预设时间范围内，false:不在预设时间范围呢
     */
    function isInTimeIntervalLocal(time0, time1, date = new Date()) {
        const a = parse24HTime(time0);
        const b = parse24HTime(time1);
        const t = [date.getHours(), date.getMinutes()];
        // 正常区间内, 是否到了设置时间范围
        if (compareTime(a, b) > 0) {
            // 判断当前时间是否已经到了设置时间
            return compareTime(a, t) <= 0 || compareTime(t, b) < 0;
        }
        return compareTime(a, t) <= 0 && compareTime(t, b) < 0;
    }
    const matchesMediaQuery = (query) => {
        if ("window" in globalThis) {
            return Boolean(window.matchMedia(query).matches);
        }
        return false;
    };
    const matchesDarkTheme = () => matchesMediaQuery("(prefers-color-scheme: dark)");
    const matchesLightTheme = () => matchesMediaQuery("(prefers-color-scheme: light)");
    const isColorSchemeSupported = matchesDarkTheme() || matchesLightTheme();
    function isSystemDarkModeEnabled() {
        if (!isColorSchemeSupported) {
            return false;
        }
        return matchesDarkTheme();
    }
    function createValidator() {
        const errors = [];
        function validateProperty(obj, key, validator, fallback) {
            if (!obj.hasOwnProperty(key) || validator(obj[key])) {
                return;
            }
            errors.push(
                `Unexpected value for "${key}": ${JSON.stringify(obj[key])}`
            );
            obj[key] = fallback[key];
        }
        function validateArray(obj, key, validator) {
            if (!obj.hasOwnProperty(key)) {
                return;
            }
            const wrongValues = new Set();
            const arr = obj[key];
            for (let i = 0; i < arr.length; i++) {
                if (!validator(arr[i])) {
                    wrongValues.add(arr[i]);
                    arr.splice(i, 1);
                    i--;
                }
            }
            if (wrongValues.size > 0) {
                errors.push(
                    `Array "${key}" has wrong values: ${Array.from(wrongValues)
                        .map((v) => JSON.stringify(v))
                        .join("; ")}`
                );
            }
        }
        return {validateProperty, validateArray, errors};
    }
    function isPlainObject(x) {
        return typeof x === "object" && x != null && !Array.isArray(x);
    }
    function isBoolean(x) {
        return typeof x === "boolean";
    }
    function isArray(x) {
        return Array.isArray(x);
    }
    function isString(x) {
        return typeof x === "string";
    }
    function isNonEmptyString(x) {
        return x && isString(x);
    }
    function isNonEmptyArrayOfNonEmptyStrings(x) {
        return (
            Array.isArray(x) &&
            x.length > 0 &&
            x.every((s) => isNonEmptyString(s))
        );
    }
    function isRegExpMatch(regexp) {
        return (x) => {
            return isString(x) && x.match(regexp) != null;
        };
    }
    const isTime = isRegExpMatch(
        /^((0?[0-9])|(1[0-9])|(2[0-3])):([0-5][0-9])$/
    );
    function isNumber(x) {
        return typeof x === "number" && !isNaN(x);
    }
    function isNumberBetween(min, max) {
        return (x) => {
            return isNumber(x) && x >= min && x <= max;
        };
    }
    function isOneOf(...values) {
        return (x) => values.includes(x);
    }
    function hasRequiredProperties(obj, keys) {
        return keys.every((key) => obj.hasOwnProperty(key));
    }
    function validateSettings(settings) {
        if (!isPlainObject(settings)) {
            return {
                errors: ["Settings are not a plain object"],
                settings: DEFAULT_SETTINGS
            };
        }
        const {validateProperty, validateArray, errors} = createValidator();
        const isValidPresetTheme = (theme) => {
            if (!isPlainObject(theme)) {
                return false;
            }
            const {errors: themeErrors} = validateTheme(theme);
            return themeErrors.length === 0;
        };
        validateProperty(settings, "toggleStatus", isString, DEFAULT_SETTINGS);
        validateProperty(settings, "currentTabUrl", isString, DEFAULT_SETTINGS);
        validateProperty(settings, "frameUrl", isString, DEFAULT_SETTINGS);
        validateProperty(settings, "isStayAround", isString, DEFAULT_SETTINGS);
        validateProperty(settings, "stay_theme", isPlainObject, DEFAULT_SETTINGS);
        const {errors: themeErrors} = validateTheme(settings.stay_theme);
        errors.push(...themeErrors);
        validateProperty(settings, "stay_presets", isArray, DEFAULT_SETTINGS);
        validateArray(settings, "stay_presets", (preset) => {
            const presetValidator = createValidator();
            if (
                !(
                    isPlainObject(preset) &&
                    hasRequiredProperties(preset, [
                        "id",
                        "name",
                        "urls",
                        "theme"
                    ])
                )
            ) {
                return false;
            }
            presetValidator.validateProperty(
                preset,
                "id",
                isNonEmptyString,
                preset
            );
            presetValidator.validateProperty(
                preset,
                "name",
                isNonEmptyString,
                preset
            );
            presetValidator.validateProperty(
                preset,
                "urls",
                isNonEmptyArrayOfNonEmptyStrings,
                preset
            );
            presetValidator.validateProperty(
                preset,
                "theme",
                isValidPresetTheme,
                preset
            );
            return presetValidator.errors.length === 0;
        });
        validateProperty(settings, "stay_customThemes", isArray, DEFAULT_SETTINGS);
        validateArray(settings, "stay_customThemes", (custom) => {
            if (
                !(
                    isPlainObject(custom) &&
                    hasRequiredProperties(custom, ["url", "theme"])
                )
            ) {
                return false;
            }
            const presetValidator = createValidator();
            presetValidator.validateProperty(
                custom,
                "url",
                isNonEmptyArrayOfNonEmptyStrings,
                custom
            );
            presetValidator.validateProperty(
                custom,
                "stay_theme",
                isValidPresetTheme,
                custom
            );
            return presetValidator.errors.length === 0;
        });

        validateProperty(settings, "stay_syncSettings", isBoolean, DEFAULT_SETTINGS);
        validateProperty(settings, "siteListDisabled", isArray, DEFAULT_SETTINGS);
        validateArray(settings, "siteListDisabled", isNonEmptyString);
       
        validateProperty(
            settings,
            "stay_automation",
            isOneOf("", "time", "system", "location"),
            DEFAULT_SETTINGS
        );
        validateProperty(
            settings,
            "stay_automationBehaviour",
            isOneOf("OnOff", "Scheme"),
            DEFAULT_SETTINGS
        );
        validateProperty(
            settings,
            "auto_time",
            (time) => {
                if (!isPlainObject(time)) {
                    return false;
                }
                const timeValidator = createValidator();
                timeValidator.validateProperty(
                    time,
                    "activation",
                    isTime,
                    time
                );
                timeValidator.validateProperty(
                    time,
                    "deactivation",
                    isTime,
                    time
                );
                return timeValidator.errors.length === 0;
            },
            DEFAULT_SETTINGS
        );
        validateProperty(
            settings,
            "auto_location",
            (location) => {
                if (!isPlainObject(location)) {
                    return false;
                }
                const locValidator = createValidator();
                const isValidLoc = (x) => x === null || isNumber(x);
                locValidator.validateProperty(
                    location,
                    "latitude",
                    isValidLoc,
                    location
                );
                locValidator.validateProperty(
                    location,
                    "longitude",
                    isValidLoc,
                    location
                );
                return locValidator.errors.length === 0;
            },
            DEFAULT_SETTINGS
        );
        validateProperty(
            settings,
            "stay_detectDarkTheme",
            isBoolean,
            DEFAULT_SETTINGS
        );
        return {errors, settings};
    }
    function validateTheme(theme) {
        if (!isPlainObject(theme)) {
            return {
                errors: ["Theme is not a plain object"],
                theme: DEFAULT_THEME
            };
        }
        const {validateProperty, errors} = createValidator();
        validateProperty(theme, "mode", isOneOf(0, 1), DEFAULT_THEME);
        validateProperty(
            theme,
            "brightness",
            isNumberBetween(0, 200),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "contrast",
            isNumberBetween(0, 200),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "grayscale",
            isNumberBetween(0, 100),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "sepia",
            isNumberBetween(0, 100),
            DEFAULT_THEME
        );
        validateProperty(theme, "useFont", isBoolean, DEFAULT_THEME);
        validateProperty(theme, "fontFamily", isNonEmptyString, DEFAULT_THEME);
        validateProperty(
            theme,
            "textStroke",
            isNumberBetween(0, 1),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "engine",
            isOneOf("dynamicTheme", "staticTheme", "cssFilter", "svgFilter"),
            DEFAULT_THEME
        );
        validateProperty(theme, "stylesheet", isString, DEFAULT_THEME);
        validateProperty(
            theme,
            "darkSchemeBackgroundColor",
            isRegExpMatch(/^#[0-9a-f]{6}$/i),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "darkSchemeTextColor",
            isRegExpMatch(/^#[0-9a-f]{6}$/i),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "lightSchemeBackgroundColor",
            isRegExpMatch(/^#[0-9a-f]{6}$/i),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "lightSchemeTextColor",
            isRegExpMatch(/^#[0-9a-f]{6}$/i),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "scrollbarColor",
            (x) => x === "" || isRegExpMatch(/^(auto)|(#[0-9a-f]{6})$/i)(x),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "selectionColor",
            isRegExpMatch(/^(auto)|(#[0-9a-f]{6})$/i),
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "styleSystemControls",
            isBoolean,
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "lightColorScheme",
            isNonEmptyString,
            DEFAULT_THEME
        );
        validateProperty(
            theme,
            "darkColorScheme",
            isNonEmptyString,
            DEFAULT_THEME
        );
        validateProperty(theme, "immediateModify", isBoolean, DEFAULT_THEME);
        return {errors, theme};
    }
    function debounce(delay, fn) {
        let timeoutId = null;
        return (...args) => {
            if (timeoutId) {
                clearTimeout(timeoutId);
            }
            timeoutId = setTimeout(() => {
                timeoutId = null;
                fn(...args);
            }, delay);
        };
    }
    const SAVE_TIMEOUT = 1000;
    class UserStorage {
        constructor() {
            this.saveSettingsIntoStorage = debounce(SAVE_TIMEOUT, async () => {
                if (this.saveStorageBarrier) {
                    await this.saveStorageBarrier.entry();
                    return;
                }
                this.saveStorageBarrier = new PromiseBarrier();
                const settings = this.settings;
                await writeLocalStorage(settings);
                // console.log("saveSettingsIntoStorage===", settings);
                if (settings.stay_syncSettings) {
                    try {
                        await writeSyncStorage(settings);
                        
                    } catch (err) {
                        logWarn(
                            "Settings synchronization was disabled due to error:",
                            browser.runtime.lastError
                        );
                        this.set({stay_syncSettings: false});
                        await this.saveSyncSetting(false);
                    }
                } 

                this.saveStorageBarrier.resolve();
                this.saveStorageBarrier = null;
            });
            this.settings = null;
        }
        async loadSettings() {
            this.settings = await this.loadSettingsFromStorage();
            // console.log("loadSettings===",this.settings)
            // let isStayAround = this.settings.isStayAround;
            let isStayAround = await this.getStayAround();
            this.settings.isStayAround = isStayAround;
            this.writeStayAroundIntoStorage(this.settings);
            return new Promise((resolve, reject) => {
                resolve(this.settings);
            });
        }

        // 获取isStayAround
        async getStayAround(){
            return new Promise((resolve, reject) => {
                browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
                    resolve(response.body);
                });
            });
        }

        async writeStayAroundIntoStorage(settings){
            let isStayAround = await this.getStayAround();
            settings = { ...settings, isStayAround };
            this.settings = settings
            // console.log("writeStayAroundIntoStorage=====", settings)
            writeSyncStorage(settings);
            writeLocalStorage(settings);
        }

        fillDefaults(settings) {
            settings.stay_theme = {...DEFAULT_THEME, ...settings.stay_theme};
            settings.auto_time = {...DEFAULT_SETTINGS.auto_time, ...settings.auto_time};
            settings.stay_presets.forEach((preset) => {
                preset.theme = {...DEFAULT_THEME, ...preset.theme};
            });
            settings.stay_customThemes.forEach((site) => {
                site.theme = {...DEFAULT_THEME, ...site.theme};
            });
        }
        async loadSettingsFromStorage() {
            // if (this.loadBarrier) {
            //     const settings = await this.loadBarrier.entry();
            //     console.log("settings--------", settings);
            //     return settings;
            // }
            this.loadBarrier = new PromiseBarrier();
            const local = await readLocalStorage(DEFAULT_SETTINGS);
            // console.log("loadSettingsFromStorage-----", local);
            const {errors: localCfgErrors} = validateSettings(local);
            localCfgErrors.forEach((err) => logWarn(err));
            if (!local.stay_syncSettings) {
                this.fillDefaults(local);
                this.loadBarrier.resolve(local);
                return local;
            }
            const $sync = await readSyncStorage(DEFAULT_SETTINGS);
            if (!$sync) {
                local.stay_syncSettings = false;
                this.settings["stay_syncSettings"] = false;
                this.saveSyncSetting(false);
                this.loadBarrier.resolve(local);
                return local;
            }
            const {errors: syncCfgErrors} = validateSettings($sync);
            syncCfgErrors.forEach((err) => logWarn(err));
            this.fillDefaults($sync);
            this.loadBarrier.resolve($sync);
            return $sync;
        }
        async saveSyncSetting(sync) {
            const obj = {stay_syncSettings: sync};
            await writeLocalStorage(obj);
            try {
                await writeSyncStorage(obj);
            } catch (err) {
                logWarn(
                    "Settings synchronization was disabled due to error:",
                    browser.runtime.lastError
                );
                this.settings["stay_syncSettings"] = false;
            }
        }
        async saveSettings() {
            await this.saveSettingsIntoStorage();
        }

        set($settings) {
            this.settings = {...this.settings, ...$settings};
            this.saveSettings()
        }
    }

    class PromiseBarrier {
        constructor() {
            this.resolves = [];
            this.rejects = [];
            this.wasResolved = false;
            this.wasRejected = false;
        }
        async entry() {
            if (this.wasResolved) {
                return Promise.resolve(this.resolution);
            }
            if (this.wasRejected) {
                return Promise.reject(this.reason);
            }
            return new Promise((resolve, reject) => {
                this.resolves.push(resolve);
                this.rejects.push(reject);
            });
        }
        async resolve(value) {
            if (this.wasRejected || this.wasResolved) {
                return;
            }
            this.wasResolved = true;
            this.resolution = value;
            this.resolves.forEach((resolve) => resolve(value));
            this.resolves = null;
            this.rejects = null;
            return new Promise((resolve) => setTimeout(() => resolve()));
        }
        async reject(reason) {
            if (this.wasRejected || this.wasResolved) {
                return;
            }
            this.wasRejected = true;
            this.reason = reason;
            this.rejects.forEach((reject) => reject(reason));
            this.resolves = null;
            this.rejects = null;
            return new Promise((resolve) => setTimeout(() => resolve()));
        }
        isPending() {
            return !this.wasResolved && !this.wasRejected;
        }
        isFulfilled() {
            return this.wasResolved;
        }
        isRejected() {
            return this.wasRejected;
        }
    }
    
    function isNonPersistent() {
        const background = browser.runtime.getManifest().background;
        if ("persistent" in background) {
            return background.persistent === false;
        }
        if ("service_worker" in background) {
            return true;
        }
    }

    function logInfo(...args) {}
    function logWarn(...args) {}

    async function queryTabs(query) {
        return new Promise((resolve) => {
            browser.tabs.query(query, (tabs) => resolve(tabs));
        });
    }

    var StateManagerState;
    (function (StateManagerState) {
        StateManagerState[(StateManagerState["INITIAL"] = 0)] = "INITIAL";
        StateManagerState[(StateManagerState["DISABLED"] = 1)] = "DISABLED";
        StateManagerState[(StateManagerState["LOADING"] = 2)] = "LOADING";
        StateManagerState[(StateManagerState["READY"] = 3)] = "READY";
        StateManagerState[(StateManagerState["SAVING"] = 4)] = "SAVING";
        StateManagerState[(StateManagerState["SAVING_OVERRIDE"] = 5)] = "SAVING_OVERRIDE";
    })(StateManagerState || (StateManagerState = {}));

    class StateManager {
        constructor(localStorageKey, parent, defaults) {
            this.meta = StateManagerState.INITIAL;
            this.loadStateBarrier = null;
            if (!isNonPersistent()) {
                this.meta = StateManagerState.DISABLED;
                return;
            }
            this.localStorageKey = localStorageKey;
            this.parent = parent;
            this.defaults = defaults;
        }
        collectState() {
            const state = {};
            for (const key of Object.keys(this.defaults)) {
                state[key] = this.parent[key] || this.defaults[key];
            }
            return state;
        }
        async saveState() {
            switch (this.meta) {
                case StateManagerState.DISABLED:
                    return;
                case StateManagerState.LOADING:
                case StateManagerState.INITIAL:
                    if (this.loadStateBarrier) {
                        await this.loadStateBarrier.entry();
                    }
                    this.meta = StateManagerState.SAVING;
                    break;
                case StateManagerState.READY:
                    this.meta = StateManagerState.SAVING;
                    break;
                case StateManagerState.SAVING:
                    this.meta = StateManagerState.SAVING_OVERRIDE;
                    return;
                case StateManagerState.SAVING_OVERRIDE:
                    return;
            }
            browser.storage.local.set(
                {[this.localStorageKey]: this.collectState()},
                () => {
                    switch (this.meta) {
                        case StateManagerState.INITIAL:
                        case StateManagerState.DISABLED:
                        case StateManagerState.LOADING:
                        case StateManagerState.READY:
                        case StateManagerState.SAVING:
                            this.meta = StateManagerState.READY;
                            break;
                        case StateManagerState.SAVING_OVERRIDE:
                            this.meta = StateManagerState.READY;
                            this.saveState();
                    }
                }
            );
        }
        async loadState() {
            switch (this.meta) {
                case StateManagerState.INITIAL:
                    this.meta = StateManagerState.LOADING;
                    this.loadStateBarrier = new PromiseBarrier();
                    return new Promise((resolve) => {
                        browser.storage.local.get(
                            this.localStorageKey,
                            (data) => {
                                this.meta = StateManagerState.READY;
                                if (data[this.localStorageKey]) {
                                    Object.assign(
                                        this.parent,
                                        data[this.localStorageKey]
                                    );
                                } else {
                                    Object.assign(this.parent, this.defaults);
                                }
                                this.loadStateBarrier.resolve();
                                this.loadStateBarrier = null;
                                resolve();
                            }
                        );
                    });
                case StateManagerState.DISABLED:
                case StateManagerState.READY:
                case StateManagerState.SAVING:
                case StateManagerState.SAVING_OVERRIDE:
                    return;
                case StateManagerState.LOADING:
                    return this.loadStateBarrier.entry();
            }
        }
    }

    function isEnabledUrlState(tabUrl, siteListDisabled){
        let tabDomain = getDomain(tabUrl);
        if(siteListDisabled.includes(tabDomain)){
            return false;
        }else{
            return true;
        }
    }

    async function getCurrentTabUrl(){
        return new Promise((resolve) => {
            browser.tabs.getSelected(null, (tab) => {
                resolve(tab.url);
            });
        });
    }

    class StayDarkModeExtension {
        constructor() {
            this.autoState = "";
            this.wasEnabledOnLastCheck = null;
            this.popupOpeningListener = null;
            this.wasLastColorSchemeDark = null;
            this.startBarrier = null;
            this.stateManager = null;
            this.alarmListener = (alarm) => {
                if (alarm.name === StayDarkModeExtension.ALARM_NAME) {
                    this.callWhenSettingsLoaded(() => {
                        this.handleAutomationCheck();
                    });
                }
            };
            this.onColorSchemeChange = ({isDark}) => {
                if (isSafari) {
                    this.wasLastColorSchemeDark = isDark;
                }
                if (this.user.settings.stay_automation !== "system") {
                    return;
                }
                this.callWhenSettingsLoaded(() => {
                    this.handleAutomationCheck();
                });
            };
            // when automation to dark mode or not
            this.handleAutomationCheck = () => {
                this.updateAutoState();
                const isSwitchedOn = this.isExtensionSwitchedOn();
                if (
                    this.wasEnabledOnLastCheck === null ||
                    this.wasEnabledOnLastCheck !== isSwitchedOn ||
                    this.autoState === "scheme-dark" ||
                    this.autoState === "scheme-light"
                ) {
                    this.wasEnabledOnLastCheck = isSwitchedOn;
                    // todo  to sendMessage to dark.user.js

                    this.handleTabMessage()

                    this.stateManager.saveState();
                }
            };

            this.config = new ConfigManager();
            this.user = new UserStorage();
            this.getAndSentConnectionMessage = (url, frameURL) => {
                // console.log("getAndSentConnectionMessage----settings-",this.user.settings);

                if (this.user.settings) {
                    this.updateAutoState();
                    // console.log("getAndSentConnectionMessage----settings-");
                    this.handleTabMessage(url, frameURL);
                }else{
                    // console.log("getAndSentConnectionMessage----settings----else-----");
                    this.user.loadSettings().then(()=>{
                        this.updateAutoState();
                        this.handleTabMessage(url, frameURL)
                    });
                }
                // return new Promise((resolve) => {
                //     this.user
                //         .loadSettings()
                //         .then(() => resolve(this.handleTabMessage(url, frameURL)));
                // });
            }
            this.handleFetchSettingForFallback = async () => {
                if (!this.user.settings) {
                    await this.user.loadSettings();
                }
                return new Promise((resolve)=>{
                    resolve(this.user.settings)
                })
            }
            this.handleTabMessage = (url, frameUrl=null) => {
                // console.log("this.config====", this.config)
                // console.log("handleTabMessage---this.user.settings=====",this.user.settings, this.autoState);
                let settings = this.user.settings;
                url = url&&url!=null?url:settings.currentTabUrl;
                frameUrl = frameUrl&&frameUrl!=null?frameUrl:settings.frameUrl
                settings = {...settings, ...{currentTabUrl: url, frameUrl: frameUrl}}
                this.user.set(settings);
                const isStayAround = settings.isStayAround;
                const toggleStatus = settings.toggleStatus;
                let darkSetings = {
                    siteListDisabled: settings.siteListDisabled,
                    toggleStatus: toggleStatus,
                    isStayAround: isStayAround,
                    darkState:"clean_up"
                }
                let message = {
                    type: "bg-clean-up",
                    stayDarkSettings: settings,
                    darkSetings
                };
                if(isStayAround && "a" === isStayAround){
                    // console.log("handleTabMessage---isStayAround=====",isStayAround, this.autoState);
                    const toggleStatus = settings.toggleStatus;
                    const urlIsEnabled = isEnabledUrlState(url, settings.siteListDisabled);
                    if(("on" === toggleStatus ||  "scheme-dark" === this.autoState ) && urlIsEnabled){
                        // console.log("handleTabMessage---toggleStatus=====",toggleStatus, urlIsEnabled);
                        darkSetings.darkState = "dark_mode";
                        const custom = settings.stay_customThemes.find(
                            ({url: urlList}) => isURLInList(url, urlList)
                        );
                        const preset = custom
                            ? null
                            : settings.stay_presets.find(({urls}) =>
                                  isURLInList(url, urls)
                              );
                        let theme = custom ? custom.theme : preset ? preset.theme : settings.stay_theme;
                        if ( this.autoState === "scheme-dark" || this.autoState === "scheme-light") {
                            const mode = this.autoState === "scheme-dark" ? 1 : 0;
                            theme = {...theme, mode};
                        }
                        const isIFrame = frameUrl != null;
                        const detectDarkTheme = !isIFrame && settings.stay_detectDarkTheme && !isPDF(url);
                        const fixes = getDynamicThemeFixesFor(
                            url,
                            frameUrl,
                            this.config.DYNAMIC_THEME_FIXES_RAW,
                            this.config.DYNAMIC_THEME_FIXES_INDEX,
                            settings.stay_enableForPDF
                        );
                        // console.log("this.user.settings==fixes===",fixes);
                        message = {
                            type: "bg-add-dynamic-theme",
                            data: {
                                theme,
                                fixes,
                                isIFrame,
                                detectDarkTheme
                            },
                            stayDarkSettings: settings,
                            darkSetings
                        };
                    }
                }

                // return message;
                // console.log("message======",message);
                browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    browser.tabs.sendMessage(
                        tabs[0].id,
                        message
                    );
                })
                
                // if (message instanceof Promise) {
                //     message.then(
                //         (asyncMessage) => {
                //             console.log("asyncMessage======",asyncMessage);
                //             asyncMessage && browser.tabs.sendMessage(
                //                 sender.tab.id,
                //                 asyncMessage,
                //                 {frameId: sender.frameId}
                //             )
                //         }
                //     );
                // } else if (message) {
                //     console.log("message======",message);
                //     browser.tabs.sendMessage(
                //         sender.tab.id,
                //         message,
                //         {frameId: sender.frameId}
                //     );
                // }
                
            }
            
            this.startBarrier = new PromiseBarrier();
            this.stateManager = new StateManager(
                StayDarkModeExtension.LOCAL_STORAGE_KEY,
                this,
                {
                    autoState: "",
                    wasEnabledOnLastCheck: null
                }
            );
            this.handleCSFrameConnect = async (sender) =>{
                await this.stateManager.loadState();
                const tabURL = sender.tab.url;
                const {frameId} = sender;
                const senderURL = sender.url;
                let frameUrl = frameId === 0 ? null : senderURL;
                // console.log("handleCSFrameConnect-----tabURL=",tabURL);
                this.getAndSentConnectionMessage(tabURL, frameUrl);
                this.stateManager.saveState();
            }
            this.handleDarkModeSettingForPopup = async () => {
                const settings = await this.user.loadSettings();
                browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
                    const tabURL = tabs[0].url;
                    let browserDomain = getDomain(tabURL);
                    let siteListDisabled = settings["siteListDisabled"];
                    const enabled = isArray(siteListDisabled)&&siteListDisabled.includes(browserDomain)?false:true;
                    browser.runtime.sendMessage({ 
                        from: "background", 
                        isStayAround: settings["isStayAround"],
                        darkmodeToggleStatus: settings["toggleStatus"], 
                        enabled: enabled,
                        operate: "giveDarkmodeConfig" 
                    });
                });
                
            }
            browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
                // console.log("addListener____request------",request)
                if ("darkmode" === request.type) {
                    if("cs-frame-connect" === request.operate){
                        this.handleCSFrameConnect(sender);
                    }
                    if("cs-color-scheme-change" === request.operate){
                        this.onColorSchemeChange(request.data);
                    }
                    else if ("FETCH_DARK_SETTING" === request.operate){
                        this.handleFetchSettingForFallback().then(settings=>{
                            // console.log("addListener____fetch----settings-----", settings);
                            this.updateAutoState();
                            const tabURL = sender.tab.url;
                            const toggleStatus = settings.toggleStatus;
                            const isStayAround = settings.isStayAround;
                            const urlIsEnabled = isEnabledUrlState(tabURL, settings.siteListDisabled);
                            let darkState = "clean_up";
                            if(("on" === toggleStatus ||  "scheme-dark" === this.autoState ) && urlIsEnabled){
                                darkState = "dark_mode"
                            }
                            const darkSetings = {
                                siteListDisabled: settings.siteListDisabled,
                                toggleStatus: toggleStatus,
                                isStayAround: isStayAround,
                                darkState
                            }
                            sendResponse({body: darkSetings})
                        })
                    }
                    return true;
                }
                else if("popup" === request.type){
                    // console.log("addListener---popup----");
                    if("FETCH_DARKMODE_CONFIG" === request.operate){
                        // console.log("addListener--FETCH_DARKMODE_CONFIG--");
                        this.handleDarkModeSettingForPopup(sender);
                    }
                    else if("DARKMODE_SETTING" === request.operate){
                        let setting = {...this.user.settings};
                        const toggleStatus = request.status;
                        let isStayAround = request.isStayAround;
                        setting["toggleStatus"] = toggleStatus
                        setting["isStayAround"] = isStayAround
                        let siteListDisabled = setting["siteListDisabled"];
                        let domain = request.domain;
                        let enabled = request.enabled;
                        
                        if(enabled){
                            if(siteListDisabled.includes(domain)){
                                siteListDisabled.splice(siteListDisabled.indexOf(domain), 1);
                            }
                        }else{
                            if(!siteListDisabled.includes(domain)){
                                siteListDisabled.push(domain)
                            }
                        }
                        setting["siteListDisabled"] = siteListDisabled

                        setting.stay_automationBehaviour="Scheme";
                        // 默认跟随系统
                        setting.stay_automation="system";
                        this.changeSettings(setting);
                    }
                    return true;
                }
            });
            browser.alarms.onAlarm.addListener(this.alarmListener);
        }
        isExtensionSwitchedOn() {
            return (
                this.autoState === "turn-on" ||
                this.autoState === "scheme-dark" ||
                this.autoState === "scheme-light" ||
                (this.autoState === "" && "on" === this.user.settings.toggleStatus)
            ) && "a" === this.user.settings.isStayAround;
        }
        updateAutoState() {
            const {stay_automation, toggleStatus, auto_location, auto_time, stay_automationBehaviour:behavior} = this.user.settings;
            let isAutoDark;
            let nextCheck;
            if("auto" === toggleStatus){
                // console.log("updateAutoState------",stay_automation,behavior);
                switch (stay_automation) {
                    // auto模式下根据【时间】来更换暗黑模式还是明亮模式
                    case "time":
                        isAutoDark = isInTimeIntervalLocal(
                            auto_time.activation,
                            auto_time.deactivation
                        );
                        nextCheck = nextTimeInterval(
                            auto_time.activation,
                            auto_time.deactivation
                        );
                        break;
                    // auto模式下跟随【系统模式】更换暗黑模式还是明亮模式
                    case "system":
                        if (isSafari) {
                            isAutoDark =
                                this.wasLastColorSchemeDark == null
                                    ? isSystemDarkModeEnabled()
                                    : this.wasLastColorSchemeDark;
                        } else {
                            isAutoDark = isSystemDarkModeEnabled();
                        }
                        break;
                    case "location": {
                        const {latitude, longitude} = auto_location;
                        if (latitude != null && longitude != null) {
                            isAutoDark = isNightAtLocation(latitude, longitude);
                            nextCheck = nextTimeChangeAtLocation(
                                latitude,
                                longitude
                            );
                        }
                        break;
                    }
                }
                let state = "";
                if (stay_automation) {
                    if (behavior === "OnOff") {
                        state = isAutoDark ? "turn-on" : "turn-off";
                    } else if (behavior === "Scheme") {
                        state = isAutoDark ? "scheme-dark" : "scheme-light";
                    }
                }
                this.autoState = state;
                if (nextCheck) {
                    if (nextCheck < Date.now()) {
                        logWarn(
                            `Alarm is set in the past: ${nextCheck}. The time is: ${new Date()}. ISO: ${new Date().toISOString()}`
                        );
                    } else {
                        browser.alarms.create(StayDarkModeExtension.ALARM_NAME, {
                            when: nextCheck
                        });
                    }
                }
            }else{
                this.autoState = ""
            }
        }
        async start() {
            await this.config.load({local: true});
            await this.user.loadSettings();
            // console.log(" this.user.settings = ",  this.user.settings);
            this.updateAutoState();
            
            logInfo("loaded", this.user.settings);
          
            this.startBarrier.resolve();
        }
       
        callWhenSettingsLoaded(callback) {
            if (this.user.settings) {
                callback();
                return;
            }
            this.user.loadSettings().then(async () => {
                await this.stateManager.loadState();
                callback();
            });
        }
        // popup上改变了stay Dark mode 设置触发事件
        async onSettingsChanged() {
            if (!this.user.settings) {
                await this.user.loadSettings();
            }
            await this.stateManager.loadState();
            this.wasEnabledOnLastCheck = this.isExtensionSwitchedOn();
            // todo sendMessage to dark.user.js
            // const tabURL = sender.tab.url;
            this.handleTabMessage()
            // browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
            //     browser.tabs.sendMessage(tabs[0].id,message);
            // });
            this.saveUserSettings();
            this.user.writeStayAroundIntoStorage(this.user.settings)
            this.stateManager.saveState();
        }
        async saveUserSettings() {
            await this.user.saveSettings();
            logInfo("saved", this.user.settings);
        }

        changeSettings(settings) {
            const prev = {...this.user.settings};
            // console.log("settings=====",settings, "------prev==",prev);
            this.user.settings = {...settings}
            // console.log("this.user.settings=====",this.user.settings);
            this.user.set(settings);
            if (
                prev.siteListDisabled.length !== settings.siteListDisabled.length || 
                prev.toggleStatus !== settings.toggleStatus
                // prev.automation !== this.user.settings.automation ||
                // prev.time.activation !== this.user.settings.time.activation ||
                // prev.time.deactivation !== this.user.settings.time.deactivation ||
                // prev.location.latitude !== this.user.settings.location.latitude ||
                // prev.location.longitude !== this.user.settings.location.longitude
            ) {
                // console.log("changeSettings-------",settings);
                this.updateAutoState();
            }
            if (prev.stay_syncSettings !== settings.stay_syncSettings) {
                this.user.saveSyncSetting(settings.stay_syncSettings);
            }
            
            this.onSettingsChanged();
        }

        
    }
    StayDarkModeExtension.ALARM_NAME = "auto-time-alarm";
    StayDarkModeExtension.LOCAL_STORAGE_KEY = "Stay-darkmode-state";
    
    const stayDarkMode = new StayDarkModeExtension();
    stayDarkMode.start();

    // browser.storage.local.remove(["time","theme","syncSettings","detectDarkTheme","customThemes","automationBehaviour","automation","presets"])
    // browser.storage.sync.remove(["time","theme","syncSettings","detectDarkTheme","customThemes","automationBehaviour","automation","presets"])
})();
