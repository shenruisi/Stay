function removeChoosePanel(){
    let pannel = document.querySelector('nav.tb-backflow-defensive');
    if (pannel){
        pannel.remove();
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
