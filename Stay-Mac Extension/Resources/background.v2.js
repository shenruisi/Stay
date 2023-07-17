browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.origin === "bootstrap"){
        if (request.operate === "background/v2/getInjectFiles"){
            const isTop = sender.frameId === 0;
            browser.runtime.sendNativeMessage("application.id", { type: request.operate, url: sender.url, isTop: isTop },
                                              function (response) {
                if (response.body.jsFiles.length > 0 && response.body.showBadge){
                    browser.browserAction.setBadgeText({text: response.body.jsFiles.length.toString()});
                }
                else{
                    browser.browserAction.setBadgeText({text: ""});
                }
                sendResponse({body: response.body});
            });
            return true;
        }
        //https://github.com/quoid/userscripts/blob/main/xcode/Safari-Extension/Resources/background.js
        //#API_XHR
        else if (request.operate === "background/v2/xmlhttpRequest"){
            // parse details and set up for XMLHttpRequest
            const details = request.details;
            const method = details.method ? details.method : "GET";
            const user = details.user || null;
            const password = details.password || null;
            let body = details.data || null;
            if (body != null && details.binary != null) {
                const len = body.length;
                const arr = new Uint8Array(len);
                for (let i = 0; i < len; i++) {
                    arr[i] = body.charCodeAt(i);
                }
                body = new Blob([arr], {type: "text/plain"});
            }
            // establish a long-lived port connection to content script
            const port = browser.tabs.connect(sender.tab.id, {
                name: request.xhrPortName
            });
            // set up XMLHttpRequest
            const xhr = new XMLHttpRequest();
            xhr.withCredentials = (details.user && details.password);
            xhr.timeout = details.timeout || 0;
            if (details.overrideMimeType) {
                xhr.overrideMimeType(details.overrideMimeType);
            }
            // add required listeners and send result back to the content script
            for (const e of request.events) {
                if (!details[e]) continue;
                xhr[e] = async event => {
                    console.log("background/v2/xmlhttpRequest event",event);
                    // can not send xhr through postMessage
                    // construct new object to be sent as "response"
                    const x = {
                        readyState: xhr.readyState,
                        response: xhr.response,
                        responseHeaders: xhr.getAllResponseHeaders(),
                        responseType: xhr.responseType,
                        responseURL: xhr.responseURL,
                        status: xhr.status,
                        statusText: xhr.statusText,
                        timeout: xhr.timeout,
                        withCredentials: xhr.withCredentials
                    };
                    // only include responseText when needed
                    if (["", "text"].indexOf(xhr.responseType) !== -1) {
                        x.responseText = xhr.responseText;
                    }
                    // need to convert arraybuffer data to postMessage
                    if (xhr.responseType === "arraybuffer") {
                        const arr = Array.from(new Uint8Array(xhr.response));
                        x.response = arr;
                    }
                    // need to blob arraybuffer data to postMessage
                    if (xhr.responseType === "blob") {
                        const base64data = await readAsDataURL(xhr.response);
                        x.response = {
                            data: base64data,
                            type: xhr.responseType
                        };
                    }
                
                    port.postMessage({name: e, event, response: x});
                };
            }
            xhr.open(method, details.url, true, user, password);
            xhr.responseType = details.responseType || "";
            if (details.headers) {
                for (const key in details.headers) {
                    const val = details.headers[key];
                    xhr.setRequestHeader(key, val);
                }
            }
            // receive messages from content script and process them
            port.onMessage.addListener(msg => {
                if (msg.name === "ABORT") xhr.abort();
                if (msg.name === "DISCONNECT") port.disconnect();
            });
            // handle port disconnect and clean tasks
            port.onDisconnect.addListener(p => {
                if (p?.error) {
                    console.error(`port disconnected due to an error: ${p.error.message}`);
                }
            });
            xhr.send(body);
            // if onloadend not set in xhr details
            // onloadend event won't be passed to content script
            // if that happens port DISCONNECT message won't be posted
            // if details lacks onloadend attach listener
            if (!details.onloadend) {
                xhr.onloadend = event => {
                    port.postMessage({name: "onloadend", event});
                };
            }
        }
    }
});


