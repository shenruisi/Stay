/**
 This file guarantees call GM api in a sandbox.
 Reference: https://github.com/greasemonkey/greasemonkey/blob/master/src/bg/api-provider-source.js
 */

'use strict';

(function() {
    function createGMApisWithUserScript(userScript,uuid){
        if (userScript.grants.length == 0) return;
        
        let source = 'const _uuid = "' + uuid + '";\n\n';
        let grants = userScript.grants;
        if (grants.includes('GM_listValues')) {
            source += GM_listValues.toString() + ';\n\n';
        }
        
        if (grants.includes('GM_deleteValue')) {
            source += GM_deleteValue.toString() + ';\n\n';
        }
        
        if (grants.includes('GM_setValue')) {
            source += GM_setValue.toString() + ';\n\n';
        }
        
        if (grants.includes('GM_getValue')) {
            source += GM_getValue.toString() + ';\n\n';
        }
        
        if (grants.includes('GM_log')) {
            source +=  GM_log.toString() + ';\n\n';
        }
        
        return source;
    }
    
    function GM_listValues(){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_listValues", uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_deleteValue(key){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_deleteValue", key: key, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_setValue(key,value){
        return new Promise((resolve,reject) => {
            browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_setValue", key: key, value: value, uuid:_uuid }, (response) => {
                resolve(response.body);
            });
        });
    }
    
    function GM_getValue(key,defaultValue){
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
    
    window.createGMApisWithUserScript = createGMApisWithUserScript;
})();
