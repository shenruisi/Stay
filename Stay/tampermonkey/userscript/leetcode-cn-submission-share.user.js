// ==UserScript==
// @name         战绩分享
// @namespace    http://tampermonkey.net/
// @version      0.5.4
// @updateURL    https://gist.githubusercontent.com/qiushijie/2572cafcb75935b409748a532c445171/raw/leetcode-cn-submission-share.user.js
// @downloadURL  https://gist.githubusercontent.com/qiushijie/2572cafcb75935b409748a532c445171/raw/leetcode-cn-submission-share.user.js
// @description  知识就是力量，学习使我快乐
// @author       qiushijie
// @match        https://leetcode-cn.com/*
// @grant        GM_setClipboard
// @run-at       context-menu
// @require      https://cdn.bootcdn.net/ajax/libs/jquery/3.5.1/jquery.min.js
// ==/UserScript==

(function exportStatus() {
    let text = $('title').text() + '\n';
    text += '执行结果：' + $('[data-cypress="SubmissionSuccess"]').text() + '\n';
    const riEl = $("*[class*='-ResultInfo']").first();
    text += riEl.text() + '\n';
    text += riEl.next().text() + '\n';
    const url = location.href;
    text += '题目链接：' + url.substr(0, url.length - 'submissions'.length - 1);
    GM_setClipboard(text);
    alert('复制成功');
})()
