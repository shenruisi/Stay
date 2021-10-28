const COMPLETE = {status:"complete"};
const CONTINUE = {status:"continue"};
const CONTINUE_TIL = (count) => {
    return {status:"continue", til:count};
};
const QUIT = {status:"quit"};

const $uri = (url) => {
    let a = document.createElement("a");
    a.href = url;
    return a;
}

const $getQueryVariable = (variable) => {
    var query = window.location.search.substring(1);
    var vars = query.split("&");
    for (var i=0;i<vars.length;i++) {
        var pair = vars[i].split("=");
        if(pair[0] == variable){return pair[1];}
    }
    return "";
}

const $getHeight = (e) => {
    return window.getComputedStyle(e).getPropertyValue('height');
}

const $res = (name) => {
    return browser.runtime.getURL(name);
}

const $noJumpUrl = (host,url) => {
    if (host == "tieba.baidu.com"){
        return $res('iframe.html')+"?url="+encodeURIComponent(url)+"&js=common.js,tieba-content.js";
    }
    else if (host == "zhuanlan.zhihu.com"){
        return "https://zhuanlan.zhihu.com/R_E_D_I_R_E_C_T/?url="+encodeURIComponent(url);
    }
    else if (host == "m.xiaohongshu.com"){
        return "https://m.xiaohongshu.com/R_E_D_I_R_E_C_T/?url="+encodeURIComponent(url);
    }
    else if (host == "m.bilibili.com" || host == "www.bilibili.com"){
        return  $res('iframe.html')+"?url="+encodeURIComponent(url);
    }
    
    return null;
}

const R_E_D_I_R_E_C_T_TEST = /R_E_D_I_R_E_C_T/
const ZHIHU_REG = /^(http|https):\/\/(.*\.){0,1}zhihu.com\/.*$/;
const TIEBA_REG = /^(http|https):\/\/tieba.baidu.com\/.*$/;
const XHS_REG = /^(http|https):\/\/m.xiaohongshu.com\/.*$/;
const BILIBILI_REG = /^(http|https):\/\/(.*\.){0,1}bilibili.com\/.*$/;

class Interval{
    constructor(tasks,millisec,maxLoop,execCount,resolve,reject,appContainer){
        this.tasks= tasks;
        this.millisec = millisec;
        this.maxLoop = maxLoop;
        this.resolve = resolve;
        this.reject = reject;
        this.appContainer = appContainer;
        this.execCount = execCount;
    }
    
    start(){
        var self = this;
        this.int = setInterval(function () { self.worker() },this.millisec)
    }
    
    worker(){
        if (this.execCount >= this.maxLoop){
            this.tasks.length = 0;
            this.resolve(this.appContainer.data());
            this.stop();
        };
        let taskCount = this.tasks.length;
        while(taskCount > 0){
            let task = this.tasks.shift();
            let ret = task();
            if (ret && ret.status == "quit"
                || ret.status == "complete"
                || (ret.status == "continue" && ret.til && ret.til == this.execCount)){
                this.appContainer.append(ret);
            }
            else{
                this.tasks.push(task);
            }
            taskCount--;
        }
        
        if (0 == this.tasks.length){
            this.resolve(this.appContainer.data());
            this.stop();
        }
        
        this.execCount = this.execCount + 1;
    }
    
    stop(){
        window.clearInterval(this.int);
    }
}

let myInterval;

/**
 Inject
 */
class Inject{
    /**
     @function run
     @param tasks       Task list
     @param millisec    Interval
     @param maxLoop     The times of execute task function
     @param firstRun    Indicate if enforce once at first time
     */
    static run(tasks,millisec,maxLoop,firstRun){
        return new Promise(function(resolve,reject){
            let appContainer = new AppContainer();
            if (firstRun){
                let taskCount = tasks.length;
                while(taskCount > 0){
                    let task = tasks.shift();
                    let ret = task();
                    if (ret && ret.status == "quit"
                        || ret.status == "complete"
                        || (ret.status == "continue" && ret.til && ret.til == 1)){
                        appContainer.append(ret);
                    }
                    else{
                        tasks.push(task);
                    }
                    taskCount--;
                }
            }
            if (0 == tasks.length){
                resolve(appContainer.data());
                return;
            }
            myInterval = new Interval(tasks,
                         millisec,
                         firstRun ? maxLoop-1:maxLoop,
                         firstRun ? 1:0,
                         resolve,
                         reject,
                         appContainer);
            myInterval.start();
        });
    }
}

window.addEventListener('unload', function(event) {
    if (myInterval) myInterval.stop();
});

class App{
    constructor(){
        this.map = {status:"complete",type:"app"};
    }
    
    id(id){
        this.map.id = id;
        return this;
    }
    
    title(title){
        this.map.title = title;
        return this;
    }
    
    icon(icon){
        this.map.icon = icon;
        return this;
    }
    
    url(url){
        this.map.url = url;
        return this;
    }
    
    data(){
        return this.map;
    }
}

class AppContainer{
    constructor(){
        this.appJumpList = [];
    }
    
    append(appDataMap){
        if (appDataMap.type == "app"){
            var exist = false;
            for (var i = 0; i < this.appJumpList.length; i++){
                var app = this.appJumpList[i];
                if (app.id == appDataMap.id){
                    exist = true;
                    break;
                }
            }
            this.appJumpList.push(appDataMap);
        }
    }
    
    data(){
        return this.appJumpList;
    }
}


