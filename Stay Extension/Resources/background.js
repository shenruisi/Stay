let appJumpList;
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if ("popup" == request.from && "fetchAppList" == request.operate){
        sendResponse({ body: appJumpList });
    }
    else if ("content" == request.from && "saveAppList" == request.operate){
        appJumpList = request.data;
    }
});
