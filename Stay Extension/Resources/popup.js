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
}
Object.prototype.show = function () {
    this.style.display = "block"
}
Object.prototype.cleanInnerHTML = function () {
    this.innerHTML = "";
}
Object.prototype.setInnerHtml = function (value) {
    this.innerHTML = value
}
Object.prototype.html = function () {
    return this.innerHTML
}

let browserLangurage = "",
    registerMenuMap = {},
    i18nProp = null,
    browserRunUrl = "",
    scriptStateList = [],
    scriptStateListDom,
    registerMenuConDom,
    toastDom,
    noneMenuDom,
    logNotifyDom,
    scriptConsole = [],
    showLogNotify = false,
    logIsFetched = false,
    scriptConsoleDom,
    darkmodeProDom,
    scriptDomTmp = [
            '<div class="info-case">',
            '<div class="title"><img style="display:{showIcon}" src={icon} />{name}<span class="version">{version}</span><span>{status}</span></div>',
            '<div class="name">{author}</div>',
            '<div class="desc">{description}</div>',
            '</div>',
            '<div class="active-case" active={active} uuid={uuid} >',
            '<div class="active-setting" style="display:{showMenu}" manually={manually} active={active} uuid={uuid}></div>',
            '<div class="active-icon" installType={installType} active={active} uuid={uuid} ></div>',
            '<div class="active-manually" style="display:{showManually}" name={name} active={active} uuid={uuid}></div>',
            '</div>'].join(''),
    registerMenuItemTemp = [
        '<div class="menu-item" uuid={uuid} menu-id={id}>{caption}</div>'
    ].join(''),
    scriptState = ['start', 'stop', 'manually start'],
    scriptLogDomTmp = [
            '<div class="console-header">',
            '<div class="console-time">{time}</div>',
            '<div class="console-name">{name}</div>',
            '</div>',
            '<div class="console-con">{message}</div>'
            ].join(''),
    logState = {error:"error-log", log:""};

//https://stackoverflow.com/questions/26246601/wildcard-string-comparison-in-javascript
//Short code
function matchRule(str, rule) {
  var escapeRegex = (str) => str.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
  return new RegExp("^" + rule.split("*").map(escapeRegex).join(".*") + "$").test(str);
}

const matchesCheck = (userLibraryScript, url) => {
    let matched = false;
    let matchPatternInBlock;
    userLibraryScript.matches.forEach((match) => { //check matches
        let matchPattern = new window.MatchPattern(match);
        if (matchPattern.doMatch(url)) {
            matched = true;
            matchPatternInBlock = matchPattern;
        }
    });
    if (matched) {
        for (var i = 0; i < userLibraryScript.includes.length; i++){
            matched = matchRule(url, userLibraryScript.includes[i]);
            console.log("matchRule",url,userLibraryScript.includes[i],matched);
            if (matched) break;
        }
        
        for (var i = 0; i < userLibraryScript.excludes.length; i++){
            matched = !matchRule(url, userLibraryScript.excludes[i]);
            if (!matched) break;
        }
    }
    return matched;
}

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    if (request.from == "content" && request.operate == "giveRegisterMenuCommand") {
        let uuid = request.uuid;
        console.log("giveRegisterMenuCommand--request.data---", uuid, request.data)
        registerMenuMap[uuid] = request.data;
        let registerMenu = registerMenuMap[uuid]
        renderRegisterMenuContent(uuid, registerMenu)
    }
    return true;
});
/**
 * 获取当前网页可匹配的脚本
 */
function fetchMatchedScriptList(){
    browser.tabs.getSelected(null, (tab) => {
        browserRunUrl = tab.url;
        browser.runtime.sendMessage({ from: "bootstrap", operate: "fetchScripts", url: browserRunUrl, digest: "yes" }, (response) => {
            try{
                scriptStateList = response.body;
                renderScriptContent(scriptStateList);
                fetchMatchedScriptConsole();
            }catch(e){
                console.log(e);
            }
        });
    });
}

/**
 * 获取控制台日志并渲染
 */
function fetchAndRenderConsoleLog(){
    if (!logIsFetched){
        fetchMatchedScriptConsole()
    }
    renderScriptConsole(scriptConsole);
}

