
let randomYTObj = {}; 

function fetchRandomStr(randomStr, speedRandomStr){
  window.webkit.messageHandlers.log.postMessage('fetchRandomStr');
  randomYTObj.randomStr = randomStr;
  randomYTObj.speedRandomStr = speedRandomStr;
}

/**
 * 自动解析video资源
 * 解析页面video标签
 */
(function () {
  let hostUrl = window.location.href;
  let host = window.location.host;
  let decodeFunStr = '';
  let decodeSpeedFunStr = '';
  let ytPublicParam = {};//cpn,cver,ptk,oid,ptchn,pltype
  let ytParam_N_Obj = {};
  let playerBase = '';
  let ytRandomBaseJs = '';
  let ytBaseJSUuid = '';
  // console.log('------------injectParseVideoJS-----start------------------')
  let videoList = [];
  let videoListMd5 = '';
  let shouldDecodeQuality = {};
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
    queryParams: function(path, name) {
      if(!path){
        return '';
      }
      let url = 'https;//stap.app?'+path;
      return this.queryURLParams(url, name);
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
    decodeBase64: function(str) {
      return decodeURIComponent(window.atob(str).split('').map(function (c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
      }).join(''));
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
    
  function startFindVideoInfo(completed){
    observerVideo()
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
    // observerVideo()
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
    // window.webkit.messageHandlers.stayapp.postMessage("videoInfo1");
    // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------in------------------');
    // console.log('parseVideoNodeList-----------------start------------------', videoDoms)
    if(videoDoms && videoDoms.length){
      // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------start------------------');
      // window.webkit.messageHandlers.stayapp.postMessage("videoInfo5");
      let videoCount = videoDoms.length
      let nullCount = 0;
      let videoNodeList = Array.from(videoDoms)
      videoNodeList.forEach(item => {
        if(!item || !(item instanceof HTMLElement)){
          // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------no--HTMLElement----------------');
          nullCount++;
          return;
        }
        const videoDom = item;
        let videoUuid = item.getAttribute('stay-sniffing');
        if(!videoUuid){
          videoUuid = Utils.generateUuid();
          item.setAttribute('stay-sniffing', videoUuid);
        }
        let downloadUrl = item.getAttribute('src');
        if(!downloadUrl){
          // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------no---src------------------');
          // console.log('parseVideoNodeList--------------downloadUrl=',downloadUrl);
          let sourceDom = item.querySelector('source');
          // console.log('parseVideoNodeList--------------sourceDom=',sourceDom);
          if(sourceDom){
            item = sourceDom;
            downloadUrl = sourceDom.getAttribute('src');
            // console.log('parseVideoNodeList--------------sourceDom.downloadUrl=',downloadUrl);
          }
        }
        if(!downloadUrl){
          // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------no---src--again----------------');
          nullCount++;
          return;
        }
        // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------start--------handleVideoInfoParse----------');
        // console.log('parseVideoNodeList------item---------',videoUuid)
        // todo fetch other scenarios
        let videoInfo = handleVideoInfoParse(item, videoUuid);
        // console.log('parseVideoNodeList------videoInfo---------',videoInfo)
        if(!videoInfo.downloadUrl){
          nullCount++;
          return;
        }
        // console.log('parseVideoNodeList------videoList--2222-------',videoList)
      })
      if(nullCount == videoCount){
        // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------start--------setTimeoutParseVideoInfoByWindow----------');
        setTimeoutParseVideoInfoByWindow();
      }
    }else{
      // window.webkit.messageHandlers.log.postMessage('parseVideoNodeList-----------------start-----------else-------');
      // window.webkit.messageHandlers.stayapp.postMessage("videoInfo3");
      // console.log('start------parseVideoInfoByWindow--------');
      setTimeoutParseVideoInfoByWindow();
    }
    // window.webkit.messageHandlers.stayapp.postMessage("videoInfo4");
    // console.log('parseVideoNodeList-----------result---------',videoList);
    
  }

  /**
   * check video if exist
   * @param {Object} videoInfo  {videoKey downloadUrl,poster,title,hostUrl,qualityList, videoUuid, m3u8Content}
   */
  function checkVideoExist(videoInfo){
    if(!videoInfo.videoKey && !videoInfo.videoUuid){
      return;
    }
    videoInfo.hostUrl = Utils.getHostname(videoInfo.hostUrl);
    let downloadUrl = videoInfo.downloadUrl;
    if(Utils.isBase64(downloadUrl)){
      downloadUrl = downloadUrl.replace(/^data:.*\w+;base64,/, '');
      videoInfo.m3u8Content = Utils.decodeBase64(downloadUrl);
    }
    if(videoInfo.videoKey && !videoInfo.videoUuid){
      videoInfo.videoUuid = videoInfo.videoKey;
    }

    // videoInfo.qualityList是否需要解密，如需解密记录下来, 等handleDecodeSignatureAndPush来解密
    const qualityList = videoInfo.qualityList;
    if(videoInfo.shouldDecode){
      videoInfo.qualityList = [];
      shouldDecodeQuality[videoInfo.videoUuid] = qualityList;
    }
    if(videoIdSet.size && (videoIdSet.has(videoInfo.videoUuid) || videoIdSet.has(videoInfo.videoKey))){
      // console.log('parseVideoNodeList----------has exost, and modify-------');
      videoList.forEach(item=>{
        if(item.videoUuid == videoInfo.videoUuid || item.videoUuid == videoInfo.videoKey){
          item.downloadUrl = videoInfo.downloadUrl;
          item.poster = videoInfo.poster?videoInfo.poster:'';
          item.title = videoInfo.title
          item.hostUrl = videoInfo.hostUrl;
          item.qualityList = videoInfo.qualityList?videoInfo.qualityList:[];
          item.videoUuid = videoInfo.videoUuid
          item.videoKey = videoInfo.videoKey
          // console.log('checkVideoExist----------item===',item);
        }
        return item;
      })
      // console.log('parseVideoNodeList------videoList---modify------',videoList)
    }else{
      // console.log('parseVideoNodeList----------has not, and push-------');
      if(videoInfo.videoUuid){
        videoIdSet.add(videoInfo.videoUuid);
      }
      if(videoInfo.videoKey){
        videoIdSet.add(videoInfo.videoKey);
      }
      
      videoList.push(videoInfo);
    }
    pushVideoListToTransfer();
  }
  
  function pushVideoListToTransfer(){
    const videoInfoListMd5 = Utils.hexMD5(JSON.stringify(videoList));
    if(videoListMd5 && videoListMd5 == videoInfoListMd5){
      return;
    }
    // console.log('checkVideoExist----------',videoList);
    videoListMd5 = videoInfoListMd5;
    window.webkit.messageHandlers.stayapp.postMessage(videoList);
  }

  function checkDecodeFunIsValid(){
    if(!decodeFunStr){
      return false;
    }
    if(!ytBaseJSUuid){
      return false;
    }
    return true;
  }

  function checkDecodeWithSpeedFunIsValid(){
    let isValid = checkDecodeFunIsValid();
    if(isValid){
      if(!decodeSpeedFunStr){
        isValid = false;
      }else{
        isValid = true;
      }
    }
    return isValid;
  }

  /**
   * 供youtube加密链接解密，app端也会调用此方法
   * @param {String} decodeYoutubeFunStr 
   * 对videoList中qualityList的signature进行解密
   */
  function handleDecodeSignatureAndPush(decodeYoutubeFunStr){
    // window.webkit.messageHandlers.stayapp.postMessage('handleDecodeSignatureAndPush---------------start');
    // console.log('handleDecodeSignatureAndPush-------------',decodeYoutubeFunStr);
    if(decodeYoutubeFunStr){
      decodeFunStr = decodeYoutubeFunStr;
    }
    if(!Object.keys(shouldDecodeQuality).length){
      // console.log('handleDecodeSignatureAndPush--------is null-----',shouldDecodeQuality);
      return;
    }
    if(!checkDecodeFunIsValid()){
      return;
    }
    // console.log('handleDecodeSignatureAndPush-------------',shouldDecodeQuality);
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
        // console.log('handleDecodeSignatureAndPush--------videoList-----',videoList);
        delete shouldDecodeQuality[videoUuid];
      }
    })
    pushVideoListToTransfer();
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
    // console.log('decodeYoutubeSourceUrl---------',signatureCipher);
    const decodeSignatureCipherFun = new Function('return ' + decodeFunStr); 
    let sourceUrl = Utils.queryParams(signatureCipher, 'url');
    let signature = Utils.queryParams(signatureCipher, 's');
    // console.log('decodeYoutubeSourceUrl------------sourceUrl=',sourceUrl, signature);
    signature = decodeSignatureCipherFun()(decodeURIComponent(signature));
    sourceUrl = `${decodeURIComponent(sourceUrl)}&sig=${signature}`;
    sourceUrl = decodeYoutubeSpeedFun(sourceUrl);
    return sourceUrl;
  }

  function getYoutubeVideoUrlOrSignture(signatureCipher){
    if(!checkDecodeFunIsValid()){
      return signatureCipher;
    }else{
      return decodeYoutubeSourceUrl(signatureCipher);
    }
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
  
  function getYoutubeAudioUrlOrSignture(audioArr){
    if(audioArr && audioArr.length){
      audioArr.sort(Utils.compare('bitrate'))
      let audioItem = audioArr[0];
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
     * @return videoInfo{videoKey(从原页面中取到的video唯一标识), downloadUrl, poster, title, hostUrl, qualityList, videoUuid(解析给video标签生成的uuid)}
     * 
     * qualityList[{downloadUrl,qualityLabel, quality }]
     * // https://www.pornhub.com/view_video.php?viewkey=ph63c4fdb2826eb
     */
  function handleVideoInfoParse(videoSnifferDom, videoUuid){
    let videoInfo = {};
    let poster = videoSnifferDom.getAttribute('poster');
    let title = videoSnifferDom.getAttribute('title');
    let downloadUrl = videoSnifferDom.getAttribute('src');
    let qualityList = [];
    hostUrl = window.location.href;

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
      // window.webkit.messageHandlers.log.postMessage('handleVideoInfoParse---host---'+host);
      videoInfo = handleYoutubeVideoInfo(videoSnifferDom);
      // window.webkit.messageHandlers.log.postMessage('handleVideoInfoParse---videoInfo---'+ JSON.stringify(videoInfo));
      if(!videoInfo.videoKey){
        return;
      }
    }
    else if(host.indexOf('baidu.com')>-1){
      videoInfo = handleBaiduVideoInfo(videoSnifferDom);
    }
    else if(host.indexOf('bilibili.com')>-1){
      videoInfo = handleBilibiliVideoInfo(videoSnifferDom);
    }
    else if(host.indexOf('mobile.twitter.com')>-1){
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
    else if(host.indexOf('jable.tv')>-1){
      videoInfo = handleJableVideoInfo(videoSnifferDom);
    }
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
    videoInfo['title'] = (videoInfo.type && videoInfo.type=='ad')?('Ad·'+title):title;
    videoInfo['poster'] = poster;
    videoInfo['downloadUrl'] = downloadUrl;
    videoInfo['hostUrl'] = hostUrl;
    videoInfo['qualityList'] = qualityList;
    videoInfo['videoUuid'] = videoUuid;

    // window.webkit.messageHandlers.log.postMessage(JSON.stringify(videoInfo));
    // console.log('parse------videoInfo========',videoInfo);
    if(downloadUrl){
      checkVideoExist(videoInfo) 
    }
    return videoInfo;
  }

  function setTimeoutParseVideoInfoByWindow(){
    // console.log('setTimeoutParseVideoInfoByWindow-------')
    setTimeout(()=>{
      parseVideoInfoByWindow()
    },300)
  }

  
    
  function parseVideoInfoByWindow(){
    let videoInfo = {}
    let host = window.location.host;
    hostUrl = window.location.href;
    videoInfo.hostUrl = hostUrl;
    if(host.indexOf('pornhub.com')>-1){
      videoInfo = parsePornhubVideoInfoByWindow(videoInfo);
    }
    else if(host.indexOf('youtube.com')>-1){
      videoInfo = handleYoutubeVideoInfo();
    }

    if(!videoInfo.downloadUrl){
      return;
    }
    checkVideoExist(videoInfo);
    // console.log('parseVideoInfoByWindow------', videoInfo)
    return videoInfo;
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
                qualityList.push({downloadUrl: item.videoUrl, qualityLabel:item.quality, quality: Number(item.quality)})
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
      console.log(videoDetailDom.classList, 'videoDetailDom.classList.contains(\'_a8b4\') ===', videoDetailDom.classList.contains('_a8b4') )
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
     * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList}
     * keyName{sd(标清),hd(高清),sc(超清), 1080p(蓝光)}
     * qualityList[{downloadUrl,qualityLabel, quality, keyName }]
     */
  function handleBaiduVideoInfo(videoDom){
    let videoInfo = {};
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
              videoList.push({title:item.title,poster:item.poster,downloadUrl: item.videoUrl,hostUrl:hostUrl,videoUuid:item.vid });
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
  function handleYoutubeVideoInfo(videoSnifferDom){
    const ytplayer = window.ytplayer;
    // window.webkit.messageHandlers.log.postMessage('handleYoutubeVideoInfo-----------------start----------ytplayer--------'+JSON.stringify(ytplayer));
    // window.webkit.messageHandlers.log.postMessage('handleYoutubeVideoInfo-----------------start---------videoId---------'+videoId);
    // console.log('handleYoutubeVideoInfo---------------videoId-------------',videoId)
    let videoInfo = {};

    let videoId = Utils.queryURLParams(hostUrl, 'v');
    if(!videoId){
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
      title = videoSnifferDom.getAttribute('title');
      videoInfo.title = title;
    }else{
      if(!ytplayer || !(playerResp.videoDetails)){
        return videoInfo;
      }
    }
    
    // console.log('playerResp-------', playerResp);
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
     
      // console.log('playerResp-------videoDetails-------------', videoDetails);
      const streamingData = playerResp.streamingData;
      const adaptiveFormats = streamingData.adaptiveFormats;
      const formats = streamingData.formats;
      title = title ? title : '';
      // 取画质的时候防止原视频有广告
      if(adaptiveFormats && adaptiveFormats.length && (!title || title.replace(/\s+/g,'') === detailTitle.replace(/\s+/g,''))){
        let qualityList = []
        let qualitySet = new Set();
        let jsPath = ytplayer.bootstrapWebPlayerContextConfig?ytplayer.bootstrapWebPlayerContextConfig.jsUrl:'';
        handleYTRandomPathUuid(jsPath);

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
    if(videoId != playerResp.videoDetails.videoId){
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
    return videoInfo;
  }

  /**
   * 解析分辨率中视频信息
   * @param {Object} qualityVideoItem  原数据中的分辨率信息
   */
  function handleParseYtQualityInfo(qualityVideoItem, webmAudioUrl, mp4AudioUrl){
    let mimeType = qualityVideoItem.mimeType;
    let qualityLabel = qualityVideoItem.qualityLabel;
    // console.log('handleParseYtQualityInfo---------',qualityVideoItem);
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
      if(!mimeType.match(/.*codecs=.*webm.*/g)){
        audioUrl = mp4AudioUrl;
      }
      let sourceUrl = decodeYoutubeSpeedFun(qualityVideoItem.url);
      return {downloadUrl:sourceUrl, qualityLabel, quality: qualityVideoItem.quality, audioUrl}
    }else{
      let videoUrl = getYoutubeVideoUrlOrSignture(qualityLabel.signatureCipher);
      let audioUrl = '';
      let protect=true;
      // 没有匹配到带音频的视频，需要加上audioUrl
      if(!mimeType.match(/.*codecs=.*webm.*/g)){
        audioUrl = webmAudioUrl;
      }
      if(!mimeType.match(/.*codecs=.*mp4.*/g)){
        audioUrl = mp4AudioUrl;
      }
      return {downloadUrl:videoUrl, qualityLabel, quality: qualityLabel.quality, protect, audioUrl}
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
      if(item.qualityLabel && item.qualityLabel.toLowerCase() == qualityLabel.toLowerCase()){
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
      395: '240p'
    };
  
    return resolutions[itag];
  }

  function handleYTRandomPathUuid(jsPath){
    try {
      if(jsPath){
        let tempRandomCode = ''
        ytRandomBaseJs = jsPath;
        let pathArr = jsPath.split('/');
        if(jsPath.startsWith('/')){
          tempRandomCode = pathArr[3]
        }else{
          tempRandomCode = pathArr[2]
        }
        if(tempRandomCode){
          ytBaseJSUuid = tempRandomCode
        }
      }
    } catch (error) {
      
    }
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
    ytBaseJSUuid = pathUuid;
    // console.log('fetchYoutubeDecodeFun-----pathUuid=',pathUuid, ',pathUrl=',pathUrl);
    window.webkit.messageHandlers.youtube.postMessage(pathUuid);
  }

  async function startFetchYoutubeFunStr(){
    // console.log('startFetchYoutubeFunStr-------start-------------',host);
    if(!(host.indexOf('youtube.com')>-1)){
      // console.log('startFetchYoutubeFunStr-------is not youtube-------------');
      return;
    }
    if(decodeFunStr){
      handleDecodeSignatureAndPush(decodeFunStr);
    }else{
      queryYoutubePlayer();
    }
  }

  function queryYoutubePlayer(){
    for(let i=1; i<10; i++){
      let timer
      (function(i){
        timer = setTimeout(()=>{
          playerBase = document.querySelector('#player-base');
          // console.log('queryYoutubePlayer------i-----',i, new Date().getTime());
          if(playerBase && playerBase.getAttribute('src')){
            // console.log('queryYoutubePlayer---iiiiiii---break-----');
            let jsPath = playerBase.getAttribute('src');
            let pathUuid = jsPath;
            let pathArr = jsPath.split('/');
            if(jsPath.startsWith('/')){
              pathUuid = pathArr[3]
            }else{
              pathUuid = pathArr[2]
            }
            fetchYoutubeDecodeFun(pathUuid, jsPath);
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

  function startSnifferVideoInfoOnPage(complate){
    console.log('startSnifferVideoInfoOnPage--------1----');
    startFetchYoutubeFunStr();
    console.log('startSnifferVideoInfoOnPage--------2----');
    startFindVideoInfo(complate);
    console.log('startSnifferVideoInfoOnPage--------3----');
  }

  startSnifferVideoInfoOnPage(false);

  document.onreadystatechange = () => {
    console.log('document.readyState==',document.readyState)
    if (document.readyState === 'complete') {
      // console.log('readyState-------------------', document.readyState)
      startSnifferVideoInfoOnPage(true);
    }
  };

  /* eslint-disable */
  Object.defineProperty(randomYTObj,'randomStr',{
    get:function(){
      return randomStr;
    },
    set:function(newValue){
      randomStr = newValue;
      console.log('set randomStr:',newValue);
      //需要触发的渲染函数可以写在这...
      handleDecodeSignatureAndPush(randomStr);
    }
  });

  // /* eslint-disable */
  Object.defineProperty(randomYTObj,'speedRandomStr',{
    get:function(){
      return speedRandomStr;
    },
    set:function(newValue){
      speedRandomStr = newValue;
      console.log('set speedRandomStr:',newValue);
      decodeSpeedFunStr = speedRandomStr;
    }
  });

})()

