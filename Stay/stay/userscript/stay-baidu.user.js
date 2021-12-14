// ==UserScript==
// @name         Baidu@PreventAppJump
// @namespace    http://stay.app/
// @version      0.0.1
// @description  防止从Baidu结果页跳转到其他App
// @author       Stay²
// @match        *://*.baidu.com/*
// @match        *://*.zhihu.com/R_E_D_I_R_E_C_T/*
// @match        *://*.xiaohongshu.com/R_E_D_I_R_E_C_T/*
// @exclude      *://tieba.baidu.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

const ZHIHU_REG = /^(http|https):\/\/(.*\.){0,1}zhihu.com\/.*$/;
const TIEBA_REG = /^(http|https):\/\/tieba.baidu.com\/.*$/;
const XHS_REG = /^(http|https):\/\/m.xiaohongshu.com\/.*$/;
const BILIBILI_REG = /^(http|https):\/\/(.*\.){0,1}bilibili.com\/.*$/;

const $uri = (url) => {
    let a = document.createElement("a");
    a.href = url;
    return a;
}

const $res = (name) => {
    return browser.runtime.getURL(name);
}

const $noJumpUrl = (host,url) => {
    if (host == "tieba.baidu.com"){
        return $res('iframe.html')+"?url="+encodeURIComponent(url);
    }
    else if (host == "zhuanlan.zhihu.com"){
        return "https://zhuanlan.zhihu.com/R_E_D_I_R_E_C_T/?url="+encodeURIComponent(url);
    }
    else if (host == "www.zhihu.com"){
        return "https://www.zhihu.com/R_E_D_I_R_E_C_T/?url="+encodeURIComponent(url);
    }
    else if (host == "m.xiaohongshu.com"){
        return "https://m.xiaohongshu.com/R_E_D_I_R_E_C_T/?url="+encodeURIComponent(url);
    }
    else if (host == "m.bilibili.com" || host == "www.bilibili.com"){
        return  $res('iframe.html')+"?url="+encodeURIComponent(url);
    }
    
    return null;
}

const $getQueryVariable = (variable) => {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
        if(pair[0] == variable){return pair[1];}
    }
    return "";
}

function banAds(){
    let header = document.querySelector('#header');
    if (null != header){
        let div = header.lastChild;
        if (div.nodeName == "DIV" && div.className == ""){
            div.style.display = "none";
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function removeAppJump(){
    let pageWrapper = document.querySelector('#page_wrapper');
    if (pageWrapper){
        return DATA();
    }
    return CONTINUE;
}

function unfold(){
    let pageWrapper = document.querySelector('#page_wrapper');
    if (pageWrapper){
        let fullText = pageWrapper.querySelector('.unfoldFullText') || pageWrapper.querySelector('.wxUnfoldText');
        if (fullText){
            fullText.click();
            setTimeout(function(){
                document.querySelector('.popup-lead-cancel')?.click();
            },50);
            return COMPLETE;
        }
       
    }

    return CONTINUE;
}

function banBottomBanner(){
    let pageCopyright = document.querySelector('#page-copyright');
    if (pageCopyright){
        let div = pageCopyright.lastChild;
        if (div && div.style.position == "fixed" && div.style.bottom == "0px"){
            div.style.display = "none";
            return COMPLETE;
        }
    }
    return CONTINUE;
}

function banBall(){
    let divs = document.querySelectorAll('.c-result');
    for (var i = 0; i<divs.length;i++){
        if (divs[i].getAttribute("tpl") == "mkt_entrance_ball"
            || divs[i].getAttribute("srcid") == "mkt_ball"
            || divs[i].getAttribute("srcid") == "mkt_ad_space"){
            divs[i].style.display = "none";
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function removeChoosePanel(){
    let pannels = document.querySelectorAll('.layer-wrap');
    for (var i = 0; i < pannels.length; i++){
        let pannel = pannels[i];
        let div = pannel.querySelector('.layer-content-shown');
        if (div){
            let btns = div.querySelectorAll('.layer-itemBtn');
            
            for (var i=0; i < btns.length; i++){
                let button = btns[i];
                if (button.innerText == "继续"){
                    button.click();
                    return COMPLETE;
                }
            }
        }
    }
    
    return CONTINUE;
}

function moreResult(){
    let results = document.querySelector('.hint-fold-results-wrapper');
    if (results){
        results.style.height = "auto";
        let box = document.querySelector('.hint-fold-results-box');
        if (box){
            box.style.display = "none";
        }
        return COMPLETE;
    }
    return CONTINUE_TIL(10);
}

function replaceDirectUrl(){
    let articles = document.querySelectorAll('article');
    for (var i = 0; i< articles.length;i++){
        let article = articles[i];
        let dataLog = JSON.parse(article.parentNode.parentNode.getAttribute("data-log"));
        if (dataLog
            && (ZHIHU_REG.test(dataLog.mu) || TIEBA_REG.test(dataLog.mu) || BILIBILI_REG.test(dataLog.mu))
            && !/R_E_D_I_R_E_C_T/.test(article.getAttribute("rl-link-href"))){
            let newUrl = $noJumpUrl($uri(dataLog.mu).host,dataLog.mu);
            if (newUrl){
                article.setAttribute("rl-link-href",newUrl);
                article.parentNode.parentNode.onclick = function(event){
                    event.preventDefault();
                    event.stopPropagation();
                    location.href = newUrl;
                }
            }
        }
    }
    
    let divs = document.querySelectorAll('div[rl-link-href]');
    for (var i = 0; i< divs.length;i++){
        let div = divs[i];
        if (div.getAttribute("rl-link-href") == "") continue;
        if (div.getAttribute("rl-link-data-click") == "") continue;
        let dataLog = JSON.parse(div.getAttribute("rl-link-data-click"));
        if (dataLog
            && (ZHIHU_REG.test(dataLog.src) || TIEBA_REG.test(dataLog.src) || XHS_REG.test(dataLog.src))
            && !/R_E_D_I_R_E_C_T/.test(div.getAttribute("rl-link-href"))){
            let newUrl = $noJumpUrl($uri(dataLog.src).host,dataLog.src);
            if (newUrl){
                div.onclick = function(event){
                    event.preventDefault();
                    event.stopPropagation();
                    location.href = newUrl;
                    console.log(newUrl);
                }
            }
        }
    }
    
    
    return CONTINUE_TIL(10);
}

function popLead(){
    let popup = document.querySelector("#pop-up");
    if (popup){
        let cancel = popup.querySelector(".popup-lead-cancel");
        if (cancel){
            cancel.click();
            return COMPLETE;
        }

    }
    return CONTINUE_TIL(10);
}

if (/R_E_D_I_R_E_C_T/.test(location.href)) {
    let url = decodeURIComponent($getQueryVariable("url")).replace("http:","https:");
    location.replace(url);
}
else{
    if (document.readyState !== "loading"){
        let tasks = [banAds,banBottomBanner,banBall,removeAppJump,unfold,removeChoosePanel,replaceDirectUrl,moreResult,popLead];
        Stay_Inject.run(tasks,100,30,false).then((data) => {});
    }
    else{
        document.addEventListener("DOMContentLoaded", function(event) {
            let tasks = [banAds,banBottomBanner,banBall,removeAppJump,unfold,removeChoosePanel,replaceDirectUrl,moreResult,popLead];
            Stay_Inject.run(tasks,100,30,false).then((data) => {});
        });
    }
   
}





