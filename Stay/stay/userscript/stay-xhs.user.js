// ==UserScript==
// @name         小红书@AutoExpend
// @namespace    http://stay.app/
// @version      0.0.1
// @description  自动展开小红书笔记
// @author       Stay²
// @match        *://*.xiaohongshu.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeTopBanner(){
    let app = document.querySelector("#app");
    if (app){
        let navbar = app.querySelector(".normal-launch-app-container");
        if (navbar){
            navbar.style.display = "none";
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function removeAppJump(){
    let app = document.querySelector("#app");
    if (app){
        let bottombar = app.querySelector(".bottom-bar");
        if (bottombar){
            bottombar.remove();
            var url = window.location.href;
            return DATA();
        }
    }
    
    return CONTINUE;
}

function unfold(){
    let app = document.querySelector("#app");
    if (app){
        let checkmore = app.querySelector(".check-more");
        if (checkmore){
            checkmore.style.display = "none";
            let content = app.querySelector(".content");
            if (content){
                content.style.height = null;
                return COMPLETE;
            }
        }
    }
    
    return CONTINUE;
}


window.onload = function() {
    let tasks = [removeTopBanner,removeAppJump,unfold];
    Stay_Inject.run(tasks,100,30,true).then((data) => {});
}

