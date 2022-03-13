/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function() {    
    function createGMApisWithUserScript(userscript, uuid, version){
        let grants = userscript.grants;
        native.nslog("native-userscript-grants-" + grants);
        let source = 'const _uuid = "' + uuid + '";\n\n';
        source += 'const _version = "' + version + '";\n\n';
        source += 'let unsafeWindow = window;\n\n';
        source += 'let GM = {};\n\n';
        source += 'let GM_info = {};\n\n';
        source += 'let retries = 3;\n\n';
        source += 'let __stroge = await _fillStroge();\n\n';
        source += 'let __resourceTextStroge = await _fillAllResourceTextStroge();\n\n';
        source += 'let __resourceUrlStroge = await _fillAllResourceUrlStroge();\n\n';
        source += 'let __RMC_CONTEXT = [];\n\n';
        source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "unsafeWindow" }, (response)=>{unsafeWindow = response.unsafeWindow;});\n';
        source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "clear_GM_log" });\n';
        source += 'browser.runtime.onMessage.addListener((request, sender, sendResponse) => {\n';
        source += '\tif (request.from == "background" && request.operate == "fetchRegisterMenuCommand"){\n';
        source += '\tbrowser.runtime.sendMessage({from:"content",data:__RMC_CONTEXT,uuid:_uuid,operate:"giveRegisterMenuCommand"});}\n';
        source += '\telse if (request.from == "background" && request.operate == "execRegisterMenuCommand" && request.uuid == _uuid){\n';
        source += '\t\tconsole.log(__RMC_CONTEXT[request.id]);\n';
        source += '\t\t__RMC_CONTEXT[request.id]["commandFunc"]();}\n';
        source += '\treturn true;\n'
        source += '});\n\n';

        if (grants.includes('GM_listValues')) {
            source += GM_listValues.toString() + ';\n\n';
        }

        if (grants.includes('GM.listValues')) {
            source += 'GM.listValues = ' + GM_listValues_p.toString() + ';\n\n';
        }

        if (grants.includes('GM_deleteValue')) {
            source += GM_deleteValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.deleteValue')) {
            source += 'GM.deleteValue = ' + GM_deleteValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM_setValue')) {
            source += GM_setValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.setValue')) {
            source += 'GM.setValue = ' + GM_setValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM_getValue')) {
            source += GM_getValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.getValue')) {
            source += 'GM.getValue = ' + GM_getValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM.registerMenuCommand')) {
            source += 'GM.registerMenuCommand = ' + GM_registerMenuCommand.toString() + ';\n\n';
        }

        if (grants.includes('GM_registerMenuCommand')) {
            source += GM_registerMenuCommand.toString() + ';\n\n';
        }

        if (grants.includes('GM_addStyle')) {
            source += GM_addStyle.toString() + ';\n\n';
        }

        if (grants.includes('GM.addStyle')) {
            source += 'GM.addStyle = ' + GM_addStyle.toString() + ';\n\n';
        }

        if (grants.includes('unsafeWindow')) {
            // source += 'let unsafeWindow = (function() {var dummyElem = document.createElement("div");dummyElem.setAttribute("id", "windowDiv"); dummyElem.setAttribute("onclick", "return window;"); let win = dummyElem.onclick();console.log("__INITIAL_SSR_STATE__--------",win);return win;})()' + ';\n\n';
            // source += 'let unsafeWindow = (function(){return document.defaultView;})();\n\n';
        }

        if (grants.includes('GM_openInTab')) {
            source += GM_openInTab.toString() + ';\n\n';
        }

        if (grants.includes('GM_getResourceURL')) {
            source += GM_getResourceURL.toString() + '; \n\n';
        }
        if (grants.includes('GM_getResourceUrl')) {
            source += 'GM_getResourceUrl =' + GM_getResourceURL.toString() + '; \n\n';
        }

        if (grants.includes('GM.getResourceURL') || grants.includes('GM.getResourceUrl')) {
            source += 'GM.getResourceURL = ' + GM_getResourceURL_p.toString() + '; \n\n';
            source += 'GM.getResourceUrl = ' + GM_getResourceURL_p.toString() + '; \n\n';
        }

        if (grants.includes('GM.getResourceText')) {
            source += 'GM.getResourceText = ' + GM_getResourceText_p.toString() + '; \n\n';
        }

        if (grants.includes('GM_getResourceText')) {
            source += GM_getResourceText.toString() + '; \n\n';
        }

        if (grants.includes('GM_xmlhttpRequest')) {
            source += GM_xmlhttpRequest.toString() + ';\n\n';
        }

        if (grants.includes('GM.xmlHttpRequest')) {
            source += 'GM.xmlHttpRequest = ' + GM_xmlhttpRequest.toString() + ';\n\n';
        }

        //add GM_log by default
        source += GM_log.toString() + ';\n\n';

        source += _fillStroge.toString() + ';\n\n';

        source += _fillAllResourceTextStroge.toString() + ';\n\n';

        source += _fillAllResourceUrlStroge.toString() + ';\n\n';
        native.nslog("native-source" + source);

        source += 'GM_info={version: _version, scriptHandler: "Stay"};\n\n';
        source += 'GM_info.script={version: "' + userscript.version + '",description:"' + userscript.description + '",namespace:"' + userscript.namespace + '"};\n\n';
        source += 'GM_info.script.resources= ' + JSON.stringify(userscript.resourceUrls ? userscript.resourceUrls:[])+ ';\n';
        source += 'GM_info.script.includes= ' + JSON.stringify(userscript.includes ? userscript.includes:[]) + ';\n';
        source += 'GM_info.script.excludes= ' + JSON.stringify(userscript.excludes ? userscript.excludes:[]) + ';\n';
        source += 'GM_info.script.matches= ' + JSON.stringify(userscript.matches ? userscript.matches :[])+ ';\n';
        source += 'GM.info = GM_info;\n\n'; 
        return source;
    }

    function _fillStroge(){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid:_uuid }, (response) => {
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
    
    function GM_listValues(){
        return __stroge;
    }
    
    function GM_deleteValue(key){
        __stroge[key] = null;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid:_uuid });
    }
    
    function GM_setValue(key,value){
        __stroge[key] = value;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid:_uuid });
    }
    
    function GM_getValue(key, defaultValue){
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid:_uuid });
        return __stroge[key] == null ? defaultValue : __stroge[key];
    }
    
    function GM_listValues_p(){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_deleteValue_p(key){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_setValue_p(key,value){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_getValue_p(key,defaultValue){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key: key, defaultValue: defaultValue, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_log(message){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_log", message: message, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_registerMenuCommand(caption, commandFunc, accessKey){
        let userInfo = {};
        userInfo["caption"] = caption;
        userInfo["commandFunc"] = commandFunc;
        userInfo["accessKey"] = accessKey;
        userInfo["id"] = __RMC_CONTEXT.length;
        __RMC_CONTEXT.push(userInfo);
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

    function unsafeWindowInit() {
        var div = document.createElement('div');
        div.setAttribute('id', 'windowDiv');
        div.setAttribute('onclick', 'return window;');
        document.body.appendChild(div);
        console.log("createGMApisWithUserScript-----------setTimeout-----unsafeWindow-----")
        return div.onclick();
    }
    
    function GM_getResourceText(name) {
        let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
        if (!resourceText || typeof resourceText === undefined) {
            // 通过name获取resource
            // resourceText = await GM_getResourceText_p(name);
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, uuid: _uuid }, (response) => {
                console.log("GM_getResourceText send to background-----", response);
            });
        }
        return resourceText;
    }


    function GM_getResourceText_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, uuid: _uuid }, (response) => {
                console.log("GM_getResourceText_p-----", response);
                resolve(response.body);
            });
        });
    }

    function GM_getResourceURL(name) {
        let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name]:"";
        if (!resourceUrl || typeof resourceUrl === undefined){
            // 通过url获取resources
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceUrl", key: name, uuid: _uuid }, (response) => {
                console.log("GM_getResourceURL----GM_getResourceURL-----", response);
            });
        }
        return resourceUrl;
    }

    function GM_getResourceURL_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceUrl", key: name, uuid: _uuid }, (response) => {
                console.log("GM_getResourceURL_p-----",response);
                resolve(response.body);
            });
        });
    }

    function GM_xmlhttpRequest(params) {
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_xmlhttpRequest", params: params, uuid: _uuid }, (response) => {
            var onreadystatechange = response.onreadystatechange;
            var onerror = response.onerror;
            var onload = response.onload;
            if (params.onreadystatechange && onreadystatechange){
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
        console.log("start GM_openInTab-----", url, options);
        // retrieve tabId to have a chance of closing this window lateron
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
            console.log("GM_openInTab response---", response)
            tabId = response.tabId;
        };
        if (url && url.search(/^\/\//) == 0) {
            url = location.protocol + url;
        }
        browser.runtime.sendMessage({ from: "gm-apis", operate: "openInTab", url: url, id: _uuid, uuid: _uuid, options: options }, resp);
        return { close: close };
    }

    window.createGMApisWithUserScript = createGMApisWithUserScript;

})();
