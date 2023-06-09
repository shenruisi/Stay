(function(){
    let addonsCallbackMap = {};
    addons:{
        utils: {
            
        },
        runtime: {
            sendMessage: function(message, callback){
//                __outer_callbackMap[__outer_callbackId++] = callback;
//                message.addonsCallbackId = __outer_callbackId;
//                message.group = "addons";
//                window.postMessage(message);
            }
        },
        
        storage: {
            local: {
                get: function(key,defaultValue){
                    window.postMessage({operate: "storage.local.get", key: key, defaultValue: defaultValue, group: "addons"})
                    return new Pormise
                },
                set: function(){
                    
                }
            }
        }
    }
    
    function receiveMessage(e){
        const message = e.data;
        if (message.group === "addons"){
//            browser.sendMessage(e.data, response => {
//                 response.addonsCallbackId
//            });
            if (message.operate === "storage.local.get"){
                browser.storage.local.get(message.key,message.defaultValue);
            }
        }
    }
    
    window.addEventListener("message", receiveMessage, false);

    window.__addons = addons;
})();

 
 


