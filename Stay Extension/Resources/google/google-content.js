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
            &&(ZHIHU_REG.test(a.href) || TIEBA_REG.test(a.href) || BILIBILI_REG.test(a.href))){
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


document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [banBottomBanner,replaceDirectUrl];
    Inject.run(tasks,100,30,true).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
