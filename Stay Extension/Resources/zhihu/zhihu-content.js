function removeChoosePanel(){
    console.log("removeChoosePanel");
    let pannel = document.querySelectorAll('.ModalWrap');
    if(pannel.length > 1){
        return COMPLETE;
    }
    
    let btns = document.querySelectorAll('.ModalWrap-itemBtn');
    
    for (var i=0; i < btns.length; i++){
        let button = btns[i];
        if (button.innerText == "继续"){
            button.click();
            return COMPLETE;
        }
    }
    return CONTINUE;
}

function removeAppJump(){
    let app = document.querySelector('button.OpenInAppButton');
    if (app){
        var url = app.getAttribute("urlscheme");
        app.remove();
        return new App()
        .id("zhihu")
        .title(document.title)
        .icon("https://is1-ssl.mzstatic.com/image/thumb/Purple125/v4/83/24/ca/8324ca44-40d5-87ed-4f8f-a47daec7dc34/AppIcon-0-0-1x_U007emarketing-0-0-0-6-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/230x0w.png")
        .url(url)
        .data();
    }
    return CONTINUE;
}

function unfold(){
    let button = document.querySelector('.ContentItem-expandButton');
    if (button){
        button.remove();
        let content = document.querySelector('.RichContent');
        if (content){
            content.className = "RichContent RichContent--unescapable";
            let contentinner = document.querySelector('.RichContent-inner');
            if (contentinner){
                contentinner.style.maxHeight = "none";
            }
        }
        return COMPLETE;
    }
    
    return CONTINUE;
}


document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [removeChoosePanel,removeAppJump,unfold];
    Inject.run(tasks,100,30,false).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});



