function removeTopBanner(){
    let app = document.querySelector("#app");
    if (app){
        let navbar = app.querySelector(".normal-launch-app-container");
        if (navbar){
            navbar.style.display = "none";
            return COMPLETE;
        }
    }
    
    return CONTINUE;
}

function removeAppJump(){
    let app = document.querySelector("#app");
    if (app){
        let bottombar = app.querySelector(".bottom-bar");
        if (bottombar){
            bottombar.remove();
            var url = window.location.href;
            return new App()
            .id("xhs")
            .title(app.querySelector(".title").innerText || "小红书")
            .icon("https://is4-ssl.mzstatic.com/image/thumb/Purple125/v4/06/00/2f/06002f58-01e1-4d98-5ae2-5807eb4c059f/AppIcon-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/230x0w.png")
            .url("xhsdiscover://item/"+url.substring(url.lastIndexOf('/')+1))
            .data();
        }
    }
    
    return CONTINUE;
}

function unfold(){
    let app = document.querySelector("#app");
    if (app){
        let checkmore = app.querySelector(".check-more");
        if (checkmore){
            checkmore.style.display = "none";
            let content = app.querySelector(".content");
            if (content){
                content.style.height = null;
                return COMPLETE;
            }
        }
    }
    
    return CONTINUE;
}

window.onload = function() {
    let tasks = [removeTopBanner,removeAppJump,unfold];
    Inject.run(tasks,100,30,false).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
}
