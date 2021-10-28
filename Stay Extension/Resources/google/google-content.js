document.addEventListener("DOMContentLoaded", function(event) {
    let tasks = [];
    Inject.run(tasks,100,30,true).then((data) => {
        browser.runtime.sendMessage({from:"content",operate:"saveAppList",data:data})
    });
});
