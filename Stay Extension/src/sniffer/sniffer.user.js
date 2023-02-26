/**
 * 解析页面video标签
 */
let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function () {
  let isContent = false;
  try {
    handleInjectScript();
    document.addEventListener('securitypolicyviolation', (e) => {
      // console.log('securitypolicyviolation--------', isContent)
      isContent = true;
      injectParseVideoJS(isContent);
    })
  } catch (error) {
  }
  
  function handleInjectScript(){
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let contentHost = window.location.host;
    let scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.id = 'stay_inject_parse_video_js_'+contentHost;
    let injectJSContent = `\n\nlet handleVideoInfo = ${injectParseVideoJS}\n\nhandleVideoInfo(false);`;
    scriptTag.appendChild(document.createTextNode(injectJSContent));
    // console.log('document.body--------------------------',document.body)
    if (document.body) {
      // console.log('document.body--------------------------')
      document.body.appendChild(scriptTag);
    } else {
      // console.log('else-----------------document.body--------------------------');
      let observerBody = new MutationObserver((mutations, observer) => {
        // console.log('---------mutations-------',mutations);
        // console.log('---------observer---------',observer);
        if (document.body) {
          // console.log('document.body---------gogogogogogogogogogo-----------------');
          document.body.appendChild(scriptTag);
          observerBody.disconnect();
        }
      });
      observerBody.observe(document.documentElement, { attributes: true, childList: true, characterData: true, subtree: true });
    }
  }


  function injectParseVideoJS(isContent){
    let hostUrl = window.location.href;
    let host = window.location.host;
    // console.log('------------injectParseVideoJS-----start------------------')
    let videoList = [];
    // 获取到的videoId 集合
    let videoIdSet = new Set();
    // Firefox和Chrome早期版本中带有前缀  
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let videoDoms;  
    let timerArr = [];

    const Utils = {
      isMobile: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        return getArr.length ? true : false;
      },
      queryURLParams: function(url, name) {
        const pattern = new RegExp('[?&#]+' + name + '=([^?&#]+)');
        const res = pattern.exec(url);
        if (!res) return '';
        if (!res[1]) return '';
        return res[1];
      },
      matchUrlInString: function(imgText){
        const urlReg = new RegExp('(https?|http)?(:)?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]', 'g');
        const imgMatchs = imgText.match(urlReg);
        //   poster = imgMatchs && imgMatchs.length ? imgMatchs[0] : '';
        if(imgMatchs && imgMatchs.length){
          return imgMatchs[0];
        }
        return '';
      },
      isURL: function(s) {
        if(!s){
          return false;
        }
        return /^http[s]?:\/\/.*/.test(s);
      },
      completionSourceUrl: function(downloadUrl){
        if(!downloadUrl){
          return '';
        }
        if(!/^(f|ht)tps?:\/\//i.test(downloadUrl)){
          if(/^\/\//i.test(downloadUrl)){
            downloadUrl = window.location.protocol+downloadUrl;
          }else{
            downloadUrl = window.location.origin+downloadUrl;
          }
        }
        return downloadUrl;
      },
      checkCharLengthAndSubStr: function(text, len=80){
        if(!text){
          return '';
        }
        let textTemp = text.replace(/[^x00-xff]/g, '01');
        if(textTemp.length <= len){
          return text;
        }else{
          return text.substr(0, len);
        }
      },
      getUrlPathName: function(srcUrl){
        let pathName = '';
        if(this.isURL(srcUrl)){
          pathName = new URL(srcUrl).pathname;
        }else{
          pathName = new URL(hostUrl).pathname;
        }
        let pathArr = pathName.split('/');
        pathArr = pathArr.filter(item=>{if(item&&item!=''){return item}});
        return pathArr.pop();
      },
      generateUuid: function(len, radix) {
        len = len || 32;
        let chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'.split('');
        let uuid = [], i;
        radix = radix || chars.length;
     
        if (len) {
          // Compact form
          for (i = 0; i < len; i++) uuid[i] = chars[0 | Math.random() * radix];
        } else {
          // rfc4122, version 4 form
          let r;
     
          // rfc4122 requires these characters
          uuid[8] = uuid[13] = uuid[18] = uuid[23] = '_';
          uuid[14] = '4';
     
          // Fill in random data.  At i==19 set the high bits of clock sequence as
          // per rfc4122, sec. 4.1.5
          for (i = 0; i < 36; i++) {
            if (!uuid[i]) {
              r = 0 | Math.random() * 16;
              uuid[i] = chars[(i == 19) ? (r & 0x3) | 0x8 : r];
            }
          }
        }
        return uuid.join('');
      },
      isBase64(str){
        if(!str){
          return false;
        }
        if(/^data:.*\w+;base64,/.test(str)){
          return true;
        }
        if(str === '' || str.trim() === ''){
          return false;
        }
        try{
          return window.btoa(window.atob(str)) == str;
        }catch(err){
          return false;
        }
      },
      isDark() {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
      },
      parseToDOM(str){
        let divDom = document.createElement('template');
        if(typeof str == 'string'){
          divDom.innerHTML = str;
          return divDom.content;
        }
        return str;
      },
      getHostname(url) {
        if(!url){
          return ''
        }
        try {
          return new URL(url).hostname.toLowerCase();
        } catch (error) {
          return url.split('/')[0].toLowerCase();
        }
      },
      div(a, b) {
        let c, d, e = 0,
          f = 0;
        try {
          e = a.toString().split('.')[1].length;
        } catch (g) {
          e = 0;
        }
        try {
          f = b.toString().split('.')[1].length;
        } catch (g) {
          f = 0;
        }
        c = Number(a.toString().replace('.', ''));
        d = Number(b.toString().replace('.', ''));
        return this.mul(c / d, Math.pow(10, f - e));
      },
      sub(a, b) {
        let c, d, e;
        try {
          c = a.toString().split('.')[1].length;
        } catch (f) {
          c = 0;
        }
        try {
          d = b.toString().split('.')[1].length;
        } catch (f) {
          d = 0;
        }
        e = Math.pow(10, Math.max(c, d));
        return (this.mul(a, e) - this.mul(b, e)) / e;
      },
      mul(a,b){
        let c = 0,
          d = a.toString(),
          e = b.toString();
        try {
          c += d.split('.')[1].length;
        } catch (f) {}
        try {
          c += e.split('.')[1].length;
        } catch (f) {}
        return Number(d.replace('.', '')) * Number(e.replace('.', '')) / Math.pow(10, c);  
      },
      add(a,b){
        let c, d, e;
        try {
          c = a.toString().split('.')[1].length;
        } catch (f) {
          c = 0;
        }
        try {
          d = b.toString().split('.')[1].length;
        } catch (f) {
          d = 0;
        }
        e = Math.pow(10, Math.max(c, d));
        return  (this.mul(a, e) + this.mul(b, e)) / e;
      }
    }

    /**
     * 长按功能，长按 700ms 以上即可调用回调方法
     *
     * @class
     */
    class LongPress {
      /**
       * 构造器
       *
       * @public
       * @param {String} dom 需要长按的 DOM 对象
       * @param {function} callback 长按触发的回调函数
       */
      constructor(dom, callback) {
        this.dom = dom;
        this.timer = 0;
        this.init(callback);
      }

      /**
       * 初始化
       *
       * @private
       
       */
      init(callback) {
        this.touchstart(callback);
        this.touchend();
        this.touchmove();
        this.bindLongPressEventFlag();
      }

      /**
       * 标记是否绑定过长按事件
       */
      bindLongPressEventFlag(){
        this.dom.setAttribute('stay-long-press', 'yes');
        // this.dom.eventList['stayLongPress'] = 'yes';
      }

      /**
       * 手指按下时开启定时器，700 毫秒后触发回调函数
       *
       * @private
       * @param {function} callback 回调函数
       */
      touchstart(callback) {
        const self = this;
        self.dom.removeEventListener('touchstart', function(event) {
          // event.preventDefault();
          // event.stopPropagation();
          self.handleLongPress(event, callback);
        })

        self.dom.addEventListener('touchstart', function(event) {
          // console.log('this.dom----touchstart-----',event)
          self.handleTargetTouchend(event.target);
          self.timer = setTimeout((e, fun) => {
            self.handleLongPress(e, fun);
          }, 600, event, callback);
          return false;
        }, false);

      }

      handleTargetTouchend(target){
        const self = this;
        if(!target){
          return;
        }
        
        target.addEventListener('touchend', (event)=>{
          // clearTimeout(self.timer);
          self.handleTouchend(event, target);
        })
      }

      handleLongPress(event, callback){
        event.preventDefault();
        event.stopPropagation();
        if(isHidden(this.dom)){
          return;
        }
        let target = event.changedTouches[0];
        try {
          // target.target.click();
          target.target.addEventListener('contextmenu', function(e){
            e.preventDefault();
          });
        } catch (error) {
          
        }
        // 开启定时器
        if (typeof callback === 'function') {
          callback();
          this.timer = 0;
        } else {
          console.error('callback is not a function!');
        }
        
      }
      /**
       * 手指抬起时清除定时器，无论按住时间是否达到 700 毫秒的阈值
       *
       * @private
       */
      touchend() {
        const self = this;
        self.dom.removeEventListener('touchend', function(event) {
          self.handleTouchend(event, null)
        });
        self.dom.addEventListener('touchend', function(event) {
          self.handleTouchend(event, null);
          return false;
        });
      }

      handleTouchend(event, isTarget){
        const self = this;
        // console.log('this.dom----handleTouchend-----isTarget', isTarget, event);
        if(isHidden(this.dom)){
          return;
        }
        event.stopPropagation();
        // 清除定时器
        clearTimeout(this.timer);
        if(this.timer!=0){
          try {
            if(isTarget){
              isTarget.removeEventListener('touchend', (event)=>{
                clearTimeout(self.timer);
              })
            }
          } catch (error) {
            
          }
        }
      }

      /**
       * 如果手指有移动，则取消所有事件，此时说明用户只是要移动而不是长按
       */
      touchmove() {
        const self = this;
        self.dom.removeEventListener('touchmove', function(event){
          // event.preventDefault();
          handleTouchmove(event);
        })
        self.dom.addEventListener('touchmove', function(event){
          // console.log('this.dom-----touchmove-------',event);
          // event.preventDefault();
          handleTouchmove(event);
          return false;
        })
        function handleTouchmove(event){
          if(isHidden(self.dom)){
            return;
          }
          clearTimeout(self.timer);//清除定时器
          self.timer = 0;
        }
      }
    }

    function isHidden(el) {
      if(!el){
        return true;
      }
      let style = window.getComputedStyle(el);//el即DOM元素
      if(!style){
        return false;
      }
      return (style.display === 'none' || style.visibility === 'hidden') 
    }
    /**
     * 判断当前target是否是显示的video或video所在位置的dom
     * 1、判断当前target是否是video标签
     * 2、是video标签，在判断是否有src,或者childNodes是否有Source标签及其src信息，再判断
     * 3、不是video标签
     *    3.1、判断该target是否展示，展示则true, 不展示则false;
     *    3.2、document.querySelectorAll('video'); ，没有则false,有再判断是否有src及childNodes是否有Source内容，空则false
     * @param {*} target 
     * @returns 
     */
    function checkTargetIfShowOnScreen(target){
      if(!target){
        return true;
      }




      return true;

    }

    /**
     * 长按功能，长按 700ms 以上即可调用回调方法
     *
     * @class
     */
    class DocumentLongPress {
      /**
       * 构造器
       *
       * @public
       * @param {String} dom 需要长按的 DOM 对象
       * @param {function} callback 长按触发的回调函数
       */
      constructor(dom, callback) {
        this.dom = dom;
        // this.startTime = 0; // 触摸起始时间
        // this.endTime = 0; // 触摸终止时间
        this.stayLongPressTimer = 0; 
        this.distance = 10; // 触摸距离值
        this.init(callback);
      }

      getDomPageStartX(){
        return this.dom.getBoundingClientRect().left;
      }

      getDomPageStartY(){
        return (document.documentElement.scrollTop || window.pageYOffset) + this.dom.getBoundingClientRect().top;
      }

      getDomPageEndX(){
        return this.getDomPageStartX() + this.dom.clientWidth;
      }

      getDomPageEndY(){
        return this.getDomPageStartY() + this.dom.clientHeight;
      }

      /**
       * 初始化
       *
       * @private
       */
      init(callback) {
        this.touchstart(callback);
        this.touchend();
        this.touchmove();
        this.bindLongPressEventFlag();
      }

      /**
       * 标记是否绑定过长按事件
       */
      bindLongPressEventFlag(){
        this.dom.setAttribute('stay-long-press', 'yes');
        // this.dom.eventList['stayLongPress'] = 'yes';
      }

      /**
       * 手指按下时开启定时器，700 毫秒后触发回调函数
       *
       * @private
       * @param {function} callback 回调函数
       */
      touchstart(callback) {
        const self = this;
        document.body.removeEventListener('touchstart', function(event){
          // event.preventDefault();
          // event.stopPropagation();
          self.handleTargetEvent(event, callback);
          return false;
        });
        document.body.addEventListener('touchstart', function(event) {
          console.log('touchstart-------',event);
          // event.preventDefault();
          // event.stopPropagation();
          self.handleTargetTouchend(event.target);
          self.handleTargetEvent(event, callback);
          return false;
        }, false);
      }

      handleTargetTouchend(target){
        const self = this;
        if(!target){
          return;
        }
        // target.stopPropagation();
        // target.stopPropagation();
        target.addEventListener('touchend', (event)=>{
          // event.stopPropagation();
          self.touchEndCallback(event, target);
          // clearTimeout(self.stayLongPressTimer);
        })
      }

      handleTargetEvent(event, callback){
        event.stopPropagation();
        event.preventDefault();
        const self = this;
        let target = event.changedTouches[0];
        const targetPageX = target.pageX;
        const targetPageY = target.pageY;
        // console.log('targetPageX=',targetPageX,',targetPageY=',targetPageY,'this.domPageStartX=',self.getDomPageStartX(), 'this.domPageStartY=',self.getDomPageStartY() ,'this.domPageEndX=',self.getDomPageEndX(),',this.domPageEndY=',self.getDomPageEndY());
        if(!isHidden(self.dom) && Math.abs(target.pageX - targetPageX) <= self.distance &&
        targetPageX >= self.getDomPageStartX() && targetPageX <= self.getDomPageEndX() && 
        targetPageY >= self.getDomPageStartY() && targetPageY <= self.getDomPageEndY()){
          // console.log('start-------', new Date().getTime());
          // event.stopPropagation();
          // event.preventDefault();
          this.stayLongPressTimer = window.setTimeout((curTarget, fun) => {
            self.stayLongPressTimer = 0;
            try {
              let classList = curTarget.target.classList;
              // console.log('start----------event----',event);
              if(!classList.contains('__stay-unselect')){
                classList.add('__stay-unselect')
              }
              if(!classList.contains('__stay-touch-action')){
                classList.add('__stay-touch-action');
              }
              // console.log('end-------', new Date().getTime());
              if (typeof fun === 'function') {
                fun();
              } else {
                console.error('callback is not a function!');
              }
              // curTarget.target.click();
              curTarget.target.addEventListener('contextmenu', function(e){
                e.preventDefault();
              });
            } catch (error) {
              
            }
          }, 600, target, callback);
          // console.log('end.end-------', new Date().getTime());
        }
      }

      /**
       * 手指抬起时清除定时器，无论按住时间是否达到 600 毫秒的阈值
       *
       * @private
       */
      touchend() {
        // console.log('handle------touchend---' );
        const self = this;
        document.body.removeEventListener('touchend', function(event){
          // event.stopPropagation();
          self.touchEndCallback(event, null);
          // return false;
        })
        document.body.addEventListener('touchend', function(event) {
          // event.stopPropagation();
          // event.preventDefault();
          // console.log('touchend-------',event);
          self.touchEndCallback(event, null)
          return false;
        });
      }


      touchEndCallback(event, isTarget){
        const self = this;
        // event.preventDefault();
        event.stopPropagation();
        if(isHidden(this.dom)){
          return;
        }
        // console.log('touchEndCallback----event------isTarget-', isTarget, event);
        // 清除定时器
        clearTimeout(this.stayLongPressTimer);
        if(this.stayLongPressTimer!=0){
          try {
            let target = event.changedTouches[0];
            if(isTarget){
              isTarget.removeEventListener('touchend', (event)=>{
                // clearTimeout(this.stayLongPressTimer);
                self.touchEndCallback(event, null)
              })
            }
            // event.target.preventDefault();
            // event.target.stopPropagation();
            // target.target.click();
          } catch (error) {
            
          }
        }
      }

      /**
       * 如果手指有移动，则取消所有事件，此时说明用户只是要移动而不是长按
       */
      touchmove() {
        const self = this;
        document.body.removeEventListener('touchmove', function(event){
          event.preventDefault();
          event.stopPropagation();
          touchmoveCallback();
        });
        document.body.addEventListener('touchmove', function(event){
          // console.log('touchmove-------',event);
          event.preventDefault();
          event.stopPropagation();
          touchmoveCallback();
          return false;
        })
        function touchmoveCallback(){
          if(isHidden(self.dom)){
            return;
          }
          window.clearTimeout(self.stayLongPressTimer);//清除定时器
          self.stayLongPressTimer = 0;
          return false;
        }
      }


    }

    function startFindVideoInfo(completed){
      observerVideo();
      // console.log('---------------startFindVideoInfo---------------')
      videoDoms = document.querySelectorAll('video');  
      // console.log('startFindVideoInfo---------videoDoms------',videoDoms)
      // let flag = false;
      let flag = videoDoms && videoDoms.length;
      if(!flag){
        videoDoms = document.querySelectorAll('.post-content shreddit-player');
        flag = videoDoms && videoDoms.length;
      }
      if(flag){
        // console.log('videoDoms---false-----',videoDoms)
        parseVideoNodeList(videoDoms);
      }else{
        parseVideoNodeList();
        // console.log('else-------else------',isContent)
        if(completed){
          afterCompleteQueryVideo()
        }
      }
      
    }

    function afterCompleteQueryVideo(){
      for(let i=1; i<10; i++){
        let timer
        (function(i){
          timer = setTimeout(()=>{
            videoDoms = document.querySelectorAll('video');  
            // console.log('startFindVideoInfo------i-----',i, new Date().getTime());
            let flag = videoDoms && videoDoms.length;
            if(flag){
              parseVideoNodeList(videoDoms);
              // console.log('startFindVideoInfo---iiiiiii---break-----');
              timerArr.forEach(timerItem=>{
                // console.log('clearTimer---------timerItem-----',timerItem);
                clearTimeout(timerItem);
              })
            }
          },i*200);
        })(i)
        timerArr.push(timer);
      }
    }

    function observerVideo(){
      // console.log('observerVideo-------------');
      // 创建观察者对象  
      const observer = new MutationObserver(function(mutations) {  
        // console.log('----------------MutationObserver---------------',mutations)
        try{
          mutations.forEach(function(mutation) {  
            // todo
            host = window.location.host;
            videoDoms = document.querySelectorAll('video');
            const mutationDoms = mutation.target.querySelectorAll('video');
            if(('VIDEO' === mutation.target.nodeName || (mutationDoms && mutationDoms.length)) && videoDoms && videoDoms.length){
              // console.log('mutation.videoDoms-----',videoDoms)
              // throw new Error('endloop');
              parseVideoNodeList(videoDoms);
            }
          });  
        } catch (e) {
          // if(e.message === 'endloop') {
          //   // 随后,你还可以停止观察  
          //   // observer.disconnect(); 
          // }else{
          //   throw e
          // }
        }
      });
        /**
       * 配置观察选项: 
       * attributes: 设为 true 以观察受监视元素的属性值变更。
       * characterData: 设为 true 以监视指定目标节点或子节点树中节点所包含的字符数据的变化。
       * childList: 设为 true 以监视目标节点（如果 subtree 为 true，则包含子孙节点）添加或删除新的子节点。
       * subtree: 目标节点所有后代节点的attributes、childList、characterData变化
       */
      const config = { attributes: true, childList: true, characterData: true, subtree: true }  
      // 传入目标节点和观察选项  
      observer.observe(document, config);  
    }
    
    function parseVideoNodeList(videoDoms){
      // console.log('parseVideoNodeList-----------------start------------------', videoDoms)
      if(videoDoms && videoDoms.length){
        let videoCount = videoDoms.length
        let nullCount = 0;
        let videoNodeList = Array.from(videoDoms)
        videoNodeList.forEach(item => {
          if(!item || !(item instanceof HTMLElement)){
            nullCount++;
            return;
          }
          let videoUuid = item.getAttribute('stay-sniffing');
          if(!videoUuid){
            videoUuid = Utils.generateUuid();
            item.setAttribute('stay-sniffing', videoUuid);
          }
          const videoDom = item;
          let downloadUrl = item.getAttribute('src');
          // console.log('parseVideoNodeList-------1-------downloadUrl=',downloadUrl);
          if(!downloadUrl){
            // console.log('parseVideoNodeList--------2------downloadUrl=',downloadUrl);
            let sourceDom = item.querySelector('source');
            // console.log('parseVideoNodeList--------------sourceDom=',sourceDom);
            if(sourceDom){
              item = sourceDom;
              downloadUrl = sourceDom.getAttribute('src');
              // console.log('parseVideoNodeList--------------sourceDom.downloadUrl=',downloadUrl);
            }
          }
          if(!downloadUrl){
            nullCount++;
            // console.log('parseVideoNodeList--------nullCount++');
            return;
          }
          // todo fetch other scenarios
          let videoInfo = handleVideoInfoParse(item, videoDom, videoUuid);
          // console.log('parseVideoNodeList------videoInfo---------',videoInfo)
          if(!videoInfo.downloadUrl){
            nullCount++;
            return;
          }
          // console.log('parseVideoNodeList------videoList---------',videoList)
          // 已存在
          // videoKey downloadUrl,poster,title,hostUrl,qualityList, videoUuid
          // console.log('parseVideoNodeList------videoList--2222-------',videoList)
        })
        if(nullCount == videoCount){
          setTimeoutParseVideoInfoByWindow();
        }
      }else{
        // console.log('start------parseVideoInfoByWindow--------');
        setTimeoutParseVideoInfoByWindow();
      }
      // console.log('parseVideoNodeList-----------result---------',videoList);
      // window.webkit.messageHandlers.stayapp.postMessage(videoList);
      window.postMessage({name: 'VIDEO_INFO_CAPTURE', videoList: videoList});
      if(isContent){
        // console.log('isContent----------------------');
        let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoInfoList: videoList};
        browser.runtime.sendMessage(message, (response) => {});
      }
    }

    /**
     * check video if exist
     * @param {Object} videoDom  视频截图 
     * @param {Object} posDom    添加长按事件的dom对象 
     * @param {Object} videoInfo 
     */
    function checkVideoExist(videoDom, posDom, videoInfo){
      let downloadUrl = videoInfo.downloadUrl;
      if(!Utils.isURL(downloadUrl)){
        videoInfo.downloadUrl = hostUrl;
      }
      videoInfo.downloadUrl = window.encodeURI(videoInfo.downloadUrl);
      addLongPress(videoDom, posDom, videoInfo);
      if(videoIdSet.size && (videoIdSet.has(videoInfo.videoUuid) || videoIdSet.has(videoInfo.videoKey))){
        // console.log('parseVideoNodeList----------has exist, and modify-------',videoInfo, videoList);
        videoList.forEach(item=>{
          if(item.videoUuid == videoInfo.videoUuid || item.videoUuid == videoInfo.videoKey){
            item.downloadUrl = videoInfo.downloadUrl;
            item.poster = videoInfo.poster?videoInfo.poster:'';
            item.title = videoInfo.title
            item.hostUrl = videoInfo.hostUrl
            item.qualityList = videoInfo.qualityList?videoInfo.qualityList:[];
            // console.log('checkVideoExist----------item===',item);
          }
          return item;
        })
        // console.log('parseVideoNodeList------videoList---modify------',videoList)
      }else{
        // console.log('parseVideoNodeList----------has not, and push-------',videoInfo);
        if(videoInfo.videoKey){
          videoIdSet.add(videoInfo.videoKey);
          if(!videoInfo.videoUuid){
            videoInfo.videoUuid = videoInfo.videoKey;
          }
        }
        if(videoInfo.videoUuid){
          videoIdSet.add(videoInfo.videoUuid);
        }
        // console.log('checkVideoExist----------',videoInfo, videoIdSet);
        videoList.push(videoInfo);
      }
    }

    /**
     * 添加长按事件
     * @param {Object} videoDom   视频video dom对象
     * @param {Object} posDom     视频区域
     * @param {Object} videoInfo  视频信息
     * @returns 
     */
    async function addLongPress(videoDom, posDom, videoInfo){
      // console.log('----addLongPress-----start------')
      if(!posDom){
        // console.log('----posDomposDomposDomposDomposDom-----null')
        return;
      }
      // console.log('----getStayAround-----start------')
      const isStayAround = await getStayAround();
      // console.log('----isStayAround-----',isStayAround)
      if(isStayAround!='a'){
        return;
      }

      if(!Utils.isMobile()){
        return;
      }
      // console.log('addLongPress-------------',videoDom, posDom, videoInfo)
      let stayLongPress = posDom.getAttribute('stay-long-press');
      if(stayLongPress && stayLongPress == 'yes'){
        // console.log('addLongPress already bind stay long press------1------');
        return;
      }
      const sinfferUnselectDom = document.querySelector('#__style_sinffer_unselect');
      if(!sinfferUnselectDom){
        let sinfferUnselect=`<style id="__style_sinffer_unselect">
          .__stay-unselect, video{
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            -webkit-touch-callout: none;
          }
          .__stay-touch-action{
            touch-action: none!important;
          }
        </style>`;
        document.body.append(Utils.parseToDOM(sinfferUnselect));
      }
      posDom.classList.add('__stay-unselect');
      posDom.classList.add('__stay-touch-action');

      const hostUrl = videoInfo.hostUrl;
      // console.log('addLongPress--------hostUrl=====',hostUrl)
      if(hostUrl.indexOf('youtube.com')>-1){
        const playerOverlay = document.querySelector('#player-control-overlay');
        if(playerOverlay){
          if(!playerOverlay.classList.contains('__stay-touch-action')){
            playerOverlay.classList.add('__stay-touch-action');
          }
          if(!playerOverlay.classList.contains('__stay-unselect')){
            playerOverlay.classList.add('__stay-unselect');
          }
        }
        const playerBg = document.querySelector('#player-control-overlay .player-controls-background-container .player-controls-background');
        if(playerBg){
          if(!playerBg.classList.contains('__stay-touch-action')){
            playerBg.classList.add('__stay-touch-action');
          }
          if(!playerBg.classList.contains('__stay-unselect')){
            playerBg.classList.add('__stay-unselect');
          }
        }
        // console.log('addLongPress--------LongPress=====',hostUrl)
        new LongPress(posDom, ()=>{
          addSinfferModal(videoDom, posDom, videoInfo);
        })
      }
      else if(hostUrl.indexOf('mobile.twitter.com')>-1){
        // console.log('----------------mobile.twitter.com-----', posDom);
        // new LongPress(posDom, ()=>{
        //   addSinfferModal(videoDom, posDom, videoInfo);
        // })
      }
      else if(hostUrl.indexOf('pornhub.com')>-1){
        // if(!dom){
        //   dom = document.querySelector('#videoShow #videoPlayerPlaceholder .mgp_videoWrapper video');
        // }
        // if(!dom){
        //   dom = document.querySelector('#videoShow #videoPlayerPlaceholder .mgp_videoWrapper');
        // }
        if(posDom){
          if(!posDom.classList.contains('__stay-touch-action')){
            posDom.classList.add('__stay-touch-action');
          }
          if(!posDom.classList.contains('__stay-unselect')){
            posDom.classList.add('__stay-unselect');
          }
        }
        new LongPress(posDom, ()=>{
          addSinfferModal(videoDom, posDom, videoInfo);
        })
      }
      
      new DocumentLongPress(posDom, ()=>{
        addSinfferModal(videoDom, posDom, videoInfo);
      });
      
    }

    function getStayAround(){
      return new Promise((resolve, reject) => {
        if(isContent){
          // console.log('getStayAround-----true');
          browser.runtime.sendMessage({from: 'sniffer', operate: 'GET_STAY_AROUND'}, (response) => {
            // console.log('GET_STAY_AROUND---------',response)
            if(response.body && JSON.stringify(response.body)!='{}'){
              let isStayAround = response.body;
              // console.log('isStayAround---------',isStayAround)
              resolve(isStayAround);
            // window.localStorage.setItem('SINFFER_FETCH_STAY_SETTING', JSON.stringify(darkmodeSetting));
            }
          });
        }else{
          // console.log('getStayAround-----false');
          const pid = Math.random().toString(36).substring(1, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'RESP_GET_STAY_AROUND') return;
            // console.log('RESP_GET_STAY_AROUND----response=', e.data);
            let isStayAround = e.data ? (e.data.response ? e.data.response.body : {}): 'b';
            // console.log('RESP_GET_STAY_AROUND----isStayAround=', isStayAround);
            resolve(isStayAround);
            window.removeEventListener('message', callback);
          };
          window.addEventListener('message', callback);
          window.postMessage({ pid: pid, name: 'GET_STAY_AROUND' });
        }
      })
    }

    /**
     * 添加长按事件
     * @param {Object} videoDom   视频video dom对象   用于截图,视频播放/暂停判断
     * @param {Object} posDom     视频区域            用于绑定长按事件
     * @param {Object} videoInfo  视频信息            用于popup信息展示
     * @returns 
     */
    function addSinfferModal(videoDom, posDom, videoInfo){
      let vWidth = posDom.clientWidth;
      let vHeight = posDom.clientHeight;
      let bodyClientHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight;
      let bodyClientWidth = window.innerWidth || document.documentElement.innerWidth || document.body.innerWidth;
      let top = posDom.getBoundingClientRect().top;
      let left = posDom.getBoundingClientRect().left;
      // console.log('videoDom.tagName====',videoDom.tagName)
      if('VIDEO' == posDom.tagName){
        // console.log('videoDom.parentNode====',videoDom.parentNode)
        top = posDom.parentNode.getBoundingClientRect().top;
        left = posDom.parentNode.getBoundingClientRect().left;
      }
      left = 10;
      // 算出16:9的宽高
      let posterWidth = bodyClientWidth;
      let posterHeight = Utils.div(Utils.mul(posterWidth, 9), 16);
      if(vHeight<Utils.div(bodyClientHeight, 2)){
        posterHeight = vHeight;
      }
      // console.log('vWidth:',vWidth,',vHeight:',vHeight, ',posterHeight:', posterHeight, ',top:',top);

      let modalDom = document.querySelector('#__stay_sinffer_modal');
      if(!modalDom){
        modalDom = createModal();
      }
      modalDom.style.visibility = 'visible';
      const popupDom = document.querySelector('#__stay_sinffer_modal ._stay-sinffer-popup');
      const modalContent = document.querySelector('#__stay_sinffer_modal .__stay-sinffer-content');
      modalContent.classList.add('__stay-trans');

      setTimeout(function(){
        modalDom.classList.add('__stay-show-modal');
        popupDom.style.visibility = 'visible';
      }, 400)


      // window.open(downloadUrl);
      function createModal(){
        let list = [{title:videoInfo.title, downloadUrl: videoInfo.downloadUrl, poster: videoInfo.poster, hostUrl: Utils.getHostname(videoInfo.hostUrl), uuid: ''}];
        let downloadUrl = 'stay://x-callback-url/snifferVideo?list='+encodeURIComponent(JSON.stringify(list));
        let downloadBg = 'background-color: rgb(247,247,247);';
        let downloadColor = 'rgb(54, 54, 57)';
        let lineColor = '#E0E0E0';
        let bg = 'background-color: rgba(0, 0, 0, 0.4);';
        let posterbg = 'background-color: rgba(255, 255, 255, 1);';
        let fontColor = 'color:#000000;'
        let downloadIcon = isContent?browser.runtime.getURL('img/popup-download-light.png'):'https://res.stayfork.app/scripts/8DF5C8391ED58046174D714911AD015E/icon.png';
        if(Utils.isDark()){
          // bg = 'background-color: rgba(0, 0, 0, 0.4);';
          posterbg = 'background-color: rgba(0, 0, 0, 1);';
          fontColor = 'color:#DCDCDC;'
          downloadBg = 'background-color: rgb(54, 54, 57);';
          downloadIcon = isContent?browser.runtime.getURL('img/popup-download-dark.png'):'https://res.stayfork.app/scripts/CFFCD2186E164262E0E776A545327605/icon.png';
          // downloadBg = 'background-color: rgba(0, 0, 0, 0.8);';
          downloadColor = 'rgb(247,247,247)';
          lineColor = '#37372F';
        }
        
        
        let countH = 1;
        let downloadCon = `<div stay-download="${downloadUrl}" class="_stay-quality-item ">Download</div>`;
        let qualityList = videoInfo.qualityList;
        if(qualityList && qualityList.length){
          let qualityItem = '';
          countH = 0
          qualityList.forEach(item=>{
            list = [{title:videoInfo.title, downloadUrl: item.downloadUrl, poster: videoInfo.poster, hostUrl: Utils.getHostname(videoInfo.hostUrl), uuid: ''}];
            downloadUrl = 'stay://x-callback-url/snifferVideo?list='+encodeURIComponent(JSON.stringify(list));
            qualityItem = qualityItem + `<div stay-download="${downloadUrl}" class="_stay-quality-item">${item.qualityLabel}</div>`
            countH = countH + 1;
          })
          downloadCon = qualityItem;
        }
        // 动画开始位置
        let transPos = top;
        // 计算高度
        let vTop = top;
        if(top<0){
          vTop = 0;
          if(bodyClientHeight <= vHeight){
            vTop = Utils.div(Utils.sub(bodyClientHeight, posterHeight), 2);
          }
        }else if(top == 0){
          // 处理全屏的top
          if(bodyClientHeight <= vHeight){
            vTop = Utils.div(Utils.sub(bodyClientHeight, posterHeight), 2);
          }
        }else{
          let paddingHeight = Utils.add(10, 36);
          let modalContentHeight = Utils.add(Utils.add(posterHeight, paddingHeight), Utils.add(Utils.mul(countH, 38), 36));
          // 内容+定位的top 超出屏幕高度, 则可展示内容的top
          if(top>Utils.sub(bodyClientHeight, modalContentHeight)){
            vTop = Utils.sub(bodyClientHeight, modalContentHeight);
          }
        }
       

        let borderRadius = '';
        let videoImg = isContent?browser.runtime.getURL('img/video-default.png'):'https://res.stayfork.app/scripts/BB8CD00276006365956C32A6556696AD/icon.png';//browser.runtime.getURL('img/video-default.png');
        let posterCon = '<div class="__stay-poster-box" ><div class="__stay-default-poster"><img style="max-width:100%;max-height:100%;" src="'+videoImg+'"/></div><span style="font-size:13px;padding-top: 20px; -webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;'+fontColor+'">'+Utils.getHostname(videoInfo.hostUrl)+'</span></div>';
        if(videoInfo.poster){
          borderRadius = 'border-radius: 15px;'
          // posterCon = '<img style="max-width:100%; max-height: 100%; box-shadow: 0 0px 10px rgba(54,54,57,0.1);'+borderRadius+'" src="'+videoInfo.poster+'"/>'
          posterCon = `<div class="__stay-video-poster" style="background:url('${videoInfo.poster}') 50% 50% no-repeat;background-size: cover;"></div>`;
        }
        // console.log('videoDom----1--',videoDom);
        const canvas = captureVideoAndDrawing(videoDom, posterWidth, posterHeight);
        
        // console.log('posterCon----3--',posterCon);
        
        let sinfferStyle = `<style id="__style_sinffer_style">
          .__stay-modal-box{
            position: fixed; 
            z-index: 9999999; 
            width: 100%; 
            height: 100%; 
            text-align: center; 
            top: 0px;
            -webkit-overflow-scrolling: touch;
            margin: 0 auto;
            transition: all 0.6s;
            box-sizing: border-box;
            visibility: hidden;
          }
          .__stay-show-modal{
            ${bg}
            -webkit-backdrop-filter: blur(8px); 
          }
          .__stay-sinffer-content{
            width:100%;
            position: absolute;
            left: 0;
            -webkit-transform: translate3d(0, ${transPos}px, 0);
            transform: translate3d(0, ${transPos}px, 0);
            will-change: transform;
            -webkit-transition: -webkit-transform .4s cubic-bezier(0,0,.25,1) 80ms;
            transition: transform .4s cubic-bezier(0,0,.25,1) 80ms;
            box-sizing: border-box;
          }
          .__stay-trans{
            -webkit-transform: translate3d(0,${vTop}px,0);
            transform: translate3d(0,${vTop}px,0);
          }
          .__stay-content{
            width:100%;
            position: relative;
            display: flex;
            flex-direction: column;
            justify-content: center;
            justify-items: center;
            align-items: center;
          }
          ._stay-sinffer-popup{
            width:230px;padding-top: 10px;box-sizing: border-box;border-radius:15px;
            ${downloadBg}
            position: relative;
            margin: 16px auto 0 auto;
            z-index:999999;
            visibility: hidden;
            animation: fadein .5s;
          }
          .__stay-sinffer-poster{
            width: 100%;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
            height: ${posterHeight}px;
            padding: 0 ${left}px;
            margin:0 auto;
            display: flex;
            flex-direction: column;
            justify-content: center;
            justify-items: center;
            align-items: center;
            box-sizing: border-box;
            box-shadow: 0 0px 10px rgba(54,54,57,0.1);
            transition: All 0.4s ease-in-out;
            -webkit-transition: All 0.4s ease-in-out;
            -moz-transition: All 0.4s ease-in-out;
            -o-transition: All 0.4s ease-in-out;
            animation-name: zoom;
            animation-duration: 0.6s;
          }
          .__stay-video-poster{
            // object-fit: contain;
            // object-position: center;
            width:100%;
            height:100%;
            background-position: center;
            background-repeat: no-repeat;
            border-radius: 15px;
           
          }
          .__stay-poster-box{
            width:100%;
            height:100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            ${posterbg}
            border-radius: 10px;
            box-shadow: 0 0px 10px rgba(54,54,57,0.1);
          }
          .__stay-default-poster{
            width:80px;
            height:60px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            justify-items: center;
            align-items: center;
            box-sizing: border-box;
          }
          ._stay-sinffer-title{
            padding-left: 15px;
            padding-right: 15px;
            width: 100%;
            height:36px;
            line-height: 18px;
            word-break:break-all;
            word-wrap:break-word;
            color: ${downloadColor};
            -webkit-box-orient: vertical;
            -webkit-user-select: none;
            overflow: hidden;
            text-overflow: ellipsis;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            text-align: left;
            margin-bottom: 10px;
            box-sizing: border-box;
            font-size: 16px;
          }
          ._stay-sinffer-download{
            width:100%;
            box-sizing: border-box;
            display: flex;
            justify-content: flex-start;
            flex-direction: column;
            align-items: center;
          }
          ._stay-quality-item{
            height: 38px;
            box-sizing: border-box;
            width:100%;
            padding-right: 20px;
            position: relative;
            color: ${downloadColor};
            text-align:left;
            font-size: 16px;
            border-top: 0.5px solid ${lineColor};
            padding: 0 15px;
            display: flex;
            align-items: center;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
          }
          ._stay-quality-item::after{
            content:"";
            background: url(${downloadIcon}) no-repeat 50% 50%;  
            background-size: 14px;
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translate(0, -52%);
            width: 14px;
            height: 20px;
          }
          @keyframes zoom {
            0% {transform: scale(1.05)}
            100% {transform: scale(1);${borderRadius}}
          }
          @keyframes fadein {
            0% {
              transform: translate(0, -100%);
            }
            100% {
              transform: none;
            }
          }
          @keyframes fadeout {
              0% {
                transform: translate(0,100%);
              }
              100% {
                  transform: none;
              }
          }
        </style>`;
        let sinfferModal = [
          '<div id="__stay_sinffer_modal" class="__stay-modal-box" >',
          '<div class="__stay-sinffer-content">',
          '<div class="__stay-content">',
          '<div class="__stay-sinffer-poster">'+posterCon+'</div>',
          '<div class="_stay-sinffer-popup">',
          '<div class="_stay-sinffer-title">'+videoInfo.title+'</div>',
          '<div class="_stay-sinffer-download">',
          downloadCon,
          '</div>',
          '</div>',
          '</div>',
          '</div>',
          '</div>'
        ];
        
        document.body.append(Utils.parseToDOM(sinfferStyle));
        document.body.append(Utils.parseToDOM(sinfferModal.join('')));
        // document.querySelector

        return document.querySelector('#__stay_sinffer_modal');
      }

      

      modalDom.addEventListener('touchmove', e =>{ 
        e.preventDefault();
        e.stopPropagation();
      }, false);
      modalDom.addEventListener('touchstart', e =>{ 
        e.preventDefault();
        // e.stopPropagation();
        // modalDom.style.display = 'none';
        modalDom.classList.remove('__stay-show-modal');
        popupDom.style.animation = 'fadeout .5s;';

        setTimeout(() => {
          if(modalDom){
            document.body.removeChild(modalDom);
          }
          document.body.removeChild(document.querySelector('#__style_sinffer_style'));
        }, 200);
      }, false);

      const downloadItems = document.querySelectorAll('#__stay_sinffer_modal ._stay-quality-item');
      if(downloadItems && downloadItems.length){
        for(let i=0; i<downloadItems.length; i++){
          (function(n){
            downloadItems[i].addEventListener('touchstart', e=>{
              // console.log('e---------',e);
              let openUrl = e.target.getAttribute('stay-download');
              let targetGun = document.createElement('a');
              targetGun.href = openUrl;
              targetGun.click();
            })
          })(i)
        }
      }
    }


    /**
     * 
     * @param {object} videoDom 
     * @param {number} width 
     * @param {number} height 
     */
    function captureVideoAndDrawing(videoDom, width, height){
      // console.log('captureVideoAndDrawing-------',videoDom.tagName);
      if(!videoDom || 'VIDEO' != videoDom.tagName){
        return null;
      }
      videoDom.setAttribute('autoplay', 'autoplay');
      videoDom.setAttribute('crossOrigin', 'anonymous');  //添加srossOrigin属性，解决跨域问题
      const canvas = document.createElement('canvas');
      // canvas.setAttribute('crossOrigin', 'anonymous');
      canvas.width = width;
      canvas.height = height;
      const ctx = canvas.getContext('2d');

      // draw the current video frame on the canvas
      ctx.drawImage(videoDom, 0, 0, canvas.width, canvas.height);
      // console.log(canvas)
      

      if(canvas){
        // let dataURL = canvas.toDataURL('image/png');  //将图片转成base64格式
        // console.log('----dataURL-',dataURL);
        // let newImg = document.createElement('img');
        // newImg.src = dataURL;
        // document.body.appendChild(newImg);

        // canvas.toBlob(function(blob) {
        //   let newImg = document.createElement('img');
        //   console.log('toBlob--1----');
        //   let url = window.URL.createObjectURL(blob);
        //   console.log('toBlob--2----');
        //   newImg.onload = function() {
        //     window.URL.revokeObjectURL(url);
        //   };
        //   newImg.src = url;
        //   // posterCon = newImg.toString();
        //   console.log('toBlob--3----',newImg);
        //   document.body.appendChild(newImg);
        // });
      }

      // let dataURL = window.URL.createObjectURL(canvas.toBlob());
      // let dataURL = canvas.toDataURL('image/png');  //将图片转成base64格式
      // console.log('----dataURL-',dataURL)
      
      return canvas;
    }
    
    
    /**
     * 获取页面上video标签获取视频信息
     * @return videoInfo{videoKey(从原页面中取到的video唯一标识), downloadUrl, poster, title, hostUrl, qualityList, videoUuid(解析给video标签生成的uuid)}
     * 
     * qualityList[{downloadUrl,qualityLabel, quality }]
     * // https://www.pornhub.com/view_video.php?viewkey=ph63c4fdb2826eb
     */
    function handleVideoInfoParse(videoSnifferDom, videoDom, videoUuid){
      let videoInfo = {};
      let poster = videoSnifferDom.getAttribute('poster');
      let title = videoSnifferDom.getAttribute('title');
      let downloadUrl = videoSnifferDom.getAttribute('src');
      let qualityList = [];
      hostUrl = window.location.href;
      let longPressDom = videoDom;
      downloadUrl = Utils.completionSourceUrl(downloadUrl);

      if(!poster){
        let posterDom = document.querySelector('source[type=\'image/webp\'] img');
        poster = posterDom?posterDom.getAttribute('src'):'';
        if(!title){
          title = posterDom?posterDom.getAttribute('alt'):'';
        }
      }
      // console.log('handleVideoInfoParse---host---', host);
      if(host.indexOf('youtube.com')>-1){
        const videoId = Utils.queryURLParams(hostUrl, 'v');
        let playerDom = document.querySelector('#player-control-overlay .player-controls-background-container .player-controls-background');
        if(!playerDom){
          playerDom = document.querySelector('#player-control-overlay');
        }
        // 短视频
        if(!playerDom){
          playerDom = document.querySelector('.carousel-wrapper .video-wrapper .reel-player-overlay-main-content');
        }
        if(playerDom){
          longPressDom = playerDom;
        }
        videoInfo = handleYoutubeVideoInfo(title, videoId);
      }
      else if(host.indexOf('baidu.com')>-1){
        videoInfo = handleBaiduVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('bilibili.com')>-1){
        videoInfo = handleBilibiliVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('mobile.twitter.com')>-1){
        // console.log('parse---------mobile.twitter.com');
        let playerDom = document.querySelector('.r-eqz5dr .r-1pi2tsx .r-1pi2tsx .r-1udh08x .r-1p0dtai div.css-1dbjc4n.r-6koalj.r-eqz5dr.r-1pi2tsx.r-13qz1uu');
        if(!playerDom){
          // console.log('--------playerDom--------is null----------');
        }
        if(playerDom){
          longPressDom = playerDom;
        }
        videoInfo = handleMobileTwitterVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('m.weibo.cn')>-1){
        videoInfo = handleMobileWeiboVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('iesdouyin.com')>-1){
        videoInfo = handleMobileDouyinVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('douyin.com')>-1){
        const pathName = window.location.pathname;
        if(pathName.indexOf('/video')>-1){
          videoInfo = handlePCDetailDouyinVideoInfo(videoSnifferDom);
        }else{
          videoInfo = handlePCHomeDouyinVideoInfo(videoSnifferDom);
        }
      }
      else if(host.indexOf('m.toutiao.com')>-1){
        // longPressDom = document.querySelector('.video .xgplayer-wrapper .xgplayer-mobile .trigger');
        videoInfo = handleMobileToutiaoVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('m.v.qq.com')>-1){
        videoInfo = handleMobileTenxunVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('www.reddit.com')>-1){
        videoInfo = handleRedditVideoInfo(videoSnifferDom);
      }
      // https://cn.pornhub.com/view_video.php?viewkey=ph61ab31f8a70fe
      else if(host.indexOf('pornhub.com')>-1){
        let dom = document.querySelector('#videoShow #videoPlayerPlaceholder .playerFlvContainer');
        if(dom){
          longPressDom = dom;
        }
        videoInfo = handlePornhubVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('facebook.com')>-1){
        videoInfo = handleFacebookVideoInfo(videoSnifferDom);
      }// https://www.instagram.com
      else if(host.indexOf('instagram.com')>-1){
        videoInfo = handleInstagramVideoInfo(videoSnifferDom);
      }
      else if(host.indexOf('xiaohongshu.com')>-1){
        videoInfo = handleXiaohongshuVideoInfo(videoSnifferDom);
      }
      // https://jable.tv/videos/dvaj-605/
      else if(host.indexOf('jable.tv')>-1){
        videoInfo = handleJableVideoInfo(videoSnifferDom);
      }
      // ztawxd5l.hxaa79.com
      else if(host.indexOf('hxaa79.com')>-1){
        videoInfo = handleHxaa79VideoInfo(videoSnifferDom);
      }

      if(videoInfo.downloadUrl){
        downloadUrl = videoInfo.downloadUrl
      }
      downloadUrl = Utils.completionSourceUrl(downloadUrl);
      if(!poster){
        poster = videoInfo.poster
      }
      if(!title){
        title = videoInfo.title
      }
      if(videoInfo.qualityList && videoInfo.qualityList.length){
        qualityList = videoInfo.qualityList;
      }
      if(!title){
        title = document.title;
      }
      if(!title){
        title = Utils.getUrlPathName(downloadUrl);
      }
      poster = Utils.completionSourceUrl(poster);
      videoInfo['title'] = title
      videoInfo['poster'] = poster;
      videoInfo['downloadUrl'] = downloadUrl;
      videoInfo['hostUrl'] = hostUrl;
      videoInfo['qualityList'] = qualityList;
      videoInfo['videoUuid'] = videoUuid;

      // console.log('parse---------mobile.twitter.com------longPressDom-',longPressDom, ',videoInfo========',videoInfo);
      if(downloadUrl){
        checkVideoExist(videoDom, longPressDom, videoInfo) 
      }

      return videoInfo;
    }

    function setTimeoutParseVideoInfoByWindow(){
      // console.log('setTimeoutParseVideoInfoByWindow-------')
      setTimeout(()=>{
        parseVideoInfoByWindow()
      },400)
    }
    
    function parseVideoInfoByWindow(){
      let videoInfo = {}
      let host = window.location.host;
      hostUrl = window.location.href;
      videoInfo.hostUrl = hostUrl;
      let posDom = null;
      if(host.indexOf('pornhub.com')>-1){
        posDom = document.querySelector('#videoShow #videoPlayerPlaceholder .mgp_videoWrapper .mgp_videoPoster img');
        // if(!posDom){
        //   posDom = document.querySelector('#videoShow #videoPlayerPlaceholder .mgp_videoWrapper video');
        // }
        // if(!posDom){
        //   posDom = document.querySelector('#videoShow #videoPlayerPlaceholder .playerFlvContainer .mgp_controls');
        // }
        if(!posDom){
          posDom = document.querySelector('#videoShow #videoPlayerPlaceholder .mgp_videoWrapper');
        }
        videoInfo = parsePornhubVideoInfoByWindow(videoInfo);
      }
      // console.log('pornhub------------------',dom);
      if(!videoInfo.downloadUrl){
        return;
      }
      checkVideoExist(null, posDom, videoInfo);
      // console.log('parseVideoInfoByWindow------', videoInfo)
      return videoInfo;
    }

    function handleBilibiliVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');

      let titleDom = document.querySelector('.main-container .ep-info-pre .ep-info-title');
      if(!titleDom){
        setTimeout(function(){
          titleDom = document.querySelector('.video .share-video-info .title-wrapper .title-name span');
          if(titleDom){
            videoInfo.title = titleDom.textContent;
          }
          return videoInfo;
        }, 200)
      }
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }

      return videoInfo;
    }

    function handleMobileTwitterVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      let titleDom = videoDom.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.nextElementSibling.childNodes[1];
      if(titleDom){
        titleDom = titleDom.querySelector('.css-1dbjc4n .r-92ivih.r-1t01tom .r-1t982j2.r-1j3t67a .css-1dbjc4n.r-1kw4oii a[data-testid=\'tweetText\'] span');
        if(titleDom){
          videoInfo.title = Utils.checkCharLengthAndSubStr(titleDom.textContent);
        }
      }
      return videoInfo;
    }

    function handleMobileWeiboVideoInfo(videoDom){

      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      if(hostUrl.match(/^.*\/detail\/.*/g)){
        videoInfo.title = Utils.checkCharLengthAndSubStr(document.querySelector('.weibo-main .weibo-text').textContent);
        // videoInfo.poster = Utils.completionSourceUrl(document.querySelector('.weibo-main .weibo-media .card-video .mwb-video .m-img-box img').getAttribute('src'));
      }
      
      return videoInfo;
    }

    function handleMobileDouyinVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      let posterDom = document.querySelector('.video-container img.poster');
      if(posterDom){
        videoInfo.poster = posterDom.getAttribute('src');
      }
      let titleDom = document.querySelector('.desc .multi-line .multi-line_text');
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }

      return videoInfo;
    }

    function handlePCDetailDouyinVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      const titleDom = document.querySelector('div[data-e2e=video-detail] div[data-e2e=detail-video-info] div h2');
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }
      return videoInfo;
    }

    function handlePCHomeDouyinVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');

      let slideDom = videoDom.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
      if(slideDom){
        let posterDom = slideDom.querySelector('.imgBackground img');
        if(posterDom){
          videoInfo.poster = posterDom.getAttribute('src');
        }
        let titleDom = slideDom.querySelector('.video-info-detail .title span.e_h_fqNj');
        if(titleDom){
          videoInfo.title = titleDom.textContent;
        }
      }
      return videoInfo;
    }

    function handleMobileToutiaoVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      const posterDom = document.querySelector('.video .xgplayer-placeholder .xgplayer-poster')
      if(posterDom){
        let posterInfo = posterDom.getAttribute('style');
        if(posterInfo){
          let poster = Utils.matchUrlInString(posterInfo);
          // console.log('poster-----',poster);
          videoInfo.poster = poster;
        }
      }
      const titleDom = document.querySelector('.video .video-header .video-title-wrapper .video-title');
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }

      return videoInfo;
    }

    function handleMobileTenxunVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      const posterDom = document.querySelector('.mod_play .player_container .txp_poster_img');
      if(posterDom){
        let poster = posterDom.getAttribute('src');
        poster = Utils.completionSourceUrl(poster);
        videoInfo.poster = poster;
      }
      const titleDom = document.querySelector('.mod_box .mod_bd .mod_video_info .video_title');
      if(titleDom){
        let title = titleDom.textContent;
        title = title?title.trim():'';
        const sliderDom = document.querySelector('.mod_box .mod_bd .mod_list_slider .slider_box .item.current span');
        if(sliderDom){
          title = title + sliderDom.textContent;
          title = title?title.trim():'';
        }
        videoInfo.title = title;
      }
      return videoInfo;
    }

    function handleRedditVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      const titleDom = document.querySelector('shreddit-app shreddit-title');
      if(titleDom){
        videoInfo.title = titleDom.getAttribute('title');
      }
      return videoInfo;
    }

    function handlePornhubVideoInfo(videoDom){
      let videoInfo = {};
      
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      let videoDetailDom = videoDom.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;
      if(videoDetailDom && videoDetailDom.classList.contains('playerWrapper')){
        // video detail info
        const titleDom = document.querySelector('#videoShow .categoryTags .headerWrap h1');
        if(titleDom){
          let title = titleDom.textContent;
          if(title){
            videoInfo.title = title.trim();
          }
        }
        
        const posterDom = document.querySelector('#videoPlayerPlaceholder img.videoElementPoster');
        if(posterDom){
          videoInfo.poster = posterDom.getAttribute('src');
        }
        return parsePornhubVideoInfoByWindow(videoInfo);
      }
      let videoLiDom = videoDom.parentNode.parentNode.parentNode.parentNode.parentNode;
      if(videoLiDom && 'li' == videoLiDom.tagName.toLowerCase()){
        let videoThumbDom = videoLiDom.querySelector('.videoWrapper .singleVideo a img.videoThumb');
        if(videoThumbDom){
          videoInfo.title = videoThumbDom.getAttribute('alt');
          if(videoInfo.title){
            videoInfo.title = '[Related videos] ' + videoInfo.title;
          }
          videoInfo.poster = videoThumbDom.getAttribute('src');
          return videoInfo;
        }
      }
      return videoInfo;
    }

    function parsePornhubVideoInfoByWindow(videoInfo){
      videoInfo = videoInfo || {};
      // console.log('videoInfo.window.location.href========',window.location.href)
      videoInfo.videoKey = Utils.queryURLParams(window.location.href, 'viewkey');
      // console.log('videoInfo.videoKey========',videoInfo.videoKey)
      // console.log('window.VIDEO_SHOW========',window.VIDEO_SHOW.vkey)
      if(window.VIDEO_SHOW && (!videoInfo.videoKey || videoInfo.videoKey == window.VIDEO_SHOW.vkey)){
        if(!videoInfo.title){
          videoInfo.title = window.VIDEO_SHOW.videoTitle;
        }
        if(!videoInfo.poster){
          videoInfo.poster = window.VIDEO_SHOW.videoImage;
        }
       
        let playerId = window.VIDEO_SHOW.playerId;
        // console.log('playerId=========',playerId);
        if(playerId){
          let idArr = playerId.split('_');
          // console.log('idArr=========',idArr);
          if(idArr.length>1){
            let flashvarsId = 'flashvars_' + idArr[1];
            // console.log('flashvarsId=========',flashvarsId);
            let mediaDefinitions = window[flashvarsId].mediaDefinitions;
            // console.log('mediaDefinitions===========',mediaDefinitions)
            if(mediaDefinitions && mediaDefinitions.length){
              let qualityList = []
              let defaultQuality = '';
              mediaDefinitions.forEach(item=>{
                if('hls' == item.format && typeof item.quality == 'string' && item.videoUrl){
                  qualityList.push({downloadUrl: window.encodeURI(item.videoUrl), qualityLabel:item.quality, quality: Number(item.quality)})
                }
                if(item.defaultQuality && ('boolean' == typeof item.defaultQuality || 'number' == typeof item.defaultQuality) ){
                  defaultQuality = item.defaultQuality;
                  if(!videoInfo.downloadUrl){
                    videoInfo.downloadUrl = item.videoUrl;
                  }
                }

              })
              // console.log('qualityList========',qualityList)
              // console.log('defaultQuality========',defaultQuality, typeof defaultQuality)
              videoInfo['qualityList'] = qualityList;
            }
          }
        }
      }
      return videoInfo;
    }

    function handleFacebookVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      let videoDetailDom = videoDom.parentElement.parentElement.parentElement.parentElement.parentElement;
      if(videoDetailDom && videoDetailDom.classList.contains('displayed') && 'container' == videoDetailDom.getAttribute('data-type')){
        let imgDom = videoDetailDom.querySelector('div[data-type=\'video\'] img.img');
        if(imgDom){
          videoInfo.poster = imgDom.getAttribute('src');
        }
        let titleDom = videoDetailDom.querySelector('div.displayed > div[data-type=\'container\'] > div[data-type=\'container\'] > div[data-type=\'container\'] > div[data-type=\'text\'] > div.native-text');
        if(titleDom){
          videoInfo.title = titleDom.textContent;
        }
      }
      return videoInfo;
    }

    function handleInstagramVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      let videoDetailDom = videoDom.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;
      if(videoDetailDom && videoDetailDom.classList.contains('_ab8w') && videoDetailDom.classList.contains('_ab94') && 
      videoDetailDom.classList.contains('_ab99') && videoDetailDom.classList.contains('_ab9h') && videoDetailDom.classList.contains('_ab9m') && 
      videoDetailDom.classList.contains('_ab9p') && videoDetailDom.classList.contains('_abcm')){
        // console.log('handleInstagramVideoInfo--------------',videoDetailDom);
        let posterDom = videoDetailDom.querySelector('._aatk .x1uhb9sk .x10l6tqk .x78zum5 img.x5yr21d');
        // console.log('posterDom-----------',posterDom)
        if(posterDom){
          videoInfo.poster = posterDom.getAttribute('src');
        }
        let titleDom = videoDetailDom.querySelector('._ab9f div._ae1h._ae1i ._ae2s div._ae5q._akdn div div div');
        // console.log('titleDom-----------',titleDom)
        if(titleDom && titleDom.textContent){
          videoInfo.title = titleDom.textContent.replace('... more', '');
        }
      }else{
        videoDetailDom = videoDom.parentNode.parentNode.parentNode.parentNode.parentNode;
        // console.log(videoDetailDom.classList, 'videoDetailDom.classList.contains(\'_a8b4\') ===', videoDetailDom.classList.contains('_a8b4') )
        if(videoDetailDom && videoDetailDom.classList.contains('_a8b4') && videoDetailDom.classList.contains('_acjh')){
          // let posterDom = videoDetailDom.querySelector('div > div div.xryxfnj.x1nhvcw1 div.xxk0z11.x1qihbgi a.x1i10hfl._a6hd div._aagu div._aagv img');
          // if(posterDom){
          //   videoInfo.poster = posterDom.getAttribute('src');
          // }
          let titleDom = videoDetailDom.querySelector('div > div > div.x9f619.x1d8287x.xz4gly6  div.x6ikm8r.x10wlt62 span');
          if(titleDom){
            videoInfo.title = titleDom.textContent;
          }
        }
      }
      return videoInfo;
    }

    function handleXiaohongshuVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      const bgDom = document.querySelector('.video-container .video-banner .img-box');
      if(bgDom){
        let posterInfo = bgDom.getAttribute('style');
        let poster = Utils.matchUrlInString(posterInfo);
        if(poster){
          videoInfo.poster = Utils.completionSourceUrl(poster);
        }
      }
      const titleDom = document.querySelector('.video-container .stage-bottom .author-desc-wrapper .author-desc');
      if(titleDom){
        let title = titleDom.textContent;
        if(title){
          title = title.replace(/^展开/g, '');
          videoInfo.title = Utils.checkCharLengthAndSubStr(title);
        }
      }
      return videoInfo;
    }

    function handleJableVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      const titleDom = document.querySelector('.video-info .info-header .header-left h4');
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }

      return videoInfo;

    }

    function handleHxaa79VideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      const titleDom = document.querySelector('.play_main .play_main_1');
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }
      return videoInfo;
    }

    /**
     * 解析baidu视频信息
     * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList,videoKey,videoUuid}
     * keyName{sd(标清),hd(高清),sc(超清), 1080p(蓝光)}
     * qualityList[{downloadUrl,qualityLabel, quality, keyName }]
     */
    function handleBaiduVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      /*--activity.baidu.com--*/ 
      // window.PAGE_DATA.remote.mainVideoList
      // window.PAGE_DATA.remote.moreVideoList
      // window.PAGE_DATA.remote.rcmdVideoList
      if(host === 'activity.baidu.com'){
        const pageData = window.PAGE_DATA;
        if(pageData && pageData.pageData && pageData.pageData.remote && pageData.pageData.remote.mainVideoList && pageData.pageData.remote.mainVideoList.length){
          const mainVideo = pageData.pageData.remote.mainVideoList[0];
          const moreVideoList = pageData.pageData.remote.moreVideoList;
          videoInfo['title'] = mainVideo.title;
          videoInfo['poster'] = mainVideo.poster;
          videoInfo['downloadUrl'] = mainVideo.videoUrl;
          if(moreVideoList && moreVideoList.length){
            moreVideoList.forEach(item=>{
              if(videoIdSet.size && (videoIdSet.has(item.vid))){
                return;
              }
              if(Utils.isURL(item.videoUrl)){
                videoIdSet.add(item.vid);
                // more video
                videoList.push({title:item.title,poster:item.poster,downloadUrl:window.encodeURI(item.videoUrl),hostUrl:hostUrl,videoUuid:item.vid });
              }
            })
          }
          return videoInfo;
        }
        videoInfo['title'] = getBaiduVideoTitle();
        const videoDom = document.querySelector('.stickyBlock .curVideoPlay video');
        if(videoDom){
          videoInfo['poster'] = videoDom.getAttribute('poster');
          videoInfo['downloadUrl'] = videoDom.getAttribute('src');
        }
        return videoInfo;
      }
      /*--https://mbd.baidu.com/--*/
      // window.jsonData.curVideoMeta
      if('mbd.baidu.com' === host ){
        const jsonData = window.jsonData;
        if(jsonData && jsonData.curVideoMeta){
          const curVideoMeta = jsonData.curVideoMeta;
          videoInfo = haokanBaiduVideoInfo(curVideoMeta);
          // 接口中的数据和dom数据是否一致
          if(videoInfo && Object.keys(videoInfo).length){
            return videoInfo;
          }
        }
        videoInfo['title'] = getBaiduVideoTitle();
        videoInfo['poster'] = getBaiduVideoPoster();
        return videoInfo;
      }

      /*--https://haokan.baidu.com/--*/
      // window.__PRELOADED_STATE__.curVideoMeta
      if('haokan.baidu.com' === host){
        // console.log('haokan----start-----');
        const preloadedState = window.__PRELOADED_STATE__;
        const videoId = Utils.queryURLParams(hostUrl, 'vid');
        const srcUrl = videoDom.getAttribute('src');
        // 主视频 
        if(srcUrl && videoId && srcUrl.indexOf(videoId)>-1){
          // console.log('haokan----videoId-----',videoId);
          if(preloadedState && preloadedState.curVideoMeta){
            const curVideoMeta = preloadedState.curVideoMeta;
            videoInfo = haokanBaiduVideoInfo(curVideoMeta);
            if(videoInfo && Object.keys(videoInfo).length){
              return videoInfo;
            }
          }
          videoInfo['title'] = getBaiduVideoTitle();
          videoInfo['poster'] = getBaiduVideoPoster();
        }else{
          videoInfo['title'] = videoDom.parentElement.parentElement.querySelector('h3.land-recommend-bottom-title')?videoDom.parentElement.parentElement.querySelector('h3.land-recommend-bottom-title').textContent:'';
          videoInfo['poster'] = videoDom.parentElement&&videoDom.parentElement.querySelector('img.video-img')?videoDom.parentElement.querySelector('img.video-img').getAttribute('src'):'';
        }
        
        return videoInfo;
      }
      
      /*--https://pan.baidu.com/--*/
      // 
      if('pan.baidu.com' === host){
        videoInfo['title'] = getBaiduVideoTitle();
      }

      return videoInfo;
    }

    function haokanBaiduVideoInfo(curVideoMeta){
      if(!curVideoMeta){
        return {};
      }
      let videoInfo = {};
      videoInfo['title'] = curVideoMeta.title;
      videoInfo['poster'] = curVideoMeta.poster;
      videoInfo['downloadUrl'] = curVideoMeta.playurl;
      if(curVideoMeta.clarityUrl && curVideoMeta.clarityUrl.length){
        let qualityList = [];
        const clarityUrl = curVideoMeta.clarityUrl;
        clarityUrl.forEach(item=>{
          let vodVideoHW = item.vodVideoHW;
          qualityList.push({downloadUrl:item.url, qualityLabel:item.title, quality: item.key})
        });
        videoInfo['qualityList'] = qualityList;
      }
      return videoInfo;
    }

    function getBaiduVideoPoster(){
      const haokanPosterDom = document.querySelector('.art-player-wrapper .art-video-player .art-poster');
      if(haokanPosterDom){
        let haokanPosterInfo = haokanPosterDom.getAttribute('style');
        if(haokanPosterInfo){
          return Utils.matchUrlInString(haokanPosterInfo);
        }
      }
      const mhdPosterDom = document.querySelector('#bdMainPlayer .art-video-player .art-poster')
      if(mhdPosterDom){
        let mhdPosterInfo = mhdPosterDom.getAttribute('style');
        if(mhdPosterInfo){
          return Utils.matchUrlInString(mhdPosterInfo);
        }
      }
      return '';
    }

    function getBaiduVideoTitle(){
      const activityTitleDom = document.querySelector('.adVideoPageV3 .curVideoInfo h3.videoTitle');
      if(activityTitleDom){
        return activityTitleDom.textContent;
      }
      const haokanTitleDom = document.querySelector('.video-info .video-info-title');
      if(haokanTitleDom){
        return haokanTitleDom.textContent;
      }
      const panTitleDom = document.querySelector('.video-main .video-content .video-title .video-title-left');
      if(panTitleDom){
        return panTitleDom.textContent;
      }
      return '';
    }

    /**
     * 解析Youtube视频信息
     * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList}
     */
    function handleYoutubeVideoInfo(title, videoId){
      // console.log('handleYoutubeVideoInfo---------------videoId-------------',videoId)
      let videoInfo = {};
      const playerResp = window.ytInitialPlayerResponse;
      // console.log('playerResp-------', playerResp);
      if(playerResp && playerResp.videoDetails && playerResp.streamingData && (!videoId || videoId === playerResp.videoDetails.videoId)){
        // console.log('hello- - - - - - -   playerResp   ----');
        const videoDetails = playerResp.videoDetails;
        let detailTitle = videoDetails.title?videoDetails.title:'';
        videoInfo['title'] = detailTitle;
        let thumbnail = videoDetails.thumbnail;
        if(thumbnail){
          let thumbnails = thumbnail.thumbnails;
          if(thumbnails && thumbnails.length){
            // console.log('thumbnails-----',thumbnails);
            videoInfo['poster'] =  thumbnails.pop().url;
          }
        }
        if(playerResp.microformat && playerResp.microformat.playerMicroformatRenderer 
          && playerResp.microformat.playerMicroformatRenderer.thumbnail 
          && playerResp.microformat.playerMicroformatRenderer.thumbnail.thumbnails.length){
          // console.log('playerResp.microformat.playerMicroformatRenderer-----',playerResp.microformat.playerMicroformatRenderer);
          videoInfo['poster'] = playerResp.microformat.playerMicroformatRenderer.thumbnail.thumbnails[0].url;
        }
       
        // console.log('playerResp-------videoDetails-------------', videoDetails);
        const streamingData = playerResp.streamingData;
        const adaptiveFormats = streamingData.adaptiveFormats;
        const formats = streamingData.formats;
        const qualityFormatsList = formats;
        title = title ? title : '';
        // 取画质的时候防止原视频有广告
        if(qualityFormatsList && qualityFormatsList.length && title.replace(/\s+/g,'') === detailTitle.replace(/\s+/g,'')){
          // console.log('playerResp-------adaptiveFormats------------------', title,  videoDetails.title, formats);
          // * qualityList[{downloadUrl, qualityLabel, quality}]
          let qualityList = []
          let qualitySet = new Set();
          qualityFormatsList.forEach(item=>{
            let mimeType = item.mimeType;
            if(mimeType.indexOf('video/mp4')>-1 && item.url && !qualitySet.has(item.quality)){
              qualitySet.add(item.quality)
              qualityList.push({downloadUrl: window.encodeURI(item.url), qualityLabel:item.qualityLabel, quality: item.quality})
            }
          });
          if(qualityList && qualityList.length){
            videoInfo['qualityList'] = qualityList;
          }
          videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        }else{
          videoInfo['title'] = title?title:getYoutubeVideoTitleByDom();
          videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        }
        if(!videoInfo['poster']){
          videoInfo['poster'] = getYoutubeVideoPosterByDom();
        }

      }else{
        videoInfo = {};
        videoInfo['title'] = title?title:getYoutubeVideoTitleByDom();
        // poster img
        videoInfo['poster'] = getYoutubeVideoPosterByDom();
        videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        // console.log('videoInfo----------',videoInfo);
      }
      return videoInfo;
    }
    
    /**
     * youtube 移动端(PC)video标签
     * @returns url
     */
    function getYoutubeVideoSourceByDom(){
      let videoDom = document.querySelector('.html5-video-player .html5-video-container video');
      if(videoDom){
        // console.log('----------------',videoDom);
        return videoDom.getAttribute('src');
      }
      return '';
    }
    
    function getYoutubeVideoTitleByDom(){
      const titleMobileDom = document.querySelector('.slim-video-metadata-header .slim-video-information-content .slim-video-information-title');
      if(titleMobileDom){
        return titleMobileDom.textContent;
      }
      const titlePcDom = document.querySelector('#title h1.style-scope');
      if(titlePcDom){
        return titlePcDom.textContent;
      }
      return '';
    }
    
    function getYoutubeVideoPosterByDom(){
      const overlayImg = document.querySelector('.ytp-cued-thumbnail-overlay-image');
      // console.log(overlayImg)
      if(overlayImg){
        // console.log('overlayImg-------',overlayImg);
        let imgText = overlayImg.getAttribute('style');
        if(imgText){
          return Utils.matchUrlInString(imgText);
        }
      }
      const overlayImgPc = document.querySelector('.html5-video-player .ytp-cued-thumbnail-overlay .ytp-cued-thumbnail-overlay-image');
      if(overlayImgPc){
        let imgText = overlayImgPc.getAttribute('style');
        if(imgText){
          return Utils.matchUrlInString(imgText);
        }
      }
      const bgStyle = document.querySelector('.video-wrapper .background-style-black');
      if(bgStyle){
        let imgText = bgStyle.getAttribute('style');
        if(imgText){
          return Utils.matchUrlInString(imgText);
        }
      }
      return '';
    }
    
    startFindVideoInfo(false);
    document.onreadystatechange = () => {
      // console.log('document.readyState==',document.readyState)
      if (document.readyState === 'complete') {
        // console.log('readyState-------------------', document.readyState)
        startFindVideoInfo(true);
      }
    };
    
    function handlePageInterceptor(){
      function isVideoLink(url){
        let re = /^(https?:\/\/|\/).*\.(mp4|m3u8)$/;
        return url.match(re) != null;
      }    
        
      let uniqueUrls = new Set()
      //XMLHttpRequest.prototype.reallySend = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.reallyOpen = XMLHttpRequest.prototype.open;
        
      XMLHttpRequest.prototype.open = function(method, url, async, user, password){
        // console.log('OPEN_URL',url);
        this.reallyOpen(method,url,async,user,password);
        if (isVideoLink(url)){
          if (!uniqueUrls.has(url)){
            uniqueUrls.add(url);
            // console.log('VIDEO_LINK_CAPTURE: ' + url);
            window.postMessage({name: 'VIDEO_LINK_CAPTURE', urls: uniqueUrls});
            if(isContent){
              let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoLinkSet:uniqueUrls};
              browser.runtime.sendMessage(message, (response) => {});
            }
          }       
        }
      };
        
      // XMLHttpRequest.prototype.send = function (body) { 
      //       alert("--req.body:---",body);
      //     //   console.log("VIDEO_LINK_CAPTURE: ",this);
      //     //  console.log("VIDEO_LINK_CAPTURE-------------");
        
      //     this.reallySend(body);
        
      // };
        
      let originalFetch = window.fetch;
      window.fetch = function(resource, options){
        let url = typeof resource == 'object' ? resource.url : resource;
        if (isVideoLink(url)){
          if (!uniqueUrls.has(url)){
            uniqueUrls.add(url);
            console.log('VIDEO_LINK_CAPTURE: ' + url);
            window.postMessage({name: 'VIDEO_LINK_CAPTURE', urls: uniqueUrls});
            if(isContent){
              let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoLinkSet:uniqueUrls};
              browser.runtime.sendMessage(message, (response) => {});
            }
          }       
        }
        return originalFetch(resource,options);
      };
    }

    handlePageInterceptor();

  }


  let videoInfoList = [];
  let videoLinkSet = new Set();
  window.addEventListener('message', (e) => {
    if (!e || !e.data || !e.data.name) return;
    const name = e.data.name;
    // console.log('snifffer.user----->e.data.name=',name);
    if(name === 'VIDEO_LINK_CAPTURE'){
      let tempSet = e.data.urls ? e.data.urls : new Set();
      // console.log('snifffer.VIDEO_LINK_CAPTURE----->tempSet=',tempSet);
      // videoLinkSet = new Set( [ ...tempSet, ...videoLinkSet ] )
      videoLinkSet = tempSet
      // console.log('snifffer.VIDEO_LINK_CAPTURE----->videoLinkSet=',videoLinkSet);
      let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoLinkSet};
      browser.runtime.sendMessage(message, (response) => {});
    }
    else if(name === 'VIDEO_INFO_CAPTURE'){
      let videoInfoListTemp = e.data.videoList ? e.data.videoList : [];
      videoInfoList = videoInfoListTemp
      // console.log('snifffer.VIDEO_INFO_CAPTURE----->videoInfoListTemp=',videoInfoListTemp);
      // videoInfoList.push(...videoInfoListTemp)
      // console.log('snifffer.VIDEO_INFO_CAPTURE----->videoInfoList=',videoInfoList);
      let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoInfoList};
      browser.runtime.sendMessage(message, (response) => {});
    }
  })
})()