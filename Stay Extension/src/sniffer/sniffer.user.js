/**
 * 自动嗅探video资源
 * 解析页面video标签
 */
let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function () {
  let videoInfoList = [];
  let videoLinkSet = new Set();
  let contentHost = window.location.host;

  let scriptTag = document.createElement('script');
  scriptTag.type = 'text/javascript';
  scriptTag.id = 'stay_inject_parse_video_js_'+contentHost;
  let injectJSContent = `\n\nlet handleVideoInfo = ${injectParseVideoJS}\n\nhandleVideoInfo();`;
  //   scriptTag.textContent = injectJSContent;
  scriptTag.appendChild(document.createTextNode(injectJSContent));
  if (document.body) {
    document.body.appendChild(scriptTag);
  } else {
    const root = document.documentElement;
    const observer = new MutationObserver(() => {
      if (document.body) {
        observer.disconnect();
        document.body.appendChild(scriptTag);
      }
    });
    observer.observe(root, {childList: true});
  }

  function injectParseVideoJS(){
    let hostUrl = window.location.href;
    let host = window.location.host;
    // console.log('------------injectParseVideoJS-----start------------------')
    let videoList = [];
    // 获取到的video Url数组
    let videoUrlSet = new Set();
    // Firefox和Chrome早期版本中带有前缀  
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let videoDoms;  

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
        const urlReg = new RegExp('(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]', 'g');
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
      }
    }
    
    // let ifreamDoms = document.getElementsByTagName('iframe');
    function startFindVideoInfo(){
      videoDoms = document.querySelectorAll('video');  
      // let flag = false;
      let flag = videoDoms && videoDoms.length;
      if(flag){
        // console.log('videoDoms---false-----',videoDoms)
        parseVideoNodeList(videoDoms);
      }else{
        observerVideo()
      }
    }

    function observerVideo(){
      // 创建观察者对象  
      const observer = new MutationObserver(function(mutations) {  
        // console.log('----------------MutationObserver---------------',mutations)
        try{
          mutations.forEach(function(mutation) {  
            // todo
            videoDoms = document.querySelectorAll('video');
            if('VIDEO' === mutation.target.nodeName && videoDoms && videoDoms.length){
              // console.log('mutation.videoDoms-----',videoDoms)
              host = window.location.host;
              parseVideoNodeList(videoDoms);
              throw new Error('endloop');
            }
          });  
        } catch (e) {
          if(e.message === 'endloop') {
            // 随后,你还可以停止观察  
            // observer.disconnect(); 
          }else{
            throw e
          }
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
      console.log('parseVideoNodeList-----------------start------------------')
      if(videoDoms && videoDoms.length){
        let videoNodeList = Array.from(videoDoms)
        videoNodeList.forEach(item => {
          if(!item || !(item instanceof HTMLElement)){
            return;
          }
          let downloadUrl = item.getAttribute('src');

          // 已存在
          if(downloadUrl && videoUrlSet.size && videoUrlSet.has(downloadUrl)){
            return;
          }
          
          // todo fetch other scenarios
          let videoInfo = handleVideoInfoParse(item);
          console.log('parseVideoNodeList------videoInfo---------',videoInfo)
          if(!videoInfo.downloadUrl){
            return;
          }
          videoUrlSet.add(downloadUrl);
          videoList.push(videoInfo);
        })
        window.postMessage({name: 'VIDEO_INFO_CAPTURE', videoList: videoList});
        console.log('parseVideoNodeList-----------result---------',videoList);
          
      }
    }
    
    /**
       * 获取视频信息
       * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList}
       * qualityList[{downloadUrl,qualityLabel, quality }]
       */
    function handleVideoInfoParse(videoDom){
      let videoInfo = {};
      let poster = videoDom.getAttribute('poster');
      let title = videoDom.getAttribute('title');
      let downloadUrl = videoDom.getAttribute('src');
      let qualityList = [];
      hostUrl = window.location.href;
      console.log('handleVideoInfoParse---host---', host);
      if(host.indexOf('youtube.com')){
        // if(Utils.isMobile()){
        //   videoInfo = handleMobileYoutubeVideoInfo(title);
        // }else{
        //   videoInfo = handleYoutubeVideoInfo(title);
        // }
        videoInfo = handleYoutubeVideoInfo(title);
      }
      else if(host.indexOf('baidu.com')){
        videoInfo = handleBaiduVideoInfo(videoDom);
      }



      if(!downloadUrl){
        downloadUrl = videoInfo.downloadUrl
      }
      if(!poster){
        poster = videoInfo.poster
      }
      if(!title){
        title = videoInfo.title
      }
      if(videoInfo.qualityList && videoInfo.qualityList.length){
        qualityList = videoInfo.qualityList;
      }
      videoInfo['title'] = title;
      videoInfo['poster'] = poster;
      videoInfo['downloadUrl'] = downloadUrl;
      videoInfo['hostUrl'] = hostUrl;
      videoInfo['qualityList'] = qualityList;
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
        if(pageData && pageData.pageData && pageData.pageData.remote && pageData.remote.mainVideoList && pageData.remote.mainVideoList.length){
          const mainVideo = pageData.remote.mainVideoList[0];
          videoInfo['title'] = mainVideo.title;
          videoInfo['poster'] = mainVideo.poster;
          videoInfo['downloadUrl'] = mainVideo.videoUrl;
          if(pageData.remote.moreVideoList && pageData.remote.moreVideoList.length){
            pageData.remote.moreVideoList.forEach(item=>{
              if(videoUrlSet.size && videoUrlSet.has(item.videoUrl)){
                return;
              }
              // more video
              videoList.push({title:item.title,poster:item.poster,downloadUrl:item.videoUrl,hostUrl:hostUrl});
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
        const preloadedState = window.__PRELOADED_STATE__;
        const videoId = Utils.queryURLParams(hostUrl, 'vid');
        const srcUrl = videoDom.getAttribute('src');
        // 主视频
        if(srcUrl && videoId && srcUrl.indexOf(videoId)){
          console.log('haokan----videoId-----',videoId);
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
      const haokanTitleDom = document.querySelector('.videoinfo .videoinfo-title');
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
    function handleYoutubeVideoInfo(title){
      let videoInfo = handleYoutubeGlobalVariable(title);
      if(Object.keys(videoInfo).length){
        return videoInfo;
      }else{
        videoInfo = {};
        videoInfo['title'] = getYoutubeVideoTitleByDom();
        // poster img
        videoInfo['poster'] = getYoutubeVideoPosterByDom();
        videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
      }
      return videoInfo;
    }
    
    /**
     * 解析Youtube视频信息
     * @return videoInfo{downloadUrl,poster,title,hostUrl,qualityList}
     */
    function handleMobileYoutubeVideoInfo(title){
      let videoInfo = handleYoutubeGlobalVariable(title);
      if(Object.keys(videoInfo).length){
        return videoInfo;
      }else{
        videoInfo = {};
        console.log('playerResp---is---null-------');
        videoInfo['title'] = getYoutubeVideoTitleByDom();
        // poster img
        videoInfo['poster'] = getYoutubeVideoPosterByDom();
        videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
      }
      return videoInfo;
    }
    
    function handleYoutubeGlobalVariable(title){
      const videoId = Utils.queryURLParams(hostUrl, 'v');
      // console.log('videoId-------------',videoId)
      let videoInfo = {};
      const playerResp = window.ytInitialPlayerResponse;
      // console.log('playerResp-------', playerResp);
      if(playerResp && playerResp.videoDetails && playerResp.streamingData && videoId === playerResp.videoDetails.videoId){
        const videoDetails = playerResp.videoDetails;
        videoInfo['title'] = videoDetails.title;
        let thumbnail = videoDetails.thumbnail;
        if(thumbnail){
          let thumbnails = thumbnail.thumbnails;
          if(thumbnails && thumbnails.length){
            // console.log('thumbnails-----',thumbnails);
            videoInfo['poster'] =  thumbnails.pop().url;
          }else{
            videoInfo['poster'] = getYoutubeVideoPosterByDom();
          }
        }else{
          videoInfo['poster'] = getYoutubeVideoPosterByDom();
        }
        // console.log('playerResp-------videoDetails-------------', videoDetails);
        const streamingData = playerResp.streamingData;
        const adaptiveFormats = streamingData.adaptiveFormats;
        // 取画质的时候防止原视频有广告
        if(adaptiveFormats && adaptiveFormats.length && title === videoDetails.title){
          // console.log('playerResp-------adaptiveFormats------------------', adaptiveFormats);
          // * qualityList[{downloadUrl, qualityLabel, quality}]
          let qualityList = []
          let qualitySet = new Set();
          adaptiveFormats.forEach(item=>{
            let mimeType = item.mimeType;
            if(mimeType.indexOf('video/mp4')>-1 && item.url && !qualitySet.has(item.quality)){
              qualitySet.add(item.quality)
              qualityList.push({downloadUrl:item.url, qualityLabel:item.qualityLabel, quality: item.quality})
            }
          });
          if(qualityList && qualityList.length){
            videoInfo['qualityList'] = qualityList;
          }
          videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        }
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
      console.log(overlayImg)
      if(overlayImg){
        console.log('overlayImg-------',overlayImg);
        let imgText = overlayImg.getAttribute('style');
        console.log('overlayImg----imgText---',imgText);
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
      return '';
    }
    
    startFindVideoInfo();
    //   observerVideo()
    document.onreadystatechange = () => {
      console.log('document.readyState==',document.readyState)
      if (document.readyState === 'complete') {
        console.log('readyState-------------------', document.readyState)
        
        
        // eslint-disable-next-line no-undef
        console.log('readyStateytInitialPlayerResponseytInitialPlayerResponse-----')
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
        console.log('OPEN_URL',url);
        this.reallyOpen(method,url,async,user,password);
        if (isVideoLink(url)){
          if (!uniqueUrls.has(url)){
            uniqueUrls.add(url);
            console.log('VIDEO_LINK_CAPTURE: ' + url);
            window.postMessage({name: 'VIDEO_LINK_CAPTURE', urls: uniqueUrls});
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
          }       
        }
        return originalFetch(resource,options);
      };
    }
  }

  
  
  window.addEventListener('message', (e) => {
    if (!e || !e.data || !e.data.name) return;
    
    const name = e.data.name;
    console.log('snifffer.user----->e.data.name=',name);
    if(name === 'VIDEO_LINK_CAPTURE'){
      videoLinkSet = e.data.urls ? e.data.urls : new Set();
      // console.log('snifffer.user----->videoLinkSet=',videoLinkSet);
    }
    else if(name === 'VIDEO_INFO_CAPTURE'){
      videoInfoList = e.data.videoList ? e.data.videoList : [];
      // console.log('snifffer.user----->videoInfoList=',videoInfoList);
    }

    // let message = { from: 'sniffer', operate: 'VIDEO_INFO_PUSH' };
    // browser.runtime.sendMessage(message, (response) => {
    // });

  })


  // document.onreadystatechange = () => {
  //   console.log('content--------document.readyState==',document.readyState)
  //   if (document.readyState === 'complete') {
  //     console.log('content--------readyState-------------------', document.readyState)
  //     // startFindVideoInfo();
      
  //     // eslint-disable-next-line no-undef
  //     console.log('content-------------')
  //   }
  // };

  

  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const requestFrom = request.from;
    const operate = request.operate;
    if('background' === requestFrom){
      if('FETCH_VIDEO_INFO' === operate){
        console.log('----videoInfoList-----',videoInfoList,videoLinkSet);
        sendResponse({body: {videoInfoList: mergeVideoInfoList()}})
      }
    }
    return true;
  })

  /**
   * 合并 videoInfoList 和 videoLinkSet
   * @returns videoInfoListRes
   */
  function mergeVideoInfoList(){
    let videoInfoListRes = [];
    let hostUrl = window.location.href;
    console.log('mergeVideoInfoList-------',hostUrl)
    if(videoInfoList.length){
      let videnLen = videoInfoList.length
      let isValidAmount = 0;
      if(videnLen == 1){
        videoInfoList.forEach(item=>{
          if(!isURL(item.downloadUrl)){
            isValidAmount = isValidAmount + 1;
            return
          }
        });
        if(videoLinkSet.size == 1){
          if(isValidAmount == 1){
            let array = [...videoLinkSet];
            videoInfoList[0].downloadUrl = array[0];
            videoInfoListRes = videoInfoList;
          }else{
            videoInfoListRes = videoInfoList;
          }
        }else{
          if(videoLinkSet.size>1){
            // 存在无效视频链接，以videoLinkSet为准
            if(isValidAmount == 1){
              let array = [...videoLinkSet];
              array.forEach(item=>{
                videoInfoListRes.push({downloadUrl:item,poster:'',title: new URL(item).pathname, hostUrl:hostUrl,qualityList:[]})
              })
              return videoInfoListRes;
            }
          }
        }
        videoInfoListRes = videoInfoList;
        return videoInfoListRes;
      }
      // videoInfoList.length>1
      else {
        // 收集有效视频信息
        videoInfoList.forEach(item=>{
          if(isURL(item.downloadUrl)){
            videoInfoListRes.push(item);
          }
        });
        // 有效视频信息videoInfoListRes与videoLinkSet进行合并
        if(videoInfoListRes.length){
          let array = [...videoLinkSet];
          let videoUrlArr = [];
          videoInfoListRes.forEach(videoItem=>{
            videoUrlArr.push(videoItem.downloadUrl);
          })
          array.forEach(item=>{
            if(!videoUrlArr.includes(item)){
              videoInfoListRes.push({downloadUrl:item,poster:'',title:new URL(item).pathname,hostUrl: hostUrl,qualityList:[]})
            }
          })
        }else{
          // videoInfoList中没有有效链接，以videoLinkSet返回
          let array = [...videoLinkSet];
          array.forEach(item=>{
            videoInfoListRes.push({downloadUrl:item,poster:'',title:new URL(item).pathname,hostUrl: hostUrl,qualityList:[]})
          })
        }
      }
    }
    return videoInfoListRes;
  }

  function isURL(s) {
    if(!s){
      return false;
    }
    return /^http[s]?:\/\/.*/.test(s);
  }
  
    
  

})()