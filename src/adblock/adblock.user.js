/**
 * 解析页面video标签
 */

let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function () {

  async function fetchStayAroundStatus(){
    return new Promise((resolve, reject) => {
      browser.runtime.sendMessage({from: 'content_script', operate: 'GET_STAY_AROUND'}, (response) => {
        console.log('GET_STAY_AROUND---------',response)
        let isStayAround = '';
        if(response.body && JSON.stringify(response.body)!='{}'){
          console.log('isStayAround---------', response.body)
          
          isStayAround = response.body;
            
        }
        resolve(isStayAround)
      });
    })
  }

  async function startInjectScript(){
    let isStayAround = await fetchStayAroundStatus();
    if(isStayAround == 'a'){
      try {
        // for page
        handleInjectScriptToPage();
        document.addEventListener('securitypolicyviolation', (e) => {
          // for content
          injectSelectedAdTagJS(true);
        })
      } catch (error) {
                
      }
    }
  }
  
  startInjectScript();

  
  /**
   * for page 
   */ 
  function handleInjectScriptToPage(){
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let contentHost = window.location.host;
    let scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.id = '__stay_inject_selecte_ad_tag_js_'+contentHost;
    let injectJSContent = `\n\nconst handleInjectSelectedAdTagJS = ${injectSelectedAdTagJS}\n\nhandleInjectSelectedAdTagJS(false);`;
    scriptTag.appendChild(document.createTextNode(injectJSContent));
    if (document.body) {
      document.body.appendChild(scriptTag);
    } else {
      let observerBody = new MutationObserver((mutations, observer) => {
        if (document.body) {
          document.body.appendChild(scriptTag);
          observerBody.disconnect();
        }
      });
      observerBody.observe(document.documentElement, { attributes: true, childList: true, characterData: true, subtree: true });
    }
  }

  /**
   * 注入标记广告方法
   * @param {boolean} isContent false:page模式，true:content模式
   */
  function injectSelectedAdTagJS(isContent){
    let showMakeupTagPanel = false;
    let checkZindexFlag = false;
    let showMakeupTagMenu = false;
    let makeupTagListenerObj = {threeFingerTapStatus: ''};
    let moveWrapperDom = null;
    let closeTagingDom = null;
    let preselectedTargetDom = null;
    let threeFingerMoveStart = null;
    let threeFingerMoveEnd = null;
    let selectedDom = null;
    let notShowTagNameList = ['STYLE','SCRIPT','#text','LINK', 'META'];
    let i18nProp = {};
    let cssSelectorSet = new Set();
    const AdLangMessage = {
      'en_US': {
        'tag_as_ad': 'Tag as ad',
        'expand': 'Expand',
        'narrow_down': 'Narrow down',
        'previous_sibling': 'Previous sibling',
        'next_sibling': 'Next sibling',
        'cancel': 'Cancel',
        'select_note': 'Tap to select an element',
        'select_confirm': 'Tap again to confirm the element',
      },
      'zh_CN': {
        'tag_as_ad': '标记为广告',
        'expand': '扩大',
        'narrow_down': '缩小',
        'previous_sibling': '前个兄弟节点',
        'next_sibling': '下个兄弟节点',
        'cancel': '取消',
        'select_note': '点击选择一个元素',
        'select_confirm': '再次点击确认元素',
      },
      'zh_HK': {
        'tag_as_ad': '標記為廣告',
        'expand': '擴大',
        'narrow_down': '縮小',
        'previous_sibling': '前個兄弟節點',
        'next_sibling': '下個兄弟節點',
        'cancel': '取消',
        'select_note': '點擊選擇一個元素',
        'select_confirm': '再次點擊確認元素',
      },
    }
    const distance = 10;
    const Utils = {
      checkExternalMouseConnected(){
        const gamepads = navigator.getGamepads();
        for (let i = 0; i < gamepads.length; i++) {
          const gamepad = gamepads[i];
          // 判断是否为鼠标类型
          if (gamepad && gamepad.mapping === 'standard' && gamepad.buttons.length >= 3) {
            return true;
          }
        }
        
        return false;
      },
      parseToDOM(str){
        let divDom = document.createElement('template');
        if(typeof str == 'string'){
          divDom.innerHTML = str;
          return divDom.content;
        }
        return str;
      },
      isMobileOrIpad: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        return getArr.length ? true : false;
      },
      isMobile: function(){
        const userAgentInfo = navigator.userAgent;
        let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPod'];
        let getArr = Agents.filter(i => userAgentInfo.includes(i));
        return getArr.length ? true : false;
      },
      useTouchEvent: function(){
        if(this.isMobile()){
          return true;
        }else{
          const hasMouse = this.checkExternalMouseConnected()
          if(hasMouse){
            return false;
          }else{
            return true;
          }
        }
      },
      isDark() {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
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
        return (this.mul(a, e) + this.mul(b, e)) / e;
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
    const clickEvent = Utils.isMobileOrIpad()?'touchstart':'click';
    let borderColor = '#ffffff';
    // if(!Utils.isMobileOrIpad()){
    //   borderColor = '#B620E0';
    // }
    const borderSize = 2;
    function languageCode() {
      let lang = (navigator.languages && navigator.languages.length > 0) ? navigator.languages[0]
        : (navigator.language || navigator.userLanguage /* IE */ || 'en');
      lang = lang.toLowerCase();
      lang = lang.replace(/-/, '_'); // some browsers report language as en-US instead of en_US
      if (lang.length > 3) {
        lang = lang.substring(0, 3) + lang.substring(3).toUpperCase();
      }
      if (lang == 'zh_TW' || lang == 'zh_MO'){
        lang = 'zh_HK'
      }
      return lang;
    }
    
    function createStyleTag(){
      let closeBg = '#ffffff';
      let closePopup = 'https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png';
      if(Utils.isDark()){
        closePopup = 'https://res.stayfork.app/scripts/27AB16B17B3CCBEFA53E5CAC0DE3215D/icon.png';
        closeBg = '#1C1C1C';
      }
     
      
      if(!document.querySelector('#__stay_select_style')){
        const styleDom = document.createElement('style');
        styleDom.type = 'text/css';
        styleDom.id='__stay_select_style';
        const styleText = `
                    .__stay_move_wrapper{
                      position:fixed;
                      left:0;
                      right:0;
                      top:0;
                      bottom:0;
                      z-index:2147483645;
                      width:100%;
                      height:100%;
                      background-color:rgba(0,0,0,0.4);
                      box-sizing: border-box;
                      user-select: none;
                      cursor: default;
                    }
                    .__stay_close_con{
                      position:fixed;
                      z-index:2147483646;
                      right: 20px;
                      top: 20px;
                      width:26px;
                      height:26px;
                      background: url("${closePopup}") 50% 50% no-repeat;
                      background-size: 40%;
                      background-color: ${closeBg};
                      border-radius:50%;
                      cursor: default;
                      user-select: none;
                    }
                    .__stay_select_target{display:none;position:fixed; box-sizing:border-box;z-index:2147483647; background-color:rgba(0,0,0,0);border: ${borderSize}px solid ${borderColor}; border-radius: 6px;box-shadow: 1px -1px 20px rgba(0,0,0,0.2);}
                    .__stay_makeup_menu_wrapper{
                      width:192px;
                      position:fixed;
                      padding: 8px 5px;
                      box-sizing: border-box;
                      z-index: 2147483647;
                    }
                    .__stay_makeup_menu_item_box{
                      width:100%;
                      box-sizing: border-box;
                      background-color: #ffffff;
                      padding-left: 12px;
                      border-radius: 5px;
                      box-shadow: 0px 2px 10px rgba(0,0,0,0.3);
                      user-select: none;
                      cursor: default;
                    }
                    .__stay_menu_item{
                      color: #212121;
                      -webkit-user-select: none;
                      height:40px;
                      border-bottom: 1px solid #e0e0e0;
                      display:flex;
                      justify-content: space-between;
                      align-items: center;
                      padding-left: 2px;
                      padding-right: 12px;
                      font-size: 16px;
                      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
                      -webkit-font-smoothing: antialiased;
                      -moz-osx-font-smoothing: grayscale;
                      cursor: default;
                      user-select: none;
                    }
                    .__item_disabled div,.__item_disabled img{
                      opacity: 0.3;
                    }
                    .__stay_weight{
                      font-weight: 600;
                    }
                    .__stay_menu_item:last-child {
                      border-bottom: none;
                    }
                    .__stay_menu_item img{
                      width:15px;
                    }
                    .__stay_select_note_warpper{
                      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
                      -webkit-font-smoothing: antialiased;
                      -moz-osx-font-smoothing: grayscale;
                      position:fixed; 
                      z-index:2147483647;
                      display: inline-block;
                      word-break: keep-all;
                      white-space: nowrap;
                      height: 25px;
                      border-radius: 10px;
                      line-height: 25px;
                      text-align: center;
                      padding: 0 15px;
                      box-sizing: border-box;
                      background-color: #fff;
                      color: #000;
                      font-weight: 700;
                      font-size: 13px;
                      left: 50%;
                      transform: translate(-50%);
                      top: -60px;
                      user-select: none;
                    }
                    .__stay_tagged_wrapper{
                      font-family: "HelveticaNeue-Light", "Helvetica Neue Light", "Helvetica Neue",Helvetica, Arial, "Lucida Grande", sans-serif;
                      -webkit-font-smoothing: antialiased;
                      -moz-osx-font-smoothing: grayscale;
                      position:fixed; 
                      z-index:2147483647;
                      width:160px;
                      height: 44px;
                      border-radius: 22px;
                      line-height: 44px;
                      text-align: center;
                      padding-left: 15px;
                      box-sizing: border-box;
                      background-color: #fff;
                      color: #000;
                      font-weight: 700;
                      font-size: 16px;
                      animation: dropIn 0.5s forwards;
                      left: 50%;
                      transform: translate(-50%, -50%);
                      top: -68px;
                      user-select: none;
                    }
                    .__stay_tagged_wrapper::before{
                      content: '';
                      background: url("https://res.stayfork.app/scripts/63A0624BB9B6793A0F389D1800E403EA/icon.png") 50% 50% no-repeat;
                      background-size: 20px;
                      width: 20px;
                      height: 20px;
                      position: absolute;
                      left: 20px;
                      top: 50%;
                      transform: translate(0, -50%);
                    }
                    @keyframes dropIn {
                      0% {
                        transform: translate(-50%, -100%);
                      }
                      100% {
                        transform: translate(-50%, 80px);
                      }
                    }
                    @keyframes dropOut {
                      0% {
                        transform: translate(-50%, 80px);
                      }
                      100% {
                        transform: translate(-50%, -100%);
                      }
                    }
                `;
        styleDom.appendChild(document.createTextNode(styleText));
        document.head.appendChild(styleDom);
      }
      
    }

    function handleThreeFingerEvent(threeFingerTapStatus){
      if(threeFingerTapStatus == 'on'){
        add3FingerEventListener();
      }else{
        remove3FingerEventListener();
      }
      asyncSetThreeFingerTapStatus(threeFingerTapStatus)
    }

    /**
     * 绑定三指手势触屏事件
     */
    function add3FingerEventListener(){
      // console.log('add3FingerEventListener---------')
      const threeFingerGesturestart = document.addEventListener('touchstart', handleTouchstartEvent);
      const threeFingerGesturechange =  document.addEventListener('touchmove', handleTouchmoveEvent);
      const threeFingerGestureend =  document.addEventListener('touchend', handleTouchendEvent);
    }

    /**
     * 移除三指手势触屏事件
     */
    function remove3FingerEventListener(){
      // console.log('remove3FingerEventListener---------')
      document.removeEventListener('touchstart', handleTouchstartEvent);
      document.removeEventListener('touchmove', handleTouchmoveEvent);
      document.removeEventListener('touchend', handleTouchendEvent);
    }

    function handleTouchstartEvent(event){
      // console.log('handleTouchstartEvent-------', event)
      if (event.touches.length === 3) {
        event.preventDefault();
        threeFingerMoveStart = event.pageX;
        if(!showMakeupTagPanel){
          if('on' == makeupTagListenerObj.makeupStatus){
            startSelecteTagAndMakeupAd()
          }else{
            makeupTagListenerObj.makeupStatus = 'on';
          }
        }
      }
      
    }

    function handleTouchmoveEvent(event){
      // console.log('handleTouchmoveEvent-------', event)
      if ( event.touches.length === 3) {
        event.preventDefault();
        threeFingerMoveEnd = event.pageX;
        let moveDistance = Math.abs(Utils.sub(threeFingerMoveEnd, threeFingerMoveStart));
        if(moveDistance <= distance && !showMakeupTagPanel){
          if('on' == makeupTagListenerObj.makeupStatus){
            startSelecteTagAndMakeupAd()
          }else{
            makeupTagListenerObj.makeupStatus = 'on';
          }
        }
      }
      // 阻止默认事件
      
    }

    function handleTouchendEvent(event){
      // event.preventDefault();
      threeFingerMoveStart = null;
      threeFingerMoveEnd = null;
    }

    /**
     * 异步获取标记标签状态
     * @returns 
     */
    async function asyncFetchMakeupTagStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          // console.log('asyncFetchMakeupTagStatus---isContent--true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
            // console.log('asyncFetchMakeupTagStatus---------',response)
            let makeupTagStatus = response&&response.makeupTagStatus?response.makeupTagStatus:'on';
            makeupTagListenerObj.makeupStatus = makeupTagStatus;
          });
        }else{
          // console.log('asyncFetchMakeupTagStatus---isContent--false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_MAKEUP_TAG_STATUS_RESP') return;
            // console.log('asyncFetchMakeupTagStatus---------',e.data.makeupTagStatus)
            window.removeEventListener('message', callback);
            let makeupStatus = e.data.makeupTagStatus
            makeupTagListenerObj.makeupStatus = makeupStatus;
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_MAKEUP_TAG_STATUS' });
          window.addEventListener('message', callback);
        }
        resolve(true)
      })
    }

    /**
     * 异步获取三指触屏状态
     * @returns 
     */
    async function asyncFetchThreeFingerTapStatus(){
      return new Promise((resolve, reject) => {
        if(isContent){
          // console.log('asyncFetchThreeFingerTapStatus---isContent--true');
          browser.runtime.sendMessage({from: 'popup', operate: 'getThreeFingerTapStatus'}, (response) => {
            // console.log('getThreeFingerTapStatus---------',response)
            let threeFingerTapStatus = response&&response.threeFingerTapStatus?response.threeFingerTapStatus:'on';
            makeupTagListenerObj.shouldSetThreeFingerTapStatus = false;
            makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
          });
          resolve(true);
        }else{
          // console.log('getThreeFingerTapStatus--isContent---false');
          const pid = Math.random().toString(36).substring(2, 9);
          const callback = e => {
            if (e.data.pid !== pid || e.data.name !== 'GET_THREE_FINGER_TAG_STATUS_RESP') return;
            let threeFingerTapStatus = e.data.threeFingerTapStatus
            // console.log('asyncFetchThreeFingerTapStatus-----getThreeFingerTapStatus---------', threeFingerTapStatus)
            //监听到content发过来的消息就不需要再set
            makeupTagListenerObj.shouldSetThreeFingerTapStatus = false;
            makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
            window.removeEventListener('message', callback);
            resolve(true);
          };
          window.postMessage({ id: pid, pid: pid, name: 'GET_THREE_FINGER_TAG_STATUS' });
          window.addEventListener('message', callback);
        }
      })
    }

    async function asyncSetThreeFingerTapStatus(threeFingerTapStatus){
      return new Promise((resolve, reject) => {
        if(!makeupTagListenerObj.shouldSetThreeFingerTapStatus){
          resolve(false);
          return;
        }
        // console.log('asyncSetThreeFingerTapStatus-----threeFingerTapStatus----', threeFingerTapStatus);
        if(isContent){
          // console.log('asyncSetThreeFingerTapStatus-----true');
          browser.runtime.sendMessage({from: 'content_script', operate: 'setThreeFingerTapStatus', threeFingerTapStatus}, (response) => {
            console.log('asyncSetThreeFingerTapStatus---------',response)
          });
        }else{
          // console.log('asyncSetThreeFingerTapStatus-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid: pid, name: 'SET_THREE_FINGER_TAG_STATUS',  threeFingerTapStatus});
        }
        resolve(true);
      })
    }


    function listenerMakeupStatusFromPopup(){
      const callback = e => {
        const name = e.data.name;
        if (!e.data.pid) return;
        if(name == 'pushMakeupTagStatus'){
          let makeupStatus = e.data.makeupTagStatus
          // console.log('listenerMakeupStatusFromPopup----pushMakeupTagStatus---------',makeupStatus)
          makeupTagListenerObj.makeupStatus = makeupStatus;
        }
        else if(name == 'pushThreeFingerTapStatus'){
          let threeFingerTapStatus = e.data.threeFingerTapStatus
          // console.log('listenerMakeupStatusFromPopup-----threeFingerTapStatus----',threeFingerTapStatus)
          if(threeFingerTapStatus == makeupTagListenerObj.threeFingerTapStatus){
            return;
          }
          makeupTagListenerObj.shouldSetThreeFingerTapStatus = true;
          makeupTagListenerObj.threeFingerTapStatus = threeFingerTapStatus;
        }
      };
      window.addEventListener('message', callback);
    }

    function handleStartMakeupStatus(makeupStatus){
      if(makeupStatus && makeupStatus == 'on'){
        startSelecteTagAndMakeupAd();
      }else{
        // 如果有正在标记广告，则需要清楚当前标记内容
        stopSelecteTagAndMakeupAd();
      }
      // asyncSetMakeupTagStatus(makeupStatus)
    }

    function startSelecteTagAndMakeupAd(){
      // document.addEventListener('DOMContentLoaded', function() {
      //   document.body.focus();
      // });
      // document.body.focus();
      showMakeupTagPanel = true;
      createOrShowSeleteTagPanelWithModal();
      startListenerMove();
      checkZindexDom();
      if(!Utils.isMobileOrIpad()){
        // document.addEventListener('DOMContentLoaded', function() {
        //   document.focus();
        // });
        
        
        // console.log('startSelecteTagAndMakeupAd-------addEventListener----keyup-----');
        // document.removeEventListener('keyup', handleKeyUpEvent, { passive: true });
        const keyupEvent = document.addEventListener('keyup', handleKeyUpEvent);
      }
    }

    function handleKeyUpEvent(event){
      console.log('keyup------keyup----', event)
      if (event.key === 'Escape') {
        // 在这里执行您的操作
        handleCloseTagingPanel(event);
      }
    }

    function stopSelecteTagAndMakeupAd(){
      stopListenerMove();
      hideSeletedTagContentModal();
      hideSeletedTagPanel();
      if(!Utils.isMobileOrIpad()){
        document.removeEventListener('keyup', handleKeyUpEvent);
      }
    }

    /**
     * 创建标记tab面板，
     */
    function createOrShowSeleteTagPanelWithModal(){
      createStyleTag();
      if(!document.querySelector('#__stay_wrapper')){
        moveWrapperDom = document.createElement('div');
        moveWrapperDom.id='__stay_wrapper';
        moveWrapperDom.setAttribute('tabindex', 'true');
        moveWrapperDom.classList.add('__stay_move_wrapper');
        closeTagingDom = document.createElement('div');
        closeTagingDom.id='__stay_close';
        closeTagingDom.classList.add('__stay_close_con');
        document.body.appendChild(closeTagingDom);
        document.body.appendChild(moveWrapperDom);
        moveWrapperDom.focus();
        window.addEventListener('scroll', () => {
          if(makeupTagListenerObj.makeupStatus == 'on'){
            hideSeletedTagContentModal();
            if(showMakeupTagMenu){
              showMakeupTagMenu = false;
              document.querySelector('#__stay_makeup_menu').remove();
            }
            startListenerMove();
          }
        });

      }else{
        moveWrapperDom.style.display = 'block';
        closeTagingDom.style.display = 'block';
        moveWrapperDom.focus();
      }
      addListenerClosePanelEvent();
      if(!document.querySelector('#__stay_selected_tag')){
        preselectedTargetDom = document.createElement('div');
        preselectedTargetDom.id='__stay_selected_tag';
        preselectedTargetDom.classList.add('__stay_select_target');
        document.body.appendChild(preselectedTargetDom);
      }
      showSelectTagNoteToast(i18nProp['select_note']);
    }

    function addListenerClosePanelEvent(){
      closeTagingDom.addEventListener(clickEvent, handleCloseTagingPanel)
    }

    function removeListenerClosePanelEvent(){
      closeTagingDom.removeEventListener(clickEvent, handleCloseTagingPanel)
    }

    function handleCloseTagingPanel(event){
      event.stopPropagation(); 
      event.preventDefault();
      // console.log('closeTagingDom addListener click---------------');
      makeupTagListenerObj.makeupStatus = 'off';
      hideSelectTagNoteToast();
      stopListenerMove();
    }


    /**
     * 开始监听面板move（touchstart）事件
     * 
     */
    function startListenerMove(){
      if(Utils.isMobileOrIpad()){
        const mouseMoveHandler = moveWrapperDom.addEventListener('touchstart', handleMoveAndSelecteDom);
      }else{
        const mouseMoveHandler = document.body.addEventListener('mousemove', handleMoveAndSelecteDom, { passive: true });
      }
      
    }

    /**
     * 移除面板move（touchstart）事件
     */
    function stopListenerMove(){
      if(Utils.isMobileOrIpad()){
        if(moveWrapperDom){
          moveWrapperDom.removeEventListener('touchstart', handleMoveAndSelecteDom);
        }
      }else{
        document.body.removeEventListener('mousemove', handleMoveAndSelecteDom, { passive: true });
      }
    }

    /**
     * 展示标记菜单
     */
    function showTagingOperateMenu(event){
      if(event){
        event.stopPropagation();
      }
      console.log('showTagingOperateMenu  addListener click----------showMakeupTagMenu-----',showMakeupTagMenu, selectedDom);
      if(showMakeupTagMenu){
        // console.log('showTagingOperateMenu=======showMakeupTagMenu is true');
        return;
      }
      hideSelectTagNoteToast();
      showMakeupTagMenu = true;
      stopListenerMove();
      stopWindowScroll();
      // if(Utils.isMobileOrIpad()){
      // }
      preselectedTargetDom.style.borderColor = '#B620E0';
      // todo
      let closeMenu = 'https://res.stayfork.app/scripts/95CF6156C3CCD94629AF09F81A6CD5FF/icon.png';
      let expand = 'https://res.stayfork.app/scripts/0D45496300EC4B6360E44B69B92D1132/icon.png';
      let narrowDown = 'https://res.stayfork.app/scripts/9902FE8B6AFA251ED975C492E184DDCA/icon.png';
      let nextSibling = 'https://res.stayfork.app/scripts/069AF48A98B2955589200B6106838811/icon.png';
      let previousSibling = 'https://res.stayfork.app/scripts/51245F785BF8817F78D5ABD914147DF5/icon.png';
      if(Utils.isDark()){
        expand = 'https://res.stayfork.app/scripts/5C42A87EF2288BEDF260D06E54A4F88F/icon.png';
        narrowDown = 'https://res.stayfork.app/scripts/DA3CFBDA1D7F29E4D99D392EE6C40496/icon.png';
        nextSibling = 'https://res.stayfork.app/scripts/C0E56AB1BFFE7709D81492B76B2588C5/icon.png';
        previousSibling = 'https://res.stayfork.app/scripts/C02CEFF452C9B642CA4594FFFB910C12/icon.png';
        closeMenu = 'https://res.stayfork.app/scripts/C3E3730228847D228F85ADF68B2336B0/icon.png';
      }

      const tagMenuDom = document.createElement('div');
      tagMenuDom.id = '__stay_makeup_menu';
      tagMenuDom.classList.add('__stay_makeup_menu_wrapper');

      let hasExpand = getValidParentNode()?true:false;
      let hasNarrowDown = getValidFirstChildNode()?true:false;
      let hasPreviousSibling = getValidPreviousSiblingNode(selectedDom)?true:false;
      let hasNextSibling = getValidNextSiblingNode(selectedDom)?true:false;
      const tagMenuDomStr = [
        '<div class="__stay_makeup_menu_item_box">',
        `<div class="__stay_menu_item" id="__stay_menu_tag" type="tag" node='true'><div class="__stay_weight">${i18nProp['tag_as_ad']}</div><img src="https://res.stayfork.app/scripts/92F21CD62874A8A6EFAF6A57618224D6/icon.png"></div>`,
        `<div class="__stay_menu_item ${!hasExpand?'__item_disabled':''}" id="__stay_menu_expand" type="expand" node='${hasExpand}'><div class="__stay_weight">${i18nProp['expand']}</div><img src="${expand}"></div>`,
        `<div class="__stay_menu_item ${!hasNarrowDown?'__item_disabled':''}" id="__stay_menu_narrowDown" type="narrowDown" node='${hasNarrowDown}'><div class="__stay_weight">${i18nProp['narrow_down']}</div><img src="${narrowDown}"></div>`,
        `<div class="__stay_menu_item ${!hasPreviousSibling?'__item_disabled':''}" id="__stay_menu_previousSibling" type="previousSibling" node='${hasPreviousSibling}'><div class="__stay_weight">${i18nProp['previous_sibling']}</div><img src="${previousSibling}"></div>`,
        `<div class="__stay_menu_item ${!hasNextSibling?'__item_disabled':''}" id="__stay_menu_nextSibling" type="nextSibling" node='${hasNextSibling}'><div class="__stay_weight">${i18nProp['next_sibling']}</div><img src="${nextSibling}"></div>`,
        `<div class="__stay_menu_item" id="__stay_menu_cancel" type="cancel" node='true'><div>${i18nProp['cancel']}</div><img src="${closeMenu}"></div>`,
        '</div>'
      ];
      tagMenuDom.appendChild(Utils.parseToDOM(tagMenuDomStr.join('')));

      const clientHeight = document.documentElement.clientHeight;
      const tagMenuDomHeight = 40*6 + 21;
      const tagMenuDomWidth = 192;
      const selectedDomRect = preselectedTargetDom.getBoundingClientRect();
      // console.log('selectedDomRect-----',selectedDomRect, ',tagMenuDomWidth--',tagMenuDomWidth,',tagMenuDomHeight---',tagMenuDomHeight);
      const clientWidth = document.documentElement.clientWidth;

      const leftWidth = selectedDomRect.x < 0 ? 0 : selectedDomRect.x;
      let rightToLeftWidth = Utils.add(leftWidth,  selectedDomRect.width);
      if(rightToLeftWidth>clientWidth){
        rightToLeftWidth = clientWidth;
      }
      let rightWidth = Utils.sub(clientWidth, rightToLeftWidth);
      if(clientWidth<=rightToLeftWidth){
        rightWidth = 0;
      }

      let onRight = false;
      let onLeft = false;
      // 优先在选中位置右边
      if(tagMenuDomWidth <= rightWidth){
        // 在选中区域右边
        tagMenuDom.style.left = `${rightToLeftWidth}px`;
        onRight = true;
      }else{
        if(tagMenuDomWidth <= leftWidth){
          // 在选中区域左边
          tagMenuDom.style.left = `${ Utils.sub(leftWidth, tagMenuDomWidth)}px`;
          onLeft = true;
        }else{
          if(rightWidth <= leftWidth){
            // 与选中区域的右边对齐
            tagMenuDom.style.right = `${Utils.sub(rightWidth, 5)}px`;
            // tagMenuDom.style.left = `${ Utils.sub(rightToLeftWidth, tagMenuDomWidth)}px`;
          }else{
            // 与选中区域左边对齐
            tagMenuDom.style.left = `${Utils.sub(leftWidth, 5)}px`;
          }
        }
      }

      const topHeight = selectedDomRect.y < 0 ? 0 : selectedDomRect.y;
      let bottomToTopHeight = Utils.add(topHeight,  selectedDomRect.height);
      if(bottomToTopHeight>clientHeight){
        bottomToTopHeight = clientHeight
      }
      let bottomHeight = Utils.sub(clientHeight, bottomToTopHeight);
  
      if(tagMenuDomHeight <= topHeight){
        if(onRight || onLeft){
          if(Utils.sub(clientHeight, topHeight) >= tagMenuDomHeight){
            tagMenuDom.style.top = `${Utils.sub(topHeight, 6)}px`;
          }else{
            tagMenuDom.style.top = `${Utils.add(Utils.sub(bottomToTopHeight, tagMenuDomHeight), 6)}px`;
          }
          // tagMenuDom.style.top = `${Utils.add(Utils.sub(bottomToTopHeight, tagMenuDomHeight), 8)}px`;
          // tagMenuDom.style.top = `${Utils.sub(topHeight, 8)}px`;
        }else{
          tagMenuDom.style.top = `${Utils.sub(topHeight, tagMenuDomHeight)}px`;
        }
      }else{
        if(tagMenuDomHeight <= bottomHeight){
          if(onRight || onLeft){
            tagMenuDom.style.top = `${Utils.sub(topHeight, 6)}px`;
          }else{
            tagMenuDom.style.top = `${bottomToTopHeight}px`;
          }
        }else{
          if(topHeight <= bottomHeight){

            if((onRight || onLeft) && Utils.sub(tagMenuDomHeight, 16) <= (Utils.sub(clientHeight, topHeight))){
              tagMenuDom.style.top = `${Utils.sub(topHeight, 6)}px`;
            }else{
              tagMenuDom.style.bottom = '-8px';
            }
            
          }else{
            if((onRight || onLeft) && Utils.sub(tagMenuDomHeight, 16) <= bottomToTopHeight){
              if(Utils.sub(clientHeight, topHeight) >= tagMenuDomHeight){
                tagMenuDom.style.top = `${Utils.sub(topHeight, 6)}px`;
              }else{
                tagMenuDom.style.top = `${Utils.add(Utils.sub(bottomToTopHeight, tagMenuDomHeight), 8)}px`;
              }
              
            }else{
              tagMenuDom.style.top = '-8px';
            }
          }
        }
          
      }
      
      

      
      preselectedTargetDom.appendChild(tagMenuDom);
      const menuItemEvent = document.querySelector('#__stay_makeup_menu .__stay_makeup_menu_item_box').addEventListener(clickEvent, handleMenuItemClick);
    }

    function getValidParentNode(){
      try {
        let parentNodeDom = selectedDom;
        // let parentNode
        while(parentNodeDom){
          parentNodeDom = parentNodeDom.parentNode
          if(['BODY','HTML'].includes(parentNodeDom.nodeName)){
            parentNodeDom = null;
            break;
          }
          if(parentNodeDom && parentNodeDom.nodeName != '#text' && parentNodeDom.getBoundingClientRect().width>0){
            break;
          }
        }
        if(!parentNodeDom || parentNodeDom.nodeName == '#text'){
          return null;
        }
        return parentNodeDom;
      } catch (error) {
        console.log('parentNode is exception---------', error)
        return null;
      }
    }

    function getValidFirstChildNode(){
      try {
        
        let firstChildNode = selectedDom;
        // let parentNode
        while(firstChildNode){
          firstChildNode = getFirstChild(firstChildNode);
          if(firstChildNode && firstChildNode.nodeName != '#text' && firstChildNode.getBoundingClientRect().width>0){
            break;
          }
        }
        if(!firstChildNode || firstChildNode.nodeName == '#text'){
          return null;
        }
        return firstChildNode;
      } catch (error) {
        return null;
      }
    }

    function getFirstChild(parentElement){
      if(!parentElement){
        return null
      }
      // 获取所有子节点
      let childNodes = parentElement.childNodes;

      // 过滤子节点，排除 <style> 和 <script> 标签
      // Node.ELEMENT_NODE (1)：表示元素节点。
      // Node.TEXT_NODE (3)：表示文本节点。
      // Node.COMMENT_NODE (8)：表示注释节点。
      // Node.DOCUMENT_NODE (9)：表示文档节点。
      let filteredChildNodes = Array.prototype.filter.call(childNodes, function(node) {
        return node.nodeType == Node.ELEMENT_NODE || !(notShowTagNameList.includes(node.nodeName));
      });
      if(filteredChildNodes && filteredChildNodes.length){
        return filteredChildNodes[0];
      }
      return null;
    }

    function getAllSiblingNode(tempDom){
      let siblings = [];
      let parentNode = tempDom.parentNode;
      let childNodes = parentNode.childNodes;

      for (let i = 0; i < childNodes.length; i++) {
        let node = childNodes[i];
        if (node.nodeType === Node.ELEMENT_NODE && !(notShowTagNameList.includes(node.nodeName)) && node !== tempDom) {
          siblings.push(node);
        }
      }
    }

    function getValidPreviousSiblingNode(tempDom){
      try {
        let previousSiblingNode = tempDom;
        // let parentNode
        while(previousSiblingNode){
          previousSiblingNode = previousSiblingNode.previousSibling
          if(previousSiblingNode && previousSiblingNode.nodeType === Node.ELEMENT_NODE && !(notShowTagNameList.includes(previousSiblingNode.nodeName)) && previousSiblingNode.getBoundingClientRect().width>0 && previousSiblingNode.getBoundingClientRect().height>0){
            break;
          }
        }
        return previousSiblingNode;
      } catch (error) {
        return null;
      }
      
    }

    function getValidNextSiblingNode(tempDom){
      try {
        let nextSiblingNode = tempDom;
        // let parentNode
        while(nextSiblingNode){
          nextSiblingNode = nextSiblingNode.nextSibling
          if(nextSiblingNode && nextSiblingNode.nodeType === Node.ELEMENT_NODE && !(notShowTagNameList.includes(nextSiblingNode.nodeName)) && nextSiblingNode.nodeName != '#text' && nextSiblingNode.getBoundingClientRect().width>0 && nextSiblingNode.getBoundingClientRect().height>0){
            break;
          }
        }
        return nextSiblingNode;
      } catch (error) {
        return null;
      }
    }

    /**
     * 选中区域菜单项处理事件
     * @param {Event} e 
     */
    function handleMenuItemClick(e){
      e.preventDefault();
      e.stopPropagation();
      const item = e.target.closest('.__stay_menu_item');
      const menuItemBox = document.querySelector('#__stay_makeup_menu .__stay_makeup_menu_item_box');
      // 如果事件目标元素是具有 "item" 类的元素
      if (item && item.parentNode === menuItemBox) {
        let hasNode = item.getAttribute('node');
        console.log(`Clicked item: ${item.textContent}, ${hasNode}`);
        if(hasNode === 'false'){
          return;
        }
        
        let menuItemType = item.getAttribute('type');

        menuItemBox.removeEventListener(clickEvent, handleMenuItemClick);
        preselectedTargetDom.removeChild(document.querySelector('#__stay_makeup_menu'));
        hideSeletedTagContentModal();
        showMakeupTagMenu = false;
        startListenerMove();
        removeStopWindowScroll();
        if('tag' === menuItemType){
          handleSelectedTag();
          showSelectTagNoteToast(i18nProp['select_note']);
        }else if('expand' === menuItemType){
          // console.log('expand--------', getValidParentNode());
          handleSelecteTagPosition(getValidParentNode(), true);
        }else if('narrowDown' === menuItemType){
          handleSelecteTagPosition(getValidFirstChildNode(), true);
        }else if('previousSibling' === menuItemType){
          handleSelecteTagPosition(getValidPreviousSiblingNode(selectedDom), true);
        }else if('nextSibling' === menuItemType){
          handleSelecteTagPosition(getValidNextSiblingNode(selectedDom), true);
        }else{
          // console.log('menu----cancel-----',menuItemType)
          showSelectTagNoteToast(i18nProp['select_note']);
        }
        
      }
      
    }

    function stopWindowScroll(){
      if(Utils.isMobileOrIpad()){
        moveWrapperDom.addEventListener('touchstart', handleStopScroll);
        moveWrapperDom.addEventListener('touchmove', handleStopScroll);
        moveWrapperDom.addEventListener('touchend', handleStopScroll);
      }else{
        document.body.addEventListener('mousemove', handleStopScroll, { passive: true });
      }
    }

    function removeStopWindowScroll(){
      if(Utils.isMobileOrIpad()){
        moveWrapperDom.removeEventListener('touchstart', handleStopScroll);
        moveWrapperDom.removeEventListener('touchmove', handleStopScroll);
        moveWrapperDom.removeEventListener('touchend', handleStopScroll);
      }else{
        document.body.removeEventListener('mousemove', handleStopScroll, { passive: true });
      }
    }
    function handleStopScroll(event){
      event.preventDefault();
      event.stopPropagation();
    }

    function handleSelectedTag(){
      let finishTaggedDom = document.querySelector('#__stay_tagged')
      if(!finishTaggedDom){
        finishTaggedDom = document.createElement('div');
        finishTaggedDom.id = '__stay_tagged';
        finishTaggedDom.classList.add('__stay_tagged_wrapper');
        finishTaggedDom.innerText = 'Tagged';
        document.body.appendChild(finishTaggedDom);
      }else{
        finishTaggedDom.style.animation = 'dropIn 0.5s forwards';
      }
      
      let durationTimer = setTimeout(()=>{
        finishTaggedDom.style.animation = 'dropOut 0.5s forwards';
        clearTimeout(durationTimer);
        durationTimer = null;
      }, 2000);
      // console.log('handleSelectedTag-----to---send');
      sendSelectedTagToHandler();
    }

    function checkWebSiteUseFullPath(){
      let url = window.location.href;
      if(url.indexOf('')){

      }
    }

    async function sendSelectedTagToHandler(){
      return new Promise((resolve, reject)=>{
        console.log('before----',selectedDom);
        let styles = window.getComputedStyle(selectedDom);
        if(styles.position == 'fixed'){
          let shouldExpand = false;
          let selectedDomSibling = getValidPreviousSiblingNode(selectedDom) || getValidNextSiblingNode(selectedDom);
          if(selectedDomSibling){
            // console.log('selectedDomSibling-----',selectedDomSibling);
            let selectedDomSiblingStyles = window.getComputedStyle(selectedDomSibling);
            if(selectedDomSiblingStyles.position == 'fixed'){
              shouldExpand = true;
            }else{
              // console.log('selectedDomSiblingStyles----not-----fixed-----');
            }
          }else{
            shouldExpand = true;
            // console.log('selectedDomSibling----null-');
          }
          if(shouldExpand){
            let fixedParentDom = getValidParentNode();
            // console.log('fixedParentDom--------',fixedParentDom)
            while(fixedParentDom){
              if(getValidPreviousSiblingNode(fixedParentDom) || getValidNextSiblingNode(fixedParentDom)){
                // console.log('fixedParentDom-----subling-------yes---');
                break;
              }
              fixedParentDom = fixedParentDom.parentNode;
              // console.log('fixedParentDom------parentNode------',fixedParentDom)
            }
            // console.log('fixedParentDom------',fixedParentDom)
            if(fixedParentDom && fixedParentDom.nodeName != 'BODY'){
              selectedDom = fixedParentDom;
            }
          }
        }
        // console.log('after----', selectedDom);
        let selector = getSelector(selectedDom);
        // console.log('selector-----selector---before----',selector)
        let selDom = document.querySelector(selector);
        // console.log('selDom-------',selDom);
        if(!selDom || selDom == null || selDom == 'null'){
          // console.log('selDom--22222222-----',selDom);
          selector = getSelector(selectedDom, 'useClass');
          selDom = document.querySelector(selector);
        }
        console.log('selector-----selector---after-----',selector,selDom)
        let url = window.location.href;

        try {
          if(selDom){
            const uuid = Utils.hexMD5(`${url}${selector}`);
            if(cssSelectorSet.has(uuid)){
              selDom.style.display = 'none';
              resolve(true);
              return;
            }else{
              selDom.style.display = 'none';
              selectedDom.style.display = 'none';
              cssSelectorSet.add(uuid);
            }
          }
        } catch (error) {
          console.log('error------',error)
        }
        
        
        // selectedDom.style.display = 'none';
        selectedDom = null;
        // console.log('sendSelectedTagToHandler----------------', selector, url);
        if(isContent){
          // console.log('sendSelectedTagToHandler-----true');
          browser.runtime.sendMessage({from: 'adblock', operate: 'sendSelectorToHandler', selector, url}, (response) => {
            console.log('sendSelectedTagToHandler---------',response)
          });
        }else{
          // console.log('sendSelectedTagToHandler-----false');
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid: pid, name: 'SEND_SELECTOR_TO_HANDLER',  selector, url});
        }
        resolve(true)
      })
    }
  
    /**
     * 隐藏标记中的模态框内容
     */
    function hideSeletedTagContentModal(){
      if(preselectedTargetDom !=null){
        preselectedTargetDom.removeEventListener(clickEvent, showTagingOperateMenu);
        preselectedTargetDom.style.width = '0px';
        preselectedTargetDom.style.height = '0px';
        preselectedTargetDom.style.left = '0px';
        preselectedTargetDom.style.top = '0px';
        preselectedTargetDom.style.display = 'none';
        preselectedTargetDom.style.borderColor = borderColor;
      }
      if(moveWrapperDom!=null){
        moveWrapperDom.style.clipPath = 'none';
      }
      
    }

    /**
     * 隐藏标记tab面板
     * @returns 
     */
    function hideSeletedTagPanel(){
      if(moveWrapperDom!=null){
        removeListenerClosePanelEvent();
        moveWrapperDom.style.display = 'none';
        showMakeupTagPanel = false;
      }
      if(closeTagingDom != null){
        closeTagingDom.style.display = 'none';
      }
    }

    /**
     * Tagging
     * @param {*} event 
     * @returns 
     */
    function handleMoveAndSelecteDom(event){
      // console.log('touchmove------handleMoveAndSelecteDom-------------', event);
      if(event.touches && event.touches.length>1){
        return;
      }
      let moveX = event.x || event.touches[0].clientX;
      let moveY = event.y || event.touches[0].clientY;
      const moveDoms = document.elementsFromPoint(moveX, moveY);
      // console.log('handleMoveAndSelecteDom----------moveDoms-----',moveDoms);
      let selectePositionDom = moveDoms[0];
      let moveDomRect = selectePositionDom.getBoundingClientRect();
      if(moveDoms && moveDoms.length>1){
        if(Utils.isMobileOrIpad()){
          if(moveDoms.length<=4){
            selectePositionDom = moveDoms[1];
            if('__stay_close' == selectePositionDom.id){
              selectePositionDom = moveDoms[2];
            }
          }else if(moveDoms.length > 4){
            selectePositionDom = moveDoms[1];
            if('__stay_close' == selectePositionDom.id){
              selectePositionDom = moveDoms[2];
            }
            let styles = window.getComputedStyle(selectePositionDom);
            // console.log('styles.position---------',styles.position)
            // 判断节点是否具有绝对定位
            if (styles.position !== 'fixed') {
              let i = 3;
              selectePositionDom = moveDoms[i];
              while(moveDomRect.height > document.documentElement.clientHeight){
                i = i - 1;
                selectePositionDom = moveDoms[i];
                moveDomRect = selectePositionDom.getBoundingClientRect();
                if(i == 1){
                  break;
                }
              }
            } 
          }
        }else{
          selectePositionDom = moveDoms[1];
        }
      }else{
        return;
      }
      if('__stay_close' == selectePositionDom.id){
        return;
      }
      // console.log('moveDom-----',selectedDom);
      handleSelecteTagPosition(selectePositionDom, false)
    }

    /**
     * 绘制选中区域
     * @param {Document} selectePositionDom 
     * @param {boolean} showMenu 
     * @returns 
     */
    function handleSelecteTagPosition(selectePositionDom, showMenu){
      // console.log('handleSelecteTagPosition------', selectePositionDom);
      if(!selectePositionDom || selectePositionDom == ''){
        console.log('handleSelecteTagPosition---selectePositionDom is null');
        return;
      }
      selectedDom = selectePositionDom
      let moveDomRect = selectedDom.getBoundingClientRect();
      if(!moveDomRect || !Object.keys(moveDomRect)){
        console.log('handleSelecteTagPosition---moveDomRect is null');
        return;
      }
      if(!showMenu && Utils.isMobileOrIpad()){
        showSelectTagNoteToast(i18nProp['select_confirm']);
      }

      
      let targetWidth = getMoveDomWidth(moveDomRect.width);
      // console.log('handleSelecteTagPosition------selectedDom----',selectedDom)
      let targetHeight = getMoveDomHeight(moveDomRect.height);
      // console.log('moveDomRect-----',moveDomRect,'targetWidth====',targetWidth,'targetHeight=====',targetHeight);
      let targetX = getMoveDomLeft(moveDomRect.left);
      let targetY = getMoveDomTop(moveDomRect.top);
  
      if(targetX == 0){
        targetX = selectedDom.offsetLeft;
        if(targetX<0){
          targetX = 0;
        }
      }
      preselectedTargetDom.removeEventListener(clickEvent, showTagingOperateMenu);
      // console.log('targetWidth=',targetWidth,',targetHeight=',targetHeight,',targetX=',targetX,',targetY=',targetY);
      while(preselectedTargetDom.firstChild){
        preselectedTargetDom.removeChild(preselectedTargetDom.firstChild)
      }
      preselectedTargetDom.style.display = 'block';
      showMakeupTagMenu = false;
      preselectedTargetDom.addEventListener(clickEvent, showTagingOperateMenu);
      // 计算蒙层裁剪区域
  
      moveWrapperDom.style.clipPath = calcPolygonPoints(targetX, targetY, targetWidth, targetHeight);
      preselectedTargetDom.style.width = targetWidth+'px';
      preselectedTargetDom.style.height = targetHeight+'px';
      preselectedTargetDom.style.left = targetX+'px';
      preselectedTargetDom.style.top = targetY+'px';

      if(showMenu){
        showTagingOperateMenu();
      }
    }

    function getMoveDomHeight(domHeight){
      if(domHeight>0){
        return domHeight
      }
      let height = domHeight;
      let selectedChild = selectedDom;
      while(height==0 && selectedChild){
        selectedChild = getFirstChild(selectedChild);
        if(selectedChild){
          height = selectedChild.offsetHeight;
        }
      }
      return height;
    }

    function getMoveDomWidth(domWidth){
      if(domWidth>0){
        return domWidth
      }
      let width = domWidth;
      let selectedChild = selectedDom;
      while(width==0 && selectedChild){
        selectedChild = getFirstChild(selectedChild);
        if(selectedChild){
          width = selectedChild.offsetWidth;
        }
      }
      return width;
    }
    function getMoveDomLeft(domLeft){
      const clientWidth = document.documentElement.clientWidth;
      if(domLeft<clientWidth){
        return domLeft
      }
      let left = domLeft;
      let selectedChild = selectedDom;
      while(domLeft>clientWidth && selectedChild){
        selectedChild = getFirstChild(selectedChild);
        if(selectedChild){
          left = selectedChild.getBoundingClientRect().left;
        }
      }
      return left;
    }
    function getMoveDomTop(domTop){
      const clientHeight = document.documentElement.clientHeight;
      if(domTop<clientHeight){
        return domTop
      }
      let top = domTop;
      let selectedChild = selectedDom;
      while(top>clientHeight && selectedChild){
        selectedChild = getFirstChild(selectedChild);
        if(selectedChild){
          top = selectedChild.getBoundingClientRect().top;
        }
      }
      return top;
    }

    function showSelectTagNoteToast(note){
      let selectNoteDom = document.querySelector('#__stay_select_note');
      if(!selectNoteDom){
        selectNoteDom = document.createElement('div');
        selectNoteDom.id = '__stay_select_note';
        selectNoteDom.classList.add('__stay_select_note_warpper');
        selectNoteDom.innerHTML = note;
        document.body.appendChild(selectNoteDom);
        selectNoteDom.style.animation = 'dropIn 0.5s forwards';
      }else{
        selectNoteDom.style.display = 'inline-block';
        selectNoteDom.innerHTML = note;
        selectNoteDom.style.animation = 'dropIn 0.5s forwards';
      }
    }

    function hideSelectTagNoteToast(){
      let selectNoteDom = document.querySelector('#__stay_select_note');
      if(selectNoteDom){
        selectNoteDom.style.animation = 'dropOut 0.5s forwards';
        let durationTimer = setTimeout(()=>{
          selectNoteDom.style.display = 'none';
          clearTimeout(durationTimer);
          durationTimer = 0;
        }, 500);
      }
    }

    
  
    /**
     * 计算选中区域的裁剪坐标
     * @param {Number} targetX 
     * @param {Number} targetY 
     * @param {Number} targetWidth 
     * @param {Number} targetHeight 
     * @returns 
     */
    function calcPolygonPoints(targetX, targetY, targetWidth, targetHeight){
      targetX = Utils.add(targetX, borderSize);
      targetY = Utils.add(targetY, borderSize);
      targetWidth = Utils.sub(targetWidth, Utils.mul(borderSize, 2));
      targetHeight = Utils.sub(targetHeight, Utils.mul(borderSize, 2));
      let rectRightPointX = Utils.add(targetX, targetWidth);
      let rectBottomPointY = Utils.add(targetY, targetHeight);
      let polygon = `polygon(0 0, 0 ${targetY}px, ${targetX}px ${targetY}px, ${rectRightPointX}px ${targetY}px, ${rectRightPointX}px ${rectBottomPointY}px, ${targetX}px ${rectBottomPointY}px, ${targetX}px ${targetY}px, 0 ${targetY}px, 0 100%,100% 100%, 100% 0)`;
      return polygon;
    }
  
    function getSelector(el, useClass) {
      if (!(el instanceof Element)) return;
      let path = [];
      try {
        while (el.nodeType === Node.ELEMENT_NODE) {
          // console.log('getSelector---el.id---',el.id)
          let selector = el.nodeName.toLowerCase();
          if(selector == 'body'){
            path.unshift(selector);
            break;
          }
          if (el.id && checkStaticSelectorId(el.id)) {
            selector += '#' + el.id;
            path.unshift(selector);
            break;
          }
          else if(el.className && useClass){
            selector += `.${el.className.replace(/\s+/g, '.')}`
          }
          else {
            const siblings = Array.from(el.parentNode.children);
            let indexNode = 0;
            try {
              siblings.forEach((node, index)=>{
                if(node == el){
                  indexNode = index;
                  throw new Error('endloop');
                }
              })
            } catch (e) {
              if(e.message === 'endloop') {
                // 终止循环
              }else{
                throw e
              }
            }
            if (siblings.length > 1) {
              // const index = siblings.indexOf(el);
              selector += `:nth-child(${indexNode + 1})`;
            }
          }
          path.unshift(selector);
          el = el.parentNode;
        }
      } catch (error) {
        console.log(error)
      }
      return path.join(' > ');
    }

    /**
     * 判断id是否是随机生成
     * 1、是否a-zA-Z0-9组成且长度大于10
     * 2、是，认定为随机字符串组成的id,
     * 3、否，认定为静态id
     * @param {String} idStr 
     * @returns 
     */
    function checkStaticSelectorId(idStr){
      if(!idStr){
        return false;
      }
      if(/^[0-9a-zA-Z-_]*$/.test(idStr) && idStr.length>10){
        return false;
      }
      return true;
    }
    

    /* eslint-disable */
    Object.defineProperty(makeupTagListenerObj, 'makeupStatus', {
      get:function(){
        return makeupStatus;
      },
      set:function(newValue){
        makeupStatus = newValue;
        // console.log('makeupTagListenerObj---makeupStatus-----',newValue);
        //监听makeupStatus, 如果发生变化, 则需要触发状态方法
        handleStartMakeupStatus(newValue)
      }
    });

    /* eslint-disable */
    Object.defineProperty(makeupTagListenerObj, 'threeFingerTapStatus', {
      get:function(){
        return threeFingerTapStatus;
      },
      set:function(newValue){
        threeFingerTapStatus = newValue;
        // console.log('makeupTagListenerObj-----threeFingerTapStatus-----',newValue);
        handleThreeFingerEvent(newValue)
      }
    });

    function startMakeupTag(){
      
      let browserLangurage = languageCode()
      i18nProp = AdLangMessage[browserLangurage] || AdLangMessage['en_US'];
      makeupTagListenerObj.makeupStatus = 'off';
      asyncFetchThreeFingerTapStatus();
      // asyncFetchMakeupTagStatus();
      listenerMakeupStatusFromPopup();
    }
    
    async function checkZindexDom(){
      if(!checkZindexFlag){
        setTimeout(()=>{
          const zIndexDoms = document.querySelectorAll("[style*='z-index']");
          const nodeList = Array.from(zIndexDoms);
          if(nodeList && nodeList.length){
            nodeList.forEach((node, i)=>{
              const zIndex = node.style.zIndex;
              if(zIndex>2147483600){
                node.style.zIndex = 2147483500;
              }
            });
          }
        }, 100)
      }
    }

    startMakeupTag();

  }


  window.addEventListener('message', (e) => {
    if (!e || !e.data || !e.data.name) return;
    const name = e.data.name;
    if(name === 'GET_MAKEUP_TAG_STATUS'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'popup', operate: 'getMakeupTagStatus'}, (response) => {
        // console.log(response);
        let makeupTagStatus = response&&response.makeupTagStatus?response.makeupTagStatus:'on';
        window.postMessage({pid:pid, name: 'GET_MAKEUP_TAG_STATUS_RESP', makeupTagStatus});
      });
    }
    else if(name === 'SET_MAKEUP_TAG_STATUS'){
      let pid = e.data.pid;
      let makeupTagStatus = e.data.makeupTagStatus;
      let type = e.data.type;
      browser.runtime.sendMessage({from: 'popup', operate: 'setMakeupTagStatus', makeupTagStatus, type}, (response) => {
        console.log('SET_MAKEUP_TAG_STATUS----',response);
      });
    }
    else if(name === 'GET_THREE_FINGER_TAG_STATUS'){
      let pid = e.data.pid;
      browser.runtime.sendMessage({from: 'content_script', operate: 'getThreeFingerTapStatus'}, (response) => {
        // console.log('GET_THREE_FINGER_TAG_STATUS-----',response);
        let threeFingerTapStatus = response&&response.threeFingerTapStatus?response.threeFingerTapStatus:'on';
        window.postMessage({pid:pid, name: 'GET_THREE_FINGER_TAG_STATUS_RESP', threeFingerTapStatus});
      });
    }
    else if(name === 'SET_THREE_FINGER_TAG_STATUS'){
      let threeFingerTapStatus = e.data.threeFingerTapStatus;
      // console.log('SET_THREE_FINGER_TAG_STATUS-----', threeFingerTapStatus)
      let type = e.data.type;
      browser.runtime.sendMessage({from: 'content_script', operate: 'setThreeFingerTapStatus', threeFingerTapStatus, type}, (response) => {
      });
    }
    // else if(name === 'pushThreeFingerTapStatus'){
    //   let pid = e.data.pid;
    //   let threeFingerTapStatus = e.data.threeFingerTapStatus
    //   window.postMessage({pid:pid, name: 'pushThreeFingerTapStatus', threeFingerTapStatus});
    // }
    else if(name === 'SEND_SELECTOR_TO_HANDLER'){
      let pid = e.data.pid;
      let selector = e.data.selector;
      let url = e.data.url;
      // console.log('sendSelectedTagToHandler--------selector-----',selector, url);
      browser.runtime.sendMessage({from: 'adblock', operate: 'sendSelectorToHandler', selector, url}, (response) => {
        // console.log('sendSelectedTagToHandler---------',response)
      });
    }
  })


  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const requestFrom = request.from;
    const operate = request.operate;
    if('popup' === requestFrom){
      if('startMakeupTagStatus' == operate){
        let makeupTagStatus = request.makeupTagStatus;
        // console.log('startMakeupTagStatus------', makeupTagStatus)
        let type = request.type;
        if(makeupTagStatus){
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid:pid, name: 'pushMakeupTagStatus', makeupTagStatus});
        }
        sendResponse({makeupTagStatus})
      }
      else if('pushThreeFingerTapStatus' == operate){
        let threeFingerTapStatus = request.threeFingerTapStatus;
        let type = request.type;
        console.log('pushThreeFingerTapStatus---threeFingerTapStatus---', threeFingerTapStatus)
        if(threeFingerTapStatus){
          const pid = Math.random().toString(36).substring(2, 9);
          window.postMessage({pid:pid, name: 'pushThreeFingerTapStatus', threeFingerTapStatus});
        }
      }else if('refreshTargetTabs' == operate){
        window.location.reload(true);
        sendResponse({ok:'ok'})
      }
    }


    return true;
  });

})()