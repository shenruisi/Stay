// ==UserScript==
// @name         腾讯新闻@AutoExpend
// @namespace    http://stay.app/
// @version      0.0.1
// @description  自动展开腾讯新闻文章
// @author       Stay²
// @match        *://xw.qq.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeAds(){
    document.querySelector(".inner")?.remove();
    document.querySelector("#landad")?.remove();
    document.querySelector(".ssp.nospl")?.remove();
    document.querySelector("#__xw_next_view_root > .wrap")?.remove();

    return CONTINUE;
}

function removeAnnoyances(){
    document.querySelector(".go-home")?.remove();
    document.querySelector(".pictureBottomBtn")?.remove();
    document.querySelector(".elevator")?.remove();

    return CONTINUE;
}

function unfold(){
    let article_body = document.querySelector("#article_body");
    if (article_body) {
        article_body.className = article_body.className.replace('packed', 'unpack');
        document.querySelector(".collapseWrapper")?.remove();
        document.querySelector(".mask")?.remove();
        return CONTINUE;
    }

    return CONTINUE;
}

if (document.readyState !== "loading"){
    let tasks = [removeAds,removeAnnoyances,unfold];
    Stay_Inject.run(tasks,100,30,true).then((data) => {});
}
else{
    document.addEventListener("DOMContentLoaded", function(event) {
        let tasks = [removeAds,removeAnnoyances,unfold];
        Stay_Inject.run(tasks,100,30,true).then((data) => {});
    });
}
