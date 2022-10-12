/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function () {
    function createGMApisWithUserScript(userscript, uuid, version, scriptWithoutComment, installType) {
        let grants = userscript.grants;
        let source = 'const _uuid = "' + uuid + '";\n\n';
        source += "let Stay_storage_listeners = [];\n\n";
        source += 'const iconUrl = "' + userscript.icon + '";\n\n';
        source += 'const usName = "' + userscript.name + '";\n\n';
        source += 'const _version = "' + version + '";\n\n';
        source += `${Stay_notifyValueChangeListeners}\n`;
        native.nslog("createGMApisWithUserScripte-- " + installType);
        if (grants.includes('unsafeWindow') || installType == 'page') {
            native.nslog("page create");
            source += 'const _userscript = ' + JSON.stringify(userscript) +';\n';
            source += injectJavaScript(userscript, version);
            return source;
        }
        source += 'let GM = {};\n\n';
        source += 'let GM_info=' + GM_info(userscript, version) + '\nwindow.GM_info = GM_info\n';
        source += 'GM.info = GM_info;\n';
        source += 'let __stroge = await _fillStroge();\n\n';
        source += 'let __resourceTextStroge = await _fillAllResourceTextStroge() || {};\n\n';
        source += 'let __resourceUrlStroge = await _fillAllResourceUrlStroge() || {};\n\n';
        source += 'let __RMC_CONTEXT = {};\n\n';
        source += GM_xmlhttpRequest.toString() + '\n\nwindow.GM_xmlhttpRequest = GM_xmlhttpRequest;\n';
        
        source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "clear_GM_log" });\n';

        if (grants.includes('GM_listValues')) {
            source += 'function GM_listValues (){ return __stroge}\n\nwindow.GM_listValues = GM_listValues;\n';
        }

        if (grants.includes('GM.listValues')) {
            source += 'GM.listValues = ' + _fillStroge.toString() + '\n\n';
        }

        if (grants.includes('GM_deleteValue')) {
            source += GM_deleteValue.toString() + '\n\nwindow.GM_deleteValue = GM_deleteValue;\n';
        }

        if (grants.includes('GM.deleteValue')) {
            source += 'GM.deleteValue = ' + deleteValue_p.toString() + '\n\n';
        }

        if (grants.includes('GM_setValue')) {
            source += GM_setValue.toString() + '\n\nwindow.GM_setValue = GM_setValue;\n';
        }

        if (grants.includes('GM.setValue')) {
            source += 'GM.setValue = ' + setValue_p.toString() + '\n\n';
        }

        if (grants.includes('GM_getValue')) {
            source += GM_getValue.toString() + '\n\nwindow.GM_getValue = GM_getValue;\n';
        }

        if (grants.includes('GM.getValue')) {
            source += 'GM.getValue = ' + getValue_p.toString() + '\n\n';
        }

        if (grants.includes("GM_addValueChangeListener")) {
            source += GM_addValueChangeListener.toString() + '\n\nwindow.GM_addValueChangeListener = GM_addValueChangeListener;\n';
        }
        if (grants.includes("GM.addValueChangeListener")) {
            source += 'GM.addValueChangeListener = ' + GM_addValueChangeListener_Async.toString() + '\n\n';
        }
        if (grants.includes("GM_removeValueChangeListener")) {
            source += GM_removeValueChangeListener.toString() + '\n\nwindow.GM_removeValueChangeListener = GM_removeValueChangeListener;\n';
        }
        if (grants.includes("GM.removeValueChangeListener")) {
            source += 'GM.removeValueChangeListener = ' + GM_removeValueChangeListener_Async.toString() + '\n\n';
        }
        if (grants.includes('GM.registerMenuCommand')) {
            source += 'GM.registerMenuCommand = ' + GM_registerMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM_registerMenuCommand')) {
            source += GM_registerMenuCommand.toString() + '\n\nwindow.GM_registerMenuCommand = GM_registerMenuCommand;\n';
        }

        if (grants.includes('GM.unregisterMenuCommand')) {
            source += 'GM.unregisterMenuCommand = ' + GM_unregisterMenuCommand.toString() + '\n\n';
        }

        if (grants.includes('GM_unregisterMenuCommand')) {
            source += GM_unregisterMenuCommand.toString() + '\n\nwindow.GM_unregisterMenuCommand = GM_unregisterMenuCommand;\n';
        }

        if (grants.includes('GM_addStyle')) {
            source += GM_addStyle.toString() + '\n\nwindow.GM_addStyle = GM_addStyle;\n';
        }

        if (grants.includes('GM.addStyle')) {
            source += 'GM.addStyle = ' + GM_addStyle.toString() + '\n\n';
        }
        if (grants.includes('GM_addElement') || grants.includes('GM.addElement')) {
            source += 'GM_addElement = ' + GM_addElement.toString() + '\n\nwindow.GM_addElement = GM_addElement;\n';
            source += 'GM.addElement = '+ GM_addElement_async.toString() + '\n\n';
        }

        if (grants.includes('GM_openInTab')) {
            source += GM_openInTab.toString() + '\n\n window.GM_openInTab = GM_openInTab; \n\n';
        }
        if (grants.includes('GM.openInTab')) {
            source += 'GM.openInTab = ' + GM_openInTab.toString() + '\n\n';
        }

        if (grants.includes('GM_getResourceURL')) {
            source += GM_getResourceURL.toString() + '\n\nwindow.GM_getResourceURL = GM_getResourceURL;\n';
        }
        if (grants.includes('GM_getResourceUrl')) {
            source += 'GM_getResourceUrl =' + GM_getResourceURL.toString() + '\n\nwindow.GM_getResourceUrl = GM_getResourceUrl;\n';
        }

        if (grants.includes('GM.getResourceURL') || grants.includes('GM.getResourceUrl')) {
            source += 'GM.getResourceURL = ' + getResourceURL_p.toString() + '\n\n';
            source += 'GM.getResourceUrl = ' + getResourceURL_p.toString() + '\n\n';
        }

        if (grants.includes('GM.getResourceText')) {
            source += 'GM.getResourceText = ' + getResourceText_p.toString() + '\n\n';
        }

        if (grants.includes('GM_getResourceText')) {
            source += GM_getResourceText.toString() + '\n\nwindow.GM_getResourceText = GM_getResourceText;\n';
        }
        if (grants.includes('GM_xmlHttpRequest')) {
            source +=  'GM_xmlHttpRequest=GM_xmlhttpRequest \n\nwindow.GM_xmlHttpRequest = GM_xmlHttpRequest;\n';
        }

        if (grants.includes('GM.xmlHttpRequest') || grants.includes('GM.xmlhttpRequest')) {
            source += 'GM.xmlHttpRequest = GM_xmlhttpRequest\n\n';
            source += 'GM.xmlhttpRequest = GM_xmlhttpRequest\n\n';
        }

        if (grants.includes('GM_notification') || grants.includes('GM.notification') ) {
            source += GM_notification.toString() + '\n\nwindow.GM_notification = GM_notification;\n';
            source += "GM.notification = " + GM_notification.toString() + '\n\n';
        }
        if (grants.includes('GM_cookie') || grants.includes('GM.cookie')) {
            source += GM_cookie.toString() + '\n\nwindow.GM_cookie = GM_cookie;\n';
            source += "GM.cookie = " + GM_cookie.toString() + '\n\n';
        }
        if (grants.includes('GM_download') || grants.includes('GM.download')) {
            source += GM_download.toString() + '\n\nwindow.GM_download = GM_download;\n';
            source += 'GM.download = GM_download\n\n';
        }
        if (grants.includes('GM_setClipboard') || grants.includes('GM.setClipboard')) {
            source += GM_setClipboard.toString() + '\n\nwindow.GM_setClipboard = GM_setClipboard;\n';
            source += "GM.setClipboard = " + GM_setClipboard.toString() + '\n\n';
        }

        //add GM_log by default
        source += GM_log.toString() + '\n\nwindow.GM_log = GM_log;\n';

        // source += injectJavaScript.toString() + ';\n\ninjectJavaScript();\n';

        source += _fillStroge.toString() + '\n\n';

        source += _fillAllResourceTextStroge.toString() + '\n\n';

        source += _fillAllResourceUrlStroge.toString() + '\n\n';
