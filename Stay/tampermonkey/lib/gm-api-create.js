/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function() {
    function createGMApisWithUserScript(grants,uuid){

        
       
        let source = 'const _uuid = "' + uuid + '";\n\n';
        source += 'let GM = {};\n\n';
        source += 'let __stroge = await _fillStroge();\n\n';
        source += 'let __RMC_CONTEXT = [];\n\n';

        source += 'browser.runtime.sendMessage({ from: "gm-apis", uuid: _uuid, operate: "clear_GM_log" });\n\n';
        
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
            source += 'unsafeWindow = ' + unsafeWindow.toString() + ';\n\n';
        }

        //add GM_log by default
        source +=  GM_log.toString() + ';\n\n';
        
        source += _fillStroge.toString() + ';\n\n';
        return source;
    }
    
    function _fillStroge(){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid:_uuid }, (response) => {
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

    function unsafeWindow() {
        return window;
    }
    
//    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//        console.log("abc");
//    });

    window.createGMApisWithUserScript = createGMApisWithUserScript;

})();
