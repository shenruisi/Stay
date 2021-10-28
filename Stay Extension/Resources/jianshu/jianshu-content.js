function removeChoosePanel(){
    let pannel = document.querySelector('.download-app-guidance');
    if (pannel){
        pannel.remove();
        return COMPLETE;
    }
    
    return CONTINUE;
}

function removeAppJump(){
    let app = document.querySelector('button.call-app-btn');
    if (app){
        app.remove();
        return COMPLETE;
    }
    
    return CONTINUE;
}

function unfold(){
    let closebtn = document.querySelector('button.close-collapse-btn');
    if (closebtn){
        closebtn.remove();
        
        let content = document.querySelector('div.collapse-free-content')
        if (content){
            content.className = null;
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