function fetchMatchedScriptConsole(){
    browser.runtime.sendMessage({ from: "popup", operate: "fetchLog" }, (response) => {
        console.log("fetchLog response----", response)
    })
    browser.runtime.sendMessage({ from: "popup", operate: "fetchMatchedScriptLog" }, (response) => {
        logIsFetched = true;
        console.log("fetchMatchedScriptLog response----", response)
        if (response && response.body && response.body.length > 0) {
            response.body.forEach(item => {
                if (item.logList && item.logList.length > 0) {
                    item.logList.forEach(logMsg => {
                        let logType = logMsg.msgType ? logMsg.msgType : "log"
                        let dateTime = logMsg && logMsg.time ? logMsg.time : ""
                        let data = {
                            uuid: item.uuid,
                            name: item.name,
                            time: dateTime,
                            //Fixed wrong variable logMsg.
                            msgType: logType,
                            message: logMsg.msg
                        };
                        scriptConsole.push(data)
                    })
                }
            })
            if (!showLogNotify && scriptConsole.length>0) {
                let count = scriptConsole.length
                let readCount = window.localStorage.getItem("console_count");
                readCount = readCount ? Number(readCount) : 0
                if (count - readCount > 0){
                    window.localStorage.setItem("console_count", count);
                    showLogNotify = true
                    logNotifyDom.show()
                    let showCount = count - readCount;
                    showCount = showCount > 99 ? "99+" : showCount
                    logNotifyDom.setInnerHtml(showCount)
                }
            }
        } else {
            scriptConsole = [];
        }
    })
}

/**
 * 匹配脚本为空的样式状态
 */
function showNullData(message){
    scriptStateListDom.hide()
    var _dom = document.getElementById("dataNull");
    _dom.setInnerHtml(message || i18nProp["null_scripts"]);
    _dom.show();
}

function languageCode() {
    let lang = (navigator.languages && navigator.languages.length > 0) ? navigator.languages[0]
        : (navigator.language || navigator.userLanguage /* IE */ || 'en');
    lang = lang.toLowerCase();
    lang = lang.replace(/-/, "_"); // some browsers report language as en-US instead of en_US
    if (lang.length > 3) {
        lang = lang.substring(0, 3) + lang.substring(3).toUpperCase();
    }
    if (lang == "zh_TW" || lang == "zh_MO"){
        lang = "zh_HK"
    }
    return lang;
}

