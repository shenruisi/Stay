/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function () {

    function createGMApisWithUserScript(userscript, uuid, version, scriptWithoutComment, installType) {
        let grants = userscript.grants;
        let source = 'const _uuid = "' + uuid + '";\n\n';
        source += 'const iconUrl = "' + userscript.icon + '";\n\n';
        source += 'const usName = "' + userscript.name + '";\n\n';
        source += 'const _version = "' + version + '";\n\n';
        native.nslog("createGMApisWithUserScripte-- " + installType);
        if (grants.includes('unsafeWindow') || installType == 'page') {
            native.nslog("page create");
            source += 'const _userscript = ' + JSON.stringify(userscript) +';\n';
            source += injectJavaScript(userscript, version);
            // source 为 window.addEventListener(), move to bootstrap
            // source += `window.addEventListener('message', (e)=>{\n${getSourceOfWindowListener}\ngetSourceOfWindowListener(e);\n})\n\n`;
            return source;
        }
        source += 'let GM = {};\n\n';
        source += 'let GM_info=' + GM_info(userscript, version) + '\n';
        source += 'GM.info = GM_info;\n';
        source += 'let __stroge = await _fillStroge();\n\n';
        source += 'let __resourceTextStroge = await _fillAllResourceTextStroge();\n\n';
        source += 'let __resourceUrlStroge = await _fillAllResourceUrlStroge();\n\n';
        source += 'let __RMC_CONTEXT = [];\n\n';

        source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "clear_GM_log" });\n';
        source += 'browser.runtime.onMessage.addListener((request, sender, sendResponse) => {\n';
        source += '\tif (request.from == "background" && request.operate == "fetchRegisterMenuCommand"){\n';
        source += '\t\tconsole.log("fetchRegisterMenuCommand=",request,__RMC_CONTEXT);\n';
        source += '\tbrowser.runtime.sendMessage({from:"content",data:__RMC_CONTEXT,uuid:_uuid,operate:"giveRegisterMenuCommand"});}\n';
        source += '\telse if (request.from == "background" && request.operate == "execRegisterMenuCommand" && request.uuid == _uuid){\n';
        source += '\t\tconsole.log("menuId=",request.id,__RMC_CONTEXT);\n let menuId = request.id;\n let place=-1;\n';
        source += '\t\tif(__RMC_CONTEXT.length>0){\n__RMC_CONTEXT.forEach((item, index)=>{\n\t\tif(item.id == menuId){\nplace = index;\n return false;\n}\n}\n)}';
        source += '\t\tif(place>=0){\n__RMC_CONTEXT[place]["commandFunc"]();\n}\n}\n';
        source += '\treturn true;\n'
        source += '});\n\n';

        if (grants.includes('GM_listValues')) {
            source += 'function GM_listValues (){ return __stroge}\n\n';
        }

        if (grants.includes('GM.listValues')) {
            source += 'GM.listValues = ' + _fillStroge.toString() + '\n\n';
        }

        if (grants.includes('GM_deleteValue')) {
            source += GM_deleteValue.toString() + '\n\n';
        }

        if (grants.includes('GM.deleteValue')) {
            source += 'GM.deleteValue = ' + deleteValue_p.toString() + '\n\n';
        }

        if (grants.includes('GM_setValue')) {
            source += GM_setValue.toString() + '\n\n';
        }

        if (grants.includes('GM.setValue')) {
            source += 'GM.setValue = ' + setValue_p.toString() + '\n\n';
        }

        if (grants.includes('GM_getValue')) {
            source += GM_getValue.toString() + '\n\n';
        }

        if (grants.includes('GM.getValue')) {
            source += 'GM.getValue = ' + getValue_p.toString() + '\n\n';
        }

        if (grants.includes('GM.registerMenuCommand')) {
            source += 'GM.registerMenuCommand = ' + GM_registerMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM_registerMenuCommand')) {
            source += GM_registerMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM.unregisterMenuCommand')) {
            source += 'GM.unregisterMenuCommand = ' + GM_unregisterMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM_unregisterMenuCommand')) {
            source += GM_unregisterMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM_addStyle')) {
            source += GM_addStyle.toString() + '\n\n';
        }

        if (grants.includes('GM.addStyle')) {
            source += 'GM.addStyle = ' + GM_addStyle.toString() + '\n\n';
        }

        if (grants.includes('GM_openInTab')) {
            source += GM_openInTab.toString() + '\n\n';
        }
        if (grants.includes('GM.openInTab')) {
            source += 'GM.openInTab = ' + GM_openInTab.toString() + '\n\n';
        }

        if (grants.includes('GM_getResourceURL')) {
            source += GM_getResourceURL.toString() + '\n\n';
        }
        if (grants.includes('GM_getResourceUrl')) {
            source += 'GM_getResourceUrl =' + GM_getResourceURL.toString() + '\n\n';
        }

        if (grants.includes('GM.getResourceURL') || grants.includes('GM.getResourceUrl')) {
            source += 'GM.getResourceURL = ' + getResourceURL_p.toString() + '\n\n';
            source += 'GM.getResourceUrl = ' + getResourceURL_p.toString() + '\n\n';
        }

        if (grants.includes('GM.getResourceText')) {
            source += 'GM.getResourceText = ' + getResourceText_p.toString() + '\n\n';
        }

        if (grants.includes('GM_getResourceText')) {
            source += GM_getResourceText.toString() + '\n\n';
        }

        if (grants.includes('GM_xmlhttpRequest')) {
            source += GM_xmlhttpRequest.toString() + '\n\n';
        }

        if (grants.includes('GM.xmlHttpRequest')) {
            source += 'GM.xmlHttpRequest = ' + GM_xmlhttpRequest.toString() + '\n\n';
        }

        if (grants.includes('GM_notification') || grants.includes('GM.notification') ) {
            source += GM_notification.toString() + '\n\n';
            source += "GM.notification = " + GM_notification.toString() + '\n\n';
        }
        if (grants.includes('GM_download') || grants.includes('GM.download')) {
            source += GM_download.toString() + '\n\n';
            source += "GM.download = " + GM_download.toString() + '\n\n';
        }
        if (grants.includes('GM_setClipboard') || grants.includes('GM.setClipboard')) {
            source += GM_setClipboard.toString() + '\n\n';
            source += "GM.setClipboard = " + GM_setClipboard.toString() + '\n\n';
        }

        //add GM_log by default
        source += GM_log.toString() + '\n\n';

        // source += injectJavaScript.toString() + ';\n\ninjectJavaScript();\n';

        source += _fillStroge.toString() + '\n\n';

        source += _fillAllResourceTextStroge.toString() + '\n\n';

        source += _fillAllResourceUrlStroge.toString() + '\n\n';
