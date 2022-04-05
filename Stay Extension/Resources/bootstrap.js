/**
 Main entrance of Stay
 1. Fetch inject scripts from SafariWebExtensionHandler
 2. Use @match, @include, @exclude to match the correct script with the url.
 
 content.js passing message to background.js or popup.js using browser.runtime.sendMessage.
 popup.js passing message to background.js using browser.runtime.sendMessage.
 background.js passing message to content.js using browser.tabs.sendMessage.
 popup.js passing message to content.js should sendMessage to background.js first.
 */
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

//https://stackoverflow.com/questions/26246601/wildcard-string-comparison-in-javascript
//Short code
function matchRule(str, rule) {
  var escapeRegex = (str) => str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
  return new RegExp("^" + rule.split("*").map(escapeRegex).join(".*") + "$").test(str);
}


const $_matchesCheck = (userLibraryScript,url) => {
    let matched = false;
    let matchPatternInBlock;
    userLibraryScript.matches.forEach((match)=>{ //check matches
        let matchPattern = new window.MatchPattern(match);
        if (matchPattern.doMatch(url)){
            matched = true;
            matchPatternInBlock = matchPattern;
        }
    });
    if (matched){
        if (userLibraryScript.includes.length > 0){
            userLibraryScript.includes.forEach((include)=>{
                if (matchPatternInBlock.doMatch(include)) {
                    matched = matchRule(url.href, include);
                }
            });
        }
        
        userLibraryScript.excludes.forEach((exclude)=>{
            if (matchPatternInBlock.doMatch(exclude)) {
                matched = !matchRule(url.href, exclude);
            }
        });
    }
    
    return matched;
}
//let injectScripts = []
(function(){
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
            if (script.requireUrls.length > 0 && script.active){
                script.requireUrls.forEach((url)=>{
                    if (injectedVendor.has(url)) return;
                    injectedVendor.add(url);
                    if (url.startsWith('stay://')){
                        browser.runtime.sendMessage({
                            from: "bootstrap",
                            operate: "injectFile",
                            file:$_res($_uri(url).pathname.substring(1)),
                            allFrames:true,
                            runAt:"document_start"
                        });
                    }
                    else{
                        script.requireCodes.forEach((urlCodeDic)=>{
                            if (urlCodeDic.url == url){
                                browser.runtime.sendMessage({
                                    from: "bootstrap",
                                    operate: "injectScript",
                                    code:urlCodeDic.code,
                                    allFrames:true,
                                    runAt:"document_start"
                                });
                            }
                        });
                    }
                });
            }
            
            if (script.active){ //inject active script
                console.log("injectScript",script.content);
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
    
    
})();

//start();
