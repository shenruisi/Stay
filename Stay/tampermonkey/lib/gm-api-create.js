/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function () {

    function createGMApisWithUserScript(userscript, uuid, version) {
        let grants = userscript.grants;
        let source = 'const _uuid = "' + uuid + '";\n\n';
        source += 'const _version = "' + version + '";\n\n';
        if (grants.includes('unsafeWindow')) {
            injectJavaScript(userscript, uuid, version);
            // source 为 window.addEventListener()
            source += `window.addEventListener('message', (e)=>{\n${getSourceOfWindowListener}\n})\n\n`;
            return source;
        }
        source += 'let GM = {};\n\n';
        source += 'let GM_info = {};\n\n';
        source += 'GM_info=' + GM_info(userscript, version) + ';\n';
        source += 'GM.info=GM_info;\n';


        // source += 'let unsafeWindow = window;\n\n console.log("createGMApisWithUserScript-----",window);';
        // source += 'window.addEventListener("message", res => {console.log("injectJavaScript----", res);let unsafeWindow6 = res.data.unsafeWindow;let srcElementWindow= res.srcElement; let unsafeWindow1 = res.source;let unsafeWindow2 = res.target.parent; console.log("srcElementWindow-bds--",srcElementWindow.bds,"unsafeWindow---",unsafeWindow, ",unsafeWindow1.bds=",unsafeWindow1.bds,",_WWW_SRV_T=",unsafeWindow._WWW_SRV_T,unsafeWindow1._WWW_SRV_T,unsafeWindow2._WWW_SRV_T)}); \n\n ';
        // source += 'let unsafeWindow = (function () { var dummyElem = document.createElement("div"); dummyElem.setAttribute("id", "windowDiv"); dummyElem.setAttribute("onclick", "return window;"); let win = dummyElem.onclick(); console.log("__INITIAL_SSR_STATE__--------", win); return win; })()' + '; \n\n';

        source += 'let __stroge = await _fillStroge();\n\n';
        source += 'let __resourceTextStroge = await _fillAllResourceTextStroge();\n\n';
        source += 'let __resourceUrlStroge = await _fillAllResourceUrlStroge();\n\n';
        source += 'let __RMC_CONTEXT = [];\n\n';
        // source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "unsafeWindow" }, (response)=>{unsafeWindow = response.unsafeWindow;});\n';

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
            source += '__stroge;\n\n';
        }

        if (grants.includes('GM.listValues')) {
            source += 'GM.listValues = ' + _fillStroge.toString() + ';\n\n';
        }

        if (grants.includes('GM_deleteValue')) {
            source += deleteValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.deleteValue')) {
            source += 'GM.deleteValue = ' + deleteValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM_setValue')) {
            source += setValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.setValue')) {
            source += 'GM.setValue = ' + setValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM_getValue')) {
            source += getValue.toString() + ';\n\n';
        }

        if (grants.includes('GM.getValue')) {
            source += 'GM.getValue = ' + getValue_p.toString() + ';\n\n';
        }

        if (grants.includes('GM.registerMenuCommand')) {
            source += 'GM.registerMenuCommand = ' + registerMenuCommand.toString() + ';\n\n';
        }

        if (grants.includes('GM_registerMenuCommand')) {
            source += registerMenuCommand.toString() + ';\n\n';
        }

        if (grants.includes('GM_addStyle')) {
            source += addStyle.toString() + ';\n\n';
        }

        if (grants.includes('GM.addStyle')) {
            source += 'GM.addStyle = ' + addStyle.toString() + ';\n\n';
        }

        // source += 'let unsafeWindow = (function() {var dummyElem = document.createElement("div");dummyElem.setAttribute("id", "windowDiv"); dummyElem.setAttribute("onclick", "return window;"); let win = dummyElem.onclick();console.log("__INITIAL_SSR_STATE__--------",win);return win;})()' + ';\n\n';
        // source += 'let unsafeWindow = (function(){return document.defaultView;})();\n\n';

        if (grants.includes('GM_openInTab')) {
            source += openInTab.toString() + ';\n\n';
        }

        if (grants.includes('GM_getResourceURL')) {
            source += getResourceURL.toString() + '; \n\n';
        }
        if (grants.includes('GM_getResourceUrl')) {
            source += 'GM_getResourceUrl =' + getResourceURL.toString() + '; \n\n';
        }

        if (grants.includes('GM.getResourceURL') || grants.includes('GM.getResourceUrl')) {
            source += 'GM.getResourceURL = ' + getResourceURL_p.toString() + '; \n\n';
            source += 'GM.getResourceUrl = ' + getResourceURL_p.toString() + '; \n\n';
        }

        if (grants.includes('GM.getResourceText')) {
            source += 'GM.getResourceText = ' + getResourceText_p.toString() + '; \n\n';
        }

        if (grants.includes('GM_getResourceText')) {
            source += getResourceText.toString() + '; \n\n';
        }

        if (grants.includes('GM_xmlhttpRequest')) {
            source += xmlhttpRequest.toString() + ';\n\n';
        }

        if (grants.includes('GM.xmlHttpRequest')) {
            source += 'GM.xmlHttpRequest = ' + xmlhttpRequest.toString() + ';\n\n';
        }

        //add GM_log by default
        source += log.toString() + ';\n\n';

        // source += injectJavaScript.toString() + ';\n\ninjectJavaScript();\n';

        source += _fillStroge.toString() + ';\n\n';

        source += _fillAllResourceTextStroge.toString() + ';\n\n';

        source += _fillAllResourceUrlStroge.toString() + ';\n\n';
        native.nslog("native-source" + source);

        source += 'GM_info={version: _version, scriptHandler: "Stay"};\n\n';
        source += 'GM_info.script={version: "' + userscript.version + '",description:"' + userscript.description + '",namespace:"' + userscript.namespace + '"};\n\n';
        source += 'GM_info.script.resources= ' + JSON.stringify(userscript.resourceUrls ? userscript.resourceUrls : []) + ';\n';
        source += 'GM_info.script.includes= ' + JSON.stringify(userscript.includes ? userscript.includes : []) + ';\n';
        source += 'GM_info.script.excludes= ' + JSON.stringify(userscript.excludes ? userscript.excludes : []) + ';\n';
        source += 'GM_info.script.matches= ' + JSON.stringify(userscript.matches ? userscript.matches : []) + ';\n';
        source += 'GM.info = GM_info;\n\n';
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

    function deleteValue(key) {
        __stroge[key] = null;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid: _uuid });
    }

    function setValue(key, value) {
        __stroge[key] = value;
        browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid: _uuid });
    }

    function getValue(key, defaultValue) {
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

    function log(message) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_log", message: message, uuid: _uuid }, (response) => {
                resolve(response.body);
            });
        });
    }

    function registerMenuCommand(caption, commandFunc, accessKey) {
        let userInfo = {};
        userInfo["caption"] = caption;
        userInfo["commandFunc"] = commandFunc;
        userInfo["accessKey"] = accessKey;
        userInfo["id"] = __RMC_CONTEXT.length;
        __RMC_CONTEXT.push(userInfo);
    }

    function addStyle(css) {
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

    function getResourceText(name) {
        let resourceText = typeof __resourceTextStroge !== undefined ? __resourceTextStroge[name] : "";
        // let resourceText;
        if (!resourceText || typeof resourceText === undefined) {
            // 通过name获取resource
            // resourceText = await GM_getResourceText_p(name);

            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, url: __resourceUrlStroge[name], uuid: _uuid }, (response) => {
                // console.log("GM_getResourceText send to background-----", response);
                __resourceTextStroge[name] = response.body;
                resourceText = response.body;
            });
        }
        return resourceText;
    }


    function getResourceText_p(name) {
        return new Promise((resolve, reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getResourceText", key: name, uuid: _uuid }, (response) => {
                // console.log("GM_getResourceText_p-----", response);
                resolve(response.body);
            });
        });
    }

    function getResourceURL(name) {
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

    function xmlhttpRequest(params) {
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
        // console.log("start GM_openInTab-----", url, options);
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
            // console.log("GM_openInTab response---", response)
            tabId = response.tabId;
        };
        if (url && url.search(/^\/\//) == 0) {
            url = location.protocol + url;
        }
        browser.runtime.sendMessage({ from: "gm-apis", operate: "openInTab", url: url, id: _uuid, uuid: _uuid, options: options }, resp);
        return { close: close };
    }

    function injectJavaScript(userscript, uuid, version) {
        const gmFunVals = [];
        let grants = userscript.grants;
        let api = `const _uuid = "${uuid}";\n`;
        api += 'const _version = "' + version + '";\n';
        api += 'GM_info =' + GM_info(userscript, version) + ';\n';

        gmFunVals.push("info: GM_info");

        grants.forEach(grant => {
            if (grant === "GM.listValues" || grant === "GM_listValues") {
                api += `${GM_listValues}\n`;
                gmVals.push("listValues: GM_listValues");
            } 
            else if (grant === "GM.deleteValue" || grant === "GM_deleteValue") {
                api += `${GM_deleteValue}\n`;
                gmVals.push("deleteValue: GM_deleteValue");
            }
            else if (grant === "GM_log"){

            }
        })


        const GM = `const GM = {${gmFunVals.join(",")}};`;
        let code = `(function() {\n${api}\n${GM}\n}\n})();`;
        const tag = document.createElement("script");
        tag.textContent = code;
        document.head.appendChild(tag);
    }

    function GM_listValues() {
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

    function GM_deleteValue(key) {
        const pid = Math.random().toString(36).substring(1, 9);
        return new Promise(resolve => {
            const callback = e => {
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                if (e.data.pid !== pid || e.data.id !== uid || e.data.name !== "RESP_DELETE_VALUE") return;
                resolve(e.data.response.body);
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
            window.postMessage({ id: _uuid, pid: pid, name: "API_DELETE_VALUE", key: key });
        });
    }

    function getSourceOfWindowListener(e) {
        if (e.data.id !== _uuid || !e.data.name) return;
        const id = e.data.id;
        const name = e.data.name;
        const pid = e.data.pid;
        let message;
        if (name === "API_LIST_VALUES") {
            message = { from: "gm-apis", operate: "GM_listValues", uuid: _uuid };
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid: _uuid }, (response) => {
                window.postMessage({ id: id, pid: pid, name: "RESP_LIST_VALUES", response: response });
            });

        }
        else if (name === "API_DELETE_VALUE"){
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: e.data.key, uuid: _uuid }, (response)=>{
                window.postMessage({ id: id, pid: pid, name: "RESP_DELETE_VALUE", response: response });
            });
        }
    }

    

    window.createGMApisWithUserScript = createGMApisWithUserScript;
})();
