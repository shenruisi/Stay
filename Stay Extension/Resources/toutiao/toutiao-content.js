function removeTopBanner(){
    let banner = document.querySelector('.top-banner-container');
    if (banner){
        banner.remove();
        return new App()
        .id("toutiao")
        .title("今日头条")
        .icon("https://is2-ssl.mzstatic.com/image/thumb/Purple125/v4/c1/f9/e5/c1f9e5bb-b6e7-10f2-ef8e-e77e893997f6/AppIcon-News-0-0-1x_U007emarketing-0-0-0-7-0-0-sRGB-0-0-0-GLES2_U002c0-512MB-85-220-0-0.png/230x0w.png")
        .url("snssdk141://")
        .data();
    }
    
    return CONTINUE;
}

function unfold(){
    let button = document.querySelector('div.fold-btn-btn');
    if (button){
        button.remove();
        let content = document.querySelector('div.fold-btn-content')
        if (content){
            content.className = null;
            content.className = "fold-btn-content";
        }
        return COMPLETE;
    }
    
    return CONTINUE;
}

document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [removeTopBanner,unfold];
    Inject.run(tasks,100,30,false).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
