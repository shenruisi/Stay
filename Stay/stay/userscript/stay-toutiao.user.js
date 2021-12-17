// ==UserScript==
// @name         今日头条@AutoExpend
// @namespace    http://stay.app/
// @version      0.0.1
// @description  自动展开今日头条文章
// @author       Stay²
// @match        *://m.toutiao.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeTopBanner(){
    let banner = document.querySelector('.top-banner-container');
    if (banner){
        banner.remove();
        return DATA();
    }
    
    return CONTINUE;
}

function unfold(){
    let button = document.querySelector('div.fold-btn-btn');
    if (button){
        button.remove();
        let content = document.querySelector('div.fold-btn-content')
        if (content){
            content.className = null;
            content.className = "fold-btn-content";
        }
        return COMPLETE;
    }
    
    return CONTINUE;
}

if (document.readyState !== "loading"){
    let tasks = [removeTopBanner,unfold];
    Stay_Inject.run(tasks,100,30,false).then((data) => {});
}
else{
    document.addEventListener("DOMContentLoaded", function(event) {
        let tasks = [removeTopBanner,unfold];
        Stay_Inject.run(tasks,100,30,false).then((data) => {});
    });
}