//        native.nslog("native-source" + source);
        return source;
    }

    function GM_info(userscript, version) {
        let info = {
            version: version,
            scriptHandler: "Stay",
            script: {
                version: userscript.version,
                description: userscript.description,
                namespace: userscript.namespace,
                resources: userscript.resourceUrls ? userscript.resourceUrls : [],
                includes: userscript.includes ? userscript.includes : [],
                excludes: userscript.excludes ? userscript.excludes : [],
                matches: userscript.matches ? userscript.matches : []
            }
        };
        return JSON.stringify(info);
    }

    function _fillStroge() {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid: _uuid }, (response) => {
                resolve(response.body);
            });
        });
    }

    function _fillAllResourceTextStroge() {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getAllResourceText", uuid: _uuid }, (response) => {
                console.log("_fillAllResourceTextStroge", response);
                // console.log("_fillAllResourceTextStroge-response.body", response);
                resolve(response.body);
            });
        });
    }

    function _fillAllResourceUrlStroge() {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getAllResourceUrl", uuid: _uuid }, (response) => {
                console.log("_fillAllResourceUrlStroge", response);
                resolve(response.body);
            });
        });
    }

    function GM_deleteValue(key) {
        __stroge[key] = null;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid: _uuid });
    }

    function GM_setValue(key, value) {
        __stroge[key] = value;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid: _uuid });
    }

    function GM_getValue(key, defaultValue) {
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid: _uuid });
        return __stroge[key] == null ? defaultValue : __stroge[key];
    }

    function deleteValue_p(key) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid: _uuid }, (response) => {
                resolve(response.body);
            });
        });
    }

    function setValue_p(key, value) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid: _uuid }, (response) => {
                resolve(response.body);
            });
        });
    }

    function getValue_p(key, defaultValue) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid: _uuid }, (response) => {
                resolve(response.body);
            });
        });
    }

    function GM_log(message) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_log", message: message, uuid: _uuid }, (response) => {
                resolve(response);
            });
        });
    }


    function GM_setClipboard(data, info) {
        
    }

    function GM_download(url, name) {
        let downloadStyle = "width: 270px;";
        if (is_iPad()) {
            downloadStyle = "width: 320px;"
        }
        let bg = "background: #fff;";
        let fontColor = "color: #000000;"
        let topLine = " border-top: 1px solid #E0E0E0;"
        let rightLine = " border-right:1px solid #E0E0E0;"
        if (is_dark()) {
            bg = "background: #000;";
            fontColor = "color: #F3F3F3;";
            topLine = " border-top: 1px solid #565656;"
            rightLine = " border-right:1px solid #565656;"
        }
        let iconDom = "";
        if (iconUrl){
            iconDom = '<img src=' + iconUrl + ' style="width: 20px;height: 20px;">'
        }
        let text = 'Allow to download "' + name+ '"';
        let popToastTemp = [
            '<div id="downloadPop" style="' + downloadStyle + ' transform: translate(-50%, -50%);left: 50%; top: 50%; border-radius: 10px; ' + bg + ' position: fixed;z-index:999; box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .6);padding-top: 6px;">',
            '<div id="gm_popTitle"  style="display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center; padding: 4px;">' + iconDom +'<div style="padding-left:4px;font-weight:600;font-size:16px;line-height:17px; ' + fontColor +'">' + usName+'</div></div>',
            '<div id="gm_popCon" style="padding:4px 8px;font-size:15px; ' + fontColor + ' line-height: 20px;">' + text +'</div>',
            '<div id="gm_popCon" style="padding:4px 8px;font-size:13px; ' + fontColor + ' line-height:17px;text-overflow:ellipsis;overflow:hidden; -webkit-line-clamp:3;-webkit-box-orient:vertical;display:-webkit-box;">' + url + '</div>',
            '<div style="' + fontColor + topLine + ' font-size: 14px;margin-top:10px; line-height: 20px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;">',
            '<div id="gm_downloadCancel" style=" ' + rightLine +' font-size:16px;font-weight:600;color: #B620E0;width:50%;padding: 8px;text-align:center;">Cancel</div>',
            '<a id="downloadLink" target="_blank" style="font-size:16px;font-weight:600;  color: #B620E0;width:50%;padding: 8px;text-align:center;">Allow</a>',
            '</div>',
            '</div>'
        ];

        let temp = popToastTemp.join("");
        let tempDom = document.createElement("div");
        tempDom.id = "downloadContainer"
        tempDom.innerHTML = temp;
        document.body.appendChild(tempDom);

        let downloadCancelDom = document.getElementById("gm_downloadCancel");
        downloadCancelDom.addEventListener("click", function (e) {
            tempDom.remove();
        })

        let downloadLinkDom = document.getElementById("downloadLink");
        console.log("downloadLinkDom",url);
        if (url.match(new RegExp("^data:image\/.*;base64,"))){ //download image directly
            downloadLinkDom.href = url;
        }
        else{
            downloadLinkDom.href = "data:application/octet-stream," + encodeURIComponent(url);
        }

        downloadLinkDom.download = name;
        downloadLinkDom.addEventListener("click", function (e) {
            tempDom.remove();
        })

        function is_dark() {
            return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        }

        function is_iPad() {
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/iPad/i) == "ipad") {
                return true;
            } else {
                return false;
            }
        }

    }

    /**
     * 1、text, title,  image, onclick
     * 2、details, ondone
     * @param {*} param1 
     * @param {*} param2 
     * @param {string} param3 
     * @param {function} param4 
     */
    function GM_notification(param1, param2, param3, param4) {
        let details = {};
        let ondone = null;
        if (typeof param1 === "object" || typeof param2 === "function") {
            details = param1;
            ondone = param2;
        } else {
            let detail = { text: param1, title: param2, image: param3, onclick: param4 }
            details = detail;
        }

        let text = details.text ? details.text : "";
        let title = details.title ? details.title : "";
        let image = details.image ? details.image : "";
        let timeout = details.timeout || 8000;
        let onclick = details.onclick;

        // let stayImg = browser.runtime.getURL("images/icon-256.png");
        let notificationStyle = "width: 270px;height: 57px;transform: translateX(-50%);left: 50%;";
        if (is_iPad()) {
            notificationStyle = "width: 320px;height: 72px; right: 10px;"
        }
        let bg = "background: #fff;";
        let fontColor = "color: #000000;"
        if (is_dark()) {
            bg = "background: #000;";
            fontColor = "color: #F3F3F3;"
        }
        let popToastTemp = [
            '<div id="notificationPop" style="' + notificationStyle + ' top: 10px; border-radius: 10px; ' + bg + ' position: fixed;z-index:999; box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;padding: 4px;">',
            '<div id="notifyImg"  style="text-decoration: none;width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src=' + image + ' style="width: 46px;height: 46px; border-radius: 4px;"></img></div>',
            '<div id="notificationCon" style="padding:0 4px;font-family:Helvetica Neue;text-decoration: none;display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:start;line-height:23px;">',
            '<div style="font-size: 16px; color: #B620E0;font-weight:700;">' + title + '</div>',
            '<div style="font-size: 12px;' + fontColor + ' line-height: 15px;padding-top:2px;text-overflow:ellipsis;overflow:hidden; -webkit-line-clamp:2;-webkit-box-orient:vertical;display:-webkit-box;">' + text + '</div>',
            '</div>',
            '</div>'
        ];
        let temp = popToastTemp.join("");
        let tempDom = document.createElement("div");
        tempDom.id = "notificationContainer"
        tempDom.innerHTML = temp;
        document.body.appendChild(tempDom);
        let notificationDom = document.getElementById("notificationContainer");
        notificationDom.addEventListener("click", () => {
            if (onclick) {
                onclick();
            }
        })
        var clearFlag = 0;
        function autoClose() {
            if (timeout > 0) {
                timeout = timeout - 500;
            } else {
                window.clearInterval(clearFlag);
                // notificationDom.removeEventListener("click");
                notificationDom.remove();
                if (ondone) {
                    ondone();
                }
            }
        }
        clearFlag = window.setInterval(() => {
            autoClose();
        }, 500);

        function is_dark() {
            return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
        }

        function is_iPad() {
            var ua = navigator.userAgent.toLowerCase();
            if (ua.match(/iPad/i) == "ipad") {
                return true;
            } else {
                return false;
            }
        }
    }

    function GM_registerMenuCommand(caption, commandFunc, accessKey) {
        const pid = Math.random().toString(36).substring(1, 9);
        let userInfo = {};
        userInfo["caption"] = caption;
        userInfo["commandFunc"] = commandFunc;
        userInfo["accessKey"] = accessKey;
        userInfo["id"] = pid;
        __RMC_CONTEXT.push(userInfo);
        return pid;
    }

    function GM_unregisterMenuCommand(menuId) {
        if (!menuId || __RMC_CONTEXT.length <= 0) {
            return;
        }
        let place = -1;
        __RMC_CONTEXT.forEach((item, index) => {
            if (item.id == menuId) {
                place = index;
                return false;
            }
            console.log("break-----")
        });
        if (place >= 0) {
            __RMC_CONTEXT.splice(place, 1);
        }
    }

    function GM_addStyle(css) {
        var head, style;
        head = document.getElementsByTagName('head')[0];
        if (!head) { return; }
        style = document.createElement('style');
        style.type = 'text/css';
        try {
            style.appendChild(document.createTextNode(css));
        } catch (ex) {
            style.styleSheet.cssText = css;//针对IE

        }
        head.appendChild(style);
    }

    function GM_getResourceText(name) {
        let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
        // let resourceText;
        if (!resourceText || typeof resourceText === undefined) {
            // 通过name获取resource
            // resourceText = await GM_getResourceText_p(name);
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, url: __resourceUrlStroge[name],  uuid: _uuid }, (response) => {
                console.log("GM_getResourceText send to background-----", response);
                __resourceTextStroge[name] = response.body;
                resourceText = response.body;
            });
        }
        return resourceText;
    }


    function getResourceText_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, url: __resourceUrlStroge[name], uuid: _uuid }, (response) => {
                console.log("GM_getResourceText_p-----", response);
                resolve(response.body);
            });
        });
    }

    function GM_getResourceURL(name) {
        let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name] : "";
        if (!resourceUrl || typeof resourceUrl === undefined) {
            // 通过url获取resources
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceUrl", key: name, uuid: _uuid }, (response) => {
                // console.log("GM_getResourceURL----GM_getResourceURL-----", response);
                __resourceUrlStroge[name] = response.body;
                resourceUrl = response.body;
            });
        }
        return resourceUrl;
    }

    function getResourceURL_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceUrl", key: name, uuid: _uuid }, (response) => {

                // console.log("GM_getResourceURL_p-----",response);
                resolve(response.body);
            });
        });
    }

    function GM_xmlhttpRequest(params) {
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_xmlhttpRequest", params: params, uuid: _uuid }, (response) => {
            var onreadystatechange = response.onreadystatechange;
            var onerror = response.onerror;
            var onload = response.onload;
            if (params.onreadystatechange && onreadystatechange) {
                params.onreadystatechange(onreadystatechange)
            }

            if (params.onerror && onerror) {
                params.onerror(onerror)
            }
            if (params.onload && onload) {
                params.onload(onload)
            }
        });
    }

    /**
     * 打开标签页
     * @param {string} url 
     * @param {boolean} options 可以是 Boolean 类型，如果是 true，则当前 tab 不变；如果是 false，则当前 tab 变为新打开的 tab
     * options对象有以下属性:
     * active：新标签页获得焦点
     * insert：新标签页在当前页面之后添加
     * setParent：当新标签页关闭后，焦点给回当前页面
     * incognito: 新标签页在隐身模式或私有模式窗口打开
     * 若只有一个参数则新标签页不会聚焦，该函数返回一个对象，有close()、监听器onclosed和closed的标记
     */

    function GM_openInTab(url, options) {
        // retrieve tabId to have a chance of closing this window lateron
        var tabId = null;
        var close = function () {
            if (tabId === null) {
                // re-schedule, cause tabId is null
                window.setTimeout(close, 500);
            } else if (tabId > 0) {
                browser.runtime.sendMessage({ from: "gm-apis", operate: "closeTab", tabId: tabId, uuid: _uuid }, resp);
                tabId = undefined;
            } else {
                console.log("env: attempt to close already closed tab!");
            }
        };
        var resp = function (response) {
            // console.log("GM_openInTab response---", response)
            tabId = response.tabId;
        };
        if (url && url.search(/^\/\//) == 0) {
            url = location.protocol + url;
        }
        browser.runtime.sendMessage({ from: "gm-apis", operate: "openInTab", url: url, uuid: _uuid, options: options }, resp);
        return { close: close };
    }

    function injectJavaScript(userscript, version) {
        let gmFunVals = [];
        let grants = userscript.grants;
        let resourceUrls = userscript.resourceUrls||{};
        let api = `${GM_listValues_Async}\n`;
        api += `${GM_getAllResourceText}\n`;
        api += 'let __listValuesStroge = await GM_listValues_Async();\n';
        api += 'let __resourceUrlStroge = ' + JSON.stringify(resourceUrls)+';\n';
        api += 'let __resourceTextStroge = await GM_getAllResourceText();\n';
        api += `console.log("__resourceTextStroge==",__resourceTextStroge);\n`;
        api += 'let __RMC_CONTEXT = [];\n';
        api += 'let GM_info =' + GM_info(userscript, version) + ';\n';
        api += `${GM_log}\n`;
        api += `${clear_GM_log}\nclear_GM_log();\n`;
        api += `${__xhr}\n`
        gmFunVals.push("info: GM_info");
        let gmFunName = [];
        grants.forEach(grant => {
            if (grant === "unsafeWindow" && !gmFunName.includes("unsafeWindow")) {
                api += `const unsafeWindow = window;\n`;
                gmFunName.push("unsafeWindow");
            } 
            else if (grant === "GM.listValues" && !gmFunName.includes("GM.listValues")) {
                gmFunVals.push("listValues: GM_listValues_Async");
                gmFunName.push("GM.listValues");
            } 
            else if (grant === "GM_listValues" && !gmFunName.includes("GM_listValues")){
                api += `function GM_listValues(){ return __listValuesStroge;}\n`;
                gmFunName.push("GM_listValues");
            }
            else if (grant === "GM.deleteValue" && !gmFunName.includes("GM_deleteValue_Async")) {
                api += `${GM_deleteValue_Async}\n`;
                gmFunVals.push("deleteValue: GM_deleteValue_Async");
                gmFunName.push("GM_deleteValue_Async");
            }
            else if (grant === "GM_deleteValue" && !gmFunName.includes("GM_deleteValue")){
                api += `${GM_deleteValue_sync}\nconst GM_deleteValue = GM_deleteValue_sync;\n`;
                gmFunName.push("GM_deleteValue");
            }
            else if (grant === "GM_addStyle" && !gmFunName.includes("GM_addStyle")) { //同步
                api += `${GM_addStyleSync}\nconst GM_addStyle = GM_addStyleSync;\n`;
                gmFunName.push("GM_addStyle");
            } 
            else if (grant === "GM.addStyle" && !gmFunName.includes("GM_addStyle_Async")) {
                api += `${GM_addStyle_Async}\n`;
                gmFunVals.push("addStyle: GM_addStyle_Async");
                gmFunName.push("GM_addStyle_Async");
            } 
            else if ("GM.setValue" === grant && !gmFunName.includes("GM_setValue_Async")){
                api += `${GM_setValue_Async}\n`;
                gmFunVals.push("setValue:  GM_setValue_Async");
                gmFunName.push("GM_setValue_Async");
            }
            else if ("GM_setValue" === grant && !gmFunName.includes("GM_setValue")) {
                api += `${GM_setValueSync}\nconst GM_setValue = GM_setValueSync;\n`;
                gmFunName.push("GM_setValue");
            }
            else if ("GM.getValue" === grant && !gmFunName.includes("GM_getValueAsync")) {
                api += `${GM_getValueAsync}\n`;
                gmFunVals.push("getValue: GM_getValueAsync");
                gmFunName.push("GM_getValueAsync");
            }
            else if ("GM_getValue" === grant && !gmFunName.includes("GM_getValueSync")) {
                api += `${GM_getValueSync}\nconst GM_getValue = GM_getValueSync;\n`;
                gmFunName.push("GM_getValueSync");
            }
            else if (("GM_registerMenuCommand" === grant || "GM.registerMenuCommand" === grant) && 
                (!gmFunName.includes("GM_registerMenuCommand") || !gmFunName.includes("GM.registerMenuCommand"))){
                api += `${GM_registerMenuCommand}\n`;
                gmFunVals.push("registerMenuCommand: GM_registerMenuCommand");
                gmFunName.push("GM_registerMenuCommand");
                gmFunName.push("GM.registerMenuCommand");
            }
            else if (("GM_unregisterMenuCommand" === grant || "GM.unregisterMenuCommand" === grant) && 
                (!gmFunName.includes("GM_unregisterMenuCommand") || !gmFunName.includes("GM.unregisterMenuCommand"))) {
                api += `${GM_unregisterMenuCommand}\n`;
                gmFunVals.push("unregisterMenuCommand: GM_unregisterMenuCommand");
                gmFunName.push("GM_unregisterMenuCommand");
                gmFunName.push("GM.unregisterMenuCommand");
            }
            else if (("GM_getResourceUrl" === grant || "GM_getResourceURL" === grant) && !gmFunName.includes("GM_getResourceURLSync")){
                api += `${GM_getResourceURLSync}\n`;
                gmFunName.push("GM_getResourceURLSync");
                api += `const GM_getResourceURL=GM_getResourceURLSync;\n`;
                api += `const GM_getResourceUrl=GM_getResourceURLSync;\n`;
            }
            else if (("GM.getResourceURL" === grant || "GM.getResourceUrl" === grant) && !gmFunName.includes("GM_getResourceURL_Async")){
                api += `${GM_getResourceURL_Async}\n`;
                gmFunVals.push("getResourceURL: GM_getResourceURL_Async");
                gmFunVals.push("getResourceUrl: GM_getResourceURL_Async");
                gmFunName.push("GM_getResourceURL_Async");

            }
            else if ("GM.getResourceText" === grant && !gmFunName.includes("GM.GM_getResourceText_Async")) {
                api += `${GM_getResourceText_Async}\n`;
                gmFunVals.push("getResourceText: GM_getResourceText_Async");
                gmFunName.push("GM_getResourceText_Async");
            }
            else if ("GM_getResourceText" === grant && !gmFunName.includes("GM_getResourceTextSync")) {
                api += `${GM_getResourceTextSync}\nconst GM_getResourceText = GM_getResourceTextSync;\n`;
                gmFunName.push("GM_getResourceTextSync");
            }
            else if ("GM.openInTab" === grant && !gmFunName.includes("GM_openInTab_async")) {
                api += `${GM_openInTab_async}\n`;
                
                gmFunVals.push("openInTab: GM_openInTab_async");
                gmFunName.push("GM_openInTab_async");
                if (!gmFunName.includes("GM_closeTab")){
                    api += `${GM_closeTab}\n`;
                    gmFunVals.push("closeTab: GM_closeTab");
                    gmFunName.push("GM_closeTab");
                }
            }
            else if ("GM_openInTab" === grant && !gmFunName.includes("GM_openInTab")) {
                api += `${GM_openInTab}\n`;
                gmFunName.push("GM_openInTab");
            }
            else if (("GM.closeTab" === grant || "GM_closeTab" === grant) && !gmFunName.includes("GM_closeTab")) {
                api += `${GM_closeTab}\n`;
                gmFunVals.push("closeTab: GM_closeTab");
                gmFunName.push("GM_closeTab");
            }
            else if (("GM.notification" === grant || "GM_notification" === grant) && !gmFunName.includes("GM_notification")) {
                api += `${GM_notification}\n`;
                gmFunVals.push("notification: GM_notification");
                gmFunName.push("GM_notification");
            }
            else if (("GM.setClipboard" === grant || "GM_setClipboard" === grant) && !gmFunName.includes("GM_setClipboard") ) {
                api += `${GM_setClipboard}\n`;
                gmFunVals.push("setClipboard: GM_setClipboard");
                gmFunName.push("GM_setClipboard");
            }
            else if (("GM.download" === grant || "GM_download" === grant) && !gmFunName.includes("GM_download")) {
                api += `${GM_download}\n`;
                gmFunVals.push("download: GM_download");
                gmFunName.push("GM_download");
            }
            else if (grant === "GM_xmlhttpRequest" && !gmFunName.includes("GM_xmlhttpRequest")){
                api += "\nconst GM_xmlhttpRequest = __xhr;\n";
                gmFunName.push("GM_xmlhttpRequest");

            }
            else if (grant === "GM.xmlHttpRequest" && !gmFunName.includes("GM.xmlHttpRequest")) {
                gmFunVals.push("xmlHttpRequest: __xhr");
                gmFunName.push("GM.xmlHttpRequest");
            }
        })

        function GM_info(userscript, version) {
            let info = {
                version: version,
                scriptHandler: "Stay",
                script: {
                    version: userscript.version,
                    description: userscript.description,
                    namespace: userscript.namespace,
                    resources: userscript.resourceUrls ? userscript.resourceUrls : [],
                    includes: userscript.includes ? userscript.includes : [],
                    excludes: userscript.excludes ? userscript.excludes : [],
                    matches: userscript.matches ? userscript.matches : []
                }
            };
            return JSON.stringify(info);
        }

        function GM_listValues_Async() {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_LIST_VALUES") return;
                    resolve(e.data.response.body);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_LIST_VALUES" });
            });
        }
        

        function GM_setValueSync(key, value) {
            __listValuesStroge[key] = value;
            window.postMessage({ id: _uuid, name: "API_SET_VALUE_SYNC", key: key, value: value });
        }

        function GM_setValue_Async(key, value) {
            __listValuesStroge[key] = value;
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_SET_VALUE") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_SET_VALUE", key: key, value: value });
            });
        }

        function GM_getValueSync(key, defaultValue) {
            const pid = Math.random().toString(36).substring(1, 9);
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE_SYNC", key: key, defaultValue: defaultValue });
            return __listValuesStroge[key] == null ? defaultValue : __listValuesStroge[key];
        }

        function GM_getValueAsync(key, defaultValue) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_VALUE") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE", key: key, defaultValue: defaultValue });
            });
        }

        function GM_deleteValue_Async(key) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_DELETE_VALUE") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                window.postMessage({ id: _uuid, pid: pid, name: "API_DELETE_VALUE", key: key });
            });
        }

        function GM_deleteValue_sync(key) {
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_DELETE_VALUE") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
            window.postMessage({ id: _uuid, pid: pid, name: "API_DELETE_VALUE", key: key });
            return key;
        }

        function GM_getResourceURLSync(name) {
            let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name] : "";
            if (!resourceText || resourceText === "" || resourceText === undefined) {
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL_SYNC", key: name });
            }
            return resourceUrl;
        }

        function GM_getResourceURL_Async(name) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_URL") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL", key: name });
            });
        }

        function GM_getResourceText_Async(name) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_TEXT") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_TEXT", key: name, url: __resourceUrlStroge[name] });
            });
        }

        function GM_getResourceTextSync(name) {
            let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
            if (!resourceText || resourceText === "" || resourceText === undefined) {
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_TEXT_SYNC", key: name, url: __resourceUrlStroge[name] });
            }
            return resourceText;
        }

        function GM_getAllResourceText() {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_ALL_REXOURCE_TEXT") return;
                    console.log("GM_getAllResourceText----", e);
                    resolve(e.data.response.body);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_ALL_REXOURCE_TEXT" });
            });
        }

        function GM_addStyleSync(css) {
            window.postMessage({ id: _uuid, name: "API_ADD_STYLE_SYNC", css: css });
            return css;
        }

        function GM_addStyle_Async(css) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_ADD_STYLE") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_ADD_STYLE", css: css });
            });
        }

        function clear_GM_log() {
            window.postMessage({ id: _uuid, name: "API_CLEAR_LOG" });
        }

        function GM_log(message) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_LOG") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                window.postMessage({ id: _uuid, pid: pid, name: "API_LOG", message: message });
            });
        }

        function GM_registerMenuCommand(caption, commandFunc, accessKey) {
            let userInfo = {};
            const pid = Math.random().toString(36).substring(1, 9);
            userInfo["caption"] = caption;
            userInfo["commandFunc"] = commandFunc;
            userInfo["accessKey"] = accessKey;
            userInfo["id"] = pid;
            __RMC_CONTEXT.push(userInfo);
            window.postMessage({ id: _uuid, name: "REGISTER_MENU_COMMAND_CONTEXT", rmc_context: JSON.stringify(__RMC_CONTEXT) });
            window.addEventListener('message', (e) => {
                if (!e || !e.data || !e.data.name) return;
                let uuid = e.data.id;
                const name = e.data.name;
                if ("execRegisterMenuCommand" === name){
                    let menuId = e.data.menuId;
                    let place = -1;
                    if (__RMC_CONTEXT.length > 0) {
                        __RMC_CONTEXT.forEach((item, index) => {
                            if (item.id == menuId) {
                                place = index;
                                return false;
                            }
                        });
                        if (place >= 0) {
                            __RMC_CONTEXT[place]["commandFunc"]();
                        }
                    }
                }
            
            });
            return pid;
        }

        function GM_unregisterMenuCommand(menuId) {
            if (!menuId || __RMC_CONTEXT.length<=0){
                return;
            }
            let place = -1;
            __RMC_CONTEXT.forEach((item, index)=>{
                if (item.id == menuId){
                    place = index;
                    return false;
                }
            });
            if (place>=0){
                __RMC_CONTEXT.splice(place, 1);
                window.postMessage({ id: _uuid, name: "UNREGISTER_MENU_COMMAND_CONTEXT", rmc_context: JSON.stringify(__RMC_CONTEXT) });
            }
        }

        function browserAddListener() {
            window.postMessage({ id: _uuid, name: "BROWSER_ADD_LISTENER"});
        }

        function GM_closeTab(tabId) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_CLOSE_TAB") return;
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_CLOSE_TAB", tabId: tabId });
            });
        }

        function GM_openInTab(url, options) {
            const pid = Math.random().toString(36).substring(1, 9);
            let tabId = null;
            var close = function () {
                if (tabId === null) {
                    // re-schedule, cause tabId is null
                    window.setTimeout(close, 500);
                } else if (tabId > 0) {
                    window.postMessage({ id: _uuid, pid: pid, name: "API_CLOSE_TAB", tabId: tabId });
                    // browser.runtime.sendMessage({ from: "gm-apis", operate: "closeTab", tabId: tabId, uuid: _uuid }, resp);
                    tabId = undefined;
                } else {
                    console.log("env: attempt to close already closed tab!");
                }
            };
            if (url && url.search(/^\/\//) == 0) {
                url = location.protocol + url;
            }
            window.postMessage({ id: _uuid, pid: pid, name: "API_OPEN_IN_TAB", url: url, options: options ? JSON.stringify(options):"{}" });
            const callback = e => {
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_OPEN_IN_TAB") return;
                tabId = e.data.tabId;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            return { close: close};
        } 

        /**
         * 打开标签页
         * @param {string} url 
         * @param {boolean} options 可以是 Boolean 类型，如果是 true，则当前 tab 不变；如果是 false，则当前 tab 变为新打开的 tab
         * options对象有以下属性:
         * active：新标签页获得焦点
         * insert：新标签页在当前页面之后添加
         * setParent：当新标签页关闭后，焦点给回当前页面
         * incognito: 新标签页在隐身模式或私有模式窗口打开
         * 若只有一个参数则新标签页不会聚焦，该函数返回一个对象，有close()、监听器onclosed和closed的标记
         */
        function GM_openInTab_async(url, options) {
            // console.log("start GM_openInTab-----", url, options);
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_OPEN_IN_TAB") return;
                    let tabId = e.data.tabId;
                    let resp = {
                        tabId,
                        close: function () {
                            GM_closeTab(tabId)
                        }
                    }
                    resolve(resp);
                    window.removeEventListener("message", ()=>{});
                };
                window.addEventListener("message", callback);
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                window.postMessage({ id: _uuid, pid: pid, name: "API_OPEN_IN_TAB", url: url, options: options ? JSON.stringify(options) : "{}" });
            });

        }

        function __xhr(details) {
            // if details didn't include url, do nothing
            if (!details.url) return;
            // create unique id for the xhr
            const xhrId = Math.random().toString(36).substring(1, 9);
            // strip out functions from details, kind of hacky
            const detailsParsed = JSON.parse(JSON.stringify(details));
            // check which functions are included in the original details object
            // add a bool to indicate if event listeners should be attached
            if (details.onabort) detailsParsed.onabort = true;
            if (details.onerror) detailsParsed.onerror = true;
            if (details.onload) detailsParsed.onload = true;
            if (details.onloadend) detailsParsed.onloadend = true;
            if (details.onloadstart) detailsParsed.onloadstart = true;
            if (details.onprogress) detailsParsed.onprogress = true;
            if (details.onreadystatechange) detailsParsed.onreadystatechange = true;
            if (details.ontimeout) detailsParsed.ontimeout = true;
            // abort function gets returned when this function is called
            const abort = () => {
                window.postMessage({ id: _uuid, name: "API_XHR_ABORT_INJ_FROM_CREATE", xhrId: xhrId });
            };
            const callback = e => {
                const name = e.data.name;
                const response = e.data.response;
                // ensure callback is responding to the proper message
                if (
                    e.data.id !== _uuid
                    || e.data.xhrId !== xhrId
                    || !name
                    || !name.startsWith("RESP_API_XHR_TO_CREATE")
                ) return;
                console.log("XHR==response=", response);
                if (name === "RESP_API_XHR_TO_CREATE") {
                    console.log("RESP_API_XHR_TO_CREATE----");
                    // ignore
                } else if (name.includes("ABORT") && details.onabort) {
                    details.onabort(response);
                } else if (name.includes("ERROR") && details.onerror) {
                    details.onerror(response);
                } else if (name === "RESP_API_XHR_TO_CREATE_LOAD" && details.onload) {
                    details.onload(response);
                } else if (name.includes("LOADEND") && details.onloadend) {
                    details.onloadend(response);
                    // remove event listener when xhr is complete
                    window.removeEventListener("message", callback);
                } else if (name.includes("LOADSTART") && details.onloadstart) {
                    details.onloadtstart(response);
                } else if (name.includes("PROGRESS") && details.onprogress) {
                    details.onprogress(response);
                } else if (name.includes("READYSTATECHANGE") && details.onreadystatechange) {
                    details.onreadystatechange(response);
                } else if (name.includes("TIMEOUT") && details.ontimeout) {
                    details.ontimeout(response);
                }
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, name: "API_XHR_FROM_CREATE", details: JSON.stringify(detailsParsed), xhrId: xhrId });
            return { abort: abort };
        }

        api += `${browserAddListener}\nbrowserAddListener();`;

        const GM = `const GM = {${gmFunVals.join(",")}};`;
        return `\n${api}\n${GM}\n`;
    }
    
    window.createGMApisWithUserScript = createGMApisWithUserScript;

})();