window.onload=function(){
    browserLangurage = languageCode()
    toastDom = document.getElementById("toastWarpper")
    logNotifyDom = document.getElementById("logNotify")
    scriptStateListDom = document.getElementById('scriptSateList');
    scriptConsoleDom = document.getElementById('scriptConsole');
    darkmodeProDom = document.getElementById('darkmodePro');
    // load i18n properties
    i18nProp = langMessage[browserLangurage] || langMessage["en_US"]
    try {
        let i18nDataAttrs = document.querySelectorAll("[data-i18n]");
        i18nDataAttrs.forEach(item => {
            var htmlContent = item.html();
            var reg = /<(.*)>/;
            if (reg.test(htmlContent)) {
                var htmlValue = reg.exec(htmlContent)[0];
                item.setInnerHtml(htmlValue + i18nProp[item.dataset.i18n]);
            }
            else {
                item.setInnerHtml(i18nProp[item.dataset.i18n]);
            }
        })
        fetchMatchedScriptList()
        // 给header tab绑定事件
        document.querySelector(".header-box .header-tab").addEventListener("click", function (e) {
            let target = e.target;
            if (target) {
                let type = target.getAttribute("tab");
                handleTabAction(target, type);
            }
        })
        // 给scriptStateListDom添加监听器
        scriptStateListDom.addEventListener("click", function (e) {
            let target = e.target;
            // e.target是被点击的元素!
            // 筛选触发事件的子元素如果是active-case执行的事件
            if (target && target.nodeName.toLowerCase() == "div" && target.className.toLowerCase() == "active-icon") {
                // 获取到具体事件触发的active-case，进行active
                let active = target.getAttribute("active");
                let uuid = target.getAttribute("uuid");
                // "page" for inject, "content" for content box
                let installType = target.getAttribute("installType");
                handleScriptActive(uuid, active.bool(), installType);
                return;
            }
            if (target && target.nodeName.toLowerCase() == "div" && target.className.toLowerCase() == "active-manually") {
                // 获取到具体事件触发的active-case，进行active
                let uuid = target.getAttribute("uuid");
                let name = target.getAttribute("name");
                handleExecScriptManually(uuid, name);
                return;
            }
            // register menu click
            if (target && target.nodeName.toLowerCase() == "div" && target.className.toLowerCase() == "active-setting") {
                let uuid = target.getAttribute("uuid");
                let active = target.getAttribute("active");
                let manually = target.getAttribute("manually");
                if (active.bool() || manually === "1"){
                    handleScriptRegisterMenu(uuid);
                }else{
                    toastDom.setInnerHtml(i18nProp["toast_keep_active"])
                    toastDom.show();
                    setTimeout(() => {
                        toastDom.hide()
                    }, 1500);
                }
                return;
            }
        });
        document.getElementById("mainIcon").addEventListener("click", (e)=>{
            window.open("stay://");
        })
        document.querySelector("#registerMenuPopup .close").addEventListener("click", function (e) {
            closeMenuPopup(e)
        })
       
    }
    catch (err) {
        console.log("loadI18nProperties", err);
    }
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
        scriptConsoleDom.show()
        scriptLogList.forEach(item=> {
            let data = item
            let logType = data.msgType ? data.msgType : "log"
            var _dom = document.createElement('div');
            _dom.setAttribute('class', 'console-item ' + logState[logType]);
            _dom.setAttribute('uuid', data["uuid"]);
            _dom.innerHTML = scriptLogDomTmp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
            scriptConsoleDom.appendChild(_dom);
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
        scriptStateListDom.show()
        document.getElementById("dataNull").hide()
        scriptList.forEach(function (item, idnex, array) {
            var data = item; 
            let uuid = data["uuid"];
            let grants = data.grants
            let showMenu = grants && grants.length > 0 && (grants.includes("GM.registerMenuCommand") || grants.includes("GM_registerMenuCommand")) ? "block":"none"
            data.showMenu = showMenu
            data.showIcon = data.icon?"inline":"none";
            let index = item.active ? 1 : 0;
            data.status = item.active ? i18nProp["state_actived"] : i18nProp["state_stopped"];
            if (data.manually == "1"){
                if (!item.active){
                    data.status = i18nProp["state_manually"];
                    index = 2;
                }
            }else{
                data.manually = "0"
            }
            let showManually = !item.active ? "block":"none"
            data.showManually = showManually;
            var _dom = document.createElement('div');
            
            _dom.setAttribute('class', 'content-item ' + scriptState[index]);
            _dom.setAttribute('uuid', uuid);
            _dom.setAttribute('author', data["author"]);
            _dom.innerHTML = scriptDomTmp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
            scriptStateListDom.appendChild(_dom);
        })
    }else{
        showNullData(i18nProp["null_scripts"]);
    }
}

/**
 * open register menu
 * @param {string} uuid 
 */
function handleScriptRegisterMenu(uuid) {
    let registerMenuPopupDom = document.getElementById("registerMenuPopup");
    registerMenuPopupDom.style.display = "block";
    document.getElementById("registerMenuWarpper").className = "register-menu-warpper filter-form-show";
    registerMenuConDom = document.getElementById("registerMenuCon");
    noneMenuDom = document.getElementById("noneMenu");
    noneMenuDom.addEventListener("click", function (e) {
        closeMenuPopup(e)
    })
    browser.runtime.sendMessage({ from: "popup", uuid: uuid, operate: "fetchRegisterMenuCommand" });
    if (!uuid){
        registerMenuConDom.hide()
        noneMenuDom.show();
        return;
    }

}

/**
 * render register menu content when click current script
 * @param {Array}  datas   register menu datas
 * @param {string} uuid    script uuid
 */
function renderRegisterMenuContent(uuid, datas) {
    const menuItemList = datas;
    registerMenuConDom.cleanInnerHTML();
    if (menuItemList && menuItemList.length > 0) {
        noneMenuDom.hide()
        registerMenuConDom.show()
        menuItemList.forEach(function (item, idnex, array) {
            var data = item;
            data.uuid = uuid;
            var _dom = document.createElement('div');
            _dom.innerHTML = registerMenuItemTemp.replace(/(\{.+?\})/g, function ($1) { return data[$1.slice(1, $1.length - 1)] });
            registerMenuConDom.appendChild(_dom.childNodes[0]);
        })
        registerMenuConDom.addEventListener("click", function (e) {
            let target = e.target;
            if (target && target.nodeName.toLowerCase() == "div" && target.className.toLowerCase() == "menu-item"){
                let menuId = target.getAttribute("menu-id");
                let uuid = target.getAttribute("uuid");
                handleRegisterMenuClickAction(menuId, uuid)
            }
        })
    } else {
        noneMenuDom.show();
        registerMenuConDom.hide()
    }
}

/**
 * close popup of register menu
 * @param {object} e 
 */
function closeMenuPopup(e) {
    document.getElementById("registerMenuWarpper").className = "register-menu-warpper filter-form-hide";
    let registerMenuPopupDom = document.getElementById("registerMenuPopup");
    registerMenuPopupDom.style.display = "none";

    noneMenuDom.removeEventListener("click", function (params) { })
    registerMenuConDom.removeEventListener("click", function (params) {})
}

/**
 * click for register menu item
 * @param {string}     menuId
 * @param {string}     uuid
 */
function handleRegisterMenuClickAction(menuId, uuid) {
    console.log(menuId, uuid);
    browser.runtime.sendMessage({ from: "popup", operate: "execRegisterMenuCommand", id: menuId, uuid: uuid }, (res)=>{
        if (res.id && res.uuid){
            window.close();
        }
    });
    closeMenuPopup();
}

/**
 * 刷新页面
 * 当启动脚本时，调用
 */
function refreshTargetTabs() {
    browser.runtime.sendMessage({ from: "popup", operate: "refreshTargetTabs"});
}

/**
 * 控制脚本是否运行
 * @param {string}   uuid        脚本id
 * @param {boolean}  active      脚本当前可执行状态
 * @param {string}   installType        page/content
 */
function handleScriptActive(uuid, active, installType) {
    if (uuid && uuid != "" && typeof uuid == "string") {
        
        browser.runtime.sendMessage({
            from: "popup",
            operate: "setScriptActive",
            uuid: uuid,
            active: !active
        }, (response) => {
            console.log("setScriptActive response,",response)
        })
        refreshTargetTabs();
        // start run script or content mode to stop
        // if (!active || (active && installType === "content")) {
        //     refreshTargetTabs();
        // }
        // 改变数据active状态
        scriptStateList.forEach(function (item, index) {
            if(uuid == item.uuid){
                item.active = !active
                item.manually = "0";
            }
        })
        renderScriptContent(scriptStateList)
    }
}

/**
 * 控制脚本是否运行
 * @param {string}   uuid        脚本id
 */
function handleExecScriptManually(uuid, name) {
    if (uuid && uuid != "" && typeof uuid == "string") {
        browser.runtime.sendMessage({
            from: "popup",
            operate: "exeScriptManually",
            uuid: uuid,
        }, (response) => {
            console.log("exeScriptManually response,", response)
        });
        // 改变数据manually状态
        scriptStateList.forEach(function (item, index) {
            if (uuid == item.uuid) {
                item.manually = "1";
            }
        })
        renderScriptContent(scriptStateList)

        let timeout = 3000;
        let toastContainer = document.getElementById("toastContainer");
        document.querySelector("#toastContainer .title").setInnerHtml(name);
        toastContainer.style.display = "flex"
        toastContainer.className = "toast-container toast-show"
        var clearFlag = 0;
        clearFlag = window.setInterval(() => {
            autoClose();
        }, 500);

        function autoClose() {
            if (timeout > 0) {
                timeout = timeout - 500;
            } else {
                window.clearInterval(clearFlag);
                toastContainer.className = "toast-container toast-hide"
            }
        }
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
            scriptStateListDom.show();
            scriptConsoleDom.hide();
        }else{
            showLogNotify = false;
            logNotifyDom.hide()
            scriptStateListDom.hide();
            scriptConsoleDom.show();
            fetchAndRenderConsoleLog()
        }
    }
}
