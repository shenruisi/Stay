var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;

const $setText = (selector,value) => {
    document.querySelector(selector).innerHTML = value;
};
var scriptStateList,
    scriptConsole,
    tmp = [
    '<div class="info-case">',
    '<div class="title">{name}</div>',
    '<div class="name">{author}</div>',
    '<div class="desc">{description}</div>',
    '</div>',
    '<div class="active-case" active={active} uuid={uuid} >',
    '<div class="active-icon" active={active} uuid={uuid} ></div>',
    '</div>'].join(''),
    state = ['start', 'stop'];


(function(){

})

function fetchMatchScriptList(){
    browser.runtime.sendMessage({from:"popup", operate: "fetchMatchScriptList"},(response)=>{
//        document.querySelector(".placeholder").innerHTML = JSON.stringify(response)
        if(response && response.body && response.body.length > 0){
            document.getElementById("scriptNull").style.display = "none";
            document.querySelector(".placeholder").innerHTML = JSON.stringify(response.body[0].uuid);
            renderAll(response.body);
            
        }else{
            document.getElementById("scriptNull").style.display = "block";
            document.querySelector(".placeholder").innerHTML = "null"
        }
    })
}

window.onload=function(){
    let self = this;
    scriptStateList = document.getElementById('scriptSateList');
    scriptConsole = document.getElementById('scriptConsole');
    fetchMatchScriptList()
    
    // 给header tab绑定事件
    document.querySelector(".header-box .header-tab").addEventListener("click", function(e){
        let target = e.target;
        if(target){
            let type = target.getAttribute("tab");
            handleTabAction(target, type);
        }
    })
    
    // 给scriptStateList添加监听器
    scriptStateList.addEventListener("click", function (e) {
        console.log("addEventListener ", e, e.target);
        let target = e.target;
        // e.target是被点击的元素!
        // 筛选触发事件的子元素如果是active-case执行的事件
        if (target && target.nodeName.toLowerCase() == "div" && (target.className.toLowerCase() == "active-case" || target.className.toLowerCase() == "active-icon")) {
            // 获取到具体事件触发的active-case，进行active
            let active = target.getAttribute("active");
            let uuid = target.getAttribute("uuid");
            console.log("active= ", active, ", uuid=", uuid, ", was clicked!");
            handleScriptActive(uuid, active);
            return;
        }
    });
};

function renderAll(datas) {
    var data;
    
    while (data = datas.shift()) {
        render(data);
    }
}

function render(data) {
    var _dom = document.createElement('div');
    let index = data.active ? 1 : 0;
    _dom.setAttribute('class', 'content-item ' + state[index]);
    _dom.setAttribute('uuid', data["uuid"]);
    _dom.setAttribute('author', data["author"]);
    _dom.innerHTML = tmp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
    scriptStateList.appendChild(_dom);
}

function handleScriptActive(uuid, active) {
    if (uuid && uuid != "" && typeof uuid == "string") {
        browser.runtime.sendMessage({
            from: "popup",
            operate: "setScriptActive",
            uuid: uuid,
            active: !active
        }, (response) => {
            console.log(response.body)
            fetchMatchScriptList()
        })
    }
}

/**
 * type [number] 1:match,2:console
 **/
function handleTabAction(target, type) {
    if (target) {
        document.getElementsByClassName("active-tab")[0].classList.remove("active-tab"); // 删除之前已选中tab的样式
        target.classList.add('active-tab'); // 给当前选中tab添加样式
        if(type == 1){
            scriptStateList.style.display = "block";
            scriptConsole.style.display = "none";
        }else{
            scriptStateList.style.display = "none";
            scriptConsole.style.display = "block";
        }
        
    }
}

//var browser = __b;
//var chrome = __b;
window.addEventListener('DOMContentLoaded', () => {    
    document.querySelector(".placeholder").style.display = "block";
    document.querySelector(".tableview").style.display = "none";
    browser.runtime.sendMessage({ from: "popup", operate: "fetchAppList" },(response)=>{
        if (response.body.length > 0){
            document.querySelector(".placeholder").style.display = "none";
            document.querySelector(".tableview").style.display = "block";
            let app = response.body[0];
            $setText(".title",app.title);
            console.log("title",app.title);
            document.querySelector(".icon").src = app.icon;
            if (app.url.length){
                document.querySelector(".cell").addEventListener("click",function (event) {
                    window.open(app.url);
                });
            }
        }
    });
    
    
    
//    browser.runtime.sendMessage({ from: "popup", operate: "fetchAppList" }).then((response) => {
//        if (response.body.length > 0){
//            document.querySelector(".placeholder").style.display = "none";
//            document.querySelector(".tableview").style.display = "block";
//            let app = response.body[0];
//            $setText(".title",app.title);
//            console.log("title",app.title);
//            document.querySelector(".icon").src = app.icon;
//            if (app.url.length){
//                document.querySelector(".cell").addEventListener("click",function (event) {
//                    window.open(app.url);
//                });
//            }
//        }
//    });
    
    
});
