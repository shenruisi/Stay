(()=>{var e={7022:(e,t,o)=>{let n;o(7658),"undefined"!==typeof window.browser&&(n=window.browser),"undefined"!==typeof window.chrome&&(n=window.chrome);const r=n;(function(){let e=!1;try{t(),document.addEventListener("securitypolicyviolation",(t=>{e=!0,o(e)}))}catch(l){}function t(){const e=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let t=window.location.host,n=document.createElement("script");n.type="text/javascript",n.id="stay_inject_parse_video_js_"+t;let r=`\n\nlet handleVideoInfo = ${o}\n\nhandleVideoInfo(false);`;if(n.appendChild(document.createTextNode(r)),document.body)document.body.appendChild(n);else{let t=new e(((e,o)=>{document.body&&(document.body.appendChild(n),t.disconnect())}));t.observe(document.documentElement,{attributes:!0,childList:!0,characterData:!0,subtree:!0})}}function o(e){let t=window.location.href,o=window.location.host,n=[],i=new Set,l=new Set;const a=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let s;const d={isMobile:function(){const e=navigator.userAgent;let t=["Android","iPhone","SymbianOS","Windows Phone","iPad","iPod"],o=t.filter((t=>e.includes(t)));return!!o.length},queryURLParams:function(e,t){const o=new RegExp("[?&#]+"+t+"=([^?&#]+)"),n=o.exec(e);return n&&n[1]?n[1]:""},matchUrlInString:function(e){const t=new RegExp("(https?|http)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]","g"),o=e.match(t);return o&&o.length?o[0]:""},isURL:function(e){return!!e&&/^http[s]?:\/\/.*/.test(e)},completionSourceUrl:function(e){return e?(/^(f|ht)tps?:\/\//i.test(e)||(e=/^\/\//i.test(e)?window.location.protocol+e:window.location.origin+e),e):""},checkCharLengthAndSubStr:function(e,t=80){if(!e)return"";let o=e.replace(/[^x00-xff]/g,"01");return o.length<=t?e:e.substr(0,t)},getUrlPathName:function(e){let o="";o=this.isURL(e)?new URL(e).pathname:new URL(t).pathname;let n=o.split("/");return n=n.filter((e=>{if(e&&""!=e)return e})),n.pop()}};function c(){s=document.querySelectorAll("video");let e=s&&s.length;e?f(s):u()}function u(){const e=new a((function(e){try{e.forEach((function(e){if(s=document.querySelectorAll("video"),"VIDEO"===e.target.nodeName&&s&&s.length)throw o=window.location.host,f(s),new Error("endloop")}))}catch(t){if("endloop"!==t.message)throw t}})),t={attributes:!0,childList:!0,characterData:!0,subtree:!0};e.observe(document,t)}function f(t){if(t&&t.length){let o=Array.from(t);if(o.forEach((e=>{if(!e||!(e instanceof HTMLElement))return;let t=e.getAttribute("src");if(!t){let o=e.querySelector("source");o&&(e=o,t=o.getAttribute("src"))}if(t=d.completionSourceUrl(t),t&&i.size&&i.has(t))return;let o=p(e);o.downloadUrl&&(i.add(t),n.push(o))})),window.postMessage({name:"VIDEO_INFO_CAPTURE",videoList:n}),console.log("parseVideoNodeList-----------result---------",n),e){let e={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoInfoList:n};r.runtime.sendMessage(e,(e=>{}))}}}function p(e){let n={},r=e.getAttribute("poster"),i=e.getAttribute("title"),a=e.getAttribute("src"),s=[];if(t=window.location.href,a=d.completionSourceUrl(a),!r){let e=document.querySelector("source[type='image/webp'] img");r=e?e.getAttribute("src"):"",i||(i=e?e.getAttribute("alt"):"")}if(o.indexOf("youtube.com")>-1){const e=d.queryURLParams(t,"v");if(l.size&&l.has(e))return console.log("videoId------isAlready",e),{};n=S(i,e),n&&Object.keys(n).length&&n.downloadUrl&&l.add(e)}else if(o.indexOf("baidu.com")>-1)n=g(e);else if(o.indexOf("bilibili.com")>-1)n=m(e);else if(o.indexOf("mobile.twitter.com")>-1)n=h(e);else if(o.indexOf("m.weibo.cn")>-1){let t=d.getUrlPathName(a);if(t&&l.size&&l.has(t))return{};n=y(e),n&&Object.keys(n).length&&n.downloadUrl&&l.add(t)}return a||(a=n.downloadUrl),a=d.completionSourceUrl(a),r||(r=n.poster),i||(i=n.title),n.qualityList&&n.qualityList.length&&(s=n.qualityList),i||(i=d.getUrlPathName(a)),r=d.completionSourceUrl(r),n["title"]=i,n["poster"]=r,n["downloadUrl"]=a,n["hostUrl"]=t,n["qualityList"]=s,n}function m(e){let t={};t.poster=e.getAttribute("poster"),t.downloadUrl=e.getAttribute("src");let o=document.querySelector(".main-container .ep-info-pre .ep-info-title");return o&&(t.title=o.textContent),t}function h(e){let t={};t.poster=e.getAttribute("poster"),t.downloadUrl=e.getAttribute("src");let o=e.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.nextElementSibling.childNodes[1];return o&&(o=o.querySelector(".css-1dbjc4n .r-92ivih.r-1t01tom .r-1t982j2.r-1j3t67a .css-1dbjc4n.r-1kw4oii a[data-testid='tweetText'] span"),o&&(t.title=d.checkCharLengthAndSubStr(o.textContent))),t}function y(e){let t={};return t.poster=e.getAttribute("poster"),t.downloadUrl=e.getAttribute("src"),t}function g(e){let r={};if("activity.baidu.com"===o){const e=window.PAGE_DATA;if(e&&e.pageData&&e.pageData.remote&&e.pageData.remote.mainVideoList&&e.pageData.remote.mainVideoList.length){const o=e.pageData.remote.mainVideoList[0],l=e.pageData.remote.moreVideoList;return r["title"]=o.title,r["poster"]=o.poster,r["downloadUrl"]=o.videoUrl,l&&l.length&&l.forEach((e=>{i.size&&i.has(e.videoUrl)||n.push({title:e.title,poster:e.poster,downloadUrl:e.videoUrl,hostUrl:t})})),r}r["title"]=v();const o=document.querySelector(".stickyBlock .curVideoPlay video");return o&&(r["poster"]=o.getAttribute("poster"),r["downloadUrl"]=o.getAttribute("src")),r}if("mbd.baidu.com"===o){const e=window.jsonData;if(e&&e.curVideoMeta){const t=e.curVideoMeta;if(r=w(t),r&&Object.keys(r).length)return r}return r["title"]=v(),r["poster"]=b(),r}if("haokan.baidu.com"===o){const o=window.__PRELOADED_STATE__,n=d.queryURLParams(t,"vid"),i=e.getAttribute("src");if(i&&n&&i.indexOf(n)>-1){if(o&&o.curVideoMeta){const e=o.curVideoMeta;if(r=w(e),r&&Object.keys(r).length)return r}r["title"]=v(),r["poster"]=b()}else r["title"]=e.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title")?e.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title").textContent:"",r["poster"]=e.parentElement&&e.parentElement.querySelector("img.video-img")?e.parentElement.querySelector("img.video-img").getAttribute("src"):"";return r}return"pan.baidu.com"===o&&(r["title"]=v()),r}function w(e){if(!e)return{};let t={};if(t["title"]=e.title,t["poster"]=e.poster,t["downloadUrl"]=e.playurl,e.clarityUrl&&e.clarityUrl.length){let o=[];const n=e.clarityUrl;n.forEach((e=>{e.vodVideoHW;o.push({downloadUrl:e.url,qualityLabel:e.title,quality:e.key})})),t["qualityList"]=o}return t}function b(){const e=document.querySelector(".art-player-wrapper .art-video-player .art-poster");if(e){let t=e.getAttribute("style");if(t)return d.matchUrlInString(t)}const t=document.querySelector("#bdMainPlayer .art-video-player .art-poster");if(t){let e=t.getAttribute("style");if(e)return d.matchUrlInString(e)}return""}function v(){const e=document.querySelector(".adVideoPageV3 .curVideoInfo h3.videoTitle");if(e)return e.textContent;const t=document.querySelector(".video-info .video-info-title");if(t)return t.textContent;const o=document.querySelector(".video-main .video-content .video-title .video-title-left");return o?o.textContent:""}function S(e,t){let o={};const n=window.ytInitialPlayerResponse;if(n&&n.videoDetails&&n.streamingData&&t===n.videoDetails.videoId){const t=n.videoDetails;let r=t.title?t.title:"";o["title"]=r;let i=t.thumbnail;if(i){let e=i.thumbnails;e&&e.length&&(o["poster"]=e.pop().url)}const l=n.streamingData,a=l.formats;if(e=e||"",a&&a.length&&e.replace(/\s+/g,"")===r.replace(/\s+/g,"")){let e=[],t=new Set;a.forEach((o=>{let n=o.mimeType;n.indexOf("video/mp4")>-1&&o.url&&!t.has(o.quality)&&(t.add(o.quality),e.push({downloadUrl:o.url,qualityLabel:o.qualityLabel,quality:o.quality}))})),e&&e.length&&(o["qualityList"]=e),o["downloadUrl"]=U()}else o["title"]=O(),o["downloadUrl"]=U(),o["poster"]=E()}else o={},o["title"]=O(),o["poster"]=E(),o["downloadUrl"]=U();return o}function U(){let e=document.querySelector(".html5-video-player .html5-video-container video");return e?e.getAttribute("src"):""}function O(){const e=document.querySelector(".slim-video-metadata-header .slim-video-information-content .slim-video-information-title");if(e)return e.textContent;const t=document.querySelector("#title h1.style-scope");return t?t.textContent:""}function E(){const e=document.querySelector(".ytp-cued-thumbnail-overlay-image");if(console.log(e),e){console.log("overlayImg-------",e);let t=e.getAttribute("style");if(t)return d.matchUrlInString(t)}const t=document.querySelector(".html5-video-player .ytp-cued-thumbnail-overlay .ytp-cued-thumbnail-overlay-image");if(t){let e=t.getAttribute("style");if(e)return d.matchUrlInString(e)}return""}function L(){function t(e){let t=/^(https?:\/\/|\/).*\.(mp4|m3u8)$/;return null!=e.match(t)}let o=new Set;XMLHttpRequest.prototype.reallyOpen=XMLHttpRequest.prototype.open,XMLHttpRequest.prototype.open=function(n,i,l,a,s){if(this.reallyOpen(n,i,l,a,s),t(i)&&!o.has(i)&&(o.add(i),console.log("VIDEO_LINK_CAPTURE: "+i),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:o}),e)){let e={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:o};r.runtime.sendMessage(e,(e=>{}))}};let n=window.fetch;window.fetch=function(i,l){let a="object"==typeof i?i.url:i;if(t(a)&&!o.has(a)&&(o.add(a),console.log("VIDEO_LINK_CAPTURE: "+a),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:o}),e)){let e={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:o};r.runtime.sendMessage(e,(e=>{}))}return n(i,l)}}c(),document.onreadystatechange=()=>{console.log("document.readyState==",document.readyState),"complete"===document.readyState&&(console.log("readyState-------------------",document.readyState),c(),console.log("readyStateytInitialPlayerResponseytInitialPlayerResponse-----"))},L()}let n=[],i=new Set;window.addEventListener("message",(e=>{if(!e||!e.data||!e.data.name)return;const t=e.data.name;if("VIDEO_LINK_CAPTURE"===t){let t=e.data.urls?e.data.urls:new Set;console.log("snifffer.VIDEO_LINK_CAPTURE-----\x3etempSet=",t),i=t;let o={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:i};r.runtime.sendMessage(o,(e=>{}))}else if("VIDEO_INFO_CAPTURE"===t){let t=e.data.videoList?e.data.videoList:[];n=t,console.log("snifffer.VIDEO_INFO_CAPTURE-----\x3evideoInfoList=",n);let o={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoInfoList:n};r.runtime.sendMessage(o,(e=>{}))}}))})()}},t={};function o(n){var r=t[n];if(void 0!==r)return r.exports;var i=t[n]={exports:{}};return e[n](i,i.exports,o),i.exports}o.m=e,(()=>{var e=[];o.O=(t,n,r,i)=>{if(!n){var l=1/0;for(c=0;c<e.length;c++){n=e[c][0],r=e[c][1],i=e[c][2];for(var a=!0,s=0;s<n.length;s++)(!1&i||l>=i)&&Object.keys(o.O).every((e=>o.O[e](n[s])))?n.splice(s--,1):(a=!1,i<l&&(l=i));if(a){e.splice(c--,1);var d=r();void 0!==d&&(t=d)}}return t}i=i||0;for(var c=e.length;c>0&&e[c-1][2]>i;c--)e[c]=e[c-1];e[c]=[n,r,i]}})(),(()=>{o.n=e=>{var t=e&&e.__esModule?()=>e["default"]:()=>e;return o.d(t,{a:t}),t}})(),(()=>{o.d=(e,t)=>{for(var n in t)o.o(t,n)&&!o.o(e,n)&&Object.defineProperty(e,n,{enumerable:!0,get:t[n]})}})(),(()=>{o.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()})(),(()=>{o.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t)})(),(()=>{o.j=875})(),(()=>{var e={875:0};o.O.j=t=>0===e[t];var t=(t,n)=>{var r,i,l=n[0],a=n[1],s=n[2],d=0;if(l.some((t=>0!==e[t]))){for(r in a)o.o(a,r)&&(o.m[r]=a[r]);if(s)var c=s(o)}for(t&&t(n);d<l.length;d++)i=l[d],o.o(e,i)&&e[i]&&e[i][0](),e[i]=0;return o.O(c)},n=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];n.forEach(t.bind(null,0)),n.push=t.bind(null,n.push.bind(n))})();var n=o.O(void 0,[998],(()=>o(7022)));n=o.O(n)})();