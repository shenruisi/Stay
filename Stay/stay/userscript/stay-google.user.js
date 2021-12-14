// ==UserScript==
// @name         Google@PreventAppJump
// @namespace    http://stay.app/
// @version      0.0.1
// @description  防止从Google结果页跳转到其他App
// @author       Stay²
// @match        *://*.google.com/*
// @match        *://*.google.com.hk/*
// @match        *://*.zhihu.com/R_E_D_I_R_E_C_T/*
// @match        *://*.xiaohongshu.com/R_E_D_I_R_E_C_T/*
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


function banBottomBanner(){
    let btns = document.querySelectorAll('g-flat-button');
    for (var i = 0; i < btns.length; i++){
        let btn = btns[i];
        if (/不用/.test(btn.innerText)){
            btn.click();
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function replaceDirectUrl(){
    let divs = document.querySelectorAll('div[data-hveid]');
    for (var i = 0; i < divs.length; i++){
        let div = divs[i];
        let a = div.querySelector('a');
        
        if (a
            &&a.href
            &&(ZHIHU_REG.test(a.href)
               || TIEBA_REG.test(a.href)
               || BILIBILI_REG.test(a.href)
               || XHS_REG.test(a.href))){
            console.log(a.href);
            let newUrl = $noJumpUrl($uri(a.href).host,a.href);
            console.log(newUrl);
            div.onclick = function(){
                event.preventDefault();
                event.stopPropagation();
                location.href = newUrl;
            }
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
        let tasks = [banBottomBanner,replaceDirectUrl];
        Stay_Inject.run(tasks,100,30,true).then((data) => {});
    }
    else{
        document.addEventListener("DOMContentLoaded", function(event) {
            let tasks = [banBottomBanner,replaceDirectUrl];
            Stay_Inject.run(tasks,100,30,true).then((data) => {});
        });
    }
    

}


