/**
 * 嗅探video资源，数据处理中心
 * 接受background push的数据，最后待popup来获取数据
 */
let __b; 
if (typeof window.browser !== 'undefined') { __b = window.browser; } if (typeof window.chrome !== 'undefined') { __b = window.chrome; }
const browser = __b;
(function(){
  let videoInfoList = [];
  let videoLinkSet = new Set();
  let videoPageUrl = '';
  let currentTabUrl = window.location.href;
  /**
     * 合并 videoInfoList 和 videoLinkSet
     * @returns videoInfoListRes
     */
  function mergeVideoInfoList(){
    let videoInfoListRes = [];
    
    // console.log('mergeVideoInfoList-------',hostUrl, videoInfoList, videoLinkSet)
    if(videoInfoList.length){
      let videnLen = videoInfoList.length
      let isValidAmount = 0;
      if(videnLen == 1){
        videoInfoList.forEach(item=>{
          if(!isURL(item.downloadUrl)){
            isValidAmount = isValidAmount + 1;
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
                videoInfoListRes.push({downloadUrl:item,poster:'',title: getLastPathName(item, videoPageUrl), hostUrl:videoPageUrl,qualityList:[]})
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
        if(!videoLinkSet || videoLinkSet.size==0){
          return videoInfoListRes;
        }
        // 有效视频信息videoInfoListRes与videoLinkSet进行合并
        if(videoInfoListRes.length){
          let array = [...videoLinkSet];
          
          let videoUrlArr = [];
          videoInfoListRes.forEach(videoItem=>{
            videoUrlArr.push(videoItem.downloadUrl);
          })
          array.forEach(item=>{
            if(!videoUrlArr.includes(item)){
              videoInfoListRes.push({downloadUrl:item,poster:'',title: getLastPathName(item, videoPageUrl),hostUrl: getHostname(videoPageUrl),qualityList:[]})
            }
          })
        }else{
          // videoInfoList中没有有效链接，以videoLinkSet返回
          let array = [...videoLinkSet];
          array.forEach(item=>{
            videoInfoListRes.push({downloadUrl:item,poster:'',title: getLastPathName(item, videoPageUrl),hostUrl: getHostname(videoPageUrl),qualityList:[]})
          })
        }
      }
    }
    return videoInfoListRes;
  }

  function getHostname(url) {
    if(!url){
      return ''
    }
    try {
      return new URL(url).hostname.toLowerCase();
    } catch (error) {
      return url.split('/')[0].toLowerCase();
    }
  }

  function isURL(s) {
    if(!s){
      return false;
    }
    return /^http[s]?:\/\/.*/.test(s);
  }

  function getLastPathName(downloadUrl, hostUrl){
    let pathName = '';
    if(downloadUrl){
      pathName = new URL(downloadUrl).pathname;
    }else{
      pathName = new URL(hostUrl).pathname;
    }
    let pathArr = pathName.split('/');
    pathArr = pathArr.filter(item=>{if(item&&item!=''){return item}});
    return pathArr.pop();
  }

  browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    const requestFrom = request.from;
    const operate = request.operate;
    if('background' === requestFrom){
      if('VIDEO_INFO_PUSH' === operate){
        videoPageUrl = request.videoPageUrl;
        if(request.videoLinkSet && request.videoLinkSet.size){
          videoLinkSet = request.videoLinkSet
          // console.log('videoLinkSet--------', videoLinkSet);
        }
        if(request.videoInfoList && request.videoInfoList.length){
          videoInfoList = request.videoInfoList
        }
      }
      
    }
    else if('popup' === requestFrom){
      if('snifferFetchVideoInfo' === operate){
        let videoListRes = mergeVideoInfoList();
        if(videoListRes.length){
          videoListRes.filter((item, i, arr)=>{
            return currentTabUrl.indexOf(item.hostUrl);        
          })
        }
        
        sendResponse({body: {videoInfoList : videoListRes}});
      }
        
    }


    return true;
  });
  
})()