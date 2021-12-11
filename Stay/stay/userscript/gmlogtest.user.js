// ==UserScript==
// @name         GM log test
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  gm test!
// @author       You
// @match        https://*/*
// @grant        GM_log
// @grant        GM_setValue
// ==/UserScript==

(function() {
    'use strict';
    GM_log("log from GM_log");
    console.log("ok");
})();


