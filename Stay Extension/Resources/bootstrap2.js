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

function addListeners(){
    
}

/**
 Struct of Response Script
 - head:
 - requiredScripts:
 - script:
 - scriptMetaStr:
 - type: js
 */

let injectFiles;
function injection(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "inject-files"}, (response) => {
        injectFiles = response.body;
        let scripts = injectFiles.jsFiles;
        
        
    });
}

async function initialize(){
    const stay =
    ```
     __
    (_ |_ _
    __)|_(_|\/
            /
    ```;
    console.info(stay,"color: #B620E0");
    let switches = await browser.storage.local.get('_userscript_switch');
    if (switches._userscript_switch === false) return console.info('Stay userscript is off');
    
    addListeners();
    injection();
}

initialize();
