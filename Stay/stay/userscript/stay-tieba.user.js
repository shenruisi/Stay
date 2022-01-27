// ==UserScript==
// @name         百度贴吧@AutoExpand
// @namespace    http://stay.app/
// @version      0.0.2
// @description  自动展开百度贴吧帖子
// @author       Stay²
// @match        *://tieba.baidu.com/*
// @run-at       document-start
// @require      stay://vendor/stay-taskloop.js
// @updateURL    https://raw.githubusercontent.com/shenruisi/Stay-Offical-Userscript/main/tieba/stay-tieba.update.js
// @downloadURL    https://raw.githubusercontent.com/shenruisi/Stay-Offical-Userscript/main/tieba/stay-tieba.user.js
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
