(()=>{var t={7022:(t,e,n)=>{let o;n(2801),n(7658),"undefined"!==typeof window.browser&&(o=window.browser),"undefined"!==typeof window.chrome&&(o=window.chrome);const i=o;(function(){let t=!1;try{e(),document.addEventListener("securitypolicyviolation",(e=>{t=!0,n(t)}))}catch(a){}function e(){const t=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let e=window.location.host,o=document.createElement("script");o.type="text/javascript",o.id="stay_inject_parse_video_js_"+e;let i=`\n\nlet handleVideoInfo = ${n}\n\nhandleVideoInfo(false);`;if(o.appendChild(document.createTextNode(i)),document.body)document.body.appendChild(o);else{let e=new t(((t,n)=>{document.body&&(document.body.appendChild(o),e.disconnect())}));e.observe(document.documentElement,{attributes:!0,childList:!0,characterData:!0,subtree:!0})}}function n(t){let e=window.location.href,n=window.location.host,o=[],r=(new Set,new Set);const l=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let s,d=[];const c={isMobile:function(){const t=navigator.userAgent;let e=["Android","iPhone","SymbianOS","Windows Phone","iPad","iPod"],n=e.filter((e=>t.includes(e)));return!!n.length},queryURLParams:function(t,e){const n=new RegExp("[?&#]+"+e+"=([^?&#]+)"),o=n.exec(t);return o&&o[1]?o[1]:""},matchUrlInString:function(t){const e=new RegExp("(https?|http)?(:)?//[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]","g"),n=t.match(e);return n&&n.length?n[0]:""},isURL:function(t){return!!t&&/^http[s]?:\/\/.*/.test(t)},completionSourceUrl:function(t){return t?(/^(f|ht)tps?:\/\//i.test(t)||(t=/^\/\//i.test(t)?window.location.protocol+t:window.location.origin+t),t):""},checkCharLengthAndSubStr:function(t,e=80){if(!t)return"";let n=t.replace(/[^x00-xff]/g,"01");return n.length<=e?t:t.substr(0,e)},getUrlPathName:function(t){let n="";n=this.isURL(t)?new URL(t).pathname:new URL(e).pathname;let o=n.split("/");return o=o.filter((t=>{if(t&&""!=t)return t})),o.pop()},generateUuid:function(t,e){t=t||32;let n,o="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz".split(""),i=[];if(e=e||o.length,t)for(n=0;n<t;n++)i[n]=o[0|Math.random()*e];else{let t;for(i[8]=i[13]=i[18]=i[23]="_",i[14]="4",n=0;n<36;n++)i[n]||(t=0|16*Math.random(),i[n]=o[19==n?3&t|8:t])}return i.join("")},isBase64(t){if(!t)return!1;if(/^data:.*\w+;base64,/.test(t))return!0;if(""===t||""===t.trim())return!1;try{return window.btoa(window.atob(t))==t}catch(e){return!1}},isDark(){return window.matchMedia&&window.matchMedia("(prefers-color-scheme: dark)").matches},parseToDOM(t){let e=document.createElement("template");return"string"==typeof t?(e.innerHTML=t,e.content):t},getHostname(t){if(!t)return"";try{return new URL(t).hostname.toLowerCase()}catch(a){return t.split("/")[0].toLowerCase()}},div(t,e){let n,o,i=0,r=0;try{i=t.toString().split(".")[1].length}catch(a){i=0}try{r=e.toString().split(".")[1].length}catch(a){r=0}return n=Number(t.toString().replace(".","")),o=Number(e.toString().replace(".","")),this.mul(n/o,Math.pow(10,r-i))},sub(t,e){let n,o,i;try{n=t.toString().split(".")[1].length}catch(r){n=0}try{o=e.toString().split(".")[1].length}catch(r){o=0}return i=Math.pow(10,Math.max(n,o)),(this.mul(t,i)-this.mul(e,i))/i},mul(t,e){let n=0,o=t.toString(),i=e.toString();try{n+=o.split(".")[1].length}catch(r){}try{n+=i.split(".")[1].length}catch(r){}return Number(o.replace(".",""))*Number(i.replace(".",""))/Math.pow(10,n)},add(t,e){let n,o,i;try{n=t.toString().split(".")[1].length}catch(r){n=0}try{o=e.toString().split(".")[1].length}catch(r){o=0}return i=Math.pow(10,Math.max(n,o)),(this.mul(t,i)+this.mul(e,i))/i}};class u{constructor(t,e){this.dom=t,this.timer=0,this.init(e)}init(t){this.touchstart(t),this.touchend(),this.touchmove(),this.bindLongPressEventFlag()}bindLongPressEventFlag(){this.dom.setAttribute("stay-long-press","yes")}touchstart(t){const e=this;function n(n){if(p(e.dom))return;let o=n.changedTouches[0];try{o.target.click()}catch(a){}e.timer=setTimeout((()=>{n.preventDefault(),"function"===typeof t?(t(),e.timer=0):console.error("callback is not a function!")}),500)}e.dom.removeEventListener("touchstart",(function(t){n(t)})),e.dom.addEventListener("touchstart",(function(t){t.preventDefault(),n(t)}),!1)}touchend(){const t=this;function e(e){if(!p(t.dom)){if(e.preventDefault(),clearTimeout(t.timer),0!=t.timer)try{e.changedTouches[0]}catch(a){}return!1}}t.dom.removeEventListener("touchend",(function(t){e(t)})),t.dom.addEventListener("touchend",(function(t){e(t)}))}touchmove(){const t=this;function e(e){if(!p(t.dom))return clearTimeout(t.timer),t.timer=0,!1}t.dom.removeEventListener("touchmove",(function(t){e(t)})),t.dom.addEventListener("touchmove",(function(t){e(t)}))}}function p(t){if(!t)return!0;let e=window.getComputedStyle(t);return!!e&&("none"===e.display||"hidden"===e.visibility)}class m{constructor(t,e){this.dom=t,this.timer=0,this.distance=10,this.init(e)}getDomPageStartX(){return this.dom.getBoundingClientRect().left}getDomPageStartY(){return document.documentElement.scrollTop||window.pageYOffset+this.dom.getBoundingClientRect().top}getDomPageEndX(){return this.getDomPageStartX()+this.dom.clientWidth}getDomPageEndY(){return this.getDomPageStartY()+this.dom.clientHeight}init(t){this.touchstart(t),this.touchend(),this.touchmove(),this.bindLongPressEventFlag()}bindLongPressEventFlag(){this.dom.setAttribute("stay-long-press","yes")}touchstart(t){const e=this;function n(n){n.preventDefault(),n.stopPropagation();let o=n.changedTouches[0];const i=o.pageX,r=o.pageY;if(!p(e.dom)&&Math.abs(o.pageX-i)<=e.distance&&i>=e.getDomPageStartX()&&i<=e.getDomPageEndX()&&r>=e.getDomPageStartY()&&r<=e.getDomPageEndY()){let i=o.target.classList;i.contains("__stay-unselect")||i.add("__stay-unselect"),e.timer=setTimeout((()=>{n.stopPropagation(),n.preventDefault(),"function"===typeof t?(t(),e.timer=0):console.error("callback is not a function!")}),500)}return!1}document.removeEventListener("touchstart",(function(t){n(t)})),document.addEventListener("touchstart",(function(t){t.preventDefault(),t.stopPropagation(),n(t)}),!1)}touchend(){const t=this;function e(e){if(!p(t.dom)){if(clearTimeout(t.timer),0!=t.timer){t.timer=0;try{let t=e.changedTouches[0];t.target.click()}catch(a){}}return!1}}document.removeEventListener("touchend",(function(t){e(t)})),document.addEventListener("touchend",(function(t){e(t)}))}touchmove(){const t=this;function e(){if(!p(t.dom))return clearTimeout(t.timer),t.timer=0,!1}document.removeEventListener("touchmove",(function(t){e()})),document.addEventListener("touchmove",(function(t){e()}))}}function f(t){s=document.querySelectorAll("video");let e=s&&s.length;e||(s=document.querySelectorAll(".post-content shreddit-player"),e=s&&s.length),e?y(s):(y(),t&&h()),g()}function h(){for(let t=1;t<10;t++){let e;(function(t){e=setTimeout((()=>{s=document.querySelectorAll("video");let t=s&&s.length;t&&(y(s),d.forEach((t=>{clearTimeout(t)})))}),200*t)})(t),d.push(e)}}function g(){const t=new l((function(t){try{t.forEach((function(t){s=document.querySelectorAll("video"),"VIDEO"===t.target.nodeName&&s&&s.length&&(n=window.location.host,y(s))}))}catch(e){}})),e={attributes:!0,childList:!0,characterData:!0,subtree:!0};t.observe(document,e)}function y(e){if(e&&e.length){let t=e.length,n=0,o=Array.from(e);o.forEach((t=>{if(!t||!(t instanceof HTMLElement))return void n++;let e=t.getAttribute("stay-sniffing");e||(e=c.generateUuid(),t.setAttribute("stay-sniffing",e));const o=t;let i=t.getAttribute("src");if(!i){let e=t.querySelector("source");e&&(t=e,i=e.getAttribute("src"))}if(!i)return void n++;let r=S(t,o,e);r.downloadUrl||n++})),n==t&&U()}else U();if(window.postMessage({name:"VIDEO_INFO_CAPTURE",videoList:o}),t){let t={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoInfoList:o};i.runtime.sendMessage(t,(t=>{}))}}function b(t,n,i){let a=i.downloadUrl;c.isURL(a)||(i.downloadUrl=e),v(t,n,i),r.size&&(r.has(i.videoUuid)||r.has(i.videoKey))?o.forEach((t=>(t.videoUuid!=i.videoUuid&&t.videoUuid!=i.videoKey||(t.downloadUrl=i.downloadUrl,t.poster=i.poster?i.poster:"",t.title=i.title,t.hostUrl=i.hostUrl,t.qualityList=i.qualityList?i.qualityList:[]),t))):(i.videoKey&&(r.add(i.videoKey),i.videoUuid||(i.videoUuid=i.videoKey)),i.videoUuid&&r.add(i.videoUuid),o.push(i))}async function v(t,e,n){if(!e)return;const o=await w();if("a"!=o)return;if(!c.isMobile())return;let i=e.getAttribute("stay-long-press");if(i&&"yes"==i)return;const r=document.querySelector("#__style_sinffer_unselect");if(!r){let t='<style id="__style_sinffer_unselect">\n          .__stay-unselect, video{\n            -webkit-user-select: none;\n            -moz-user-select: none;\n            -ms-user-select: none;\n            user-select: none;\n            -webkit-touch-callout: none;\n          }\n          .__stay-touch-action{\n            touch-action: none!important;\n          }\n        </style>';document.body.append(c.parseToDOM(t))}e.classList.add("__stay-unselect");const a=n.hostUrl;if(a.indexOf("youtube.com")>-1){const o=document.querySelector("#player-control-overlay");o&&(o.classList.contains("__stay-touch-action")||o.classList.add("__stay-touch-action"),o.classList.contains("__stay-unselect")||o.classList.add("__stay-unselect"));const i=document.querySelector("#player-control-overlay .player-controls-background-container .player-controls-background");i&&(i.classList.contains("__stay-touch-action")||i.classList.add("__stay-touch-action"),i.classList.contains("__stay-unselect")||i.classList.add("__stay-unselect")),new u(e,(()=>{_(t,e,n)}))}else a.indexOf("mobile.twitter.com")>-1||a.indexOf("pornhub.com");new m(e,(()=>{_(t,e,n)}))}function w(){return new Promise(((e,n)=>{if(t)i.runtime.sendMessage({from:"sniffer",operate:"GET_STAY_AROUND"},(t=>{if(t.body&&"{}"!=JSON.stringify(t.body)){let n=t.body;e(n)}}));else{const t=Math.random().toString(36).substring(1,9),n=o=>{if(o.data.pid!==t||"RESP_GET_STAY_AROUND"!==o.data.name)return;let i=o.data?o.data.response?o.data.response.body:{}:"b";e(i),window.removeEventListener("message",n)};window.addEventListener("message",n),window.postMessage({pid:t,name:"GET_STAY_AROUND"})}}))}function _(e,n,o){n.clientWidth;let r=n.clientHeight,a=window.innerHeight||document.documentElement.clientHeight||document.body.clientHeight,l=window.innerWidth||document.documentElement.innerWidth||document.body.innerWidth,s=n.getBoundingClientRect().top,d=n.getBoundingClientRect().left;"VIDEO"==n.tagName&&(s=n.parentNode.getBoundingClientRect().top,d=n.parentNode.getBoundingClientRect().left),d=10;let u=l,p=c.div(c.mul(u,9),16);r<c.div(a,2)&&(p=r);let m=document.querySelector("#__stay_sinffer_modal");m||(m=g()),m.style.visibility="visible";const f=document.querySelector("#__stay_sinffer_modal ._stay-sinffer-popup"),h=document.querySelector("#__stay_sinffer_modal .__stay-sinffer-content");function g(){let n=[{title:o.title,downloadUrl:o.downloadUrl,poster:o.poster,hostUrl:c.getHostname(o.hostUrl),uuid:""}],l="stay://x-callback-url/snifferVideo?list="+encodeURIComponent(JSON.stringify(n)),m="background-color: rgb(247,247,247);",f="rgb(54, 54, 57)",h="#E0E0E0",g="background-color: rgba(0, 0, 0, 0.4);",y="background-color: rgba(255, 255, 255, 1);",b="color:#000000;",v=t?i.runtime.getURL("img/popup-download-light.png"):"https://res.stayfork.app/scripts/8DF5C8391ED58046174D714911AD015E/icon.png";c.isDark()&&(y="background-color: rgba(0, 0, 0, 1);",b="color:#DCDCDC;",m="background-color: rgb(54, 54, 57);",v=t?i.runtime.getURL("img/popup-download-dark.png"):"https://res.stayfork.app/scripts/CFFCD2186E164262E0E776A545327605/icon.png",f="rgb(247,247,247)",h="#37372F");let w=1,_=`<div stay-download="${l}" class="_stay-quality-item ">Download</div>`,S=o.qualityList;if(S&&S.length){let t="";w=0,S.forEach((e=>{n=[{title:o.title,downloadUrl:e.downloadUrl,poster:o.poster,hostUrl:c.getHostname(o.hostUrl),uuid:""}],l="stay://x-callback-url/snifferVideo?list="+encodeURIComponent(JSON.stringify(n)),t+=`<div stay-download="${l}" class="_stay-quality-item">${e.qualityLabel}</div>`,w+=1})),_=t}let U=s,A=s;if(s<0)A=0;else if(0==s)a==r&&(A=c.div(c.sub(a,p),2));else{let t=c.add(10,36),e=c.add(c.add(p,t),c.add(c.mul(w,38),36));s>c.sub(a,e)&&(A=c.sub(a,e))}let E="",q=t?i.runtime.getURL("img/video-default.png"):"https://res.stayfork.app/scripts/BB8CD00276006365956C32A6556696AD/icon.png",L='<div class="__stay-poster-box" ><div class="__stay-default-poster"><img style="max-width:100%;max-height:100%;" src="'+q+'"/></div><span style="font-size:13px;padding-top: 20px; -webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;'+b+'">'+c.getHostname(o.hostUrl)+"</span></div>";o.poster&&(E="border-radius: 15px;",L=`<div class="__stay-video-poster" style="background:url('${o.poster}') 50% 50% no-repeat;background-size: cover;"></div>`);x(e,u,p);let O=`<style id="__style_sinffer_style">\n          .__stay-modal-box{\n            position: fixed; \n            z-index: 9999999; \n            width: 100%; \n            height: 100%; \n            text-align: center; \n            top: 0px;\n            -webkit-overflow-scrolling: touch;\n            margin: 0 auto;\n            transition: all 0.6s;\n            box-sizing: border-box;\n            visibility: hidden;\n          }\n          .__stay-show-modal{\n            ${g}\n            -webkit-backdrop-filter: blur(8px); \n          }\n          .__stay-sinffer-content{\n            width:100%;\n            position: absolute;\n            left: 0;\n            -webkit-transform: translate3d(0, ${U}px, 0);\n            transform: translate3d(0, ${U}px, 0);\n            will-change: transform;\n            -webkit-transition: -webkit-transform .4s cubic-bezier(0,0,.25,1) 80ms;\n            transition: transform .4s cubic-bezier(0,0,.25,1) 80ms;\n            box-sizing: border-box;\n          }\n          .__stay-trans{\n            -webkit-transform: translate3d(0,${A}px,0);\n            transform: translate3d(0,${A}px,0);\n          }\n          .__stay-content{\n            width:100%;\n            position: relative;\n            display: flex;\n            flex-direction: column;\n            justify-content: center;\n            justify-items: center;\n            align-items: center;\n          }\n          ._stay-sinffer-popup{\n            width:230px;padding-top: 10px;box-sizing: border-box;border-radius:15px;\n            ${m}\n            position: relative;\n            margin: 16px auto 0 auto;\n            z-index:999999;\n            visibility: hidden;\n            animation: fadein .5s;\n          }\n          .__stay-sinffer-poster{\n            width: 100%;\n            -webkit-user-select: none;\n            -moz-user-select: none;\n            -ms-user-select: none;\n            user-select: none;\n            height: ${p}px;\n            padding: 0 ${d}px;\n            margin:0 auto;\n            display: flex;\n            flex-direction: column;\n            justify-content: center;\n            justify-items: center;\n            align-items: center;\n            box-sizing: border-box;\n            box-shadow: 0 0px 10px rgba(54,54,57,0.1);\n            transition: All 0.4s ease-in-out;\n            -webkit-transition: All 0.4s ease-in-out;\n            -moz-transition: All 0.4s ease-in-out;\n            -o-transition: All 0.4s ease-in-out;\n            animation-name: zoom;\n            animation-duration: 0.6s;\n          }\n          .__stay-video-poster{\n            // object-fit: contain;\n            // object-position: center;\n            width:100%;\n            height:100%;\n            background-position: center;\n            background-repeat: no-repeat;\n            border-radius: 15px;\n           \n          }\n          .__stay-poster-box{\n            width:100%;\n            height:100%;\n            display: flex;\n            flex-direction: column;\n            justify-content: center;\n            align-items: center;\n            ${y}\n            border-radius: 10px;\n            box-shadow: 0 0px 10px rgba(54,54,57,0.1);\n          }\n          .__stay-default-poster{\n            width:80px;\n            height:60px;\n            display: flex;\n            flex-direction: column;\n            justify-content: center;\n            justify-items: center;\n            align-items: center;\n            box-sizing: border-box;\n          }\n          ._stay-sinffer-title{\n            padding-left: 15px;\n            padding-right: 15px;\n            width: 100%;\n            height:36px;\n            line-height: 18px;\n            word-break:break-all;\n            word-wrap:break-word;\n            color: ${f};\n            -webkit-box-orient: vertical;\n            -webkit-user-select: none;\n            overflow: hidden;\n            text-overflow: ellipsis;\n            display: -webkit-box;\n            -webkit-line-clamp: 2;\n            text-align: left;\n            margin-bottom: 10px;\n            box-sizing: border-box;\n            font-size: 16px;\n          }\n          ._stay-sinffer-download{\n            width:100%;\n            box-sizing: border-box;\n            display: flex;\n            justify-content: flex-start;\n            flex-direction: column;\n            align-items: center;\n          }\n          ._stay-quality-item{\n            height: 38px;\n            box-sizing: border-box;\n            width:100%;\n            padding-right: 20px;\n            position: relative;\n            color: ${f};\n            text-align:left;\n            font-size: 16px;\n            border-top: 0.5px solid ${h};\n            padding: 0 15px;\n            display: flex;\n            align-items: center;\n            -webkit-user-select: none;\n            -moz-user-select: none;\n            -ms-user-select: none;\n            user-select: none;\n          }\n          ._stay-quality-item::after{\n            content:"";\n            background: url(${v}) no-repeat 50% 50%;  \n            background-size: 14px;\n            position: absolute;\n            right: 15px;\n            top: 50%;\n            transform: translate(0, -52%);\n            width: 14px;\n            height: 20px;\n          }\n          @keyframes zoom {\n            0% {transform: scale(1.05)}\n            100% {transform: scale(1);${E}}\n          }\n          @keyframes fadein {\n            0% {\n              transform: translate(0, -100%);\n            }\n            100% {\n              transform: none;\n            }\n          }\n          @keyframes fadeout {\n              0% {\n                transform: translate(0,100%);\n              }\n              100% {\n                  transform: none;\n              }\n          }\n        </style>`,k=['<div id="__stay_sinffer_modal" class="__stay-modal-box" >','<div class="__stay-sinffer-content">','<div class="__stay-content">','<div class="__stay-sinffer-poster">'+L+"</div>",'<div class="_stay-sinffer-popup">','<div class="_stay-sinffer-title">'+o.title+"</div>",'<div class="_stay-sinffer-download">',_,"</div>","</div>","</div>","</div>","</div>"];return document.body.append(c.parseToDOM(O)),document.body.append(c.parseToDOM(k.join(""))),document.querySelector("#__stay_sinffer_modal")}h.classList.add("__stay-trans"),setTimeout((function(){m.classList.add("__stay-show-modal"),f.style.visibility="visible"}),400),m.addEventListener("touchmove",(t=>{t.preventDefault()}),!1),m.addEventListener("touchstart",(t=>{t.preventDefault(),m.classList.remove("__stay-show-modal"),f.style.animation="fadeout .5s;",setTimeout((()=>{m&&document.body.removeChild(m),document.body.removeChild(document.querySelector("#__style_sinffer_style"))}),200)}),!1);const y=document.querySelectorAll("#__stay_sinffer_modal ._stay-quality-item");if(y&&y.length)for(let t=0;t<y.length;t++)(function(e){y[t].addEventListener("touchstart",(t=>{let e=t.target.getAttribute("stay-download"),n=document.createElement("a");n.href=e,n.click()}))})()}function x(t,e,n){if(!t||"VIDEO"!=t.tagName)return null;t.setAttribute("autoplay","autoplay"),t.setAttribute("crossOrigin","anonymous");const o=document.createElement("canvas");o.width=e,o.height=n;const i=o.getContext("2d");return i.drawImage(t,0,0,o.width,o.height),o}function S(t,o,i){let r={},a=t.getAttribute("poster"),l=t.getAttribute("title"),s=t.getAttribute("src"),d=[];e=window.location.href;let u=o;if(s=c.completionSourceUrl(s),!a){let t=document.querySelector("source[type='image/webp'] img");a=t?t.getAttribute("src"):"",l||(l=t?t.getAttribute("alt"):"")}if(n.indexOf("youtube.com")>-1){const t=c.queryURLParams(e,"v");let n=document.querySelector("#player-control-overlay .player-controls-background-container .player-controls-background");n||(n=document.querySelector("#player-control-overlay")),n&&(u=n),r=F(l,t)}else if(n.indexOf("baidu.com")>-1)r=z(t);else if(n.indexOf("bilibili.com")>-1)r=E(t);else if(n.indexOf("mobile.twitter.com")>-1){let e=document.querySelector(".r-eqz5dr .r-1pi2tsx .r-1pi2tsx .r-1udh08x .r-1p0dtai div.css-1dbjc4n.r-6koalj.r-eqz5dr.r-1pi2tsx.r-13qz1uu");e&&(u=e),r=q(t)}else if(n.indexOf("m.weibo.cn")>-1)r=L(t);else if(n.indexOf("iesdouyin.com")>-1)r=O(t);else if(n.indexOf("douyin.com")>-1){const e=window.location.pathname;r=e.indexOf("/video")>-1?k(t):D(t)}else n.indexOf("m.toutiao.com")>-1?r=N(t):n.indexOf("m.v.qq.com")>-1?r=C(t):n.indexOf("www.reddit.com")>-1?r=P(t):n.indexOf("pornhub.com")>-1?r=M(t):n.indexOf("facebook.com")>-1?r=T(t):n.indexOf("instagram.com")>-1?r=R(t):n.indexOf("xiaohongshu.com")>-1?r=V(t):n.indexOf("jable.tv")>-1&&(r=j(t));return r.downloadUrl&&(s=r.downloadUrl),s=c.completionSourceUrl(s),a||(a=r.poster),l||(l=r.title),r.qualityList&&r.qualityList.length&&(d=r.qualityList),l||(l=document.title),a=c.completionSourceUrl(a),r["title"]=l,r["poster"]=a,r["downloadUrl"]=s,r["hostUrl"]=e,r["qualityList"]=d,r["videoUuid"]=i,s&&b(o,u,r),r}function U(){setTimeout((()=>{A()}),400)}function A(){let t={},n=window.location.host;e=window.location.href,t.hostUrl=e;let o=null;if(n.indexOf("pornhub.com")>-1&&(o=document.querySelector("#videoShow #videoPlayerPlaceholder .mgp_videoWrapper .mgp_videoPoster img"),o||(o=document.querySelector("#videoShow #videoPlayerPlaceholder .mgp_videoWrapper video")),o||(o=document.querySelector("#videoShow #videoPlayerPlaceholder .playerFlvContainer .mgp_controls")),o||(o=document.querySelector("#videoShow #videoPlayerPlaceholder .mgp_videoWrapper")),t=I(t)),t.downloadUrl)return b(null,o,t),t}function E(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");let n=document.querySelector(".main-container .ep-info-pre .ep-info-title");return n||setTimeout((function(){return n=document.querySelector(".video .share-video-info .title-wrapper .title-name span"),n&&(e.title=n.textContent),e}),200),n&&(e.title=n.textContent),e}function q(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");let n=t.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.nextElementSibling.childNodes[1];return n&&(n=n.querySelector(".css-1dbjc4n .r-92ivih.r-1t01tom .r-1t982j2.r-1j3t67a .css-1dbjc4n.r-1kw4oii a[data-testid='tweetText'] span"),n&&(e.title=c.checkCharLengthAndSubStr(n.textContent))),e}function L(t){let n={};return n.poster=t.getAttribute("poster"),n.downloadUrl=t.getAttribute("src"),e.match(/^.*\/detail\/.*/g)&&(n.title=c.checkCharLengthAndSubStr(document.querySelector(".weibo-main .weibo-text").textContent)),n}function O(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");let n=document.querySelector(".video-container img.poster");n&&(e.poster=n.getAttribute("src"));let o=document.querySelector(".desc .multi-line .multi-line_text");return o&&(e.title=o.textContent),e}function k(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");const n=document.querySelector("div[data-e2e=video-detail] div[data-e2e=detail-video-info] div h2");return n&&(e.title=n.textContent),e}function D(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");let n=t.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;if(n){let t=n.querySelector(".imgBackground img");t&&(e.poster=t.getAttribute("src"));let o=n.querySelector(".video-info-detail .title span.e_h_fqNj");o&&(e.title=o.textContent)}return e}function N(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");const n=document.querySelector(".video .xgplayer-placeholder .xgplayer-poster");if(n){let t=n.getAttribute("style");if(t){let n=c.matchUrlInString(t);e.poster=n}}const o=document.querySelector(".video .video-header .video-title-wrapper .video-title");return o&&(e.title=o.textContent),e}function C(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");const n=document.querySelector(".mod_play .player_container .txp_poster_img");if(n){let t=n.getAttribute("src");t=c.completionSourceUrl(t),e.poster=t}const o=document.querySelector(".mod_box .mod_bd .mod_video_info .video_title");if(o){let t=o.textContent;t=t?t.trim():"";const n=document.querySelector(".mod_box .mod_bd .mod_list_slider .slider_box .item.current span");n&&(t+=n.textContent,t=t?t.trim():""),e.title=t}return e}function P(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");const n=document.querySelector("shreddit-app shreddit-title");return n&&(e.title=n.getAttribute("title")),e}function M(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src");let n=t.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement;if(n&&n.classList.contains("playerWrapper")){const t=document.querySelector("#videoShow .categoryTags .headerWrap h1");if(t){let n=t.textContent;n&&(e.title=n.trim())}const n=document.querySelector("#videoPlayerPlaceholder img.videoElementPoster");return n&&(e.poster=n.getAttribute("src")),I(e)}let o=t.parentNode.parentNode.parentNode.parentNode.parentNode;if(o&&"li"==o.tagName.toLowerCase()){let t=o.querySelector(".videoWrapper .singleVideo a img.videoThumb");if(t)return e.title=t.getAttribute("alt"),e.title&&(e.title="[Related videos] "+e.title),e.poster=t.getAttribute("src"),e}return e}function I(t){if(t=t||{},t.videoKey=c.queryURLParams(window.location.href,"viewkey"),window.VIDEO_SHOW&&(!t.videoKey||t.videoKey==window.VIDEO_SHOW.vkey)){t.title||(t.title=window.VIDEO_SHOW.videoTitle),t.poster||(t.poster=window.VIDEO_SHOW.videoImage);let e=window.VIDEO_SHOW.playerId;if(e){let n=e.split("_");if(n.length>1){let e="flashvars_"+n[1],o=window[e].mediaDefinitions;if(o&&o.length){let e=[],n="";o.forEach((o=>{"hls"==o.format&&"string"==typeof o.quality&&e.push({downloadUrl:o.videoUrl,qualityLabel:o.quality,quality:Number(o.quality)}),!o.defaultQuality||"boolean"!=typeof o.defaultQuality&&"number"!=typeof o.defaultQuality||(n=o.defaultQuality,t.downloadUrl||(t.downloadUrl=o.videoUrl))})),t["qualityList"]=e,e.length&&e.forEach((e=>{e.quality==n&&(t.downloadUrl=e.downloadUrl)}))}}}}return t}function T(t){let e={};e.poster=t.getAttribute("poster"),e.downloadUrl=t.getAttribute("src"),e.title=t.getAttribute("title");let n=t.parentElement.parentElement.parentElement.parentElement.parentElement;if(n&&n.classList.contains("displayed")&&"container"==n.getAttribute("data-type")){let t=n.querySelector("div[data-type='video'] img.img");t&&(e.poster=t.getAttribute("src"));let o=n.querySelector("div.displayed > div[data-type='container'] > div[data-type='container'] > div[data-type='container'] > div[data-type='text'] > div.native-text");o&&(e.title=o.textContent)}return e}function R(t){let e={};e.poster=t.getAttribute("poster")||"",e.downloadUrl=t.getAttribute("src"),e.title=t.getAttribute("title");let n=t.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode.parentNode;if(n&&n.classList.contains("_ab8w")&&n.classList.contains("_ab94")&&n.classList.contains("_ab99")&&n.classList.contains("_ab9h")&&n.classList.contains("_ab9m")&&n.classList.contains("_ab9p")&&n.classList.contains("_abcm")){let t=n.querySelector("._aatk .x1uhb9sk .x10l6tqk .x78zum5 img.x5yr21d");t&&(e.poster=t.getAttribute("src"));let o=n.querySelector("._ab9f div._ae1h._ae1i ._ae2s div._ae5q._akdn div div div");o&&o.textContent&&(e.title=o.textContent.replace("... more",""))}else if(n=t.parentNode.parentNode.parentNode.parentNode.parentNode,console.log(n.classList,"videoDetailDom.classList.contains('_a8b4') ===",n.classList.contains("_a8b4")),n&&n.classList.contains("_a8b4")&&n.classList.contains("_acjh")){let t=n.querySelector("div > div > div.x9f619.x1d8287x.xz4gly6  div.x6ikm8r.x10wlt62 span");t&&(e.title=t.textContent)}return e}function V(t){let e={};e.poster=t.getAttribute("poster")||"",e.downloadUrl=t.getAttribute("src"),e.title=t.getAttribute("title");const n=document.querySelector(".video-container .video-banner .img-box");if(n){let t=n.getAttribute("style"),o=c.matchUrlInString(t);o&&(e.poster=c.completionSourceUrl(o))}const o=document.querySelector(".video-container .stage-bottom .author-desc-wrapper .author-desc");if(o){let t=o.textContent;t&&(t=t.replace(/^展开/g,""),e.title=c.checkCharLengthAndSubStr(t))}return e}function j(t){let e={};e.poster=t.getAttribute("poster")||"",e.downloadUrl=t.getAttribute("src"),e.title=t.getAttribute("title");const n=document.querySelector(".video-info .info-header .header-left h4");return n&&(e.title=n.textContent),e}function z(t){let i={};if(i.poster=t.getAttribute("poster")||"",i.downloadUrl=t.getAttribute("src"),i.title=t.getAttribute("title"),"activity.baidu.com"===n){const t=window.PAGE_DATA;if(t&&t.pageData&&t.pageData.remote&&t.pageData.remote.mainVideoList&&t.pageData.remote.mainVideoList.length){const n=t.pageData.remote.mainVideoList[0],a=t.pageData.remote.moreVideoList;return i["title"]=n.title,i["poster"]=n.poster,i["downloadUrl"]=n.videoUrl,a&&a.length&&a.forEach((t=>{r.size&&r.has(t.vid)||(r.add(t.vid),o.push({title:t.title,poster:t.poster,downloadUrl:t.videoUrl,hostUrl:e,videoUuid:t.vid}))})),i}i["title"]=$();const n=document.querySelector(".stickyBlock .curVideoPlay video");return n&&(i["poster"]=n.getAttribute("poster"),i["downloadUrl"]=n.getAttribute("src")),i}if("mbd.baidu.com"===n){const t=window.jsonData;if(t&&t.curVideoMeta){const e=t.curVideoMeta;if(i=H(e),i&&Object.keys(i).length)return i}return i["title"]=$(),i["poster"]=W(),i}if("haokan.baidu.com"===n){const n=window.__PRELOADED_STATE__,o=c.queryURLParams(e,"vid"),r=t.getAttribute("src");if(r&&o&&r.indexOf(o)>-1){if(n&&n.curVideoMeta){const t=n.curVideoMeta;if(i=H(t),i&&Object.keys(i).length)return i}i["title"]=$(),i["poster"]=W()}else i["title"]=t.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title")?t.parentElement.parentElement.querySelector("h3.land-recommend-bottom-title").textContent:"",i["poster"]=t.parentElement&&t.parentElement.querySelector("img.video-img")?t.parentElement.querySelector("img.video-img").getAttribute("src"):"";return i}return"pan.baidu.com"===n&&(i["title"]=$()),i}function H(t){if(!t)return{};let e={};if(e["title"]=t.title,e["poster"]=t.poster,e["downloadUrl"]=t.playurl,t.clarityUrl&&t.clarityUrl.length){let n=[];const o=t.clarityUrl;o.forEach((t=>{t.vodVideoHW;n.push({downloadUrl:t.url,qualityLabel:t.title,quality:t.key})})),e["qualityList"]=n}return e}function W(){const t=document.querySelector(".art-player-wrapper .art-video-player .art-poster");if(t){let e=t.getAttribute("style");if(e)return c.matchUrlInString(e)}const e=document.querySelector("#bdMainPlayer .art-video-player .art-poster");if(e){let t=e.getAttribute("style");if(t)return c.matchUrlInString(t)}return""}function $(){const t=document.querySelector(".adVideoPageV3 .curVideoInfo h3.videoTitle");if(t)return t.textContent;const e=document.querySelector(".video-info .video-info-title");if(e)return e.textContent;const n=document.querySelector(".video-main .video-content .video-title .video-title-left");return n?n.textContent:""}function F(t,e){let n={};const o=window.ytInitialPlayerResponse;if(o&&o.videoDetails&&o.streamingData&&(!e||e===o.videoDetails.videoId)){const e=o.videoDetails;let i=e.title?e.title:"";n["title"]=i;let r=e.thumbnail;if(r){let t=r.thumbnails;t&&t.length&&(n["poster"]=t.pop().url)}o.microformat&&o.microformat.playerMicroformatRenderer&&o.microformat.playerMicroformatRenderer.thumbnail&&o.microformat.playerMicroformatRenderer.thumbnail.thumbnails.length&&(n["poster"]=o.microformat.playerMicroformatRenderer.thumbnail.thumbnails[0].url);const a=o.streamingData,l=a.adaptiveFormats,s=a.formats,d=l||s;if(t=t||"",d&&d.length&&t.replace(/\s+/g,"")===i.replace(/\s+/g,"")){let t=[],e=new Set;d.forEach((n=>{let o=n.mimeType;o.indexOf("video/mp4")>-1&&n.url&&!e.has(n.quality)&&(e.add(n.quality),t.push({downloadUrl:n.url,qualityLabel:n.qualityLabel,quality:n.quality}))})),t&&t.length&&(n["qualityList"]=t),n["downloadUrl"]=K()}else n["title"]=t||B(),n["downloadUrl"]=K();n["poster"]||(n["poster"]=X())}else n={},n["title"]=t||B(),n["poster"]=X(),n["downloadUrl"]=K();return n}function K(){let t=document.querySelector(".html5-video-player .html5-video-container video");return t?t.getAttribute("src"):""}function B(){const t=document.querySelector(".slim-video-metadata-header .slim-video-information-content .slim-video-information-title");if(t)return t.textContent;const e=document.querySelector("#title h1.style-scope");return e?e.textContent:""}function X(){const t=document.querySelector(".ytp-cued-thumbnail-overlay-image");if(t){let e=t.getAttribute("style");if(e)return c.matchUrlInString(e)}const e=document.querySelector(".html5-video-player .ytp-cued-thumbnail-overlay .ytp-cued-thumbnail-overlay-image");if(e){let t=e.getAttribute("style");if(t)return c.matchUrlInString(t)}const n=document.querySelector(".video-wrapper .background-style-black");if(n){let t=n.getAttribute("style");if(t)return c.matchUrlInString(t)}return""}function Y(){function e(t){let e=/^(https?:\/\/|\/).*\.(mp4|m3u8)$/;return null!=t.match(e)}let n=new Set;XMLHttpRequest.prototype.reallyOpen=XMLHttpRequest.prototype.open,XMLHttpRequest.prototype.open=function(o,r,a,l,s){if(this.reallyOpen(o,r,a,l,s),e(r)&&!n.has(r)&&(n.add(r),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:n}),t)){let t={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:n};i.runtime.sendMessage(t,(t=>{}))}};let o=window.fetch;window.fetch=function(r,a){let l="object"==typeof r?r.url:r;if(e(l)&&!n.has(l)&&(n.add(l),console.log("VIDEO_LINK_CAPTURE: "+l),window.postMessage({name:"VIDEO_LINK_CAPTURE",urls:n}),t)){let t={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:n};i.runtime.sendMessage(t,(t=>{}))}return o(r,a)}}f(!1),document.onreadystatechange=()=>{"complete"===document.readyState&&f(!0)},Y()}let o=[],r=new Set;window.addEventListener("message",(t=>{if(!t||!t.data||!t.data.name)return;const e=t.data.name;if("VIDEO_LINK_CAPTURE"===e){let e=t.data.urls?t.data.urls:new Set;r=e;let n={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoLinkSet:r};i.runtime.sendMessage(n,(t=>{}))}else if("VIDEO_INFO_CAPTURE"===e){let e=t.data.videoList?t.data.videoList:[];o=e;let n={from:"sniffer",operate:"VIDEO_INFO_PUSH",videoInfoList:o};i.runtime.sendMessage(n,(t=>{}))}}))})()}},e={};function n(o){var i=e[o];if(void 0!==i)return i.exports;var r=e[o]={exports:{}};return t[o](r,r.exports,n),r.exports}n.m=t,(()=>{var t=[];n.O=(e,o,i,r)=>{if(!o){var a=1/0;for(c=0;c<t.length;c++){o=t[c][0],i=t[c][1],r=t[c][2];for(var l=!0,s=0;s<o.length;s++)(!1&r||a>=r)&&Object.keys(n.O).every((t=>n.O[t](o[s])))?o.splice(s--,1):(l=!1,r<a&&(a=r));if(l){t.splice(c--,1);var d=i();void 0!==d&&(e=d)}}return e}r=r||0;for(var c=t.length;c>0&&t[c-1][2]>r;c--)t[c]=t[c-1];t[c]=[o,i,r]}})(),(()=>{n.n=t=>{var e=t&&t.__esModule?()=>t["default"]:()=>t;return n.d(e,{a:e}),e}})(),(()=>{n.d=(t,e)=>{for(var o in e)n.o(e,o)&&!n.o(t,o)&&Object.defineProperty(t,o,{enumerable:!0,get:e[o]})}})(),(()=>{n.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(t){if("object"===typeof window)return window}}()})(),(()=>{n.o=(t,e)=>Object.prototype.hasOwnProperty.call(t,e)})(),(()=>{n.j=875})(),(()=>{var t={875:0};n.O.j=e=>0===t[e];var e=(e,o)=>{var i,r,a=o[0],l=o[1],s=o[2],d=0;if(a.some((e=>0!==t[e]))){for(i in l)n.o(l,i)&&(n.m[i]=l[i]);if(s)var c=s(n)}for(e&&e(o);d<a.length;d++)r=a[d],n.o(t,r)&&t[r]&&t[r][0](),t[r]=0;return n.O(c)},o=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];o.forEach(e.bind(null,0)),o.push=e.bind(null,o.push.bind(o))})();var o=n.O(void 0,[998],(()=>n(7022)));o=n.O(o)})();