// ==UserScript==
// @name         搜狐@AutoExpand
// @namespace    http://stay.app/
// @version      0.0.2
// @description  自动展开搜狐文章
// @author       Stay²
// @match        *://*.sohu.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// @updateURL    https://raw.githubusercontent.com/shenruisi/Stay-Offical-Userscript/main/sohu/stay-sohu.update.js
// @downloadURL    https://raw.githubusercontent.com/shenruisi/Stay-Offical-Userscript/main/sohu/stay-sohu.user.js
// ==/UserScript==

function removeAds(){
    let ad = document.querySelector(".middle-insert-ad");
    if (ad){
        ad.style.display = "none";
        return COMPLETE;
    }
    
    return CONTINUE;
}

function unfold(){
    let lookallbox = document.querySelector(".article-main .lookall-box");
    console.log(lookallbox);
    if (lookallbox){
        lookallbox.style.display = "none";
        if (lookallbox){
            let otherContent = document.querySelector(".article-main .hidden-content");
            if (otherContent){
                otherContent.className = "hidden-content";
                return COMPLETE;
            }
        }
    }
    
    return CONTINUE;
}

if (document.readyState !== "loading"){
    let tasks = [removeAds,unfold];
    Stay_Inject.run(tasks,100,30,true).then((data) => {});
}
else{
    document.addEventListener("DOMContentLoaded", function(event) {
        let tasks = [removeAds,unfold];
        Stay_Inject.run(tasks,100,30,true).then((data) => {});
    });
}
