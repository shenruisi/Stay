var __b; if (typeof browser != "undefined") {__b = browser;} if (typeof chrome != "undefined") {__b = chrome;}
var browser = __b;
/**
 * String原型对象方法
 * 将字符串的true/false 转为boolean基本数据类型
 * @returns boolean
 */
String.prototype.bool = function () {
    return (/^true$/i).test(this);
}
Object.prototype.hide = function () {
    this.style.display = "none"
    // this.style.transition = "background 3s ease-in"
}
Object.prototype.show = function () {
    this.style.display = "block"
    // this.style.transition = "background 3s ease-in"
}
Object.prototype.cleanInnerHTML = function () {
    this.innerHTML = "";
}
Object.prototype.setInnerHtml = function (value) {
    this.innerHTML = value
}

let scriptStateList = [],
    scriptStateListDom,
    scriptConsole = [],
    logIsFetched = false,
    scriptConsoleDom,
    scriptDomTmp = [
            '<div class="info-case">',
            '<div class="title">{name}</div>',
            '<div class="name">{author}</div>',
            '<div class="desc">{description}</div>',
            '</div>',
            '<div class="active-case" active={active} uuid={uuid} >',
            '<div class="active-icon" active={active} uuid={uuid} ></div>',
            '</div>'].join(''),
    scriptLogDomTmp = [
            '<div class="console-name">{name}</div>',
            '<div class="console-con">{message}</div>'
            ].join(''),
    state = ['start', 'stop'];


(function(){

})

/**
 * 获取当前网页可匹配的脚本
 */
function fetchMatchedScriptList(){
    browser.runtime.sendMessage({from:"popup", operate: "fetchMatchedScriptList"},(response)=>{
        if(response && response.body && response.body.length > 0){
            scriptStateList = response.body;
            // scriptStateList.push({ uuid: "324353423354", version: "1.0.0", active: true, name: "scriptContent.js", author: "Stay offical", description:"防止跳转知乎App，自动展开知乎回答"})
//             document.querySelector(".placeholder").innerHTML = JSON.stringify(scriptStateList);
        }else{
//             document.querySelector(".placeholder").innerHTML = "null"
        }
        renderScriptContent(scriptStateList);
    })
}

/**
 * 获取控制台日志
 */
function fetchMatchedScriptConsole(){
    if (logIsFetched){
        renderScriptConsole(scriptConsole);
        return;
    }
    browser.runtime.sendMessage({from: "popup", operate: "fetchMatchedScriptLog"},(response)=>{
        logIsFetched = true;
        if(response && response.body && response.body.length > 0){
            scriptConsole = response.body
            renderScriptConsole(response.body);
        }else{
            scriptConsoleDom.cleanInnerHTML();
        }
    })
}

/**
 * 匹配脚本为空的样式状态
 */
function showNullData(message){
    var _dom = document.getElementById("dataNull");
    _dom.setInnerHtml(message || "未匹配到可用脚本");
    _dom.show();
}

window.onload=function(){
    let self = this;
    scriptStateListDom = document.getElementById('scriptSateList');
    scriptConsoleDom = document.getElementById('scriptConsole');
    fetchMatchedScriptList()
    
    // 给header tab绑定事件
    document.querySelector(".header-box .header-tab").addEventListener("click", function(e){
        let target = e.target;
        if(target){
            let type = target.getAttribute("tab");
            handleTabAction(target, type);
        }
    })
    
    // 给scriptStateListDom添加监听器
    scriptStateListDom.addEventListener("click", function (e) {
        let target = e.target;
        // e.target是被点击的元素!
        // 筛选触发事件的子元素如果是active-case执行的事件
        if (target && target.nodeName.toLowerCase() == "div" && (target.className.toLowerCase() == "active-case" || target.className.toLowerCase() == "active-icon")) {
            // 获取到具体事件触发的active-case，进行active
            let active = target.getAttribute("active");
            let uuid = target.getAttribute("uuid");
            console.log("active= ", active, ", uuid=", uuid, ", was clicked!");
//            document.querySelector(".placeholder").innerHTML ="active= "+active +", uuid="+ uuid+ ", was clicked!";
            handleScriptActive(uuid, active.bool());
            return;
        }
    });
};

