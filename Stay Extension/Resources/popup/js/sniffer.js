(()=>{var e={7022:(e,t,o)=>{let n;o(7658),"undefined"!==typeof window.browser&&(n=window.browser),"undefined"!==typeof window.chrome&&(n=window.chrome);const r=n;(function(){let e=[],t=new Set,o=window.location.host,n=document.createElement("script");n.type="text/javascript",n.id="stay_inject_parse_video_js_"+o;let i=`\n\nlet handleVideoInfo = ${l}\n\nhandleVideoInfo();`;if(n.appendChild(document.createTextNode(i)),document.body)document.body.appendChild(n);else{const e=document.documentElement,t=new MutationObserver((()=>{document.body&&(t.disconnect(),document.body.appendChild(n))}));t.observe(e,{childList:!0})}function l(){let e=window.location.href,t=window.location.host,o=[],n=new Set;const r=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let i;const l={isMobile:function(){const e=navigator.userAgent;let t=["Android","iPhone","SymbianOS","Windows Phone","iPad","iPod"],o=t.filter((t=>e.includes(t)));return!!o.length},queryURLParams:function(e,t){const o=new RegExp("[?&#]+"+t+"=([^?&#]+)"),n=o.exec(e);return n&&n[1]?n[1]:""},matchUrlInString:function(e){const t=new RegExp("(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]","g"),o=e.match(t);return o&&o.length?o[0]:""},isURL:function(e){return!!e&&/^http[s]?:\/\/.*/.test(e)}};function a(){i=document.querySelectorAll("video");let e=i&&i.length;e?d(i):s()}function s(){const e=new r((function(e){try{e.forEach((function(e){if(i=document.querySelectorAll("video"),"VIDEO"===e.target.nodeName&&i&&i.length)throw t=window.location.host,d(i),new Error("endloop")}))}catch(o){if("endloop"!==o.message)throw o}})),o={attributes:!0,childList:!0,characterData:!0,subtree:!0};e.observe(document,o)}function d(e){if(e&&e.length){let t=Array.from(e);t.forEach((e=>{if(!e||!(e instanceof HTMLElement))return;let t=e.getAttribute("src");if(t&&n.size&&n.has(t))return;let r=u(e);r.downloadUrl&&(n.add(t),o.push(r))})),window.postMessage({name:"VIDEO_INFO_CAPTURE",videoList:o}),console.log("parseVideoNodeList-----------result---------",o)}}function u(o){let n={},r=o.getAttribute("poster"),i=o.getAttribute("title"),l=o.getAttribute("src"),a=[];return e=window.location.href,console.log("handleVideoInfoParse---host---",t),t.indexOf("youtube.com")>-1?n=h(i):t.indexOf("baidu.com")>-1&&(n=c(o)),l||(l=n.downloadUrl),r||(r=n.poster),i||(i=n.title),n.qualityList&&n.qualityList.length&&(a=n.qualityList),n["title"]=i,n["poster"]=r,n["downloadUrl"]=l,n["hostUrl"]=e,n["qualityList"]=a,n}function c(r){let i={};if("activity.baidu.com"===t){const t=window.PAGE_DATA;if(t&&t.pageData&&t.pageData.remote&&t.remote.mainVideoList&&t.remote.mainVideoList.length){const r=t.remote.mainVideoList[0];return i["title"]=r.title,i["poster"]=r.poster,i["downloadUrl"]=r.videoUrl,t.remote.moreVideoList&&t.remote.moreVideoList.length&&t.remote.moreVideoList.forEach((t=>{n.size&&n.has(t.videoUrl)||o.push({title:t.title,poster:t.poster,downloadUrl:t.videoUrl,hostUrl:e})})),i}i["title"]=p();const r=document.querySelector(".stickyBlock .curVideoPlay video");return r&&(i["poster"]=r.getAttribute("poster"),i["downloadUrl"]=r.getAttribute("src")),i}if("mbd.baidu.com"===t){const e=window.jsonData;if(e&&e.curVideoMeta){const t=e.curVideoMeta;if(i=f(t),i&&Object.keys(i).length)return i}return i["title"]=p(),i["poster"]=m(),i}if("haokan.baidu.com"===t){const t=window.__PRELOADED_STATE__,o=l.queryURLParams(e,"vid"),n=r.getAttribute("src");if(n&&o&&n.indexOf(o)>-1){if(t&&t.curVideoMeta){const e=t.curVideoMeta;if(i=f(e),i&&Object.keys(i).length)return i}i["title"]=p(),i["poster"]=m()}else i["title"]=r.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title")?r.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title").textContent:"",i["poster"]=r.parentElement&&r.parentElement.querySelector("img.video-img")?r.parentElement.querySelector("img.video-img").getAttribute("src"):"";return i}return"pan.baidu.com"===t&&(i["title"]=p()),i}function f(e){if(!e)return{};let t={};if(t["title"]=e.title,t["poster"]=e.poster,t["downloadUrl"]=e.playurl,e.clarityUrl&&e.clarityUrl.length){let o=[];const n=e.clarityUrl;n.forEach((e=>{e.vodVideoHW;o.push({downloadUrl:e.url,qualityLabel:e.title,quality:e.key})})),t["qualityList"]=o}return t}function m(){const e=document.querySelector(".art-player-wrapper .art-video-player .art-poster");if(e){let t=e.getAttribute("style");if(t)return l.matchUrlInString(t)}const t=document.querySelector("#bdMainPlayer .art-video-player .art-poster");if(t){let e=t.getAttribute("style");if(e)return l.matchUrlInString(e)}return""}function p(){const e=document.querySelector(".adVideoPageV3 .curVideoInfo h3.videoTitle");if(e)return e.textContent;const t=document.querySelector(".video-info .video-info-title");if(t)return t.textContent;const o=document.querySelector(".video-main .video-content .video-title .video-title-left");return o?o.textContent:""}function h(e){let t=y(e);return Object.keys(t).length||(t={},t["title"]=g(),t["poster"]=v(),t["downloadUrl"]=w()),t}function y(t){const o=l.queryURLParams(e,"v");let n={};const r=window.ytInitialPlayerResponse;if(r&&r.videoDetails&&r.streamingData&&o===r.videoDetails.videoId){const e=r.videoDetails;n["title"]=e.title;let o=e.thumbnail;if(o){let e=o.thumbnails;e&&e.length?n["poster"]=e.pop().url:n["poster"]=v()}else n["poster"]=v();const i=r.streamingData,l=i.adaptiveFormats;if(l&&l.length&&t===e.title){let e=[],t=new Set;l.forEach((o=>{let n=o.mimeType;n.indexOf("video/mp4")>-1&&o.url&&!t.has(o.quality)&&(t.add(o.quality),e.push({downloadUrl:o.url,qualityLabel:o.qualityLabel,quality:o.quality}))})),e&&e.length&&(n["qualityList"]=e),n["downloadUrl"]=w()}}return n}function w(){let e=document.querySelector(".html5-video-player .html5-video-container video");return e?e.getAttribute("src"):""}function g(){const e=document.querySelector(".slim-video-metadata-header .slim-video-information-content .slim-video-information-title");if(e)return e.textContent;const t=document.querySelector("#title h1.style-scope");return t?t.textContent:""}function v(){const e=document.querySelector(".ytp-cued-thumbnail-overlay-image");if(console.log(e),e){console.log("overlayImg-------",e);let t=e.getAttribute("style");if(console.log("overlayImg----imgText---",t),t)return l.matchUrlInString(t)}const t=document.querySelector(".html5-video-player .ytp-cued-thumbnail-overlay .ytp-cued-thumbnail-overlay-image");if(t){let e=t.getAttribute("style");if(e)return l.matchUrlInString(e)}return""}function b(){function e(e){let t=/^(https?:\/\/|\/).*\.(mp4|m3u8)$/;return null!=e.match(t)}let t=new Set;XMLHttpRequest.prototype.reallyOpen=XMLHttpRequest.prototype.open,XMLHttpRequest.prototype.open=function(o,n,r,i,l){console.log("OPEN_URL",n),this.reallyOpen(o,n,r,i,l),e(n)&&(t.has(n)||(t.add(n),console.log("VIDEO_LINK_CAPTURE: "+n),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:t})))};let o=window.fetch;window.fetch=function(n,r){let i="object"==typeof n?n.url:n;return e(i)&&(t.has(i)||(t.add(i),console.log("VIDEO_LINK_CAPTURE: "+i),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:t}))),o(n,r)}}a(),document.onreadystatechange=()=>{console.log("document.readyState==",document.readyState),"complete"===document.readyState&&(console.log("readyState-------------------",document.readyState),a(),console.log("readyStateytInitialPlayerResponseytInitialPlayerResponse-----"))},b()}function a(){let o=[],n=window.location.href;if(console.log("mergeVideoInfoList-------",n),e.length){let r=e.length,i=0;if(1==r){if(e.forEach((e=>{s(e.downloadUrl)||(i+=1)})),1==t.size)if(1==i){let n=[...t];e[0].downloadUrl=n[0],o=e}else o=e;else if(t.size>1&&1==i){let e=[...t];return e.forEach((e=>{o.push({downloadUrl:e,poster:"",title:new URL(e).pathname,hostUrl:n,qualityList:[]})})),o}return o=e,o}if(e.forEach((e=>{s(e.downloadUrl)&&o.push(e)})),o.length){let e=[...t],r=[];o.forEach((e=>{r.push(e.downloadUrl)})),e.forEach((e=>{r.includes(e)||o.push({downloadUrl:e,poster:"",title:new URL(e).pathname,hostUrl:n,qualityList:[]})}))}else{let e=[...t];e.forEach((e=>{o.push({downloadUrl:e,poster:"",title:new URL(e).pathname,hostUrl:n,qualityList:[]})}))}}return o}function s(e){return!!e&&/^http[s]?:\/\/.*/.test(e)}window.addEventListener("message",(o=>{if(!o||!o.data||!o.data.name)return;const n=o.data.name;console.log("snifffer.user-----\x3ee.data.name=",n),"VIDEO_LINK_CAPTURE"===n?t=o.data.urls?o.data.urls:new Set:"VIDEO_INFO_CAPTURE"===n&&(e=o.data.videoList?o.data.videoList:[])})),r.runtime.onMessage.addListener(((o,n,r)=>{const i=o.from,l=o.operate;return"background"===i&&"FETCH_VIDEO_INFO"===l&&(console.log("----videoInfoList-----",e,t),r({body:{videoInfoList:a()}})),!0}))})()}},t={};function o(n){var r=t[n];if(void 0!==r)return r.exports;var i=t[n]={exports:{}};return e[n](i,i.exports,o),i.exports}o.m=e,(()=>{var e=[];o.O=(t,n,r,i)=>{if(!n){var l=1/0;for(u=0;u<e.length;u++){n=e[u][0],r=e[u][1],i=e[u][2];for(var a=!0,s=0;s<n.length;s++)(!1&i||l>=i)&&Object.keys(o.O).every((e=>o.O[e](n[s])))?n.splice(s--,1):(a=!1,i<l&&(l=i));if(a){e.splice(u--,1);var d=r();void 0!==d&&(t=d)}}return t}i=i||0;for(var u=e.length;u>0&&e[u-1][2]>i;u--)e[u]=e[u-1];e[u]=[n,r,i]}})(),(()=>{o.n=e=>{var t=e&&e.__esModule?()=>e["default"]:()=>e;return o.d(t,{a:t}),t}})(),(()=>{o.d=(e,t)=>{for(var n in t)o.o(t,n)&&!o.o(e,n)&&Object.defineProperty(e,n,{enumerable:!0,get:t[n]})}})(),(()=>{o.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()})(),(()=>{o.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t)})(),(()=>{o.j=875})(),(()=>{var e={875:0};o.O.j=t=>0===e[t];var t=(t,n)=>{var r,i,l=n[0],a=n[1],s=n[2],d=0;if(l.some((t=>0!==e[t]))){for(r in a)o.o(a,r)&&(o.m[r]=a[r]);if(s)var u=s(o)}for(t&&t(n);d<l.length;d++)i=l[d],o.o(e,i)&&e[i]&&e[i][0](),e[i]=0;return o.O(u)},n=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];n.forEach(t.bind(null,0)),n.push=t.bind(null,n.push.bind(n))})();var n=o.O(void 0,[998],(()=>o(7022)));n=o.O(n)})();