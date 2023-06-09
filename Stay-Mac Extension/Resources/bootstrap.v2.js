let extension;
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
        extension.storage.local.set(item);
    },
    getValue : function(key, defaultValue){
        console.log("getValue...");
        if (typeof key !== "string" || !key.length) {
            console.error("%s GM.getValue invalid key %s",`{this.name}`,key);
            return new Promise((resolve, reject) => {
               reject();
            });
        }
        
        return new Promise(resolve => {
            const realKey = `_${this.uuid}_${key}`;
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

function staySay(msg){
    return `Stay say: ${msg}`;
}

const label = Math.random().toString(36).substring(2, 9);

function executeScript(userscript){
    const sourceTag = window.self === window.top ? "[main]" : `[${label}](window.location)`;
    let injectInto = userscript.metadata["inject-into"];
    if ((injectInto === "auto") && (userscript.fallback || cspEnter)){
        console.warn(staySay(`${userscript.metadata.name}.js will fallback injecting to content.`));
        injectInto = "content";
    }
    
    if (injectInto === "content"){
        try {
            console.info(staySay(`Inject %c${userscript.metadata.name}(js) %cto content.`),"color: #B620E0","color: #000000");
            const code = `
                (function(){
                    extension = window.browser || window.chrome;
                    ${userscript.genCode}
                    async function main(){
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
        const code = `
            (function(){
                const extension = window.browser;
                ${userscript.genCode}
                async function main(){
                    const GM_apis = undefined;
                    const browser = undefined;
                    ${userscript.code}
                    window.postMessage({uuid: ${userscript.uuid}, operate: "remove_tag", group: "stay"});
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
    if (e.data?.group === "stay"){
        const uuid = e.data?.uuid;
        const operate = e.data?.operate;
        
        if (operate === "remove_tag"){
            document.getElementById(uuid).remove();
        }
    }
}

function addListeners(){
    document.addEventListener("securitypolicyviolation", cspCallback);
    window.addEventListener("message", receiveMessage, false);
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
                console.warn(staySay(`${script.metadata.name}(js) @inject-into value set to 'page' due to @grant unsafeWindow.`));
                script.metadata["inject-into"] = "page";
            }
            else if (grants.length && injectInto === "auto"){
                console.warn(staySay(`${script.metadata.name}(js) @inject-into value set to 'content' due to has @grant values: ${grants}`));
                script.metadata["inject-into"] = "content";
            }
            
            for (let j = 0; j < grants.length; j++){
                const grant = grants[j];
                const apiGroup = grant.split('.')[0] || grant.split('_')[0];
                const apiName = grant.split('.')[1] || "_" + grant.split('_')[1];
                if (apiGroup == "GM"){
                    if (!Object.keys(GM_apis).includes(apiName)) continue;
                    
                    let apiStr = `${apiName}: GM_apis.${apiName}`;
                    switch(apiName){
                        case "setValue":
                        case "getValue":
                            gmApis.push(apiStr + `.bind(${context})`);
                            break;
                        case "_setValue":
                            userscript.genCode += `const GM_${apiName} = GM_apis.${apiName}.bind(${context})`;
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
    let switches = await browser.storage.local.get('_userscript_switch');
    if (switches._userscript_switch === false) return console.info('Stay userscript is off');
    
    addListeners();
    injection();
}

initialize();
