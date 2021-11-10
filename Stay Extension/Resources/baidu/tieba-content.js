function removeChoosePanel(){
    let pannel = document.querySelector('nav.tb-backflow-defensive');
    if (pannel){
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



document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [removeChoosePanel];
    Inject.run(tasks,100,30,false).then((data) => {
        console.log(data);
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
