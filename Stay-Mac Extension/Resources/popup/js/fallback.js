(()=>{(function(){"use strict";function e(){(new Date).getTime();function e(e){try{return new URL(e).hostname.toLowerCase()}catch(t){return e.split("/")[0].toLowerCase()}}let t=e(window.location.href),o=window.localStorage.getItem("FETCH_DARK_SETTING");if(o&&""!==o&&"null"!==o&&"undefined"!==o&&"clean_up"!=o&&"dark_mode"!=o){let e=JSON.parse(o),t={...e};a(t)}else browser.runtime.sendMessage({from:"darkmode",operate:"FETCH_DARK_SETTING"},(e=>{e.body&&"{}"!=JSON.stringify(e.body)&&(darkmodeSetting=e.body,window.localStorage.setItem("FETCH_DARK_SETTING",JSON.stringify(darkmodeSetting))),a(darkmodeSetting)}));function n(e){return Boolean(window.matchMedia(e).matches)}function d(){return n("(prefers-color-scheme: dark)")}function i(e){return"undefined"!=typeof e.darkState&&""!==e.darkState&&"dark_mode"===e.darkState||!("undefined"==typeof e.isStayAround||""===e.isStayAround||"a"!==e.isStayAround||!(d()&&"off"!=e.toggleStatus&&e.siteListDisabled&&"[]"!==e.siteListDisabled&&e.siteListDisabled.length>0&&!e.siteListDisabled.includes(t)||!d()&&"on"===e.toggleStatus&&e.siteListDisabled&&"[]"!==e.siteListDisabled&&e.siteListDisabled.length>0&&!e.siteListDisabled.includes(t)))}function a(e){if(!document.querySelector(".darkreader--fallback")&&(!document.querySelector(".noir")||!document.querySelector(".noir-root"))&&document.documentElement instanceof HTMLHtmlElement&&i(e)){const e='html, body, body :not(iframe):not(div[style^="position:absolute;top:0;left:-"]) { background-color: #181a1b !important; border-color: #776e62 !important; color: #e8e6e3 !important; } html, body { opacity: 1 !important; transition: none !important; }',t=document.createElement("style");if(t.classList.add("darkreader"),t.classList.add("darkreader--fallback"),t.media="screen",t.textContent=e,document.head)document.head.append(t);else{const e=document.documentElement;e.append(t);const o=new MutationObserver((()=>{document.head&&(o.disconnect(),t.isConnected&&document.head.append(t))}));o.observe(e,{childList:!0})}}}}e()})()})();