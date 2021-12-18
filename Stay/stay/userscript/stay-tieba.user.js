// ==UserScript==
// @name         百度贴吧@AutoExpend
// @namespace    http://stay.app/
// @version      0.0.1
// @description  自动展开百度贴吧帖子
// @author       Stay²
// @match        *://tieba.baidu.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// ==/UserScript==

function removeChoosePanel(){
    console.log("removeChoosePanel");
    let pannel = document.querySelector('nav.tb-backflow-defensive');
    console.log(document,pannel);
    if (pannel){
        console.log(pannel);
        let btns = pannel.querySelectorAll('.tb-share__btn');
        for (var i=0; i < btns.length; i++){
            let button = btns[i];
            if (button.innerText == "继续"){
                button.click();
                return COMPLETE;
            }
        }
        return COMPLETE;
    }
    
    return CONTINUE;
}

if (document.readyState !== "loading"){
    let tasks = [removeChoosePanel];
    Stay_Inject.run(tasks,100,30,false).then((data) => {});
}
else{
    document.addEventListener("DOMContentLoaded", function(event) {
        let tasks = [removeChoosePanel];
        Stay_Inject.run(tasks,100,30,false).then((data) => {});
    });
}