//        native.nslog("native-source" + source);
        return source;
    }

    /**
     * 
     * @param {string} name  The name of the observed variable
     * @param {any} oldVal   The old value of the observed variable (undefined if it was created)
     * @param {any} newVal   The new value of the observed variable (undefined if it was deleted)
     * @param {boolean} remote     true if modified by the userscript instance of another tab or false for this script instance. 
     * Can be used by scripts of different browser tabs to communicate with each other. in Stay case, default false value.
     * @returns 
     */
    function Stay_notifyValueChangeListeners(name, oldVal, newVal, remote) {
        if (oldVal == newVal) return;
        for (var i in Stay_storage_listeners) {
            if (!Stay_storage_listeners.hasOwnProperty(i)) continue;
            var n = Stay_storage_listeners[i];
            if (n && n.key == name) {
                if (n.cb) {
                    try {
                        n.cb(name, oldVal, newVal, remote);
                    } catch (e) {
                        if (D) console.log("env: value change listener of '" + name + "' failed with: " + e.message);
                    }
                }
            }
        }
    }

    function GM_addValueChangeListener(name, cb) {
        var id = 0;
        for (var n in Stay_storage_listeners) {
            if (!Stay_storage_listeners.hasOwnProperty(n)) continue;
            var i = Stay_storage_listeners[n];
            if (i.id > id) {
                id = n.id;
            }
        }
        id++;
        var s = { id: id, key: name, cb: cb };
        Stay_storage_listeners.push(s);
        return id;
    }

    function GM_addValueChangeListener_Async(name, cb) {
        return new Promise((resolve, reject)=>{
            var id = 0;
            for (var n in Stay_storage_listeners) {
                if (!Stay_storage_listeners.hasOwnProperty(n)) continue;
                var i = Stay_storage_listeners[n];
                if (i.id > id) {
                    id = n.id;
                }
            }
            id++;
            var s = { id: id, key: name, cb: cb };
            Stay_storage_listeners.push(s);
            resolve(id)
        });
    }

    function GM_removeValueChangeListener(id) {
        Stay_storage_listeners = Stay_storage_listeners.filter(item => item.id != id);
    }

    function GM_removeValueChangeListener_Async(id) {
        return new Promise((resolve, reject)=>{
            Stay_storage_listeners = Stay_storage_listeners.filter(item => item.id != id);
            resolve()
        });
        
    }

    function GM_info(userscript, version) {
        let info = {
            version: version,
            scriptHandler: "Stay",
            script: {
                version: userscript.version,
                description: userscript.description,
                namespace: userscript.namespace,
                name: userscript.namespace,
                scriptMetaStr: "",
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
            browser.storage.local.get(null, (res) => {
                // console.log("GM_listValues====", res);
                if(res){
                    let resp = {};
                    Object.keys(res).forEach((localKey) => {
                        if(localKey.startsWith(_uuid)){
                            let key = localKey.replace(_uuid+"_", "");
                            resp[key] = res[localKey];
                        }
                    })
                    // console.log("GM_listValues==-----------resp==", resp);
                    resolve(resp)
                }else{
                    browser.runtime.sendNativeMessage("application.id", { type: request.operate, uuid: uuid }, function (response) {
                        resolve(response.body);
                    });
                }
            })
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
                // console.log("_fillAllResourceUrlStroge", response);
                resolve(response.body);
            });
        });
    }
   
    function GM_setValue(key, value) {
        let old = __stroge[key];
        let type = "string";
        __stroge[key] = value;
        if(typeof value === "object"){
            value = JSON.stringify(value)
            type = "object";
        }
        // console.log("GM_setValue-----typeof value =", typeof value );
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid: _uuid, type: type }, (response) => {
            Stay_notifyValueChangeListeners(key, old, __stroge[key], false);
            // console.log("GM_setValue=====----content-----==", response);
            // resolve(response.body);
        });
        Stay_notifyValueChangeListeners(key, old, __stroge[key], false);
        return key
    }

    function setValue_p(key, value) {
        // console.log("setValue_p-----typeof value =", typeof value );
        return new Promise((resolve, reject) => {
            let type = "string";
            let old = __stroge[key];
            __stroge[key] = value;
            if(typeof value === "object"){
                value = JSON.stringify(value)
                type = "object";
            }
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid: _uuid, type: type }, (response) => {
                Stay_notifyValueChangeListeners(key, old, __stroge[key], false);
                // console.log("setValue_p====content----------------===", response);
                resolve(key);
            });
        });
    }

    function GM_getValue(key, defaultValue) {
        // console.log("GM_getValue-----typeof value =", typeof key );
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid: _uuid }, (response) => {
            __stroge[key]=response.body
            // console.log("GM_getValue-----value -----=====", response);
        });
        return !__stroge || typeof __stroge[key] === "undefined" || __stroge[key] == null ? defaultValue : __stroge[key];
    }

    function getValue_p(key, defaultValue) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid: _uuid }, (response) => {
                // console.log("getValue_p-----typeof response------ =",response );
                resolve(response);
                __stroge[key]=response.body
            });
        });
    }

    function deleteValue_p(key) {
        let old = __stroge[key];
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid: _uuid }, (response) => {
                delete __stroge[key];
                resolve(response.body);
                Stay_notifyValueChangeListeners(key, old, undefined, false);
            });
        });
    }

    function GM_deleteValue(key) {
        let old = __stroge[key];
        delete __stroge[key];
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid: _uuid });
        Stay_notifyValueChangeListeners(key, old, undefined, false);
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

    function GM_cookie(action, detail, res) {
        
    }

    function GM_download(options, name) {
        // console.log("options.111-------", options);
        let popToastTemp = [
            '<a id="GM_downloadLink" target="_blank" style="display:none">Allow</a>',
        ];
        let tempDom = document.getElementById("GM_downloadContainer");
        if (!tempDom){
            let temp = popToastTemp.join("");
            tempDom = document.createElement("div");
            tempDom.id = "GM_downloadContainer"
            tempDom.innerHTML = temp;
            document.body.appendChild(tempDom);
        }
        let downloadLinkDom = document.getElementById("GM_downloadLink");
        downloadLinkDom.addEventListener("click", function (e) {
            tempDom.remove();
        })
        // console.log("options.222-------", options);
        let url;
        if(typeof options === "string"){
            downloadLinkDom.download = name;
            url = options;
            // console.log("GM_downloadLink-------", url);
            if (url.match(new RegExp("^data:.*;base64,"))){ //download image directly
                downloadLinkDom.href = url;
                downloadLinkDom.click()
            }else{
                let gm_xhr = GM_xmlhttpRequest || __xhr;
                gm_xhr({
                    method: "GET",
                    responseType: "blob",
                    url: url,
                    onload: res => {
                        // console.log("download====",res);
                        if (res.status === 200) {
                            let downLoadUrl = res.response.blobUrl;
                            // console.log("downLoadUrl----1----", downLoadUrl);
                            downloadLinkDom.href = downLoadUrl
                            downloadLinkDom.click()
                        }
                    }
                });
            }
        }else{
            url = options.url;
            // console.log("options.-------", options);
            name = options.name;
            downloadLinkDom.download = name;
            let gm_xhr = GM_xmlhttpRequest || __xhr;
            gm_xhr({
                method: "GET",
                responseType: "blob",
                url: url,
                headers: options.headers?options.headers:{},
                timeout: options.timeout,
                onerror:  options.onerror,
                ontimeout: options.ontimeout,
                onprogress: options.onprogress,
                onload: res => {
                    options.onload(res);
                    // console.log("res-------",res)
                    if (res.status === 200) {
                        let downLoadUrl = res.response.blobUrl;
                        // console.log("downLoadUrl----1----", downLoadUrl);
                        downloadLinkDom.href = downLoadUrl
                        downloadLinkDom.click();
                    }
                }
            });
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
        userInfo["uuid"] = _uuid;
        
        let UUID_RMC_CONTEXT = __RMC_CONTEXT[_uuid]
        if (!UUID_RMC_CONTEXT || UUID_RMC_CONTEXT == "" || UUID_RMC_CONTEXT == "[]") {
            UUID_RMC_CONTEXT = [];
        }
        UUID_RMC_CONTEXT.push(userInfo);
        __RMC_CONTEXT[_uuid] = UUID_RMC_CONTEXT;
        // console.log("gm-api-----GM_registerMenuCommand");
        browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, command_content: userInfo,  operate: "REGISTER_MENU_COMMAND_CONTEXT" });
        browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
            let message_uuid = request.uuid; 
            // console.log("create_gmAPI-----execRegisterMenuCommand---1", message_uuid, _uuid, request)
            if (request.from == "background" && request.operate == "execRegisterMenuCommand" && message_uuid == _uuid) {
                let MESSAGE_UUID_RMC_CONTEXT = __RMC_CONTEXT[_uuid];
                let menuId = request.id;
                let place = -1;
                // console.log("create_gmAPI-----execRegisterMenuCommand---2", message_uuid, _uuid, MESSAGE_UUID_RMC_CONTEXT)
                if (MESSAGE_UUID_RMC_CONTEXT && MESSAGE_UUID_RMC_CONTEXT != "[]" && MESSAGE_UUID_RMC_CONTEXT.length > 0) {
                    try {
                        MESSAGE_UUID_RMC_CONTEXT.forEach((item, index) => {
                            if (item.id == menuId) {
                                place = index;
                                throw new Error("break");
                            }
                        })
                    } catch (error) {
                        if (error.message != "break") throw error;
                    }
                    // console.log("create_gmAPI-----execRegisterMenuCommand---2", message_uuid, _uuid, place)
                    if (place>=0){
                        MESSAGE_UUID_RMC_CONTEXT[place]["commandFunc"]();
                        sendResponse({ body: [], id: menuId, uuid: message_uuid })
                    }
                }
            }
            return true;
        })
        return pid;
    }

    function GM_unregisterMenuCommand(menuId) {
        let __UUID_RMC_CONTEXT = __RMC_CONTEXT[_uuid]
        if (!menuId || __UUID_RMC_CONTEXT.length <= 0) {
            return;
        }
        let place = -1;
        try {
            __UUID_RMC_CONTEXT.forEach((item, index) => {
                if (item.id == menuId && item.uuid == _uuid) {
                    place = index;
                    throw new Error("break");
                }
            });
        } catch (error) {
            if (error.message != "break") throw error;
        }
        
        if (place >= 0) {
            let pid = __UUID_RMC_CONTEXT[place].id
            __UUID_RMC_CONTEXT.splice(place, 1);
            __RMC_CONTEXT[_uuid] = __UUID_RMC_CONTEXT;
            browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, menuId: pid, operate: "REGISTER_MENU_COMMAND_CONTEXT" });
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

    function GM_addElement_async(parentElement, tagStr, attrObj){
        return new Promise((resolve, reject)=>{
            resolve(GM_addElement(parentElement, tagStr, attrObj));
        })

    }

    function GM_addElement(parentElement, tagStr, attrObj){
        if(typeof parentElement === "undefined"){
            return;
        }
        if(typeof parentElement === "string"){
            attrObj = tagStr;
            tagStr = parentElement;
            return createElementNode(tagStr, attrObj);
        }
        let tagDom = createElementNode(tagStr, attrObj);;
       
        parentElement.appendChild(tagDom);

        function createElementNode(tagStr, attrObj){
            if(!tagStr || tagStr === ""){
                return;
            }
            let tagDom = document.createElement(tagStr);
            if(typeof attrObj === "object"){
                Object.keys(attrObj).forEach((key, index) => {
                    tagDom[key] = attrObj[key];
                })
            }
            const headTags = ["script", "link", "style", "meta"]
            if(headTags.includes(tagStr.toLowerCase())){
                document.head.append(tagDom)
            }else{
                document.body.appendChild(tagDom)
            }
            return tagDom;
    
        }

        return tagDom;
    }

    

    function GM_getResourceText(name) {
        let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
        // let resourceText;
        if (!resourceText || typeof resourceText === undefined) {
            // 通过name获取resource
            // resourceText = await GM_getResourceText_p(name);
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, url: __resourceUrlStroge[name],  uuid: _uuid }, (response) => {
                // console.log("GM_getResourceText send to background-----", response);
                __resourceTextStroge[name] = response.body;
                resourceText = response.body;
            });
        }
        return resourceText;
    }


    function getResourceText_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, url: __resourceUrlStroge[name], uuid: _uuid }, (response) => {
                // console.log("GM_getResourceText_p-----", response);
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
        const xhrId = Math.random().toString(36).substring(1, 9);
        let shouldSendRequestToStay = false;
        if (params.headers && JSON.stringify(params.headers) != '{}') {
            const unsafeHeaders = ["accept-charset",
            "accept-encoding",
            "access-control-request-headers",
            "access-control-request-method",
            "connection",
            "content-length",
            "cookie",
            "cookie2",
            "date",
            "dnt",
            "expect",
            "host",
            "keep-alive",
            "origin",
            "proxy-",
            "sec-",
            "referer",
            "te",
            "trailer",
            "transfer-encoding",
            "upgrade",
            "via"];
            let headers = params.headers;
            try{
                Object.keys(headers).forEach((key) => {
                    let lowerKey = key.toLocaleLowerCase();
                    if(unsafeHeaders.includes(lowerKey) || lowerKey.startsWith("proxy-") || lowerKey.startsWith("sec-")){
                        // console.log("lowerKey======",lowerKey)
                        shouldSendRequestToStay = true;
                        throw new Error("endLoop");
                    }
                });
            }catch(e){
                if(e.message !== 'endLoop') throw e
            }
        }

        if(shouldSendRequestToStay){
            // console.log("shouldSendRequestToStay===GM_xmlhttpRequestGM_xmlhttpRequest===",shouldSendRequestToStay)
            browser.runtime.sendMessage({ from: "gm-apis", operate: "HTTP_REQUEST_API_FROM_CREATE_TO_APP", type:"content", details: params, uuid: _uuid, xhrId: xhrId }, (response) => {
                // console.log("HTTP_REQUEST_API_FROM_CREATE_TO_APP----response=====", response)
                if(response){
                    const { status } = response
                    if( status >= 200 && status < 400){
                        if (params.onload) {
                            params.onload(response);
                        } 
                        if (params.onloadend) {
                            params.onloadend(response);
                        } 
                        if (params.onloadstart) {
                            params.onloadtstart(response);
                        } 
                        if (params.onprogress) {
                            params.onprogress(response);
                        } 
                        if (params.onreadystatechange) {
                            params.onreadystatechange(response);
                        } 
                    }else if(status == 504){
                        if (params.ontimeout) {
                            params.ontimeout(response);
                        }
                    }else{
                        if (params.onerror) {
                            params.onerror(response);
                        } 
                    }
                }else{
                    if (params.onerror) {
                        params.onerror({});
                    } 
                }
                // if (params.onabort) {
                //     params.onabort(response);
                // } 
            })
        }else{
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_xmlhttpRequest", params: params, uuid: _uuid, xhrId: xhrId }, (response) => {
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
                    // console.log("GM_xmlhttpRequest.onload====",onload)
                    params.onload(onload)
                }
            });
        }

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
        api += `${GM_getAllResourceText}\nwindow.GM_getAllResourceText = GM_getAllResourceText;\n`;
        api += 'let __listValuesStroge = await GM_listValues_Async() || {};\n';
        api += 'let __resourceUrlStroge = ' + JSON.stringify(resourceUrls)+';\n';
        api += 'let __resourceTextStroge = await GM_getAllResourceText() || {};\n';
        api += 'let __RMC_CONTEXT = {};\n';
        api += 'let GM_info =' + GM_info(userscript, version) + ';\nwindow.GM_info = GM_info;\n';
        api += `${GM_log}\nwindow.GM_log = GM_log;\n`;
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
                api += `function GM_listValues(){ return __listValuesStroge;}\nwindow.GM_listValues = GM_listValues;\n`;
                gmFunName.push("GM_listValues");
            }
            else if (grant === "GM.deleteValue" && !gmFunName.includes("GM_deleteValue_Async")) {
                api += `${GM_deleteValue_Async}\n`;
                gmFunVals.push("deleteValue: GM_deleteValue_Async");
                gmFunName.push("GM_deleteValue_Async");
            }
            else if (grant === "GM_deleteValue" && !gmFunName.includes("GM_deleteValue")){
                api += `${GM_deleteValue_sync}\nconst GM_deleteValue = GM_deleteValue_sync;\nwindow.GM_deleteValue = GM_deleteValue;\n`;
                gmFunName.push("GM_deleteValue");
            }
            else if (grant === "GM_addStyle" && !gmFunName.includes("GM_addStyle")) { //同步
                api += `${GM_addStyleSync}\nconst GM_addStyle = GM_addStyleSync;\nwindow.GM_addStyle = GM_addStyle;\n`;
                gmFunName.push("GM_addStyle");
            } 
            else if (grant === "GM.addStyle" && !gmFunName.includes("GM_addStyle_Async")) {
                api += `${GM_addStyle_Async}\n`;
                gmFunVals.push("addStyle: GM_addStyle_Async");
                gmFunName.push("GM_addStyle_Async");
            } 
            else if ((grant === "GM_addElement" || grant === "GM.addElement") && !gmFunName.includes("${GM_addElement}")) { //同步
                api += `${GM_addElement}\nwindow.GM_addElement = GM_addElement;\n`;
                api += `${GM_addElement_async}\n`;
                gmFunName.push("GM_addElement");
                gmFunVals.push("addElement: GM_addElement_async");
            } 
            else if ("GM.setValue" === grant && !gmFunName.includes("GM_setValue_Async")){
                api += `${GM_setValue_Async}\n`;
                gmFunVals.push("setValue:  GM_setValue_Async");
                gmFunName.push("GM_setValue_Async");
            }
            else if ("GM_setValue" === grant && !gmFunName.includes("GM_setValue")) {
                api += `${GM_setValueSync}\nconst GM_setValue = GM_setValueSync;\nwindow.GM_setValue = GM_setValue;\n`;
                gmFunName.push("GM_setValue");
            }
            else if ("GM.getValue" === grant && !gmFunName.includes("GM_getValueAsync")) {
                api += `${GM_getValueAsync}\n`;
                gmFunVals.push("getValue: GM_getValueAsync");
                gmFunName.push("GM_getValueAsync");
            }
            else if ("GM_getValue" === grant && !gmFunName.includes("GM_getValueSync")) {
                api += `${GM_getValueSync}\nconst GM_getValue = GM_getValueSync;\nwindow.GM_getValue = GM_getValue;\n`;
                gmFunName.push("GM_getValueSync");
            }
            else if (("GM_registerMenuCommand" === grant || "GM.registerMenuCommand" === grant) && 
                (!gmFunName.includes("GM_registerMenuCommand") || !gmFunName.includes("GM.registerMenuCommand"))){
                api += `${GM_registerMenuCommand}\nwindow.GM_registerMenuCommand = GM_registerMenuCommand;\n`;
                gmFunVals.push("registerMenuCommand: GM_registerMenuCommand");
                gmFunName.push("GM_registerMenuCommand");
                gmFunName.push("GM.registerMenuCommand");
            }
            else if (("GM_unregisterMenuCommand" === grant || "GM.unregisterMenuCommand" === grant) && 
                (!gmFunName.includes("GM_unregisterMenuCommand") || !gmFunName.includes("GM.unregisterMenuCommand"))) {
                api += `${GM_unregisterMenuCommand}\nwindow.GM_unregisterMenuCommand = GM_unregisterMenuCommand;\n`;
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
            else if ("GM.getResourceText" === grant && !gmFunName.includes("GM_getResourceText_Async")) {
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
                api += `${GM_openInTab}\n window.GM_openInTab = GM_openInTab;\n`;
                gmFunName.push("GM_openInTab");
            }
            else if (("GM.closeTab" === grant || "GM_closeTab" === grant) && !gmFunName.includes("GM_closeTab")) {
                api += `${GM_closeTab}\nwindow.GM_closeTab = GM_closeTab;\n`;
                gmFunVals.push("closeTab: GM_closeTab");
                gmFunName.push("GM_closeTab");
            }
            else if (("GM.notification" === grant || "GM_notification" === grant) && !gmFunName.includes("GM_notification")) {
                api += `${GM_notification}\nwindow.GM_notification = GM_notification;\n`;
                gmFunVals.push("notification: GM_notification");
                gmFunName.push("GM_notification");
            }
            else if (("GM_addValueChangeListener" === grant) && !gmFunName.includes("GM_addValueChangeListener")) {
                api += `${GM_addValueChangeListener}\nwindow.GM_addValueChangeListener = GM_addValueChangeListener;\n`;
                gmFunName.push("GM_addValueChangeListener");
            }
            else if ("GM.addValueChangeListener" === grant && !gmFunName.includes("GM_addValueChangeListener_Async")) {
                api += `${GM_addValueChangeListener_Async}\n`;
                gmFunVals.push("addValueChangeListener: GM_addValueChangeListener_Async");
                gmFunName.push("GM_addValueChangeListener_Async");
            }
            else if (("GM_removeValueChangeListener" === grant) && !gmFunName.includes("GM_removeValueChangeListener")) {
                api += `${GM_removeValueChangeListener}\nwindow.GM_removeValueChangeListener = GM_removeValueChangeListener;\n`;
                gmFunVals.push("removeValueChangeListener: GM_removeValueChangeListener");
                gmFunName.push("GM_removeValueChangeListener");
            }
            else if ("GM.removeValueChangeListener" === grant && !gmFunName.includes("GM_removeValueChangeListener_Async")) {
                api += `${GM_removeValueChangeListener_Async}\n`;
                gmFunVals.push("removeValueChangeListener: GM_removeValueChangeListener_Async");
                gmFunName.push("GM_removeValueChangeListener_Async");
            }
            else if (("GM.setClipboard" === grant || "GM_setClipboard" === grant) && !gmFunName.includes("GM_setClipboard") ) {
                api += `${GM_setClipboard}\nwindow.GM_setClipboard = GM_setClipboard;\n`;
                gmFunVals.push("setClipboard: GM_setClipboard");
                gmFunName.push("GM_setClipboard");
            }
            else if (("GM.download" === grant || "GM_download" === grant) && !gmFunName.includes("GM_download")) {
                api += `${GM_download}\nwindow.GM_download = GM_download;\n`;
                gmFunVals.push("download: GM_download");
                gmFunName.push("GM_download");
            }
            else if (("GM.cookie" === grant || "GM_cookie" === grant) && !gmFunName.includes("GM_cookie")) {
                api += `${GM_cookie}\nwindow.GM_cookie = GM_cookie;\n`;
                gmFunVals.push("cookie: GM_cookie");
                gmFunName.push("GM_cookie");
            }
            else if (grant === "GM_xmlhttpRequest" && !gmFunName.includes("GM_xmlhttpRequest")){
                api += "\nconst GM_xmlhttpRequest = __xhr;\nwindow.GM_xmlhttpRequest = GM_xmlhttpRequest;\n";
                gmFunName.push("GM_xmlhttpRequest");

            }
            else if (grant === "GM_xmlHttpRequest" && !gmFunName.includes("GM_xmlHttpRequest")){
                api += "\nconst GM_xmlHttpRequest = __xhr;\nwindow.GM_xmlHttpRequest = GM_xmlhttpRequest;\n";
                gmFunName.push("GM_xmlHttpRequest");

            }
            else if (grant === "GM.xmlHttpRequest" && !gmFunName.includes("GM.xmlHttpRequest")) {
                gmFunVals.push("xmlHttpRequest: __xhr");
                gmFunName.push("GM.xmlHttpRequest");
            }
            else if (grant === "GM.xmlhttpRequest" && !gmFunName.includes("GM.xmlhttpRequest")) {
                gmFunVals.push("xmlhttpRequest: __xhr");
                gmFunName.push("GM.xmlhttpRequest");
            }
        })

        function GM_listValues_Async() {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_LIST_VALUES") return;
                    // console.log("GM_listValues_Async----response=", e.data);
                    let res = e.data ? (e.data.response ? e.data.response.body : {}): {};
                    resolve(res);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_LIST_VALUES" });
            });
        }
        

        function GM_setValueSync(key, value) {
            // console.log("GM_setValueSync-----key===", key,",value=",value, ",JSON.stringify(value)=",JSON.stringify(value));
            let type = "string";
            let old = __listValuesStroge[key];
            __listValuesStroge[key] = value;
            if(typeof value === "object"){
                value = JSON.stringify(value)
                type = "object";
            }
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_SET_VALUE") return;
                Stay_notifyValueChangeListeners(key, old, __listValuesStroge[key], false);
                // console.log("GM_setValue_Async----res", e.data);
                
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, pid: pid, name: "API_SET_VALUE", key: key, value: value, type: type });
            return key;
        }

        function GM_setValue_Async(key, value) {
            // console.log("setValue_p-----typeof value =", typeof value );
            let old = __listValuesStroge[key];
            __listValuesStroge[key] = value;
            let type = "string";
            if(typeof value === "object"){
                value = JSON.stringify(value)
                type = "object";
            }
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_SET_VALUE") return;
                    Stay_notifyValueChangeListeners(key, old, __listValuesStroge[key], false);
                    // console.log("GM_setValue_Async----res", e.data);
                    resolve(key);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_SET_VALUE", key: key, value: value, type: type });
            });
        }

        function GM_getValueSync(key, defaultValue) {
            // console.log("GM_getValueSync-----typeof key =", key, ", defaultValue=",defaultValue, typeof defaultValue, ",__listValuesStroge===",__listValuesStroge );
            let type = "string";
            let value = defaultValue
            if(typeof value === "object"){
                value = JSON.stringify(value)
                type = "object";
            }
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_VALUE") return;
                // console.log("---api-----GM_getValueSync----res----", e.data);
                __listValuesStroge[key] = e.data.response
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE", key: key, defaultValue: value, type: type });
            // window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE_SYNC", key: key, defaultValue: value, type: type });
            return !__listValuesStroge || typeof __listValuesStroge[key] === "undefined" || __listValuesStroge[key] == null ? defaultValue : __listValuesStroge[key];
        }

        function GM_getValueAsync(key, defaultValue) {
            // console.log("GM_getValueAsync-----typeof key =", typeof key, ", defaultValue=",defaultValue, typeof defaultValue );
            const pid = Math.random().toString(36).substring(1, 9);
            let type = "string";
            let value = defaultValue
            if(typeof value === "object"){
                value = JSON.stringify(value)
                type = "object";
            }
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_VALUE") return;
                    // console.log("GM_getValueAsync----res----", e.data);
                    resolve(e.data.response?e.data.response:defaultValue);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE", key: key, defaultValue: value, type: type });
            });
        }

        function GM_deleteValue_Async(key) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_DELETE_VALUE") return;
                    let old = __listValuesStroge[key];
                    delete __listValuesStroge[key];
                    Stay_notifyValueChangeListeners(key, old, __listValuesStroge[key], false);
                    resolve(e.data.response);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                window.postMessage({ id: _uuid, pid: pid, name: "API_DELETE_VALUE", key: key });
            });
        }

        function GM_deleteValue_sync(key) {
            let old = __listValuesStroge[key];
            delete __listValuesStroge[key];
            Stay_notifyValueChangeListeners(key, old, __listValuesStroge[key], false);
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
            // if (!resourceText || resourceText === "" || resourceText === undefined) {
            //     window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL_SYNC", key: name });
            // }
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_URL") return;
                // console.log("GM_getResourceURLSync------",e);
                __resourceUrlStroge[name] = e.data.response.body
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL", key: name });
            return resourceUrl;
        }

        function GM_getResourceURL_Async(name) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_URL") return;
                    // console.log("GM_getResourceURL_Async------",e);
                    resolve(e.data.response.body);
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL", key: name });
            });
        }

        function GM_getResourceText_Async(name) {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name] : "";
                if(!resourceUrl){
                    let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
                    resolve(resourceText)
                    return ;
                }
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_TEXT") return;
                    // console.log("GM_getResourceText_Async------",e)
                    resolve(e.data.response && e.data.response.body?e.data.response.body:"");
                    window.removeEventListener("message", callback);
                };
                window.addEventListener("message", callback);
                // console.log(" __resourceUrlStroge[name]----", __resourceUrlStroge[name])
                window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_TEXT", key: name, url: resourceUrl });
            });
        }

        function GM_getResourceTextSync(name) {
            const pid = Math.random().toString(36).substring(1, 9);
            let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";

            let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name] : "";
            if(!resourceUrl){
                return resourceText;
            }
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_TEXT", key: name, url: resourceUrl });
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_TEXT") return;
                // console.log("GM_getResourceTextSync------",e)
                __resourceTextStroge[name] = e.data.response && e.data.response.body?e.data.response.body:"";
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            return resourceText;
        }

        function GM_getAllResourceText() {
            const pid = Math.random().toString(36).substring(1, 9);
            return new Promise(resolve => {
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_ALL_REXOURCE_TEXT") return;
                    // console.log("GM_getAllResourceText----", e);
                    let res = e.data ? (e.data.response ? e.data.response.body : {}) : {};
                    resolve(res);
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
            userInfo["accessKey"] = accessKey;
            userInfo["id"] = pid;
            userInfo["uuid"] = _uuid;
            userInfo["commandFunc"] = commandFunc;
            // console.log("GM_registerMenuCommand----", userInfo);
            window.postMessage({ id: _uuid, pid: pid, name: "REGISTER_MENU_COMMAND_CONTEXT", rmc_context: JSON.stringify(userInfo) });
            let UUID_RMC_CONTEXT = __RMC_CONTEXT[_uuid]
            if (!UUID_RMC_CONTEXT || UUID_RMC_CONTEXT == "" || UUID_RMC_CONTEXT == "[]"){
                UUID_RMC_CONTEXT = [];
            }
            UUID_RMC_CONTEXT.push(userInfo);
            __RMC_CONTEXT[_uuid] = UUID_RMC_CONTEXT;
            window.addEventListener('message', (e) => {
                if (!e || !e.data || !e.data.name) return;
                let uuid = e.data.uuid;
                const name = e.data.name;
                if ("execRegisterMenuCommand" === name && uuid == _uuid){
                    let menuId = e.data.menuId;
                    let place = -1;
                    let __UUID_RMC_CONTEXT = __RMC_CONTEXT[uuid]
                    if (__UUID_RMC_CONTEXT && __UUID_RMC_CONTEXT.length > 0) {
                        try{
                            __UUID_RMC_CONTEXT.forEach((item, index) => {
                                if (item.id == menuId) {
                                    place = index;
                                    throw new Error("break");
                                }
                            });
                        }catch(e){
                            if (e.message != "break") throw e;
                        }
                        if (place >= 0) {
                            __UUID_RMC_CONTEXT[place]["commandFunc"]();
                        }
                    }
                }
            });
            return pid;
        }

        function GM_unregisterMenuCommand(menuId) {
            let __UUID_RMC_CONTEXT = __RMC_CONTEXT[_uuid]
            // console.log("GM_unregisterMenuCommand, __UUID_RMC_CONTEXT=1==", __UUID_RMC_CONTEXT, "====menuId=", menuId);
            if (!menuId || __UUID_RMC_CONTEXT.length<=0){
                return;
            }
            let place = -1;
            try {
                __UUID_RMC_CONTEXT.forEach((item, index) => {
                    console.log("GM_unregisterMenuCommand, item===", item,",index=",index);
                    if (item.id == menuId && item.uuid == _uuid) {
                        // console.log("GM_unregisterMenuCommand, menuId===", menuId);
                        place = index;
                        throw new Error("break");
                    }
                });
            } catch (error) {
                if (error.message != "break") throw error;
            }
            if (place>=0){
                let pid = __UUID_RMC_CONTEXT[place].id
                __UUID_RMC_CONTEXT.splice(place, 1);
                __RMC_CONTEXT[_uuid] = __UUID_RMC_CONTEXT;
                // console.log("GM_unregisterMenuCommand, __UUID_RMC_CONTEXT=2==", __UUID_RMC_CONTEXT);
                window.postMessage({ id: _uuid, name: "UNREGISTER_MENU_COMMAND_CONTEXT", pid: pid });
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
            let shouldSendRequestToStay = false;
            // console.log("XHR==request=", details);
            if (details.headers && JSON.stringify(details.headers) != '{}') {
                const unsafeHeaders = ["accept-charset",
                "accept-encoding",
                "access-control-request-headers",
                "access-control-request-method",
                "connection",
                "content-length",
                "cookie",
                "cookie2",
                "date",
                "dnt",
                "expect",
                "host",
                "keep-alive",
                "origin",
                "proxy-",
                "sec-",
                "referer",
                "te",
                "trailer",
                "transfer-encoding",
                "upgrade",
                "via"];
                let headers = details.headers;
                try{
                    Object.keys(headers).forEach((key) => {
                        let lowerKey = key.toLocaleLowerCase();
                        if(unsafeHeaders.includes(lowerKey) || lowerKey.startsWith("proxy-") || lowerKey.startsWith("sec-")){
                            // console.log("lowerKey======",lowerKey)
                            shouldSendRequestToStay = true;
                            throw new Error("endLoop");
                        }
                    });
                }catch(e){
                    if(e.message !== 'endLoop') throw e
                }
            }

            if(shouldSendRequestToStay){
                // console.log("shouldSendRequestToStay==__xhr__xhr__xhr__xhr====",shouldSendRequestToStay)
                window.addEventListener("message", (e)=>{
                    const response = e.data.response;
                    const name = e.data.name;
                    
                    if( e.data.xhrId !== xhrId
                        || !name
                        || name !== "RESP_HTTP_REQUEST_API_FROM_CREATE_TO_APP"){
                            return;
                    }
                    console.log("name===",name,"response===",response);
                    if(response){
                        const { status } = response
                        if( status >= 200 && status < 400){
                            if (details.onload) {
                                details.onload(response);
                            } 
                            if (details.onloadend) {
                                details.onloadend(response);
                                window.removeEventListener("message", ()=>{});
                            } 
                            if (details.onloadstart) {
                                details.onloadtstart(response);
                            } 
                            if (details.onprogress) {
                                details.onprogress(response);
                            } 
                            if (details.onreadystatechange) {
                                details.onreadystatechange(response);
                            } 
                        }else if(status == 504){
                            if (details.ontimeout) {
                                details.ontimeout(response);
                            }
                        }else{
                            if (details.onerror) {
                                details.onerror(response);
                            } 
                        }
                    }else{
                        if (details.onerror) {
                            details.onerror({});
                        } 
                    }
                });
                window.postMessage({ id: _uuid, name: "HTTP_REQUEST_API_FROM_CREATE_TO_APP", details: JSON.stringify(detailsParsed), xhrId: xhrId });
            }else{
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
                    // console.log("XHR==response=", response);
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
            }
            return { abort: abort };
        }

        api += `${browserAddListener}\nbrowserAddListener();`;

        const GM = `const GM = {${gmFunVals.join(",")}};`;
        return `\n${api}\n${GM}\n`;
    }
    
    window.createGMApisWithUserScript = createGMApisWithUserScript;

})();
