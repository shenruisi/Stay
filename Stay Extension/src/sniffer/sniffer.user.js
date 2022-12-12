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
    const hostUrl = window.location.href;
    let host = window.location.host;
    console.log('------------injectParseVideoJS-----start------------------')
    let videoList = [];
    // 获取到的video Url数组
    let videoUrlSet = new Set();
    // Firefox和Chrome早期版本中带有前缀  
    const MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    let videoDoms;  
      
    // let ifreamDoms = document.getElementsByTagName('iframe');
    function startFindVideoInfo(){
      videoDoms = document.querySelectorAll('video');  
      // let flag = false;
      let flag = videoDoms && videoDoms.length;
      if(flag){
        console.log('videoDoms---false-----',videoDoms)
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
              console.log('mutation.videoDoms-----',videoDoms)
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
          console.log('parseVideoNodeList-----------------start------------------')
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

      console.log('handleVideoInfoParse---host---', host);
      if(host.indexOf('youtube.com')){
        videoInfo = handleYoutubeVideoInfo();
      }
      else if(host.indexOf('baidu.com')){
        videoInfo = handleBaiduVideoInfo();
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
    function handleBaiduVideoInfo(){
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
        if(preloadedState && preloadedState.curVideoMeta){
          const curVideoMeta = preloadedState.curVideoMeta;
          videoInfo = haokanBaiduVideoInfo(curVideoMeta);
          if(videoInfo && Object.keys(videoInfo).length){
            return videoInfo;
          }
        }
        videoInfo['title'] = getBaiduVideoTitle();
        videoInfo['poster'] = getBaiduVideoPoster();
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
          return matchUrlInString(haokanPosterInfo);
        }
      }
      const mhdPosterDom = document.querySelector('#bdMainPlayer .art-video-player .art-poster')
      if(mhdPosterDom){
        let mhdPosterInfo = mhdPosterDom.getAttribute('style');
        if(mhdPosterInfo){
          return matchUrlInString(mhdPosterInfo);
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
    function handleYoutubeVideoInfo(){
      let videoInfo = {};
      const playerResp = window.ytInitialPlayerResponse;
      console.log(window)
      if(playerResp){
        console.log('playerResp-------', playerResp);
        const videoDetails = playerResp.videoDetails;
        if(videoDetails){
          if(videoDetails.title){
            videoInfo['title'] = videoDetails.title;
          }else{
            videoInfo['title'] = getYoutubeVideoTitleByDom();
          }
          let thumbnail = videoDetails.thumbnail;
          if(thumbnail){
            let thumbnails = thumbnail.thumbnails;
            if(thumbnails && thumbnails.length){
            //   console.log('thumbnails-----',thumbnails);
              videoInfo['poster'] =  thumbnails.pop().url;
            }else{
              videoInfo['poster'] = getYoutubeVideoPosterByDom();
            }
          }else{
            videoInfo['poster'] = getYoutubeVideoPosterByDom();
          }
        }else{
          videoInfo['title'] = getYoutubeVideoTitleByDom();
          // poster img
          videoInfo['poster'] = getYoutubeVideoPosterByDom();
        }
        const streamingData = playerResp.streamingData;
        if(streamingData){
          const adaptiveFormats = streamingData.adaptiveFormats;
          if(adaptiveFormats && adaptiveFormats.length){
            // * qualityList[{downloadUrl,qualityLabel, quality }]
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
              videoInfo['downloadUrl'] = qualityList[0].url;
              videoInfo['qualityList'] = qualityList;
            }else{
              videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
            }
          }else{
            videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
          }
        }else{
          videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
        }
      }else{
        console.log('playerResp---is---null-------');
        videoInfo['title'] = getYoutubeVideoTitleByDom();
        // poster img
        videoInfo['poster'] = getYoutubeVideoPosterByDom();
        videoInfo['downloadUrl'] = getYoutubeVideoSourceByDom();
      }
      return videoInfo;
    }
    
    function getYoutubeVideoSourceByDom(){
      let videoDom = document.querySelector('.html5-video-player .html5-video-container video');
      if(videoDom){
        return videoDom.getAttribute('src');
      }
      return '';
    }
    
    function getYoutubeVideoTitleByDom(){
      const titleDom = document.querySelector('.slim-video-metadata-header .slim-video-information-content .slim-video-information-title');
      if(titleDom){
        return titleDom.textContent;
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
          return matchUrlInString(imgText);
        }
      }
      return '';
    }
    
    function matchUrlInString(imgText){
      const urlReg = new RegExp('(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]', 'g');
      const imgMatchs = imgText.match(urlReg);
      //   poster = imgMatchs && imgMatchs.length ? imgMatchs[0] : '';
      if(imgMatchs && imgMatchs.length){
        return imgMatchs[0];
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
      console.log('snifffer.user----->videoLinkSet=',videoLinkSet);
    }
    else if(name === 'VIDEO_INFO_CAPTURE'){
      videoInfoList = e.data.videoList ? e.data.videoList : [];
      console.log('snifffer.user----->videoInfoList=',videoInfoList);
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
        sendResponse({body : {videoInfoList, videoLinkSet}})
      }
    }
    return true;
  })

  
    
  

})()