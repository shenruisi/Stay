// ==UserScript==
// @name         GM log test
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  gm test!
// @author       You
// @match        https://*/*
// @exclude        https://*.baidu.com/*
// @grant        GM_log
// @grant        GM_setValue
// @grant        GM_setValue
// @grant        GM_listValues
// @noframes
// ==/UserScript==

(function() {
    'use strict';
    GM_log("log from GM_log");
    console.log("ok");
//    console.log(GM_listValues());
//    GM_setValue("name","stay");
    console.log(GM_getValue("name"));
})();


