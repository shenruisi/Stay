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
        return new App()
        .id("csdn")
        .title(document.title)
        .icon("https://is1-ssl.mzstatic.com/image/thumb/Purple125/v4/b7/1c/7d/b71c7d47-6ae3-cdc0-bdf8-7e1385707f30/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/230x0w.png")
        .url(url)
        .data();
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

document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [removeChoosePanel,removeAppJump,unfold];
    Inject.run(tasks,100,30,false).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
