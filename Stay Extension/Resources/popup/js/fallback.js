!function(){"use strict";{(new Date).getTime();let e=function(e){try{return new URL(e).hostname.toLowerCase()}catch(t){return e.split("/")[0].toLowerCase()}}(window.location.href),t=window.localStorage.getItem("FETCH_DARK_SETTING");function o(){return Boolean(window.matchMedia("(prefers-color-scheme: dark)").matches)}function n(t){if(!document.querySelector(".darkreader--fallback")&&(!document.querySelector(".noir")||!document.querySelector(".noir-root"))&&document.documentElement instanceof HTMLHtmlElement&&(void 0!==t.darkState&&""!==t.darkState&&"dark_mode"===t.darkState||o()&&"off"!=t.toggleStatus&&t.siteListDisabled&&"[]"!==t.siteListDisabled&&0<t.siteListDisabled.length&&!t.siteListDisabled.includes(e)||!o()&&"on"===t.toggleStatus&&t.siteListDisabled&&"[]"!==t.siteListDisabled&&0<t.siteListDisabled.length&&!t.siteListDisabled.includes(e))){const e=document.createElement("style");if(e.classList.add("darkreader"),e.classList.add("darkreader--fallback"),e.media="screen",e.textContent='html, body, body :not(iframe):not(div[style^="position:absolute;top:0;left:-"]) { background-color: #181a1b !important; border-color: #776e62 !important; color: #e8e6e3 !important; } html, body { opacity: 1 !important; transition: none !important; }',document.head)document.head.append(e);else{t=document.documentElement,t.append(e);const o=new MutationObserver((()=>{document.head&&(o.disconnect(),e.isConnected)&&document.head.append(e)}));o.observe(t,{childList:!0})}}}t&&""!==t&&"null"!==t&&"undefined"!==t&&"clean_up"!=t&&"dark_mode"!=t?n({...JSON.parse(t)}):darkconfigJS.handleDarkmodeSettingListenerFromUserJS({from:"darkmode",operate:"FETCH_DARK_SETTING"},(e=>{n(e),window.localStorage.setItem("FETCH_DARK_SETTING",JSON.stringify(e))}))}}();