browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.origin === "bootstrap"){
        if (request.operate === "script.v2.getInjectFiles"){
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
    }
});
