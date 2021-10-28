const $setText = (selector,value) => {
    document.querySelector(selector).textContent = value;
};


window.addEventListener('DOMContentLoaded', () => {
    document.querySelector(".placeholder").style.display = "block";
    document.querySelector(".tableview").style.display = "none";
    browser.runtime.sendMessage({ from: "popup", operate: "fetchAppList" }).then((response) => {
        if (response.body.length > 0){
            document.querySelector(".placeholder").style.display = "none";
            document.querySelector(".tableview").style.display = "block";
            let app = response.body[0];
            $setText(".title",app.title);
            document.querySelector(".icon").src = app.icon;
            if (app.url.length){
                document.querySelector(".cell").addEventListener("click",function (event) {
                    window.open(app.url);
                });
            }
        }
    });
});
