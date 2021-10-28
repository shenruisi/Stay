function removeAds(){
    let ad = document.querySelector(".middle-insert-ad");
    if (ad){
        ad.style.display = "none";
        return COMPLETE;
    }
    
    return CONTINUE;
}

function unfold(){
    let lookallbox = document.querySelector(".article-main .lookall-box");
    console.log(lookallbox);
    if (lookallbox){
        lookallbox.style.display = "none";
        if (lookallbox){
            let otherContent = document.querySelector(".article-main .hidden-content");
            if (otherContent){
                otherContent.className = "hidden-content";
                return COMPLETE;
            }
        }
    }
    
    return CONTINUE;
}

document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [removeAds,unfold];
    Inject.run(tasks,100,30,true).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
