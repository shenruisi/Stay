let __storage;
let __storageChangeListeners = [];
let __extension = window.browser;
//Supported GM APIS
//https://violentmonkey.github.io/api/gm/
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
                    if (e.data.pid !== pid || e.data.id !== `${this.uuid}` || e.data.operate !== "setValue" || e.data.type !== "resp") return;
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
            __extension.storage.local.set(item);
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== `${this.uuid}` || e.data.operate !== "setValue" || e.data.type !== "resp") return;
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
            if (Object.keys(item).length === 0) {
                if (defaultValue != null) {
                    resolve(defaultValue);
                } else {
                    resolve(undefined);
                }
            } else {
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
            const allKeys = __storage.keys();
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
        const allKeys = __storage.keys();
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
            __storage.delete(realKey);
            if (__extension){
                __extension.storage.local.remove(realKey, () => {
                    resolve();
                });
            }
            else{
                const pid = Math.random().toString(36).substring(1, 9);
                const callback = e => {
                    if (e.data.pid !== pid || e.data.id !== `${this.uuid}` || e.data.operate !== "deleteValue" || e.data.type !== "resp") return;
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
        __storage.delete(realKey);
        
        if (__extension){
            __extension.storage.local.remove(realKey);
        }
        else{
            const pid = Math.random().toString(36).substring(1, 9);
            const callback = e => {
                if (e.data.pid !== pid || e.data.id !== `${this.uuid}` || e.data.operate !== "deleteValue" || e.data.type !== "resp") return;
                window.removeEventListener("message", callback);
            };
            window.addEventListener("message", callback);
            window.postMessage({ uuid: `${this.uuid}`, pid: pid, operate: "deleteValue", key: realKey, group: "gm_apis", type: "req"});
        }
    },
    addValueChangeListener: function(name, callback){
        
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
            window.postMessage({ pid: pid, operate: "storage.local.getAll", group: "stay", type: "req"});
        });
    }
}

const label = Math.random().toString(36).substring(2, 9);

let storage;
let env;
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
        const GM_apis_code = `
        {
           setValue: ${GM_apis.setValue},
           _setValue: ${GM_apis._setValue},
           getValue: ${GM_apis.getValue},
           _getValue: ${GM_apis._getValue},
        };
        `;
        const code = `
            (async function(){
                //env
                __extension = undefined;
                ${fetchStorage}
                console.time();
                __storage = await fetchStorage();
                console.timeEnd();
                const GM_apis = ${GM_apis_code};
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
    if (message.group === "stay"){
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
    }
}

function storageLocalOnChanged(changes){
    const changedItems = Object.keys(changes);

      for (const item of changedItems) {
        console.log(`${item} has changed:`);
        console.log("Old value: ", changes[item].oldValue);
        console.log("New value: ", changes[item].newValue);
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
                fallback: false
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
            
            for (let j = 0; j < grants.length; j++){
                const grant = grants[j];
                const apiGroup = (grant.split('.').length > 1 ? grant.split('.')[0] : undefined) || grant.split('_')[0];
                const apiName = (grant.split('.').length > 1 ? grant.split('.')[1] : undefined) || "_" + grant.split('_')[1];
                if (apiGroup == "GM"){
                    let apiStr = `${apiName}: GM_apis.${apiName}`;
                    switch(apiName){
                        case "setValue":
                        case "getValue":
                            gmApis.push(apiStr + `.bind(${context})`);
                            break;
                        case "_setValue":
                        case "_getValue":
                            userscript.genCode += `const GM${apiName} = GM_apis.${apiName}.bind(${context});`;
                            break;
                    }
                }
            }
            
            gmApis.push("info: GM_info");
            
            userscript.genCode += `const GM_info = ${JSON.stringify(GM_info)};`
            userscript.genCode += `const GM = {${gmApis.join(",")}};`
            userscript.metadata = script.metadata;
            userscript.code = script.code;
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
