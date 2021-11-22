// ==UserScript==
// @name         Stay知乎脚本
// @namespace    http://stay.app/
// @version      0.0.1
// @description  防止跳转知乎App，自动展开回答，支持知乎桌面版
// @author       Stay
// @match        *://*.zhihu.com/*
// @grant        GM_log
// @grant        GM_setValue
// @grant        GM_getValue
// @grant        GM_listValues
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeChoosePanel(){
    let pannels = document.querySelectorAll('.ModalWrap');
    for (var i = 0; i < pannels.length; i++){
        let pannel = pannels[i];
        let div = pannel.querySelector('.ModalExp-modalShow');
        if (div){
            let btns = div.querySelectorAll('.ModalWrap-itemBtn');
            
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

function removeAppJump(){
    let app = document.querySelector('button.OpenInAppButton');
    if (app){
        var url = app.getAttribute("urlscheme");
        app.remove();
        return DATA();
    }
    return CONTINUE;
}

function unfold(){
    let btns = document.querySelectorAll('.ContentItem-expandButton');
    for (var i = 0; i < btns.length; i++){
        let btn = btns[i];
        if (/展开阅读全文/.test(btn.innerText)){
            let content = btn.parentNode;
            if (content){
                content.className = "RichContent RichContent--unescapable";
                let contentinner = content.querySelector('.RichContent-inner');
                if (contentinner){
                    contentinner.style.maxHeight = "none";
                }
            }
            btn.remove();
            let main = document.querySelector(".Question-main");
            if (main){
                main.onclick = function(event){
                    let target = event.target;
                    while(!/RichContent/.test(target.className) && target.tagName != "BODY"){
                        target = target.parentNode;
                    }
                    if (/RichContent/.test(target.className)){
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    
                }
            }
            
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function replaceDirectUrl(){
    let items = document.querySelectorAll('.Feed');
    if (items){
        for (var i = 0; i < items.length; i++){
            let item = items[i];
            let a = item.querySelector('a');
            item.onclick = function(event){
                event.preventDefault();
                event.stopPropagation();
                location.href = a.href;
            }
        }
        return COMPLETE;
    }
    
    return CONTINUE_TIL(10);
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

if (/R_E_D_I_R_E_C_T/.test(location.href)) {
    let url = decodeURIComponent($getQueryVariable("url")).replace("http:","https:");
    location.replace(url);
}

document.addEventListener("DOMContentLoaded", function(event) {
    console.log(window.navigator.userAgent);
    console.log(GM_listValues());
//    GM_setValue("first","1");
//    let a = GM_getValue("first");
//    console.log("getValue",a);
    if (/Macintosh/.test(window.navigator.userAgent)){
        var css = "*{box-sizing:border-box;min-width:initial!important;max-width:100%!important;}html{overflow-y:auto!important;}body{position:absolute!important;top:0!important;width:100%;-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;}.RichContent-actions.is-fixed,.Question-sideColumn,.ContentLayout-sideColumn,.QuestionHeader-footer,#free-reward-panel,.show-foot,.meta-bottom{display:none!important;}.Question-mainColumn,.ContentLayout-mainColumn{width:100%!important;margin:0!important;padding:6px!important;}#free-reward-panel,.AdblockBanner,.AppHeader-Tabs,.AppHeader-userInfo,.Modal-wrapper,.Pc-word,.Question-sideColumn,.QuestionHeader-footer,.RichContent-actions.is-fixed,.meta-bottom,.show-foot,body>div:last-child,.Question-mainColumnLogin,.Profile-sideColumn,.QuestionHeader-side,.ModalWrap,.ShareMenu{display:none!important;}.Topstory{padding:0!important;}.GlobalSideBar,.Question-sideColumn,.QuestionHeader-side,.TopstoryItem--advertCard,.TopstorySideBar,.css-1qefhqu{display:none!important;}.AppHeader,.AppHeader-widescreenResponsive.AppHeader-inner{box-sizing:content-box!important;width:100%!important;min-width:100%!important;padding:0!important;}.QuestionHeader{min-width:initial;}.Question-mainColumn,.Topstory-mainColumn,.TopstoryMain,.TopstoryV2-mainColumn{width:100%!important;max-width:100%!important;}.Topstory-mainColumn{margin:0!important;}.TopstoryItem.ZVideoItem{margin:0;}.TopstoryItem.ZVideoItem.RichContent{overflow:hidden;margin-top:20px;}.ContentItem-more.ContentItem-arrowIcon{vertical-align:-2px;}.AnswerItem,.ArticleItem,.Layout-main.av-card{font-size:120%!important;}.RichTextpre{font-size:90%!important;padding:0.8em1.2em!important;padding-top:0.6em;padding-bottom:0.6em;}.RichTextcode,.RichTextpre{font-family:\"JetBrainsMono\",FiraMono-Regular,Menlo,Courier,monospace!important;}.ContentItem-time,.Post-Header,.Post-NormalMain>div,.Post-NormalSub.Comments-container,.Post-RichTextContainer,.Post-topicsAndReviewer,.PostIndex-Contributions,.TitleImage{width:100%!important;}.Post-RichText{font-size:18px;}.Footer{display:none!important;}.SearchResult-Card.ContentItem-title{color:#0084ff!important;}.Search-container.RichContent.is-collapsed.RichContent-inner{font-size:16px!important;}.Profile-lightList{padding:6px20px;}.Profile-lightItem:first-child{border-top:0none!important;}.Profile-lightItem:last-child{border-bottom:0none!important;}.ProfileMain.RichContent{line-height:1.8;}.ContentItem-actions{margin:6px0;padding:0;flex-wrap:wrap;justify-content:space-between;}.QuestionHeader-main,.Question-main{padding:0;}.Post-Main{margin:02em;}.AppHeader-inner.css-qqgmyv{padding:6px10px;}.QuestionHeader-content{padding:012px;}.List-item{padding:10px12px;}";
            var node = document.createElement("style");
            node.type = "text/css";
            node.appendChild(document.createTextNode(css));
            var heads = document.getElementsByTagName("head");
            if (heads.length > 0) {
                heads[0].appendChild(node);
            } else {
                document.documentElement.appendChild(node);
            }
    }
});

window.onload = function(){
    console.log("console log window.onload");
    GM_log("gmlog window.onload");
    if (!/Macintosh/.test(window.navigator.userAgent)){
        
        let tasks = [removeChoosePanel,removeAppJump,replaceDirectUrl,unfold];
        Stay_Inject.run(tasks,100,30,false).then((data) => {
            browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
        });
    }
    
}

document.addEventListener("scroll", function(event) {
    if (!/Macintosh/.test(window.navigator.userAgent)){
        let guide = document.querySelector('div.DownloadGuide');
        if (guide){
            console.log(guide);
            guide.style.display = "none";
        }
    }
    
});
