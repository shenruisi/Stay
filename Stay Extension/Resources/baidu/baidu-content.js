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
        console.log(pageWrapper);
        var app = pageWrapper.querySelector('.mL3ndd4cDuSxL');
        console.log(app);
        if (!app){
            let divs = pageWrapper.querySelectorAll('div');
            for (var i = 0; i < divs.length; i++){
                let p = divs[i].querySelector('p');
                if (p){
                    if (p.innerText == "百度APP内阅读"){
                        app = divs[i];
                        break;
                    }
                }
            }
        }

        if (app){
            app.style.display = "none";
            //TODO: ??
            return new App()
            .id("baidu")
            .title("百度APP")
            .icon("https://is3-ssl.mzstatic.com/image/thumb/Purple115/v4/ed/f8/1e/edf81e19-cb51-7d84-c44f-6ff31ad1b7dd/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/230x0w.png")
            .url("baiduboxapp://")
            .data();
        }

    }
    return CONTINUE;
}

function unfold(){
    let pageWrapper = document.querySelector('#page_wrapper');
    if (pageWrapper){
        let fullText = pageWrapper.querySelector('.unfoldFullText') || pageWrapper.querySelector('.wxUnfoldText');
        if (fullText){
            fullText.style.display = "none";
            let mainContent = pageWrapper.querySelector('.mainContent');
            if (mainContent){
                mainContent.style.height = null;
                return COMPLETE;
            }
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
    let layerMain = document.querySelector('.layer-main');
    if (layerMain){
        console.log(layerMain);
        layerMain.remove();
        return COMPLETE;
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
            && !R_E_D_I_R_E_C_T_TEST.test(article.getAttribute("rl-link-href"))){
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
            && !R_E_D_I_R_E_C_T_TEST.test(div.getAttribute("rl-link-href"))){
            let newUrl = $noJumpUrl($uri(dataLog.src).host,dataLog.src);
            if (newUrl){
                div.onclick = function(event){
                    event.preventDefault();
                    event.stopPropagation();
                    location.href = newUrl;
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

document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [banAds,banBottomBanner,banBall,removeAppJump,unfold,removeChoosePanel,moreResult,replaceDirectUrl,popLead];
    Inject.run(tasks,100,30,false).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
