// ==UserScript==
// @name         CSDN@AutoExpend
// @namespace    http://stay.app/
// @version      0.0.1
// @description  自动展开CSDN文章
// @author       Stay²
// @match        *://*.csdn.net/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeChoosePanel(){
    let pannel = document.querySelector('.weixin-shadowbox');
    if (pannel){
        pannel.remove();
        return COMPLETE;
    }
    
    return CONTINUE;
}

function removeAppJump(){
    let app = document.querySelector('span.feed-Sign-span');
    if (app){
        var url = app.getAttribute("data-href");
        app.remove();
        return DATA();
    }
    
    return CONTINUE;
}

function unfold(){
    let main = document.querySelector('#main');
    if (main){
        let content = main.querySelector(".article_content");
        if (content){
            content.style.overflow = null;
            content.style.height = null;
        }
        
        let readallbox = main.querySelector(".readall_box");
        console.log(readallbox);
        if (readallbox){
            readallbox.remove();
            readallbox.className = "readall_box_nobg";
        }
        
        let prompt = main.querySelector(".btn_open_app_prompt_div");
        if (prompt){
            prompt.remove();
        }
        
        return COMPLETE;
    }
    
    return CONTINUE;
}

if (document.readyState !== "loading"){
    let tasks = [removeChoosePanel,removeAppJump,unfold];
    Stay_Inject.run(tasks,100,30,false).then((data) => {});
}
else{
    document.addEventListener("DOMContentLoaded", function(event) {
        let tasks = [removeChoosePanel,removeAppJump,unfold];
        Stay_Inject.run(tasks,100,30,false).then((data) => {});
    });
}
