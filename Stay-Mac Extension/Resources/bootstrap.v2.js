let __storage;
let __storageChangeListeners = new Map();
let __extension = window.browser;
let __resourceUrls;
let __resourceTexts;
//Supported GM APIS
//https://violentmonkey.github.io/api/gm/
//https://wiki.greasespot.net/Greasemonkey_Manual:API
//https://www.tampermonkey.net/documentation.php
const GM_apis = {
    setValue: function(key, value){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.setValue invalid key %s",`${this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        if (value == null) {
            console.error("%s GM.setValue invalid value %s",`${this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const realKey = `_${this.uuid}_${key}`;
            __storage[realKey] = value;
            const item = {};
            item[realKey] = value;
            if (__extension){
                __extension.storage.local.set(item, () => resolve());
            }
            else{
                const pid = Math.random().toString(36).substring(1, 9);
                const callback = e => {
                    if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "setValue" || e.data.type !== "resp") return;
                    window.removeEventListener("message", callback);
                    resolve();
                };
                window.addEventListener("message", callback);
                window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "setValue", key: realKey, value: value, group: "gm_apis", type: "req"});
            }
            
        });
    },
    _setValue: function(key, value){
        if (typeof key !== "string" || !key.length) {
            return console.error("%s GM_setValue invalid key %s",`${this.name}`,key);
        }
        if (value == null) {
            return console.error("%s GM_setValue invalid value %s",`${this.name}`,key);
        }
        
        const realKey = `_${this.uuid}_${key}`;
        __storage[realKey] = value;
        const item = {};
        item[realKey] = value;
        if (__extension){
            //TODO: This sync will cause the valueChangeListener received the message before added.
            __extension.storage.local.set(item);
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "setValue" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "setValue", key: realKey, value: value, group: "gm_apis", type: "req"});
        }
    },
    getValue: function(key, defaultValue){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.getValue invalid key %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const realKey = `_${this.uuid}_${key}`;
            const value = __storage[realKey];
            if (value === undefined){
                if (defaultValue != null) {
                    resolve(defaultValue);
                } else {
                    resolve(undefined);
                }
            }
            else {
                resolve(value);
            }
        });
    },
    _getValue: function(key, defaultValue){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM_getValue invalid key %s",`{this.name}`,key);
            return;
        }
        const realKey = `_${this.uuid}_${key}`;
        const value = __storage[realKey];
        return value || defaultValue;
    },
    listValues: function(){
        return new Promise(resolve => {
            const prefix = `_${this.uuid}_`;
            const keys = [];
            const allKeys = Object.keys(__storage);
            for (let i = 0; i < allKeys.length; i++){
                const key = allKeys[i];
                if (key.startsWith(prefix)) {
                    const k = key.replace(prefix, "");
                    keys.push(k);
                }
            }
            resolve(keys);
        });
    },
    _listValues: function(){
        const prefix = `_${this.uuid}_`;
        const keys = [];
        const allKeys = Object.keys(__storage);
        for (let i = 0; i < allKeys.length; i++){
            const key = allKeys[i];
            if (key.startsWith(prefix)) {
                const k = key.replace(prefix, "");
                keys.push(k);
            }
        }
        return keys;
    },
    deleteValue: function(key){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.deleteValue invalid key %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const realKey = `_${this.uuid}_${key}`;
            delete __storage[realKey];
            if (__extension){
                __extension.storage.local.remove(realKey, () => {
                    resolve();
                });
            }
            else{
                const pid = Math.random().toString(36).substring(1, 9);
                const callback = e => {
                    if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "deleteValue" || e.data.type !== "resp") return;
                    window.removeEventListener("message", callback);
                    resolve();
                };
                window.addEventListener("message", callback);
                window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "deleteValue", key: realKey, group: "gm_apis", type: "req"});
            }
        });
    },
    _deleteValue: function(key){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.deleteValue invalid key %s",`{this.name}`,key);
            return;
        }
        
        const realKey = `_${this.uuid}_${key}`;
        delete __storage[realKey];
        
        if (__extension){
            __extension.storage.local.remove(realKey);
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "deleteValue" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "deleteValue", key: realKey, group: "gm_apis", type: "req"});
        }
    },
    addValueChangeListener: function(name, valueChangeCallback){
        const realKey = `_${this.uuid}_${name}`;
        __storageChangeListeners[realKey] = valueChangeCallback;
        return new Promise(resolve => {
            if (__extension){
                resolve(realKey);
            }
            else{
                const pid = Math.random().toString(36).substring(1, 9);
                const callback = e => {
                    if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "addValueChangeListener" || e.data.type !== "resp") return;
                    window.removeEventListener("message", callback);
                    resolve(realKey);
                };
                window.addEventListener("message", callback);
                window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "addValueChangeListener", key: realKey, group: "gm_apis", type: "req"});
            }
        });
    },
    _addValueChangeListener: function(name, valueChangeCallback){
        const realKey = `_${this.uuid}_${name}`;
        __storageChangeListeners[realKey] = valueChangeCallback;
        if (__extension){
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "addValueChangeListener" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "addValueChangeListener", key: realKey, group: "gm_apis", type: "req"});
        }
        return realKey;
    },
    removeValueChangeListener: function(listenerId){
        return new Promise(resolve => {
            if (__extension){
                delete __storageChangeListeners[listenerId];
                resolve();
            }
            else{
                const pid = Math.random().toString(36).substring(1, 9);
                const callback = e => {
                    if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "removeValueChangeListener" || e.data.type !== "resp") return;
                    window.removeEventListener("message", callback);
                    resolve();
                };
                window.addEventListener("message", callback);
                window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "removeValueChangeListener", key: listenerId, group: "gm_apis", type: "req"});
            }
        });
    },
    _removeValueChangeListener: function(listenerId){
        if (__extension){
            delete __storageChangeListeners[listenerId];
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.uuid !== `${this.uuid}` || e.data.operate !== "removeValueChangeListener" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "removeValueChangeListener", key: listenerId, group: "gm_apis", type: "req"});
        }
    },
    _getResourceText: function(name){
        return __resourceTexts[name];
    },
    _getResourceURL: function(name){
        return __resourceUrls[name];
    },
    getResourceUrl: function(name){
        let url = __resourceUrls[name];
        return new Promise(resolve => {
            resolve(url);
        });
    }
}

function staySays(msg){
    return `Stay says: ${msg}`;
}


const fetchStorage = function fetchStorage(){
    if (__extension){
        return __extension.storage.local.get(null);
    }
    else{
        return new Promise(resolve => {
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.operate !== "storage.local.getAll" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
                const items = JSON.parse(e.data.items);
                resolve(items);
            };
            window.addEventListener("message", callback);
            window.postMessage({ pid: pid, operate: "storage.local.getAll", group: "page", type: "req"});
        });
    }
}

const label = Math.random().toString(36).substring(2, 9);

let storage;
async function executeScript(userscript){
    const sourceTag = window.self === window.top ? "[main]" : `[${label}](window.location)`;
    let injectInto = userscript.metadata["inject-into"];
    if ((injectInto === "auto") && (userscript.fallback || cspEnter)){
        console.warn(staySays(`${userscript.metadata.name}.js will fallback injecting to content.`));
        injectInto = "content";
    }
    
    if (injectInto === "content"){
        try {
            console.info(staySays(`Inject %c${userscript.metadata.name}(js) %cto content.`),"color: #B620E0","color: #000000");
            if (storage == undefined){
                console.time();
                storage = await fetchStorage();
                console.timeEnd();
            }
            
            const code = `
                (function(){
                    __storage = storage;
                    const __resourceUrls = JSON.parse(${userscript.resourceUrls});
                    const __resourceTexts = JSON.parse(${userscript.resourceTexts});
                    ${userscript.genCode}
                    function main(){
                        const GM_apis = undefined;
                        const browser = undefined;
                        ${userscript.code}
                    }
                    main();
                    //# sourceURL=${userscript.metadata.name}.replace(/\s/g, "-") + ${sourceTag}
                })();
            `;
            return Function(code)();
        } catch (error) {
            console.error(`${userscript.metadata.name} error`, error);
        }
    }
    else{
        console.info(staySays(`Inject %c${userscript.metadata.name}(js) %cto page.`),"color: #B620E0","color: #000000");
        
        const code = `
            (async function(){
                //env
                const __storageChangeListeners = {};
                window.addEventListener("message", ${valueChangeDispatchInPage}, false);
                const __extension = undefined;
                ${fetchStorage}
                const __storage = await fetchStorage();
                const GM_apis = ${userscript.apisInPage};
//                const __resourceUrls = JSON.parse(${userscript.resourceUrls});
//                const __resourceTexts = JSON.parse(${userscript.resourceTexts});
                ${userscript.genCode}
                function main(){
                    const GM_apis = undefined;
                    const browser = undefined;
                    ${userscript.code}
//                    window.postMessage({uuid: ${userscript.uuid}, operate: "remove_tag", group: "stay"});
                }
                main();
                //# sourceURL=${userscript.metadata.name}.replace(/\s/g, "-") + ${sourceTag}
            })();
        `;
        const tag = document.createElement("script");
        tag.type = 'text/javascript';
        tag.id = `${userscript.uuid}`;
        tag.textContent = code;
        document.head.appendChild(tag);
    }
}

function run(userscript){
    const runAt = "document_"+userscript.metadata["run-at"];
    if (runAt === "document_start") {
        executeScript(userscript);
    } else if (runAt === "document_end" || runAt === "document_body") {
        if (document.readyState !== "loading") {
            executeScript(userscript);
        } else {
            document.addEventListener("DOMContentLoaded", function() {
                executeScript(userscript);
            });
        }
    } else if (runAt === "document_idle") {
        if (document.readyState === "complete") {
            executeScript(userscript);
        } else {
            document.addEventListener("readystatechange", function(e) {
                if (document.readyState === "complete") {
                    executeScript(userscript);
                }
            });
        }
    }
}

let cspEnter = false;
function cspCallback(e){
    if (e.effectiveDirective === "script-src"
        || e.effectiveDirective === "script-src-elem") {
        if (!userscripts || cspEnter) return;
        
        cspEnter = true;
        
        for (let i = 0; i < userscripts.length; i++){
            const userscript = userscripts[i];
            if (userscript.metadata.injectInto !== "auto") continue;
            userscript.fallback = true;
            run(userscript);
        }
    }
}

function receiveMessage(e){
    const message = e.data;
//    console.log("receiveMessage: ",message);
    if (message.group === "page"){
        const uuid = message.uuid;
        const operate = message.operate;
        
        if (operate === "remove_tag"){
            document.getElementById(uuid).remove();
        }
        else if (operate === "storage.local.getAll"){
            browser.storage.local.get(null, (items) => {
                window.postMessage({pid: message.pid, operate: message.operate, items: JSON.stringify(items), type: "resp"});
            });
        }
    }
    else if (message.group == "gm_apis"){
        const uuid = message.uuid;
        const operate = message.operate;
        if (operate === "setValue"){
            const item = {};
            item[message.key] = message.value;
            browser.storage.local.set(item);
            window.postMessage({ uuid: message.uuid, pid: message.pid, operate: message.operate, type: "resp"});
        }
        else if (operate == "deleteValue"){
            browser.storage.local.remove(message.key, () => {
                window.postMessage({ uuid: message.uuid, pid: message.pid, operate: message.operate, type: "resp"});
            });
        }
        else if (operate === "addValueChangeListener"){
            __storageChangeListeners[message.key] = message.key;
            window.postMessage({ uuid: message.uuid, pid: message.pid, operate: message.operate, type: "resp"});
        }
        else if (operate == "removeValueChangeListener"){
            delete __storageChangeListeners[message.key];
            window.postMessage({ uuid: message.uuid, pid: message.pid, operate: message.operate, type: "resp"});
        }
    }
}

function valueChangeDispatchInPage(e){
    const message = e.data;
    if (message.group === "content"){
        if (message.operate === "storage.local.onChanged"){
            const callback = __storageChangeListeners[message.key];
            if (callback){
                callback(message.name,message.oldValue,message.newValue,false);
            }
        }
    }
}

function storageLocalOnChanged(changes){
    const changedItems = Object.keys(changes);
    for (const item of changedItems) {
        const callback = __storageChangeListeners[item];
        if (typeof callback === 'function'){
            callback(item.substring(34),changes[item].oldValue,changes[item].newValue,false);
        }
        else{
            window.postMessage({key: callback, name: item.substring(34), oldValue: changes[item].oldValue, newValue: changes[item].newValue, operate: "storage.local.onChanged" , group: "content"})
        }
    }
}

function addListeners(){
    document.addEventListener("securitypolicyviolation", cspCallback);
    window.addEventListener("message", receiveMessage, false);
    browser.storage.local.onChanged.addListener(storageLocalOnChanged);
}

/**
 Struct of Response Script
 - uuid:
 - metadata:
 - requiredScripts:
 - code:
 - scriptMetaStr:
 - type: js
 - resourceUrls:
 - resourceTexts;
 */

let userscripts;
function injection(){
    browser.runtime.sendMessage({ origin: "bootstrap", operate: "script.v2.getInjectFiles" }, (response) => {
        const injectFiles = response.body;
        let scripts = injectFiles.jsFiles;
        userscripts = [];
        for (let i = 0; i < scripts.length; i++){
            const script = scripts[i];
            let userscript = {
                genCode:"",
                code:"",
                fallback: false,
                apisInPage:""
                resourceUrls: JSON.stringify(script.resourceUrls),
                resourceTexts: JSON.stringify(script.resourceTexts)
            };
            const gmApis = [];
            const grants = script.metadata.grants;
            const context = `{"uuid": "${script.uuid}"}`;
            
            //https://wiki.greasespot.net/GM.info
            const GM_info = {
                script: script.metadata,
                scriptMetaStr: script.scriptMetaStr,
                scriptHandler: injectFiles.scriptHandler,
                version : injectFiles.scriptHandlerVersion
            };
            
            const injectInto = script.metadata["inject-into"];

            if (grants.includes("none")) grants.length = 0;
            
            const unsafeWindow = grants.includes("unsafeWindow");

            if (unsafeWindow && injectInto === "auto"){
                console.warn(staySays(`${script.metadata.name}(js) @inject-into value set to 'page' due to @grant unsafeWindow.`));
                script.metadata["inject-into"] = "page";
            }
            else if (grants.length && injectInto === "auto"){
                console.warn(staySays(`${script.metadata.name}(js) @inject-into value set to 'content' due to has @grant values: ${grants}`));
                script.metadata["inject-into"] = "content";
            }
            
            let apisInPage = "{\n";
            for (let j = 0; j < grants.length; j++){
                const grant = grants[j];
                const apiGroup = (grant.split('.').length > 1 ? grant.split('.')[0] : undefined) || grant.split('_')[0];
                const apiName = (grant.split('.').length > 1 ? grant.split('.')[1] : undefined) || "_" + grant.split('_')[1];
                if (!Object.keys(GM_apis).includes(apiName)){
                    continue;
                }
                
                const sync = apiName.startsWith('_');
                
                if (apiGroup == "GM"){
                    let apiStr = `${apiName}: GM_apis.${apiName}`;
                    let func = GM_apis[apiName];
                    apisInPage += `${apiName}: ${func},\n`;
                    if (sync){
                        userscript.genCode += `const GM${apiName} = GM_apis.${apiName}.bind(${context});`;
                    }
                    else{
                        gmApis.push(apiStr + `.bind(${context})`);
                    }
                }
            }
            
            apisInPage += "\n};\n";
            
            gmApis.push("info: GM_info");
            
            userscript.genCode += `const GM_info = ${JSON.stringify(GM_info)};`
            userscript.genCode += `const GM = {${gmApis.join(",")}};`
            userscript.metadata = script.metadata;
            userscript.code = script.code;
            userscript.apisInPage = apisInPage;
            userscripts.push(userscript);
            run(userscript);
        }
    });
}

async function initialize(){
    const stay =`
     __
    (__ _|_  _  \\ /
    ___) |_ (_|  /
    `;
    console.log(`%c${stay}`,"color: #B620E0");
    console.log("Developed by DJ APPS");
    console.time();
    let switches = await browser.storage.local.get('_userscript_switch');
    console.timeEnd();
    if (switches._userscript_switch === false) return console.info('Stay userscript is off');
    addListeners();
    injection();
}

initialize();
