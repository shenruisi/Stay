const COMPLETE = {status:"complete"};
const CONTINUE = {status:"continue"};
const CONTINUE_TIL = (count) => {
    return {status:"continue", til:count};
};
const QUIT = {status:"quit"};
const DATA = (data) => {
    return {status:"complete", data:data};
}

class Stay_Interval{
    constructor(tasks,millisec,maxLoop,execCount,resolve,reject,collect){
        this.tasks= tasks;
        this.millisec = millisec;
        this.maxLoop = maxLoop;
        this.resolve = resolve;
        this.reject = reject;
        this.collect = collect;
        this.execCount = execCount;
    }
    
    start(){
        var self = this;
        this.int = setInterval(function () { self.worker() },this.millisec)
    }
    
    worker(){
        if (this.execCount >= this.maxLoop){
            this.tasks.length = 0;
            this.resolve(this.collect.data());
            this.stop();
        };
        let taskCount = this.tasks.length;
        while(taskCount > 0){
            let task = this.tasks.shift();
            let ret = task();
            if (ret && ret.status == "quit"
                || ret.status == "complete"
                || (ret.status == "continue" && ret.til && ret.til == this.execCount)){
                this.collect.append(ret);
            }
            else{
                this.tasks.push(task);
            }
            taskCount--;
        }
        
        if (0 == this.tasks.length){
            this.resolve(this.collect.data());
            this.stop();
        }
        
        this.execCount = this.execCount + 1;
    }
    
    stop(){
        window.clearInterval(this.int);
    }
}

let myInterval;

class Stay_Collect{
    constructor(){
        this.dataList = [];
    }
    
    append(X){
        if (X.data != null){
            this.dataList.push(X.data);
        }
    }
    
    data(){
        return this.dataList;
    }
}


/**
 Inject
 */
class Stay_Inject{
    /**
     @function run
     @param tasks       Task list
     @param millisec    Interval
     @param maxLoop     The times of execute task function
     @param firstRun    Indicate if enforce once at first time
     */
    static run(tasks,millisec,maxLoop,firstRun){
        return new Promise(function(resolve,reject){
            let collect = new Stay_Collect();
            if (firstRun){
                let taskCount = tasks.length;
                while(taskCount > 0){
                    let task = tasks.shift();
                    let ret = task();
                    if (ret && ret.status == "quit"
                        || ret.status == "complete"
                        || (ret.status == "continue" && ret.til && ret.til == 1)){
                        collect.append(ret);
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
            myInterval = new Stay_Interval(tasks,
                         millisec,
                         firstRun ? maxLoop-1:maxLoop,
                         firstRun ? 1:0,
                         resolve,
                         reject,
                         collect);
            myInterval.start();
        });
    }
}

window.addEventListener('unload', function(event) {
    if (myInterval) myInterval.stop();
});