/**
 * String原型对象方法
 * 将字符串的true/false 转为boolean基本数据类型
 * @returns boolean
 */
String.prototype.bool = function () {
    return (/^true$/i).test(this);
};

/**
 * 匹配脚本的控制台数据绑定及渲染
 * @param {Array} datas   匹配脚本的控制台数据
 */
function renderScriptConsole(datas) {
    const scriptLogList = datas;
    scriptConsoleDom.cleanInnerHTML();
    if(scriptLogList && scriptLogList.length>0){
        scriptLogList.forEach(item=> {
            if(item.logList && item.logList.length>0){
                item.logList.forEach(logMsg=>{
                    let data = {
                        uuid: item.uuid,
                        name: item.name,
                        //Fixed wrong variable logMsg.
                        message:logMsg
                    };
                    console.log(data.logMsg);
                    var _dom = document.createElement('div');
                    _dom.setAttribute('class', 'console-item');
                    _dom.setAttribute('uuid', data["uuid"]);
                    _dom.innerHTML = scriptLogDomTmp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
                    scriptConsoleDom.appendChild(_dom);
                })
            }
        })
        if (scriptConsoleDom.children.length == 0){
            scriptConsoleDom.hide();
        }
    }else{
        scriptConsoleDom.hide();
    }
}

/**
 * 匹配脚本的数据绑定及渲染
 * @param {Array} datas   匹配脚本数据
 */
function renderScriptContent(datas) {
    const scriptList = datas;
    scriptStateListDom.cleanInnerHTML();
    if (scriptList && scriptList.length>0){
        document.getElementById("dataNull").style.display = "none";
        scriptList.forEach(function (item, idnex, array) {
            var data = item; 
            var _dom = document.createElement('div');
            let index = data.active ? 1 : 0;
            _dom.setAttribute('class', 'content-item ' + state[index]);
            _dom.setAttribute('uuid', data["uuid"]);
            _dom.setAttribute('author', data["author"]);
            _dom.innerHTML = scriptDomTmp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
            scriptStateListDom.appendChild(_dom);
        })
    }else{
        showNullData("未匹配到可用脚本");
    }
}

/**
 * 控制脚本是否运行
 * @param {string}  uuid         脚本id
 * @param {string}  active       脚本当前可执行状态
 */
function handleScriptActive(uuid, active) {
    if (uuid && uuid != "" && typeof uuid == "string") {
        browser.runtime.sendMessage({
            from: "popup",
            operate: "setScriptActive",
            uuid: uuid,
            active: !active
        }, (response) => {
            // todo 改变数据active状态
            scriptStateList.forEach(function (item, index) {
                if(uuid == item.uuid){
                    item.active = !active
                }
            })
            renderScriptContent(scriptStateList)
        })
    }
}


/**
 * tab切换点击事件
 * @param {object} target   被点击的元素
 * @param {number} type     1:match,2:console
 **/
function handleTabAction(target, type) {
    if (typeof type != "undefined" && type > 0) {
        document.getElementsByClassName("active-tab")[0].classList.remove("active-tab"); // 删除之前已选中tab的样式
        target.classList.add('active-tab'); // 给当前选中tab添加样式
        if(type == 1){
            // document.querySelector(".content-container .placeholder").innerHTML = "match tab8888888";
            scriptStateListDom.show();
            scriptConsoleDom.hide();
        }else{
            
            // document.querySelector(".content-container .placeholder").innerHTML = "console tab8888888";
            scriptStateListDom.hide();
            scriptConsoleDom.show();
            fetchMatchedScriptConsole()
        }
    }
}
