/**
 * 解析页面video标签
 */

let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function () {
  try {
    // for page
    handleInjectScript();
    document.addEventListener('securitypolicyviolation', (e) => {
      // for content
      injectParseVideoJS(true);
    })
  } catch (error) {
  }
  /**
   * for page 
   */ 
  function handleInjectScript(){
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let contentHost = window.location.host;
    let scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.id = 'stay_inject_parse_video_js_'+contentHost;
    let injectJSContent = `\n\nconst handleInjectParseVideoJS = ${injectParseVideoJS}\n\nhandleInjectParseVideoJS(false);`;
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
    let isLoadingAround = false;
    let isLoadingLongPressStatus = false;
    let definedObj = {};
    let videoListMd5 = '';
    let isStayAround = '';
    let documentLongPressEvent = null;
    let videoAreaLongPressEvent = null;
    let longPressStatus = '';
    let hostUrl = window.location.href;
    let host = window.location.host;
    let decodeSignatureCipher = {}; 
    let playerBase = '';
    let ytBaseJSUuid = '';
    let ytRandomBaseJs = '';
    let ytPublicParam = {};//cpn,cver,ptk,oid,ptchn,pltype
    let ytParam_N_Obj = {};
    // console.log('------------injectParseVideoJS-----start------------------',decodeSignatureCipher)
    let videoList = [];
    // key:videoUuid,
    // value:qualityList,
    let shouldDecodeQuality = {};
    // 获取到的videoId 集合
    let videoIdSet = new Set();
    // Firefox和Chrome早期版本中带有前缀  
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let videoDoms;  
    let timerArr = [];

    const Utils = {
      compare: function(key){
        return (cur, next)=>{
          let curValue = cur[key];
          let nextValue = next[key];
          if(typeof curValue != 'number'){
            curValue = curValue.replace(/[^0-9]/g,'');
            if(!curValue){
              curValue = 0;
            }else{
              curValue = Number(curValue);
            }
          }
          if(typeof nextValue != 'number'){
            nextValue = nextValue.replace(/[^0-9]/g,'');
            if(!nextValue){
              nextValue = 0;
            }else{
              nextValue = Number(nextValue);
            }
          }
          return nextValue - curValue;
        };
      },
      isMobileOrIpad: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        let isIphoneOrIpad = getArr.length ? true : false;
        if(isIphoneOrIpad){
          return isIphoneOrIpad
        }else{
          if (userAgentInfo.match(/Macintosh/) && navigator.maxTouchPoints > 1) {
            return true;
          } 
        }
        return isIphoneOrIpad;
      },
      isMobile: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        return getArr.length ? true : false;
      },
      /*
      * 替换URL的参数值
      * url 目标url
      * arg 需要替换的参数名称(区分大小写)
      * arg_val 替换后的参数的值
      * return url 参数替换后的url
      */
      replaceUrlArg: function (url, arg, argVal){
        const urlObj = new URL(url);
        urlObj.searchParams.set(arg, argVal)
        return urlObj.href
      },
      queryURLParams: function(url, name) {
        const pattern = new RegExp('[?&#]+' + name + '=([^?&#]+)');
        const res = pattern.exec(url);
        if (!res) return '';
        if (!res[1]) return '';
        return res[1];
      },
      queryParams: function(path, name) {
        if(!path){
          return '';
        }
        let url = 'https;//stap.app?'+path;
        return this.queryURLParams(url, name);
      },
      getLastPathParameter: function(url) {
        const path = new URL(url).pathname;
        const segments = path.split('/').filter(segment => segment !== '');
        return segments[segments.length - 1];
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
            if(/^\//i.test(downloadUrl)){
              downloadUrl = window.location.origin+downloadUrl;
            }
          }
        }
        return downloadUrl;
      },
      checkCharLengthAndSubStr: function(text, len){
        if(!text){
          return '';
        }
        if(!len){
          len=80
        }
        let textTemp = text.replace(/[^x00-xff]/g, '01');
        if(textTemp.length <= len){
          return text;
        }else{
          return text.substr(0, len);
        }
      },
      isChinese(obj){
        if(!obj){
          return false;
        }
        if(/.*[u4e00-u9fa5]+.*$/.test(obj)){
          return true;
        }
        return false;
      },
      urlEncodeChinese(urlStr){
        if(!urlStr){
          return urlStr;
        }
        let reg = new RegExp('[\\u4E00-\\u9FFF]','g');
        return urlStr.replace(reg, function(match) {return window.encodeURI(match)})
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
      },
      hexMD5 (str) { 
        /*
        * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
        * Digest Algorithm, as defined in RFC 1321.
        * Version 1.1 Copyright (C) Paul Johnston 1999 - 2002.
        * Code also contributed by Greg Holt
        * See http://pajhome.org.uk/site/legal.html for details.
        */

        /*
        * Add integers, wrapping at 2^32. This uses 16-bit operations internally
        * to work around bugs in some JS interpreters.
        */
        function safe_add(x, y)
        {
          let lsw = (x & 0xFFFF) + (y & 0xFFFF)
          let msw = (x >> 16) + (y >> 16) + (lsw >> 16)
          return (msw << 16) | (lsw & 0xFFFF)
        }

        /*
        * Bitwise rotate a 32-bit number to the left.
        */
        function rol(num, cnt)
        {
          return (num << cnt) | (num >>> (32 - cnt))
        }

        /*
        * These functions implement the four basic operations the algorithm uses.
        */
        function cmn(q, a, b, x, s, t)
        {
          return safe_add(rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b)
        }
        function ff(a, b, c, d, x, s, t)
        {
          return cmn((b & c) | ((~b) & d), a, b, x, s, t)
        }
        function gg(a, b, c, d, x, s, t)
        {
          return cmn((b & d) | (c & (~d)), a, b, x, s, t)
        }
        function hh(a, b, c, d, x, s, t)
        {
          return cmn(b ^ c ^ d, a, b, x, s, t)
        }
        function ii(a, b, c, d, x, s, t)
        {
          return cmn(c ^ (b | (~d)), a, b, x, s, t)
        }

        /*
        * Calculate the MD5 of an array of little-endian words, producing an array
        * of little-endian words.
        */
        function coreMD5(x)
        {
          let a = 1732584193
          let b = -271733879
          let c = -1732584194
          let d = 271733878

          for(let i = 0; i < x.length; i += 16)
          {
            let olda = a
            let oldb = b
            let oldc = c
            let oldd = d

            a = ff(a, b, c, d, x[i+ 0], 7 , -680876936)
            d = ff(d, a, b, c, x[i+ 1], 12, -389564586)
            c = ff(c, d, a, b, x[i+ 2], 17, 606105819)
            b = ff(b, c, d, a, x[i+ 3], 22, -1044525330)
            a = ff(a, b, c, d, x[i+ 4], 7 , -176418897)
            d = ff(d, a, b, c, x[i+ 5], 12, 1200080426)
            c = ff(c, d, a, b, x[i+ 6], 17, -1473231341)
            b = ff(b, c, d, a, x[i+ 7], 22, -45705983)
            a = ff(a, b, c, d, x[i+ 8], 7 , 1770035416)
            d = ff(d, a, b, c, x[i+ 9], 12, -1958414417)
            c = ff(c, d, a, b, x[i+10], 17, -42063)
            b = ff(b, c, d, a, x[i+11], 22, -1990404162)
            a = ff(a, b, c, d, x[i+12], 7 , 1804603682)
            d = ff(d, a, b, c, x[i+13], 12, -40341101)
            c = ff(c, d, a, b, x[i+14], 17, -1502002290)
            b = ff(b, c, d, a, x[i+15], 22, 1236535329)

            a = gg(a, b, c, d, x[i+ 1], 5 , -165796510)
            d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632)
            c = gg(c, d, a, b, x[i+11], 14, 643717713)
            b = gg(b, c, d, a, x[i+ 0], 20, -373897302)
            a = gg(a, b, c, d, x[i+ 5], 5 , -701558691)
            d = gg(d, a, b, c, x[i+10], 9 , 38016083)
            c = gg(c, d, a, b, x[i+15], 14, -660478335)
            b = gg(b, c, d, a, x[i+ 4], 20, -405537848)
            a = gg(a, b, c, d, x[i+ 9], 5 , 568446438)
            d = gg(d, a, b, c, x[i+14], 9 , -1019803690)
            c = gg(c, d, a, b, x[i+ 3], 14, -187363961)
            b = gg(b, c, d, a, x[i+ 8], 20, 1163531501)
            a = gg(a, b, c, d, x[i+13], 5 , -1444681467)
            d = gg(d, a, b, c, x[i+ 2], 9 , -51403784)
            c = gg(c, d, a, b, x[i+ 7], 14, 1735328473)
            b = gg(b, c, d, a, x[i+12], 20, -1926607734)

            a = hh(a, b, c, d, x[i+ 5], 4 , -378558)
            d = hh(d, a, b, c, x[i+ 8], 11, -2022574463)
            c = hh(c, d, a, b, x[i+11], 16, 1839030562)
            b = hh(b, c, d, a, x[i+14], 23, -35309556)
            a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060)
            d = hh(d, a, b, c, x[i+ 4], 11, 1272893353)
            c = hh(c, d, a, b, x[i+ 7], 16, -155497632)
            b = hh(b, c, d, a, x[i+10], 23, -1094730640)
            a = hh(a, b, c, d, x[i+13], 4 , 681279174)
            d = hh(d, a, b, c, x[i+ 0], 11, -358537222)
            c = hh(c, d, a, b, x[i+ 3], 16, -722521979)
            b = hh(b, c, d, a, x[i+ 6], 23, 76029189)
            a = hh(a, b, c, d, x[i+ 9], 4 , -640364487)
            d = hh(d, a, b, c, x[i+12], 11, -421815835)
            c = hh(c, d, a, b, x[i+15], 16, 530742520)
            b = hh(b, c, d, a, x[i+ 2], 23, -995338651)

            a = ii(a, b, c, d, x[i+ 0], 6 , -198630844)
            d = ii(d, a, b, c, x[i+ 7], 10, 1126891415)
            c = ii(c, d, a, b, x[i+14], 15, -1416354905)
            b = ii(b, c, d, a, x[i+ 5], 21, -57434055)
            a = ii(a, b, c, d, x[i+12], 6 , 1700485571)
            d = ii(d, a, b, c, x[i+ 3], 10, -1894986606)
            c = ii(c, d, a, b, x[i+10], 15, -1051523)
            b = ii(b, c, d, a, x[i+ 1], 21, -2054922799)
            a = ii(a, b, c, d, x[i+ 8], 6 , 1873313359)
            d = ii(d, a, b, c, x[i+15], 10, -30611744)
            c = ii(c, d, a, b, x[i+ 6], 15, -1560198380)
            b = ii(b, c, d, a, x[i+13], 21, 1309151649)
            a = ii(a, b, c, d, x[i+ 4], 6 , -145523070)
            d = ii(d, a, b, c, x[i+11], 10, -1120210379)
            c = ii(c, d, a, b, x[i+ 2], 15, 718787259)
            b = ii(b, c, d, a, x[i+ 9], 21, -343485551)

            a = safe_add(a, olda)
            b = safe_add(b, oldb)
            c = safe_add(c, oldc)
            d = safe_add(d, oldd)
          }
          return [a, b, c, d]
        }
        /*
        * Convert an 8-bit character string to a sequence of 16-word blocks, stored
        * as an array, and append appropriate padding for MD4/5 calculation.
        * If any of the characters are >255, the high byte is silently ignored.
        */
        function str2binl(str) {
          let bin = [];
          for (let i = 0; i < str.length * 8; i += 8) {
            bin[i >> 5] |= (str.charCodeAt(i / 8) & 0xFF) << (i % 32);
          }
          return bin;
        }
        
        /*
        * Convert an array of little-endian words to a hex string.
        */
        function binl2hex(binarray){
          let hex_tab = '0123456789abcdef'
          let str = ''
          for(let i = 0; i < binarray.length * 4; i++)
          {
            str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
                    hex_tab.charAt((binarray[i>>2] >> ((i%4)*8)) & 0xF)
          }
          return str
        }
        return binl2hex(coreMD5(str2binl(str))) 
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
        // event.stopPropagation();
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
        this.callback = callback;
        this.dom = dom;
        // this.startTime = 0; // 触摸起始时间
        // this.endTime = 0; // 触摸终止时间
        this.stayLongPressTimer = 0; 
        this.distance = 10; // 触摸距离值
        this.handleTouchStartEvent = this.handleTouchStartEvent.bind(this);
        this.touchmoveCallback = this.touchmoveCallback.bind(this);
        this.touchEndCallback = this.touchEndCallback.bind(this);
        this.init();
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
       * 初始化(监听长按事件)
       *
       * @private
       */
      init() {
        this.stayLongPressTimer = 0; 
        this.distance = 10; // 触摸距离值
        this.touchstart();
        this.touchmove();
        this.touchend();
        this.bindLongPressEventFlag();
      }

      /**
       * 移除长按事件
       */
      removeEvent(){
        // console.log('removeEvent------------------',this.stayLongPressTimer);
        if(this.stayLongPressTimer){
          clearTimeout(this.stayLongPressTimer)
          this.stayLongPressTimer = 0;
        }
        this.removeTouchstart();
        this.removeTouchmove();
        this.removeTouchend();
      }

      /**
       * 标记是否绑定过长按事件
       */
      bindLongPressEventFlag(){
        this.dom.setAttribute('stay-long-press', 'yes');
      }

      /**
       * 手指按下时开启定时器，700 毫秒后触发回调函数
       *
       * @private
       */
      touchstart() {
        this.removeTouchstart();
        document.body.addEventListener('touchstart', this.handleTouchStartEvent);
      }

      removeTouchstart(){
        document.body.removeEventListener('touchstart', this.handleTouchStartEvent);
      }

      handleTouchStartEvent(event){
        const self = this;
       
        console.log(event);
        let target = event.changedTouches[0];
        if(!target){
          return;
        }
        const targetPageX = target.pageX;
        const targetPageY = target.pageY;
        // console.log('this.dom------------',this.dom.getBoundingClientRect());
        // console.log('targetPageX=',targetPageX,',targetPageY=',targetPageY,'this.domPageStartX=',self.getDomPageStartX(), 'this.domPageStartY=',self.getDomPageStartY() ,'this.domPageEndX=',self.getDomPageEndX(),',this.domPageEndY=',self.getDomPageEndY());
        if(!isHidden(self.dom) && Math.abs(target.pageX - targetPageX) <= self.distance &&
        targetPageX >= self.getDomPageStartX() && targetPageX <= self.getDomPageEndX() && 
        targetPageY >= self.getDomPageStartY() && targetPageY <= self.getDomPageEndY()){
          event.stopPropagation();
          event.preventDefault();
          // console.log('start-------', new Date().getTime());
          this.stayLongPressTimer = window.setTimeout((curTarget) => {
            try {
              let classList = curTarget.target.classList;
              // console.log('start----------event----',event);
              if(!classList.contains('__stay-unselect')){
                classList.add('__stay-unselect')
              }
              if(!classList.contains('__stay-touch-action')){
                classList.add('__stay-touch-action');
              }
              if (typeof this.callback === 'function') {
                this.callback();
              } else {
                console.error('callback is not a function!');
              }
              // console.log('end-------', new Date().getTime());
              curTarget.target.addEventListener('contextmenu', handleContextmenuEvent);
              // eslint-disable-next-line no-inner-declarations
              function handleContextmenuEvent(e){
                e.preventDefault();
                curTarget.target.removeEventListener('contextmenu', handleContextmenuEvent);
              }
              
              // this.removeEvent();
            } catch (error) {
              
            }finally{
              // this.removeEvent();
            }
          }, 600, target);
          // console.log('end.end-------', new Date().getTime());
        }
        
        self.handleTargetTouchend(event.target);
      }

      handleTargetTouchend(target){
        const self = this;
        if(!target){
          return;
        }
        target.addEventListener('touchend', handleTargetEvent)
        function handleTargetEvent(event){
          self.touchEndCallback(event)
          target.removeEventListener('touchend', handleTargetEvent)
        }


      }

      /**
       * 手指抬起时清除定时器，无论按住时间是否达到 600 毫秒的阈值
       *
       * @private
       */
      touchend() {
        // console.log('handle------touchend---' );
        this.removeTouchend()
        document.body.addEventListener('touchend', this.touchEndCallback);
      }

      removeTouchend(){
        document.body.removeEventListener('touchend', this.touchEndCallback)
      }

      touchEndCallback(event){
        const self = this;
        // event.stopPropagation();
        if(isHidden(this.dom)){
          return;
        }
        // console.log('touchEndCallback----event-------', event);
        if(this.stayLongPressTimer!=0){
          try {
            clearTimeout(this.stayLongPressTimer);
            // 清除定时器
            this.stayLongPressTimer = 0;
          } catch (error) {
            
          }
        }
      }

      /**
       * 如果手指有移动，则取消所有事件，此时说明用户只是要移动而不是长按
       */
      touchmove() {
        this.removeTouchmove();
        document.body.addEventListener('touchmove', this.touchmoveCallback, { passive: true })
      }

      removeTouchmove(){
        document.body.removeEventListener('touchmove', this.touchmoveCallback, { passive: true });
      }

      touchmoveCallback(event){
        const self = this;
        if(isHidden(self.dom)){
          return;
        }
        window.clearTimeout(self.stayLongPressTimer);//清除定时器
        self.stayLongPressTimer = 0;
      }

    }

    function startFindVideoInfo(completed){
      observerVideo();
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
      let flag = false;
      for(let i=1; i<10; i++){
        let timer
        (function(i){
          timer = setTimeout(()=>{
            videoDoms = document.querySelectorAll('video');  
            // console.log('startFindVideoInfo------i-----',i, new Date().getTime());
            flag = videoDoms && videoDoms.length;
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
        if(flag){
          break;
        }
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
        let videoNodeList = Array.from(videoDoms);
        videoNodeList.forEach((item) => {
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
        })
        if(nullCount == videoCount){
          setTimeoutParseVideoInfoByWindow();
        }
      }else{
        // console.log('start------parseVideoInfoByWindow--------');
        setTimeoutParseVideoInfoByWindow();
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
      if(!videoInfo.videoKey && !videoInfo.videoUuid){
        return;
      }
      if(!Utils.isURL(downloadUrl)){
        videoInfo.downloadUrl = hostUrl;
      }
      if(videoInfo.videoKey && !videoInfo.videoUuid){
        videoInfo.videoUuid = videoInfo.videoKey;
      }
      videoInfo.title = videoInfo.title?videoInfo.title.replace(/\//g, '|'):'';
      const qualityList = videoInfo.qualityList;
      // videoInfo.qualityList是否需要解密，如需解密记录下来, 等handleDecodeSignatureAndPush来解密
      if(videoInfo.shouldDecode){
        videoInfo.qualityList = [];
        shouldDecodeQuality[videoInfo.videoUuid] = qualityList;
      }
      // videoInfo.downloadUrl = Utils.isChinese(videoInfo.downloadUrl) ? window.encodeURI(videoInfo.downloadUrl) : videoInfo.downloadUrl;
      try {
        addLongPress(videoDom, posDom, videoInfo);
      } catch (error) {
        
      }
      
      if(videoIdSet.size && (videoIdSet.has(videoInfo.videoUuid) || videoIdSet.has(videoInfo.videoKey))){
        // console.log('parseVideoNodeList----------has exist, and modify-------',videoInfo, videoList);
        videoList.forEach(item=>{
          if(item.videoUuid == videoInfo.videoUuid || item.videoUuid == videoInfo.videoKey){
            item.downloadUrl = videoInfo.downloadUrl;
            item.poster = videoInfo.poster?videoInfo.poster:'';
            item.title = videoInfo.title
            item.hostUrl = videoInfo.hostUrl
            item.qualityList = videoInfo.qualityList&&videoInfo.qualityList.length?videoInfo.qualityList:[];
            item.type= videoInfo.type?videoInfo.type:'';
            item.videoUuid = videoInfo.videoUuid
            item.videoKey = videoInfo.videoKey
            // console.log('checkVideoExist----------item===',item);
          }
          return item;
        })
        // console.log('parseVideoNodeList------videoList---modify------',videoList)
      }else{
        // console.log('parseVideoNodeList----------has not, and push-------',videoInfo);
        if(videoInfo.videoUuid){
          videoIdSet.add(videoInfo.videoUuid);
        }
        if(videoInfo.videoKey){
          videoIdSet.add(videoInfo.videoKey);
        }
        // console.log('checkVideoExist----------',videoInfo, videoIdSet);
        videoList.push(videoInfo);
      }
      pushVideoListToTransfer()
    }

    function checkDecodeFunIsValid(){
      if(!decodeSignatureCipher || !Object.keys(decodeSignatureCipher).length){
        return false;
      }
      if(!ytBaseJSUuid){
        return false;
      }
      if(!decodeSignatureCipher.decodeFunStr){
        return false;
      }
      if(ytBaseJSUuid != decodeSignatureCipher.pathUuid){
        return false;
      }
      return true;
    }

    function checkDecodeWithSpeedFunIsValid(){
      let isValid = checkDecodeFunIsValid();
      if(isValid){
        if(!decodeSignatureCipher.decodeSpeedFunStr){
          isValid = false;
        }else{
          isValid = true;
        }
      }
      return isValid;
    }

    /**
     * 对videoList中qualityList的signature进行解密
     */
    function handleDecodeSignatureAndPush(){
      if(!Object.keys(shouldDecodeQuality).length){
        return;
      }
      if(!checkDecodeFunIsValid()){
        return;
      }
      Object.keys(shouldDecodeQuality).forEach((videoUuid, qualityList)=>{
        if(qualityList.length){
          qualityList.forEach((quality)=>{
            if(quality.downloadUrl && !Utils.isURL(quality.downloadUrl)){
              quality.downloadUrl = decodeYoutubeSourceUrl(quality.downloadUrl);
            }
            if(quality.audioUrl && !Utils.isURL(quality.audioUrl)){
              quality.audioUrl = decodeYoutubeSourceUrl(quality.audioUrl);
            }
            return quality;
          });
          let newQualityList = qualityList.filter((item)=>{
            if(item.downloadUrl){
              return item;
            }
          })
          videoList.forEach(videoItem => {
            if(videoItem.videoUuid == videoUuid){
              videoItem.qualityList = newQualityList;
              return videoItem;
            }
          })
          delete shouldDecodeQuality[videoUuid];
        }
      })
      pushVideoListToTransfer();
    }

    /**
     * push videoList to transfer
     */
    function pushVideoListToTransfer(){
      const videoInfoListMd5 = Utils.hexMD5(JSON.stringify(videoList));
      if(videoListMd5 && videoListMd5 == videoInfoListMd5){
        return;
      }
      console.log('pushVideoListToTransfer------',videoList);
      videoListMd5 = videoInfoListMd5;
      if(isContent){
        // console.log('isContent----------------------');
        let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH',  videoInfoList: videoList};
        browser.runtime.sendMessage(message, (response) => {});
      }else{
        window.postMessage({name: 'VIDEO_INFO_CAPTURE', videoList: videoList});
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
      // console.log('----addLongPress-----start------');
      if(!posDom){
        // console.log('----posDomposDomposDomposDomposDom-----null',posDom);
        return;
      }
      if(!Utils.isMobile()){
        return;
      }

      if(isLoadingAround || isLoadingLongPressStatus){
        return;
      }


      if(!longPressStatus){
        isLoadingLongPressStatus = true;
        longPressStatus = await getLongPressStatus();
        isLoadingLongPressStatus = false;
      }

      if(!longPressStatus || (longPressStatus && longPressStatus == 'off')){
        return;
      }

      // console.log('----getStayAround-----start------');
      if(!isStayAround){
        isLoadingAround = true;
        isStayAround = await getStayAround();
        isLoadingAround = false;
      }
      // console.log('----isStayAround-----',isStayAround);
      if(isStayAround!='a'){
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
            touch-action: auto!important;
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
        videoAreaLongPressEvent = new LongPress(posDom, ()=>{
          addSinfferModal(videoDom, posDom, videoInfo);
        })
      }
      else if(hostUrl.indexOf('mobile.twitter.com')>-1){
        
      }
      else if(hostUrl.indexOf('pornhub.com')>-1){
        if(posDom){
          if(!posDom.classList.contains('__stay-touch-action')){
            posDom.classList.add('__stay-touch-action');
          }
          if(!posDom.classList.contains('__stay-unselect')){
            posDom.classList.add('__stay-unselect');
          }
        }
        videoAreaLongPressEvent = new LongPress(posDom, ()=>{
          addSinfferModal(videoDom, posDom, videoInfo);
        })
      }
      else if(hostUrl.indexOf('muiplayer.js.org')>-1){
        let posterDom = document.querySelector('#mplayer-media-wrapper');
        if(!posterDom){
          posterDom = document.querySelector('#mplayer-cover');
        }
        if(posterDom){
          // posDom = posterDom;
          videoAreaLongPressEvent = new LongPress(posterDom, ()=>{
            addSinfferModal(videoDom, posterDom, videoInfo);
          })
        }
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
              // console.log('isStayAround---------', response.body)
              resolve( response.body);
            }
          });
        }else{
          // console.log('getStayAround-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_STAY_AROUND_RESP') return;
            // console.log('RESP_GET_STAY_AROUND----response=', e.data);
            let isStayPro = e.data ? (e.data.response ? e.data.response.body : 'b'): 'b';
            // console.log('RESP_GET_STAY_AROUND----isStayAround=', isStayPro);
            resolve(isStayPro);
            window.removeEventListener('message', callback);
          };
          // console.log('getStayAround-----false-----start---pid=',pid);
          window.postMessage({ id: pid, pid: pid, name: 'GET_STAY_AROUND' });
          window.addEventListener('message', callback);
        }
      })
    }

    function getLongPressStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          // console.log('getLongPressStatus-----true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getLongPressStatus'}, (response) => {
            // console.log('getLongPressStatus---------',response)
            let longPressStatusRes = response&&response.longPressStatus?response.longPressStatus:'on';
            resolve(longPressStatusRes);
          });
        }else{
          // console.log('getLongPressStatus-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_LONG_PRESS_STATUS_RESP') return;
            // console.log('getLongPressStatus---------',e.data.longPressStatusRes)
            resolve(e.data.longPressStatusRes);
            window.removeEventListener('message', callback);
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_LONG_PRESS_STATUS' });
          window.addEventListener('message', callback);
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
      // console.log('videoDom.tagName====',videoDom, posDom)
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

      let visibleTimer = setTimeout(function(){
        modalDom.classList.add('__stay-show-modal');
        popupDom.style.visibility = 'visible';
        clearTimeout(visibleTimer);
        visibleTimer = 0;
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
        let hdLine = '#F7B500';
        let hdBg = '#000';
        let titleIcon = 'https://res.stayfork.app/scripts/22BF8566F3522614F4F3A15EBC87378E/icon.png';
        let airplayIcon = 'https://res.stayfork.app/scripts/D660FA085601F608C3BE6F9CDB44DFCC/icon.png';
        let pipIcon = 'https://res.stayfork.app/scripts/3F8E6C0D8F4FDD3767A7F0B151A72E94/icon.png';
        if(Utils.isDark()){
          // bg = 'background-color: rgba(0, 0, 0, 0.4);';
          posterbg = 'background-color: rgba(0, 0, 0, 1);';
          fontColor = 'color:#DCDCDC;'
          downloadBg = 'background-color: rgb(54, 54, 57);';
          downloadIcon = isContent?browser.runtime.getURL('img/popup-download-dark.png'):'https://res.stayfork.app/scripts/CFFCD2186E164262E0E776A545327605/icon.png';
          // downloadBg = 'background-color: rgba(0, 0, 0, 0.8);';
          downloadColor = 'rgb(247,247,247)';
          lineColor = '#37372F';
          hdBg = 'rgb(247,247,247)';
          titleIcon = 'https://res.stayfork.app/scripts/102BDC80B489A31FCA2F4E3A3B7CCE74/icon.png';
          airplayIcon = 'https://res.stayfork.app/scripts/F6E653EE027B789962CEE7E6FB2CF65F/icon.png';
          pipIcon = 'https://res.stayfork.app/scripts/DC8756A3CE2F2752ED738E5C1A71FCFF/icon.png';
        }
        
        let countH = 1;
        let downloadCon = `<div stay-download="${downloadUrl}" class="_stay-quality-item ">${videoInfo.type == 'ad'? 'Download Ad':'Download'}</div>`;
        let qualityList = videoInfo.qualityList;
        if(qualityList && qualityList.length){
          // checkQualityList Decode
          let qualityItem = '';
          countH = 0
          qualityList.forEach(item=>{
            let downloadUrl = item.downloadUrl;
            let audioUrl = item.audioUrl;
            if(videoInfo.shouldDecode){
              if(!Utils.isURL(downloadUrl)){
                downloadUrl = decodeYoutubeSourceUrl(downloadUrl);
                if(!downloadUrl){
                  return;
                }
              }
              if(audioUrl && !Utils.isURL(audioUrl)){
                audioUrl = decodeYoutubeSourceUrl(audioUrl);
                if(!audioUrl){
                  return;
                }
              }
            }

            list = [{title:videoInfo.title, downloadUrl, poster: videoInfo.poster, hostUrl: Utils.getHostname(videoInfo.hostUrl), uuid: '', protect:item.protect?item.protect:false, audioUrl, qualityLabel:item.qualityLabel }];
            downloadUrl = 'stay://x-callback-url/snifferVideo?list='+encodeURIComponent(JSON.stringify(list));
            let quality = item.qualityLabel;
            let heightQualityLabel = '';
            if(quality){
              try {
                quality = quality.replace(/[^0-9]/g,'');
                if(Number(quality) > 780){
                  heightQualityLabel = '<span class="__stay-hd">HD</span>';
                }
              } catch (error) {
                
              }
              
            }
            qualityItem = qualityItem + `<div stay-download="${downloadUrl}" class="_stay-quality-item">${item.qualityLabel}${heightQualityLabel}</div>`
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
          let paddingHeight = Utils.add(4, 36);
          let modalContentHeight = Utils.add(Utils.add(posterHeight, paddingHeight), Utils.add(Utils.mul(countH, 38), 36));
          // modalContentHeight = Utils.add(modalContentHeight, 38);
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
        // const canvas = captureVideoAndDrawing(videoDom, posterWidth, posterHeight);
        
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
            font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
            -webkit-font-smoothing: antialiased;
            -moz-osx-font-smoothing: grayscale;
          }
          .__stay-show-modal{
            ${bg}
            -webkit-backdrop-filter: blur(10px); 
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
            padding-left: 44px;
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
            position: relative;
          }
          ._stay-sinffer-title::before{
            content: '';
            background: url(${titleIcon}) 50% 50% no-repeat;
            background-size: 18px;
            width: 18px;
            height: 18px;
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translate(0, -50%);
            }
          }
          ._stay-sinffer-title span{
            font-weight: 600;
            color: ${fontColor}
          }
          ._stay-sinffer-tool{
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 9px 15px;
            height: 38px;
            box-sizing: border-box;
          }
          ._stay-sinffer-tool .__tool{
            width: 50%;
            height: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            color: ${fontColor}
          }
          ._stay-sinffer-tool .__tool img{
            width: 20px;
          }
          ._stay-sinffer-tool .__tool span{
            padding-left: 10px;
          }
          ._stay-sinffer-tool .__airplay{
            
            border-right: 0.5px solid ${lineColor};
          }
          ._stay-sinffer-tool .__pip{

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
          ._stay-quality-item .__stay-hd{
            border: 1px solid ${hdLine};
            background: ${hdBg};
            color: ${hdLine};
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
            padding: 0px 4px;
            border-radius: 4px;
            margin-left: 10px;
            align-items: center;
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
          // `<div class="_stay-sinffer-tool"><div id="__stay_airplay" class="__tool __airplay"><img src="${airplayIcon}" /><span>Airplay</span></div><div id="__stay_pip" title="Picture-in-Picture" class="__tool __pip"><img src="${pipIcon}" /><span>PIP</span></div></div>`,
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

      function restartEventListener(){

       
      }

      modalDom.addEventListener('touchstart', handleModalEvent);

      function handleModalEvent(event){
        event.preventDefault();
        event.stopPropagation();
        // modalDom.style.display = 'none';
        // removeModalMouseMoveEvent();
        restartEventListener();
        modalDom.classList.remove('__stay-show-modal');
        popupDom.style.animation = 'fadeout .5s;';
        
        let removeTimer = setTimeout(() => {
          if(modalDom){
            modalDom.removeEventListener('touchstart', handleModalEvent);
            document.body.removeChild(modalDom);
          }
          document.body.removeChild(document.querySelector('#__style_sinffer_style'));
          clearTimeout(removeTimer);
          removeTimer = 0;
        }, 200);
      }

      const downloadItems = document.querySelectorAll('#__stay_sinffer_modal ._stay-quality-item');
      if(downloadItems && downloadItems.length){
        for(let i=0; i<downloadItems.length; i++){
          (function(n){
            downloadItems[i].addEventListener('touchstart', handleDownloadItemEvent);
            function handleDownloadItemEvent(e){
              let openUrl = e.target.getAttribute('stay-download');
              let targetGun = document.createElement('a');
              targetGun.href = openUrl;
              targetGun.click();
              downloadItems[i].removeEventListener('touchstart', handleDownloadItemEvent);
              restartEventListener();
            }
          })(i)
        }
      }
      async function openPiP(video) {
        try {
          const pipWindow = await video.requestPictureInPicture();
          // 进入画中画模式...
        } catch (e) {   
          console.error(e) // 处理异常
        }
      }
      
      
     
      // const pip_button_act = (isPip) => {
      //   if(isPip){
      //     document.querySelector('#__stay_pip img').style.opacity = 0.2;
      //   }else{
      //     document.querySelector('#__stay_pip img').style.opacity = 1;
      //   }
      // }
      
      // const enterpictureinpicture = e => pip_button_act(true);
      // const leavepictureinpicture = e => pip_button_act(false);
      // const webkitpresentationmodechanged = event => {
      //   event.target.webkitPresentationMode == 'picture-in-picture'
      //     ? (pip_button_act(true), event.stopImmediatePropagation())
      //     : pip_button_act(false);
      // }
      
      // const pip_init = video => {
      //   if (!video || video.nodeName != 'VIDEO' || !video.hasAttribute('src')) return;
      //   if (video.webkitPresentationMode === undefined) {
      //     video.addEventListener('enterpictureinpicture', enterpictureinpicture);
      //     video.addEventListener('leavepictureinpicture', leavepictureinpicture);
      //   } else {
      //     video.addEventListener('webkitpresentationmodechanged', webkitpresentationmodechanged, true);
      //   }
      // }

      // pip_init(videoDom);


      // document.querySelector('#__stay_pip').addEventListener('touchstart', event => {
      //   // console.log('touch--pip--------',e);
      //   // e.stopPropagation();
      //   if (videoDom.webkitPresentationMode === undefined) {
      //     if (document.pictureInPictureElement) {
      //       document.exitPictureInPicture();
      //     } else {
      //       videoDom.requestPictureInPicture();
      //     }
      //   } else {
      //     if (videoDom.webkitPresentationMode != 'inline') {
      //       videoDom.webkitSetPresentationMode('inline');
      //     } else {
      //       videoDom.webkitSetPresentationMode('picture-in-picture');
      //     }
      //   }
      //   event.preventDefault();
      //   event.stopImmediatePropagation();
      // })

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
     * decodeURIComponent(sourceUrl)+"&sig="+Gta(decodeURIComponent(signature))
     * @param {string} decodeSignatureCipherFunStr 
     * @param {String} signatureCipher 
     * @returns 
     */
    function decodeYoutubeSourceUrl(signatureCipher){
      if(!checkDecodeFunIsValid()){
        console.log('decodeSignatureCipherFunStr------decodeSignatureCipherFunStr or signatureCipher is null', signatureCipher)
        return '';
      }
      let decodeFunStr = decodeSignatureCipher.decodeFunStr;
      // console.log('decodeYoutubeSourceUrl---------',signatureCipher);
      const decodeSignatureCipherFun = new Function('return '+decodeFunStr); 
      let sourceUrl = Utils.queryParams(signatureCipher, 'url');
      let signature = Utils.queryParams(signatureCipher, 's');
      // console.log('decodeYoutubeSourceUrl------------sourceUrl=',sourceUrl, signature);
      signature = decodeSignatureCipherFun()(decodeURIComponent(signature));
      sourceUrl = `${decodeURIComponent(sourceUrl)}&sig=${signature}`;
      sourceUrl = decodeYoutubeSpeedFun(sourceUrl);
      return sourceUrl;
    }

    function decodeYoutubeSpeedFun(sourceUrl){
      if(!checkDecodeWithSpeedFunIsValid()){
        console.log('decodeYoutubeSpeedFun------checkDecodeWithSpeedFunIsValid is false', sourceUrl)
        return sourceUrl;
      }

      if(Utils.queryURLParams(sourceUrl, 'oid')){
        return sourceUrl;
      }

      // if(Object.keys(ytPublicParam).length<6){
      //   return sourceUrl
      // }
      let paramStr = '';
      let paramCount = 0;
      for (let name in ytPublicParam) {
        if (ytPublicParam[name] && typeof ytPublicParam[name] != 'undefined') {
          paramCount = paramCount + 1;
          paramStr += '&' + name + '=' + ytPublicParam[name];
        }
      }
      // console.log('decodeYoutubeSpeedFun----paramStr------',paramStr)
      // if(paramCount<6){
      //   console.log('decodeYoutubeSpeedFun---paramCount<6---', ytPublicParam);
      //   return sourceUrl;
      // }

      let n = Utils.queryURLParams(sourceUrl, 'n');
      if(!n){
        console.log('decodeYoutubeSpeedFun---n-is-null---',n);
        return sourceUrl;
      }
      if(!ytParam_N_Obj[n]){
        ytParam_N_Obj[n] = getYoutubeNParam(n);
      }

      if(!ytParam_N_Obj[n]){
        console.log('decodeYoutubeSpeedFun---ytParam_N_Obj[n]-is-null---',n);
        return sourceUrl
      }
      
      sourceUrl = Utils.replaceUrlArg(sourceUrl, 'n', ytParam_N_Obj[n]);

      sourceUrl = sourceUrl + paramStr;
      // console.log('decodeYoutubeSpeedFun---sourceUrl----',sourceUrl);
      return sourceUrl;
    }

    function getYoutubeNParam(n){
      try {
        let decodeSpeedFunStr = decodeSignatureCipher.decodeSpeedFunStr;
        const decodeSpeedFun = new Function('return '+decodeSpeedFunStr); 
        return decodeSpeedFun()(decodeURIComponent(n));
      } catch (error) {
        return '';
      }
    }

    /**
     * 获取 sourceUrl 公共参数
     * cpn,cver,ptk,oid,ptchn,pltype
     * @param {*} sourceUrl video标签下src的url
     * return cpn=b_JppE6c7Cd9y2Z9&cver=2.20230331.01.00&ptk=youtube_single&oid=grYThWmtgGXLlb99XVUPQQ&ptchn=aO6TYtlC8U5ttz62hTrZgg&pltype=content
     */
    function setYoutubePublicParam(sourceUrl, playerRes){
      if(sourceUrl){
        ytPublicParam.cver = ytPublicParam.cver ? ytPublicParam.cver : Utils.queryURLParams(sourceUrl, 'cver');
        setYtParmeObj(sourceUrl)
      }
      if(playerRes && Object.keys(playerRes).length){
        // https://m.youtube.com/ptracking?ei=EJotZK4dw-CwApmmldgO&oid=noTyR-gah-30KqQfy7jXjw&plid=AAX4mNQPIivbGnid&pltype=content&ptchn=hB3UnDddahXU7FKZXmpzMA&ptk=youtube_single&video_id=EQOarcurXfY
        // window.ytplayer.bootstrapPlayerResponse.playbackTracking.ptrackingUrl.baseUrl
        // window.ytplayer.bootstrapPlayerResponse.responseContext.serviceTrackingParams[1].params[2].cver
        if(playerRes.playbackTracking && playerRes.playbackTracking.ptrackingUrl && playerRes.playbackTracking.ptrackingUrl.baseUrl){
          setYtParmeObj(playerRes.playbackTracking.ptrackingUrl.baseUrl);
        }
        if(playerRes.responseContext && playerRes.responseContext.serviceTrackingParams && playerRes.responseContext.serviceTrackingParams.length){
          playerRes.responseContext.serviceTrackingParams.forEach(item=>{
            if('CSI' == item.service && item.params.length){
              item.params.forEach(param => {
                if('cver' == param.key){
                  ytPublicParam.cver = ytPublicParam.cver ? ytPublicParam.cver : param.value;
                }
              })
            }
          })
        }
      }
      // console.log('ytPublicParam-------',ytPublicParam)
    }

    function setYtParmeObj(sourceUrl){
      ytPublicParam.cpn = ytPublicParam.cpn?ytPublicParam.cpn:Utils.queryURLParams(sourceUrl, 'cpn');
      ytPublicParam.ptk = ytPublicParam.ptk?ytPublicParam.ptk:Utils.queryURLParams(sourceUrl, 'ptk');
      ytPublicParam.oid = ytPublicParam.oid?ytPublicParam.oid:Utils.queryURLParams(sourceUrl, 'oid');
      ytPublicParam.ptchn = ytPublicParam.ptchn?ytPublicParam.ptchn:Utils.queryURLParams(sourceUrl, 'ptchn');
      ytPublicParam.pltype = ytPublicParam.pltype?ytPublicParam.pltype:Utils.queryURLParams(sourceUrl, 'pltype');
    }

    function getYoutubeVideoUrlOrSignture(signatureCipher){
      if(!checkDecodeFunIsValid()){
        return signatureCipher;
      }else{
        return decodeYoutubeSourceUrl(signatureCipher);
      }
    }
    
    function getYoutubeAudioUrlOrSignture(audioArr){
      if(audioArr && audioArr.length){
        audioArr.sort(Utils.compare('bitrate'));
        let audioItem= audioArr[0];
        if(audioItem.url){
          return audioItem.url;
        }else{
          if(!checkDecodeFunIsValid()){
            return audioItem.signatureCipher;
          }
          // console.log('audioItem--------',audioItem)
          return decodeYoutubeSourceUrl(audioItem.signatureCipher);
        }
      }else{
        return '';
      }
    }

    /**
     * 获取页面上video标签获取视频信息
     * @return videoInfo{videoKey(从原页面中取到的video唯一标识), downloadUrl, poster, title, hostUrl, qualityList, videoUuid(解析给video标签生成的uuid), audioUrl（音频url）, protect(视频是否受保护, true/false)}
     * 
     * qualityList[{downloadUrl,qualityLabel, quality, audioUrl（音频url）, protect(视频是否受保护, true/false) }]
     * // https://www.pornhub.com/view_video.php?viewkey=ph63c4fdb2826eb
     */
    function handleVideoInfoParse(videoSnifferDom, videoDom, videoUuid){
      let videoInfo = {};
      let poster = videoSnifferDom.getAttribute('poster') || videoSnifferDom.getAttribute('data-poster');
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
        setYoutubePublicParam(downloadUrl, '');
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
        videoInfo = handleYoutubeVideoInfo(videoSnifferDom);
        if(!videoInfo.videoKey){
          return videoInfo;
        }
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
      else if(host.indexOf('91porn.com')>-1){
        const dom = document.querySelector('#videodetails .video-container');
        if(dom){
          longPressDom = dom;
        }
        videoInfo = handle91PormVideoInfo(videoSnifferDom);
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
      else if(host.indexOf('555yy4.com')>-1){
        videoInfo = handle555yy4VideoInfo(videoSnifferDom);
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
      videoInfo['title'] = (videoInfo.type && videoInfo.type=='ad')?('<span style="font-weight: 700;">Ad·</span>'+title):title;
      videoInfo['poster'] = poster;
      videoInfo['downloadUrl'] = downloadUrl;
      videoInfo['hostUrl'] = hostUrl;
      videoInfo['qualityList'] = qualityList;
      videoInfo['videoUuid'] = videoUuid;

      // console.log('parse------videoInfo========',videoInfo);
      if(downloadUrl){
        checkVideoExist(videoDom, longPressDom, videoInfo) 
      }
      return videoInfo;
    }

    function setTimeoutParseVideoInfoByWindow(){
      // console.log('setTimeoutParseVideoInfoByWindow-------')
      let loadingTimer = setTimeout(()=>{
        parseVideoInfoByWindow();
        clearTimeout(loadingTimer);
        loadingTimer = 0;
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
      else if(host.indexOf('youtube.com')>-1){
        videoInfo = handleYoutubeVideoInfo();
      }
  
      // console.log('pornhub------------------',dom);
      if(!videoInfo.downloadUrl){
        return;
      }
      checkVideoExist(null, posDom, videoInfo);
    }

    function handleBilibiliVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');

      let titleDom = document.querySelector('.main-container .ep-info-pre .ep-info-title');
      if(!titleDom){
        titleDom = document.querySelector('.video .share-video-info .title-wrapper .title .title-name span');
        if(!titleDom){
          let bilibiliTimer = setTimeout(function(){
            titleDom = document.querySelector('.video .share-video-info .title-wrapper .title .title-name span');
            if(titleDom){
              videoInfo.title = titleDom.textContent;
            }
            clearTimeout(bilibiliTimer);
            bilibiliTimer = 0;
            return videoInfo;
          }, 200)
        }
      }
      if(titleDom){
        videoInfo.title = titleDom.textContent;
      }

      const episodeDom = document.querySelector('div.m-video-part-new > ul.list > li.part-item.on > span');
      if(episodeDom){
        let episode = episodeDom.textContent;
        videoInfo.title = episode + videoInfo.title;
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

    function handle91PormVideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.title = videoDom.getAttribute('title');
      videoInfo.poster = videoDom.getAttribute('poster');
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      if(!videoInfo.poster){
        const posterDom = document.querySelector('#player_one');
        if(posterDom){
          videoInfo.poster = posterDom.getAttribute('poster');
        }

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
                  qualityList.push({downloadUrl:item.videoUrl, qualityLabel:item.quality, quality: Number(item.quality)})
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

    function handle555yy4VideoInfo(videoDom){
      let videoInfo = {};
      videoInfo.poster = videoDom.getAttribute('poster') || '';
      videoInfo.downloadUrl = videoDom.getAttribute('src');
      videoInfo.title = videoDom.getAttribute('title');
      let videoTitle = window.parent.document.title;
      console.log('videoTitle------',videoTitle,window.parent.ep_title,window.parent.MAC.Title);
      if(!videoTitle){
        videoTitle = window.parent.ep_title;
        
      }
      if(!videoTitle){
        videoTitle = window.parent.MAC.Title;
      }
      videoInfo.title = videoTitle;
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
                videoList.push({title:item.title,poster:item.poster,downloadUrl:item.videoUrl,hostUrl:hostUrl,videoUuid:item.vid });
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
      if('m.baidu.com' === host){
        const baiduTitle = document.querySelector('.sfc-video-page-info .sfc-video-page-info-title h3.title-waterfallB');
        if(baiduTitle){
          videoInfo['title'] = baiduTitle.textContent;
        }
        const imgDom = document.querySelector('.video-poster .c-img-wrapper img.c-img-img');
        if(imgDom){
          videoInfo['poster'] = imgDom.getAttribute('src');
        }
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
     * @param() videoSnifferDom
     * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList}
     */
    function handleYoutubeVideoInfo(videoSnifferDom){
      let videoInfo = {};
      const ytplayer = window.ytplayer;
      let videoId = Utils.queryURLParams(hostUrl, 'v') || Utils.getLastPathParameter(hostUrl);
      if(!videoId){
        // console.log('videoId-------',videoId);
        let videoIdDom = document.querySelector('#player-control-container > ytm-custom-control > div.inline-player-controls > a.inline-player-overlay');
        if(videoIdDom){
          let hrefLink = videoIdDom.getAttribute('href');
          videoId = Utils.queryParams(hrefLink, 'v');
        }
      }

      // console.log('handleYoutubeVideoInfo---------------videoId-------------',videoId)
      const playerResp = ytplayer?ytplayer.bootstrapPlayerResponse : {};
      if(!videoId){
        return videoInfo;
      }
      let title = '';
      if(videoSnifferDom){
        videoInfo.poster = videoSnifferDom.getAttribute('poster') || '';
        videoInfo.downloadUrl = videoSnifferDom.getAttribute('src');
        let title = videoSnifferDom.getAttribute('title');
        videoInfo.title = title;
      }else{
        if(!ytplayer || !(playerResp.videoDetails)){
          return videoInfo;
        }
      }
      
      if(playerResp && playerResp.videoDetails && playerResp.streamingData && (!videoId || videoId === playerResp.videoDetails.videoId)){
        setYoutubePublicParam('', playerResp);
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
        const streamingData = playerResp.streamingData;
        const adaptiveFormats = streamingData.adaptiveFormats;
        const formats = streamingData.formats;
        title = title ? title : '';
        // 取画质的时候防止原视频有广告
        if(adaptiveFormats && adaptiveFormats.length && (!title || title.replace(/\s+/g,'') === detailTitle.replace(/\s+/g,''))){
          let qualityList = []
          let qualitySet = new Set();
          let jsPath = ytplayer.bootstrapWebPlayerContextConfig?ytplayer.bootstrapWebPlayerContextConfig.jsUrl:'';
          handleYTRandomPathUuidToDefinedObj(jsPath);
          // key为分辨率quality,value为分辨率数组
          let qualityVideoListMap = {};
          let mp4AudioArr = [];
          let webmAudioArr = [];
          adaptiveFormats.forEach(item => {
            let mimeType = item.mimeType;
            if(mimeType.indexOf('video')>-1){
              let quality = item.height;
              if(Object.prototype.hasOwnProperty.call(qualityVideoListMap, quality)){
                qualityVideoListMap[quality].push(item);
              }else{
                qualityVideoListMap[quality] = [item];
              }
            }else if(mimeType.indexOf('audio/mp4')>-1){
              mp4AudioArr.push(item);
            }else if(mimeType.indexOf('audio/webm')>-1){
              webmAudioArr.push(item);
            }
          })

          // 获取webm格式
          let webmAudioUrl = getYoutubeAudioUrlOrSignture(webmAudioArr);
          
          // 获取mp4音频
          let mp4AudioUrl = getYoutubeAudioUrlOrSignture(mp4AudioArr);

          Object.keys(qualityVideoListMap).map(key => {
            let qualityVideoArr = qualityVideoListMap[key];
            let qualityMp4VideoArr = qualityVideoArr.filter(item => {
              let mimeType = item.mimeType;
              if(mimeType.indexOf('video/mp4')>-1){
                return item;
              }
            });
            let qualityWebmVideoArr = qualityVideoArr.filter(item => {
              let mimeType = item.mimeType;
              if(mimeType.indexOf('video/webm')>-1){
                return item;
              }
            });
            let qualityVideoTempArr = [];
            let qualityVideoItem = {};
            // 大于1080的视频以webm优先
            if(Number(key)>=1080){
              if(qualityWebmVideoArr.length){
                qualityVideoTempArr = qualityWebmVideoArr;
              }else{
                qualityVideoTempArr = qualityMp4VideoArr;
              }
            }
            // 小于1080的视频以mp4优先
            else{
              if(qualityMp4VideoArr.length){
                qualityVideoTempArr = qualityMp4VideoArr;
              }else{
                qualityVideoTempArr = qualityWebmVideoArr;
              }
            }
            // console.log('qualityVideoTempArr--------',qualityVideoTempArr);
            qualityVideoTempArr.sort(Utils.compare('fps'));
            if(qualityVideoTempArr.length>1){
              let qualityVideoItem0 = qualityVideoTempArr[0];
              let qualityVideoItem1 = qualityVideoTempArr[1];
              if(qualityVideoItem0.fps == qualityVideoItem1.fps){
                if(qualityVideoItem1.qualityLabel.toLowerCase().indexOf('hdr')>-1){
                  qualityVideoItem = qualityVideoItem1;
                }else{
                  qualityVideoItem = qualityVideoItem0;
                }
              }else{
                qualityVideoItem = qualityVideoItem0;
              }
            }else{
              qualityVideoItem = qualityVideoTempArr[0];
            }
            
            let qualityItem = handleParseYtQualityInfo(qualityVideoItem, webmAudioUrl, mp4AudioUrl);
            if(qualityItem && Object.keys(qualityItem).length){
              if((qualityItem.audioUrl && !Utils.isURL(qualityItem.audioUrl)) || (qualityItem.videoUrl && !Utils.isURL(qualityItem.videoUrl))){
                videoInfo.shouldDecode = true;
              }
              qualityList.push(qualityItem);
            }
          })
          // console.log('qualityList===================',qualityList, videoInfo);
          if(qualityList && qualityList.length){
            if(!videoInfo['downloadUrl'] || videoInfo['downloadUrl'].startsWith('blob')){
              videoInfo['downloadUrl'] = qualityList[0].downloadUrl;
              videoInfo['audioUrl'] = qualityList[0].audioUrl;
              videoInfo['protect'] = qualityList[0].protect;
            }else{
              qualityList = matchDefaultUrlInQualityList(qualityList, videoInfo['downloadUrl']);
            }
            qualityList.sort(Utils.compare('qualityLabel'));
            videoInfo['qualityList'] = qualityList;
          }
          if(!videoInfo['downloadUrl']){
            videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
          }
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
        videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        // console.log('videoInfo----------',videoInfo);
      }

      let posterImg = videoInfo['poster'];
      if(!posterImg){
        posterImg = getYoutubeVideoPosterByDom();
      }
      if(playerResp.videoDetails && videoId != playerResp.videoDetails.videoId){
        posterImg = `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`;
      }
      if(!posterImg){
        posterImg = `https://i.ytimg.com/vi/${videoId}/hqdefault.jpg`;
      }
      videoInfo['poster'] = posterImg;

      if(checkAdForYoutube(videoInfo['downloadUrl'])){
        videoInfo['type'] = 'ad';
      }
      videoInfo.videoKey = videoId;

      // console.log('handleYoutubeVideoInfo-------videoId=',videoId);
      return videoInfo;
    }

    /**
     * 解析分辨率中视频信息
     * @param {Object} qualityVideoItem  原数据中的分辨率信息
     */
    function handleParseYtQualityInfo(qualityVideoItem, webmAudioUrl, mp4AudioUrl){
      // console.log('handleParseYtQualityInfo---------',qualityVideoItem);
      let mimeType = qualityVideoItem.mimeType;
      let qualityLabel = qualityVideoItem.qualityLabel;
      qualityLabel = qualityLabel ? qualityLabel.replace(/p[\d]{2}/, 'P') : '';
      let height = qualityVideoItem.height;
      if(height<1080){
        qualityLabel = qualityLabel ? qualityLabel.replace(/[\s]?HDR|hdr/, '') : '';
      }
      if(qualityVideoItem.url){
        let audioUrl = '';
        if(!mimeType.match(/.*codecs=.*webm.*/g)){
          audioUrl = webmAudioUrl;
        }
        if(!mimeType.match(/.*codecs=.*mp4.*/g)){
          audioUrl = mp4AudioUrl;
        }
        let sourceUrl = decodeYoutubeSpeedFun(qualityVideoItem.url);
        return {downloadUrl:sourceUrl, qualityLabel, quality: qualityVideoItem.quality, audioUrl}
      }else{
        let videoUrl = getYoutubeVideoUrlOrSignture(qualityVideoItem.signatureCipher);
        let audioUrl = '';
        let protect=true;
        // 没有匹配到带音频的视频，需要加上audioUrl
        if(!mimeType.match(/.*codecs=.*webm.*/g)){
          audioUrl = webmAudioUrl;
        }
        if(!mimeType.match(/.*codecs=.*mp4.*/g)){
          audioUrl = mp4AudioUrl;
        }
        return {downloadUrl:videoUrl, qualityLabel, quality: qualityVideoItem.quality, protect, audioUrl}
      }
    }

    function matchDefaultUrlInQualityList(qualityList, downloadUrl){
      let itag = Utils.queryURLParams(downloadUrl, 'itag');
      // console.log('itag------',itag);
      if(!itag){
        return qualityList;
      }
      
      let qualityLabel = getResolutionFromItag(itag);
  
      // console.log('qualityLabel------',qualityLabel);
      if(!qualityLabel){
        return qualityList;
      }
      
      qualityList.forEach(item=>{
        if(item.qualityLabel && item.qualityLabel.toLowerCase().indexOf(qualityLabel.toLowerCase())>-1){
          // console.log('match----qualityLabel------',qualityLabel);
          item.downloadUrl = downloadUrl;
          item.audioUrl = '';
          item.protect = false;
        }
        return item;
      })
  
      return qualityList;
    }
  
    function getResolutionFromItag(itag) {
      const resolutions = {
        5: '240p',
        6: '270p',
        13: '144p',
        17: '144p',
        18: '360p',
        22: '720p',
        34: '360p',
        35: '480p',
        36: '240p',
        37: '1080p',
        38: '3072p',
        43: '360p',
        44: '480p',
        45: '720p',
        46: '1080p',
        59: '480p',
        78: '480p',
        82: '360p',
        83: '480p',
        84: '720p',
        85: '1080p',
        91: '144p',
        92: '240p',
        93: '360p',
        94: '480p',
        95: '720p',
        96: '1080p',
        100: '360p',
        101: '480p',
        102: '720p',
        132: '240p',
        151: '720p',
        133: '240p',
        134: '360p',
        135: '480p',
        136: '720p',
        137: '1080p',
        138: '2160p',
        160: '144p',
        212: '480p',
        213: '480p',
        214: '720p',
        215: '720p',
        216: '1080p',
        217: '1080p',
        264: '1440p',
        266: '2160p',
        298: '720p',
        299: '1080p',
        399: '1080p',
        398: '720p',
        397: '480p',
        396: '360p',
        395: '240p',
        313: '2160p',
        337: '2160p HDR',
      };
    
      return resolutions[itag];
    }

    function handleYTRandomPathUuidToDefinedObj(jsPath){
      try {
        if(jsPath){
          ytRandomBaseJs = jsPath;
          let tempRandomCode = parseBaseJsPath(jsPath);
          if(tempRandomCode){
            definedObj.randomPathUuid = tempRandomCode;
          }
        }
      } catch (error) {
        
      }
    }

    function parseBaseJsPath(jsPath){
      if(!jsPath){
        return '';
      }
      let tempRandomCode = '';
      let pathArr = jsPath.split('/');
      if(jsPath.startsWith('/')){
        tempRandomCode = pathArr[3]
      }else{
        tempRandomCode = pathArr[2]
      }
      return tempRandomCode;
    }

    function checkAdForYoutube(downloadUrl){
      if((downloadUrl && downloadUrl.indexOf('pltype=adhost')>-1)){
        return true;
      }
      const adPlayer = document.querySelector('#container .video-ads');
      if(adPlayer && !isHidden(adPlayer)){
        return true;
      }
      return false;
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
    
    
    /**
     * 
     * @param {String} pathUuid   /s/player/7862ca1f/player_ias.vflset/zh_CN/base.js中7862ca1f关键字符串
     * @param {String} pathUrl    base.js的路径/s/player/7862ca1f/player_ias.vflset/zh_CN/base.js
     * @returns 
     */
    function fetchYoutubeDecodeFun(pathUuid, pathUrl){
      // console.log('fetchYoutubeDecodeFun-----pathUuid=',pathUuid, ',pathUrl=',pathUrl);
      pathUrl = window.location.href;
      return new Promise((resolve, reject) => {
        if(isContent){
          // console.log('fetchYoutubeDecodeFun-----true');
          browser.runtime.sendMessage({from: 'sniffer', operate: 'fetchYoutubeDecodeFun', pathUuid: pathUuid, pathUrl}, (response) => {
            // console.log('fetchYoutubeDecodeFun-----true----',response)
            let decodeFunObj = response&&response.decodeFunObj?response.decodeFunObj:{};
            resolve(decodeFunObj);
          });
        }else{
          // console.log('fetchYoutubeDecodeFun-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_YOUTUBE_DECODE_FUN_RESP') return;
            // console.log('fetchYoutubeDecodeFun-----false----',e.data)
            resolve(e.data.decodeFunObj);
            window.removeEventListener('message', callback);
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_YOUTUBE_DECODE_FUN', pathUuid, pathUrl });
          window.addEventListener('message', callback);
        }
      })
    }

    /**
     * 
     * @param {String} pathUuid   /s/player/7862ca1f/player_ias.vflset/zh_CN/base.js中7862ca1f关键字符串
     * @param {String} pathUrl    base.js的路径/s/player/7862ca1f/player_ias.vflset/zh_CN/base.js
     * @returns 
     */
    function saveYoutubeDecodeFun(pathUuid, randomFunStr, randomSpeedFunStr){
      console.log('saveYoutubeDecodeFun-----pathUuid=',pathUuid, ',randomFunStr=',randomFunStr);
      if(isContent){
        console.log('saveYoutubeDecodeFun-----true');
        browser.runtime.sendMessage({from: 'sniffer', operate: 'saveYoutubeDecodeFun', pathUuid: pathUuid, randomFunStr, randomSpeedFunStr}, (response) => {
          console.log('saveYoutubeDecodeFun---------',response)
        });
      }else{
        console.log('saveYoutubeDecodeFun-----false');
        const pid = Math.random().toString(36).substring(2, 9);
        const callback = e => {
          if (e.data.pid !== pid || e.data.name !== 'SAVE_YOUTUBE_DECODE_FUN_STR_RESP') return;
          console.log('saveYoutubeDecodeFun---------',e.data.decodeFun)
          window.removeEventListener('message', callback);
        };
        window.postMessage({ id: pid, pid: pid, name: 'SAVE_YOUTUBE_DECODE_FUN_STR', pathUuid, randomFunStr, randomSpeedFunStr});
        window.addEventListener('message', callback);
      }
      
    }

    async function startFetchYoutubeFunStr(){
      // console.log('startFetchYoutubeFunStr-------start-------------',host);
      if(!(host.indexOf('youtube.com')>-1)){
        // console.log('startFetchYoutubeFunStr-------is not youtube-------------');
        return;
      }
      queryYoutubePlayerPath((pathUuid, jsPath)=>{
        let decodeObjStr = window.localStorage.getItem('__stay_decode_str');
        if(decodeObjStr){
          console.log('startFetchYoutubeFunStr------',pathUuid, jsPath, decodeObjStr);
          decodeSignatureCipher = JSON.parse(decodeObjStr);
          // pathUuid与本地匹配
          if(decodeSignatureCipher.pathUuid && decodeSignatureCipher.pathUuid == pathUuid){
            if(decodeSignatureCipher.decodeFunStr){
              handleDecodeSignatureAndPush();
              // 异步请求一次服务端的code, 获取服务端最新配置
              handleFetchYoutubePlayer(pathUuid, jsPath, false);
            }else{
              handleFetchYoutubePlayer(pathUuid, jsPath, true)
            }
          }else{
            // 本地不匹配器
            handleFetchYoutubePlayer(pathUuid, jsPath, true)
          }
        }else{
          handleFetchYoutubePlayer(pathUuid, jsPath, true)
        }
      })
    }

    function queryYoutubePlayerPath(callback){
      if(window.ytplayer){
        ytRandomBaseJs = window.ytplayer.bootstrapWebPlayerContextConfig?window.ytplayer.bootstrapWebPlayerContextConfig.jsUrl:'';
      }
      if(ytRandomBaseJs){
        ytBaseJSUuid = parseBaseJsPath(ytRandomBaseJs);
        callback(ytBaseJSUuid, ytRandomBaseJs);
      }else{
        for(let i=1; i<10; i++){
          let timer
          (function(i){
            timer = setTimeout(()=>{
              playerBase = document.querySelector('#player-base');
              // console.log('queryYoutubePlayer------i-----',i, new Date().getTime());
              if(playerBase && playerBase.getAttribute('src')){
                // console.log('queryYoutubePlayer---iiiiiii---break-----');
                ytRandomBaseJs = playerBase.getAttribute('src');
                ytBaseJSUuid = parseBaseJsPath(ytRandomBaseJs);
                callback(ytBaseJSUuid, ytRandomBaseJs);
                // handleFetchYoutubePlayer(pathUuid, jsPath, true)
                timerArr.forEach(timerItem=>{
                  // console.log('clearTimer---------timerItem-----',timerItem);
                  clearTimeout(timerItem);
                })
              }
            },i*200);
          })(i)
          if(playerBase && playerBase.getAttribute('src')){
            break;
          }
          timerArr.push(timer);
        }
      }
    }

    /**
     * {pathUuid:pathUuid, decodeStr: decodeSignatureCipher}
     * @param {String} pathUuid 
     * @param {String} jsPath 
     * @param {boolean} shouldDecode   是否需要执行解密方法
     */
    async function handleFetchYoutubePlayer(pathUuid, jsPath, shouldDecode){
      let decodeFunObj = await fetchYoutubeDecodeFun(pathUuid, jsPath);
      console.log('handleFetchYoutubePlayer------',decodeFunObj);
      if(decodeFunObj && Object.keys(decodeFunObj).length){
        // 200匹配到方法，可解析，
        if( decodeFunObj.status && 200 == decodeFunObj.status){
          setLocalYTRandomFunStr(pathUuid, decodeFunObj.decodeFunStr, decodeFunObj.decodeSpeedFunStr);
          if(shouldDecode){
            handleDecodeSignatureAndPush();
          }
        }else{
          // 404未匹配到，需要重新从base中匹配方法
          fetchCurrentYtRandomStr(pathUuid, jsPath);
        }
      }else{
        console.log('handleFetchYoutubePlayer---decodeFunObj--null-----')
        fetchCurrentYtRandomStr(pathUuid, jsPath);
        
      }
    }
    
    function setLocalYTRandomFunStr(pathUuid, decodeFunStr, decodeSpeedFunStr){
      decodeSignatureCipher = {pathUuid, decodeFunStr, decodeSpeedFunStr};
      definedObj.decodeFunStr = decodeFunStr;
      definedObj.decodeSpeedFunStr = decodeSpeedFunStr;
      window.localStorage.setItem('__stay_decode_str', JSON.stringify(decodeSignatureCipher));
    }

    async function fetchCurrentYtRandomStr(pathUuid, jsPath){
      if(!jsPath || !pathUuid){
        setLocalYTRandomFunStr(pathUuid, '', '');
        console.log('fetchCurrentYtRandomStr--------pathUuid=',pathUuid,',jsPath=',jsPath)
        return;
      }
      function testYtDecodeFun(randomFunStr){
        try {
          let decodeFun =  new Function('return '+randomFunStr); 
          let signature = '%3D%3DQmbTSWlgLuztoft4F_uqQieS7_jBtboKab9zSp5WRdSAiApcTRtZLjBmFtzLXphJ0x_haWmWIhVtdAg8jD1rsKkRKAhIQRw8JQ0qOAOA';
          // eslint-disable-next-line max-len
          let sourceUrl = 'https://rr5---sn-o097znsk.googlevideo.com/videoplayback%3Fexpire%3D1679042695%26ei%3DJ9QTZJ6FFKeksfIPkaSL-Aw%26ip%3D2602%253Afeda%253A30%253Aae86%253A40e7%253A53ff%253Afe8b%253A9a97%26id%3Do-AI3u_uLu7PqvSwoVFwTG0fSk-puen4XBHxlLqco9MH8Q%26itag%3D135%26aitags%3D133%252C134%252C135%252C160%252C242%252C243%252C244%252C278%26source%3Dyoutube%26requiressl%3Dyes%26mh%3D_m%26mm%3D31%252C26%26mn%3Dsn-o097znsk%252Csn-a5meknzk%26ms%3Dau%252Conr%26mv%3Dm%26mvi%3D5%26pl%3D44%26initcwndbps%3D2135000%26vprv%3D1%26mime%3Dvideo%252Fmp4%26ns%3DwhOrAPi40PxLIKHeHvAaoDIL%26gir%3Dyes%26clen%3D18438908%26dur%3D584.533%26lmt%3D1635010443575003%26mt%3D1679020854%26fvip%3D5%26keepalive%3Dyes%26fexp%3D24007246%26c%3DMWEB%26txp%3D5432434%26n%3D3BrEIxrXFc7SkC%26sparams%3Dexpire%252Cei%252Cip%252Cid%252Caitags%252Csource%252Crequiressl%252Cvprv%252Cmime%252Cns%252Cgir%252Cclen%252Cdur%252Clmt%26lsparams%3Dmh%252Cmm%252Cmn%252Cms%252Cmv%252Cmvi%252Cpl%252Cinitcwndbps%26lsig%3DAG3C_xAwRgIhAKYBlOvRZiHPnnEJJ5foNn7LZU1cgGvfyO3WU9TjETfZAiEA6PvSgRq0gdcsBBTTj0VHXybmMwb-ouW2TVIYGmG_PG0%253D';
          signature = decodeFun()(decodeURIComponent(signature));
          sourceUrl = `${decodeURIComponent(sourceUrl)}&sig=${signature}`;
          // console.log(sourceUrl);
          if(sourceUrl){
            return true;
          }
        } catch (error) {
          
        }
        return false;
      }
      try {
        let jsResponse = await fetch(`https://m.youtube.com${jsPath}`);
        let jsText = await jsResponse.text();
        if(!jsText){
          setLocalYTRandomFunStr(pathUuid, '', '');
          console.log('handleFetchYoutubePlayer------jsText is null')
          return;
        }
        // eslint-disable-next-line no-useless-escape
        let randomArr = jsText.match(/[a-zA-Z0-9$]+\=function\(a\)\{[\r\n|a]\=a\.split\(\"\"\).*return\s+a\.join\(\"\"\)\};/g);
        console.log(randomArr)
        let randomFunStr = '';
        if(randomArr && randomArr.length){
          randomFunStr = randomArr[0];
          // console.log(randomFunStr);
        }
        if(!randomFunStr){
          setLocalYTRandomFunStr(pathUuid, '', '');
          console.log('handleFetchYoutubePlayer---1---randomFunStr is null')
          return;
        }
        let subRandomStr = '';
        // eslint-disable-next-line no-useless-escape
        let subRandomArr = jsText.match(/var\s+[a-zA-Z0-9$]{2}\=\{[a-zA-Z0-9]{2}\:function[\s\S]*(a\.reverse\(\)|splice\(0\,b\)|length\]\=c)\}\};/g);
        if(subRandomArr && subRandomArr.length){
          subRandomStr = subRandomArr[0];
          // console.log(subRandomStr);
        }
        if(!subRandomStr){
          setLocalYTRandomFunStr(pathUuid, '', '');
          console.log('handleFetchYoutubePlayer------subRandomStr is null')
          return;
        }
        // eslint-disable-next-line no-useless-escape
        randomFunStr = randomFunStr.replace(/[a-zA-Z0-9$]+\=function\(a\)\{/g, 'function decodeFun(a){'+subRandomStr);
        if(!randomFunStr){
          setLocalYTRandomFunStr(pathUuid, '', '');
          console.log('handleFetchYoutubePlayer---2---randomFunStr is null')
          return;
        }
        // console.log('randomFunStr-------',randomFunStr);
        let randomSpeedFunStr = '';
        // eslint-disable-next-line no-useless-escape
        let randomSpeedArr = jsText.match(/[a-zA-Z0-9$]+\=function\(a\)\{var\sb=a\.split\(\"\"\)[\s\S]*\}return\sb\.join\(\"\"\)\};/g);
        if(randomSpeedArr && randomSpeedArr.length){
          randomSpeedFunStr = randomSpeedArr[0];
          // console.log(randomSpeedFunStr);
        }
        if(randomSpeedFunStr){
          // eslint-disable-next-line no-useless-escape
          randomSpeedFunStr = randomSpeedFunStr.replace(/^[a-zA-Z0-9$]+\=function\(a\)\{/g, 'function decodeSpeedFun(a){');
          // console.log('randomSpeedFunStr------',randomSpeedFunStr);
        }
        if(testYtDecodeFun(randomFunStr)){
          saveYoutubeDecodeFun(pathUuid, randomFunStr, randomSpeedFunStr);
        }else{
          console.log('handleFetchYoutubePlayer------testYtDecodeFun-------false',randomFunStr);
        }
        setLocalYTRandomFunStr(pathUuid, randomFunStr, randomSpeedFunStr);
      } catch (error) {
        console.error(jsPath,error);
        setLocalYTRandomFunStr(pathUuid, '', '');
      }
    }

    async function fetchLongPressConfig(){
      if(!isStayAround){
        isLoadingAround = true;
        isStayAround = await getStayAround();
        isLoadingAround = false;
      }
      if(!longPressStatus){
        isLoadingLongPressStatus = true;
        longPressStatus = await getLongPressStatus();
        isLoadingLongPressStatus = false;
      }
    }
    
    function startSnifferVideoInfoOnPage(complate){
      fetchLongPressConfig();
      startFetchYoutubeFunStr();
      startFindVideoInfo(complate);
    }

    startSnifferVideoInfoOnPage(false);


    document.onreadystatechange = () => {
      // console.log('document.readyState==',document.readyState)
      if (document.readyState === 'complete') {
        // console.log('readyState-------------------', document.readyState)
        startSnifferVideoInfoOnPage(true);
      }
    };

    /* eslint-disable */
    Object.defineProperty(definedObj, 'randomPathUuid', {
      get:function(){
        return randomPathUuid;
      },
      set:function(newValue){
        randomPathUuid = newValue;
        //监听ytBaseJSUuid如果发生变化，则需要从basejs中重新匹配解密方法
        if(newValue != ytBaseJSUuid){
          console.log('randomPathUuid--!==-newValue-----',randomPathUuid);
          ytBaseJSUuid = newValue
          handleFetchYoutubePlayer(ytBaseJSUuid, ytRandomBaseJs, false);
        }
      }
    });
    Object.defineProperty(definedObj, 'decodeFunStr', {
      get:function(){
        return decodeFunStr;
      },
      set:function(newValue){
        decodeFunStr = newValue;
        if(decodeFunStr){
          handleDecodeSignatureAndPush();
        }
      }
    });

    /**
     * @discarded 废弃请求拦截
     */
    function handlePageInterceptor(){
      function isVideoLink(url){
        let re = /^(https?:\/\/|\/).*\.(mp4|m3u8)$/;
        return url.match(re) != null;
      }    
        
      let uniqueUrls = new Set()
      //XMLHttpRequest.prototype.reallySend = XMLHttpRequest.prototype.send;
      XMLHttpRequest.prototype.reallyOpen = XMLHttpRequest.prototype.open;
        
      XMLHttpRequest.prototype.open = function(method, url, async, user, password){
        console.log('OPEN_URL',url);
        this.reallyOpen(method,url,async,user,password);
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

    // handlePageInterceptor();

  }

  let videoPageUrl = window.location.href;
  let videoInfoList = [];
  let videoLinkSet = new Set();
  window.addEventListener('message', (e) => {
    if (!e || !e.data || !e.data.name) return;
    const name = e.data.name;
    // console.log('snifffer.user----->e.data.name=',name);
    // @discarded  VIDEO_LINK_CAPTURE
    if(name === 'VIDEO_LINK_CAPTURE'){
      let tempSet = e.data.urls ? e.data.urls : new Set();
      videoLinkSet = tempSet
      let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH', videoPageUrl, videoLinkSet};
      browser.runtime.sendMessage(message, (response) => {});
    }
    else if(name === 'VIDEO_INFO_CAPTURE'){
      let videoInfoListTemp = e.data.videoList ? e.data.videoList : [];
      videoInfoList = videoInfoListTemp
      let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH', videoPageUrl, videoInfoList};
      browser.runtime.sendMessage(message, (response) => {});
    }
    else if(name === 'GET_STAY_AROUND'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'sniffer', operate: 'GET_STAY_AROUND'}, (response) => {
        window.postMessage({pid:pid, name: 'GET_STAY_AROUND_RESP', response: response });
      });
    }
    else if(name === 'GET_LONG_PRESS_STATUS'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'popup', operate: 'getLongPressStatus'}, (response) => {
        let longPressStatusRes = response&&response.longPressStatus?response.longPressStatus:'on';
        window.postMessage({pid:pid, name: 'GET_LONG_PRESS_STATUS_RESP', longPressStatusRes});
      });
    }
    else if(name === 'GET_YOUTUBE_DECODE_FUN'){
      let pid = e.data.pid;
      let pathUuid = e.data.pathUuid;
      let pathUrl = e.data.pathUrl;
      browser.runtime.sendMessage({from: 'sniffer', operate: 'fetchYoutubeDecodeFun', pathUrl, pathUuid}, (response) => {
        // console.log('fetchYoutubeDecodeFun------response----',response);
        let decodeFunObj = response&&response.decodeFunObj?response.decodeFunObj:{};
        window.postMessage({pid:pid, name: 'GET_YOUTUBE_DECODE_FUN_RESP', decodeFunObj:decodeFunObj});
      });
    }
    else if(name === 'SAVE_YOUTUBE_DECODE_FUN_STR'){
      let pid = e.data.pid;
      let pathUuid = e.data.pathUuid;
      let randomFunStr = e.data.randomFunStr;
      let randomSpeedFunStr = e.data.randomSpeedFunStr;
      browser.runtime.sendMessage({from: 'sniffer', operate: 'saveYoutubeDecodeFun', pathUuid, randomFunStr, randomSpeedFunStr}, (response) => {
        let decodeFun = '';
        window.postMessage({pid:pid, name: 'SAVE_YOUTUBE_DECODE_FUN_STR_RESP', decodeFun});
      });
    }
  })
})()