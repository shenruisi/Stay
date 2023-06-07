
const GM_apis = {
    setValue : function(key, value){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.setValue invalid key %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        if (value == null) {
            console.error("%s GM.setValue invalid value %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const item = {};
            item[`$_{this.uuid}_${key}`] = value;
            extension.storage.local.set(item, () => resolve());
        });
        
    },
    _setValue : function(key, value){
        if (typeof key !== "string" || !key.length) {
            return console.error("%s GM.setValue invalid key %s",`{this.name}`,key);
        }
        if (value == null) {
            return console.error("%s GM.setValue invalid value %s",`{this.name}`,key);
        }
        
        const item = {};
        item[`$_{this.uuid}_${key}`] = value;
        await extension.storage.local.set(item);
    },
    getValue : function(key, defaultValue){
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.getValue invalid key %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const realKey = `$_{this.uuid}_${key}`;
            extension.storage.local.get(realKey, items => {
                if (Object.keys(item).length === 0) {
                    if (defaultValue != null) {
                        resolve(defaultValue);
                    } else {
                        resolve(undefined);
                    }
                } else {
                    resolve(Object.values(item)[0]);
                }
            });
        });
    }
}

const label = Math.random().toString(36).substring(2, 9);

function executeScript(userscript){
    const tag = window.self === window.top ? "[main]" : `[${label}](window.location)`;
    let injectInto = userscript.head.injectInto;
    if ((injectInto === "auto" && (userscript.fallback || cspEnter))){
        console.warn(`${userscript.head.name}.js will fallback injecting to content.`);
        injectInto = "content";
    }
    
    if (injectInto === "content"){
        try {
            const code = `
                (function(){
                    const extension = window.browser;
                    ${userscript.genCode}
                    async function main(){
                        const GM_apis = undefined;
                        const browser = undefined;
                        ${userscrip.code}
                    }
                    main();
                    //# sourceURL=${userscript.head.name.replace(/\s/g, "-") + tag}
                })();
            `;
            return Function(code)();
        } catch (error) {
            console.error(`${userscript.head.name} error`, error);
        }
    }
    else{
        
    }
}

function run(userscript){
    if (userscript.head.runAt === "document_start") {
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
            if (userscript.head.injectInto !== "auto") continue;
            userscript.fallback = true;
            run(userscript);
        }
    }
}

function addListeners(){
    document.addEventListener("securitypolicyviolation", cspCallback);
}

/**
 Struct of Response Script
 - uuid:
 - head:
 - requiredScripts:
 - code:
 - scriptMetaStr:
 - type: js
 - fallback: false
 */

let userscripts;
function injection(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "inject-files"}, (response) => {
        injectFiles = response.body;
        let scripts = injectFiles.jsFiles;
        userscripts = [];
        for (let i = 0; i < scripts.length; i++){
            const script = scripts[i];
            const userscript = {};
            const gmApis = [];
            const grants = script.head.grants;
            const context = `{"uuid": "${script.uuid}"}`;
            
            //https://wiki.greasespot.net/GM.info
            const GM_info = {
                script: script.head,
                scriptMetaStr: script.scriptMetaStr.script,
                scriptHandler: injectFiles.scriptHandler,
                version : injectFiles.scriptHandlerVersion
            };
            
            if (grants.includes("none")) grants.length = 0;
            
            grants.forEach(grant => {
                const apiGroup = grant.split('.')[0] || grant.split('_')[0];
                const apiName = grant.split('.')[1] || "_" + grant.split('_')[1];
                if (apiGroup == "GM"){
                    if (!Object.keys(GM_apis).includes(apiName)) return;
                    
                    let apiStr = `${apiName}: GM_apis.${apiName}`;
                    switch(apiName){
                        case "setValue":
                            gmApis.push(apiStr + `.bind(${context})`);
                            break;
                        case "_setValue":
                            userscript.genCode += `const GM_${apiName} = GM_apis.${apiName}.bind(${context})`;
                    }
                }
            });
            
            userscript.genCode += `const GM = {${gmApis.join(",")}};`
            userscript.genCode += `const GM_info = ${JSONstringify(GM_info)};`
            userscript.head = script.head;
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
    let switches = await browser.storage.local.get('_userscript_switch');
    if (switches._userscript_switch === false) return console.info('Stay userscript is off');
    
    addListeners();
    injection();
}

initialize();
