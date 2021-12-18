console.log("bootstrap inject");
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

const $_matchesCheck = (userLibraryScript,url) => {
    let matched = false;
    userLibraryScript.matches.forEach((match)=>{ //check matches
        let matchPattern = new window.MatchPattern(match);
        if (matchPattern.doMatch(url)){
            matched = true;
        }
    });
    if (matched){
        if (userLibraryScript.includes.length > 0){
            matched = false;
            userLibraryScript.includes.forEach((include)=>{
                let matchPattern = new RegExp(include);
                if (matchPattern.test(url)){
                    matched = true;
                }
            });
        }
        
        
        userLibraryScript.excludes.forEach((exclude)=>{
            let matchPattern = new RegExp(exclude);
            if (matchPattern.test(url)){
                matched = false;
            }
        });
    }
    
    return matched;
}

async function start(){
    browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts" }, (response) => {
        let injectedVendor = new Set();
        let userLibraryScripts = JSON.parse(response.body);
        let injectScripts = [];
        userLibraryScripts.forEach((userLibraryScript)=>{
            console.log(userLibraryScript);
            
            if ($_matchesCheck(userLibraryScript,new URL(location.href))){
                injectScripts.push(userLibraryScript);
            }
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
            
            if (script.active){ //inject active script
                console.log("injectScript",script);
                browser.runtime.sendMessage({
                    from: "bootstrap",
                    operate: "injectScript",
                    code:script.content,
                    allFrames:!script.noFrames,
                    runAt:"document_"+script.runAt
                });
            }
        });
                
        browser.runtime.sendMessage({
            from: "bootstrap",
            operate: "setMatchedScripts",
            matchScripts: injectScripts
        });
    });
    
    
}

start();
