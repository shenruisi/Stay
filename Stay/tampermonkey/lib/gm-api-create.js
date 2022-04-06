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
        api += `${GM_listValues}\n`;
        api += `${GM_getAllResourceText}\n`;
        api += 'let __listValuesStroge = await GM_listValues();\n';
        api += 'let __resourceUrlStroge = ' + JSON.stringify(userscript[resourceUrls])+';\n';
        api += 'let __resourceTextStroge = await GM_getAllResourceText();\n';
        api += 'let __RMC_CONTEXT = [];\n';
        api += 'GM_info =' + GM_info(userscript, version) + ';\n';
        api += `${GM_log}\n`;
        api += `${clear_GM_log}\n`;
        api += `${browserAddListener}\n`;
        
        gmFunVals.push("info: GM_info");

        grants.forEach(grant => {
            if (grant === "GM.listValues") {
                // api += `${GM_listValues}\n`;
                gmFunVals.push("listValues: GM_listValues");
            } 
            else if (grant === "GM_listValues"){
                // api += `${GM_listValues}\n`;
                api += `const GM_listValues = __listValuesStroge;\n`;
            }
            else if (grant === "GM.deleteValue") {
                api += `${GM_deleteValue}\n`;
                gmFunVals.push("deleteValue: GM_deleteValue");
            }
            else if (grant === "GM_deleteValue"){
                api += `${GM_deleteValue}\nconst GM_deleteValue = await GM_deleteValue;\n`;
            }
            else if (grant === "GM_addStyle") { //同步
                api += `${GM_addStyleSync}\nconst GM_addStyle = GM_addStyleSync;\n`;
            } 
            else if (grant === "GM.addStyle") {
                api += `${GM_addStyle}\n`;
                gmFunVals.push("addStyle: GM_addStyle");
            } 
            else if ("GM.setValue" === grant){
                api += `${GM_setValue}\n`;
                gmFunVals.push("setValue: GM_setValue");
            }
            else if ("GM_setValue" === grant) {
                api += `${GM_setValueSync}\nconst GM_setValue = GM_setValueSync;\n`;
            }
            else if ("GM.getValue" === grant) {
                api += `${GM_getValue}\n`;
                gmFunVals.push("getValue: GM_getValue");
            }
            else if ("GM_getValue" === grant) {
                api += `${GM_getValueSync}\nconst GM_getValue = GM_getValueSync;\n`;
            }
            else if ("GM_registerMenuCommand" === grant || "GM.registerMenuCommand" === grant){
                api += `${registerMenuCommand}\nconst GM_registerMenuCommand = registerMenuCommand;\n`;
                gmFunVals.push("registerMenuCommand: registerMenuCommand");
            }
            else if ("GM_getResourceURL" === grant){
                api += `${GM_getResourceURLSync}\nconst GM_getResourceURL=GM_getResourceURLSync;\n`;
                
            }
            else if ("GM_getResourceUrl" === grant) {
                api += `${GM_getResourceURLSync}\nconst GM_getResourceUrl=GM_getResourceURLSync;\n`;
                gmFunVals.push("getResourceUrl: GM_getResourceUrl");
            }
            else if ("GM.getResourceURL" === grant){
                api += `${GM_getResourceURL}\n`;
                gmFunVals.push("getResourceURL: GM_getResourceURL");
            }
            else if ("GM.getResourceUrl" === grant) {
                api += `${GM_getResourceURL}\n`;
                gmFunVals.push("getResourceUrl: GM_getResourceURL");
            }
            else if ("GM.getResourceText" === grant) {
                api += `${GM_getResourceText}\n`;
                gmFunVals.push("getResourceText: GM_getResourceText");
            }
            else if ("GM_getResourceText" === grant) {
                api += `${GM_getResourceTextSync}\nconst GM_getResourceText = GM_getResourceTextSync`;
            }
        })

        const GM = `const GM = {${gmFunVals.join(",")}};`;
        let code = `(function() {\n${api}\n${GM}\n}\n})();`;
        const tag = document.createElement("script");
        tag.textContent = code;
        document.head.appendChild(tag);
    }
    function GM_setValueSync(key, value) {
        __listValuesStroge[key] = value;
        window.postMessage({ id: _uuid, name: "API_SET_VALUE_SYNC", key: key, value: value });
    }

    function GM_setValue(key, value) {
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
        window.postMessage({ id: _uuid, pid: pid, name: "API_GET_VALUE_SYNC", key: key, defaultValue: defaultValue });
        return __listValuesStroge[key] == null ? defaultValue : __listValuesStroge[key];
    }

    function GM_getResourceURLSync(name) {
        let resourceUrl = typeof __resourceUrlStroge !== undefined ? __resourceUrlStroge[name] : "";
        if (!resourceText || resourceText === "" || resourceText === undefined) {
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL_SYNC", key: name});
        }
        return resourceUrl;
    }

    function GM_getResourceURL(name) {
        const pid = Math.random().toString(36).substring(1, 9);
        return new Promise(resolve => {
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== _uuid || e.data.name !== "RESP_GET_REXOURCE_URL") return;
                resolve(e.data.response);
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_REXOURCE_URL", key: name});
        });
    }

    function GM_getResourceText(name) {
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
                resolve(e.data.response);
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ id: _uuid, pid: pid, name: "API_GET_ALL_REXOURCE_TEXT"});
        });
    }

    function GM_getValue(key, defaultValue) {
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

    function GM_addStyleSync(css) {
        window.postMessage({ id: _uuid, name: "API_ADD_STYLE_SYNC", css: css });
        return css;
    }

    function GM_addStyle(css) {
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
        window.postMessage({ id: _uuid, name: "API_CLEAR_LOG"});
    }

    function browserAddListener() {
        window.postMessage({ id: _uuid, name: "BROWSER_ADD_LISTENER"});
    }

    function GM_log(message) {
        const pid = Math.random().toString(36).substring(1, 9);
        return new Promise(resolve => {
            const callback = e => {
                // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
                if (e.data.pid !== pid || e.data.id !== uid || e.data.name !== "RESP_LOG") return;
                resolve(e.data.response.body);
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            // eslint-disable-next-line no-undef -- filename var accessible to the function at runtime
            window.postMessage({ id: _uuid, pid: pid, name: "API_LOG", message: message });
        });
    }

    function getSourceOfWindowListener(e) {
        if (e.data.id !== _uuid || !e.data.name) return;
        const id = e.data.id;
        const name = e.data.name;
        const pid = e.data.pid;
        let message = { from: "gm-apis", uuid: id };
        if (name === "API_LIST_VALUES") {
            message.operate =  "GM_listValues";
            browser.runtime.sendMessage(message, (response) => {
                window.postMessage({ id: id, pid: pid, name: "RESP_LIST_VALUES", response: response });
            });

        }
        else if (name === "API_DELETE_VALUE"){
            message.operate = "GM_deleteValue";
            message.key = e.data.key;
            browser.runtime.sendMessage(message, (response)=>{
                window.postMessage({ id: id, pid: pid, name: "RESP_DELETE_VALUE", response: response });
            });
        }
        else if ("API_LOG" === name) {
            message.message = e.data.message;
            message.operate = "GM_log";
            browser.runtime.sendMessage(message, (response) => {
                resolve(response.body);
            });
        }
        else if ("API_CLEAR_LOG" === name){
            message.operate = "clear_GM_log";
            browser.runtime.sendMessage(message);
        }
        else if ("BROWSER_ADD_LISTENER" === name){
            browser.runtime.onMessage.addListener((request, sender, sendResponse)=>{
                if (request.from == "background" && request.operate == "fetchRegisterMenuCommand"){
                    browser.runtime.sendMessage({ from: "content", data: __RMC_CONTEXT, uuid: _uuid, operate: "giveRegisterMenuCommand" });
                }
                else if (request.from == "background" && request.operate == "execRegisterMenuCommand" && request.uuid == _uuid){
                    console.log(__RMC_CONTEXT[request.id]);
                    __RMC_CONTEXT[request.id]["commandFunc"]();
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
                if (name === "API_SET_VALUE"){
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
        else if ("API_GET_ALL_REXOURCE_TEXT" === name){
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
                if ("API_GET_REXOURCE_TEXT" === name){
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
    }

    

    window.createGMApisWithUserScript = createGMApisWithUserScript;
})();
