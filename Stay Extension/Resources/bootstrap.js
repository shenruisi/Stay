var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;

const $_res = (name) => {
    return browser.runtime.getURL(name);
}

const $_uri = (url) => {
    let a = document.createElement("a");
    a.href = url;
    return a;
}

async function start(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts" }, (response) => {
        let injectedVendor = new Set();
        let activeScripts = JSON.parse(response.body);
        let injectScripts = [];
        activeScripts.forEach((activeScript)=>{
            console.log(activeScript);
            activeScript.matches.forEach((match)=>{
                let matchPattern = new window.MatchPattern(match);
                if (matchPattern.doMatch(new URL(location.href))){
                    injectScripts.push(activeScript);
                }
            });
        });
        
        injectScripts.forEach((script) => {
            if (script.requireUrls.length > 0){
                script.requireUrls.forEach((url)=>{
                    if (injectedVendor.has(url)) return;
                    injectedVendor.add(url);
                    browser.runtime.sendMessage({
                        from: "bootstrap",
                        operate: "injectFile",
                        file:$_res($_uri(url).pathname.substring(1)),
                        allFrames:true,
                        runAt:"document_start"
                    });
                    
                });
            }
            browser.runtime.sendMessage({
                from: "bootstrap",
                operate: "injectScript",
                code:script.content,
                allFrames:!script.noFrames,
                runAt:"document_"+script.runAt
            });
            
        });
        
        console.log(injectScripts);
        browser.runtime.sendMessage({
            from: "bootstrap",
            operate: "setMatchedScripts",
            matchScripts: injectScripts
        });
    });
    
    
}

start();
