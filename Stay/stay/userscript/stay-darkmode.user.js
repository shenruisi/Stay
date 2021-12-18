// ==UserScript==
// @name         暗黑模式
// @namespace    http://stay.app/
// @version      1.0
// @description  支持浏览器网页暗黑模式
// @author       Stay²
// @match        *://*/*
// @grant        GM_log
// ==/UserScript==

(function () {
    'use strict';
    // check in ifream at the website
    var isInIframe = window.top !== window.self
    let root = document.querySelector(':root')
    let body = document.querySelector('body')
    let rootStyle = window.getComputedStyle(root)
    let bodyStyle = window.getComputedStyle(body)
    let bodyBg = bodyStyle.backgroundColor;
    let htmlBg = rootStyle.backgroundColor;
    let background = null
    GM_log("start")
    console.log("start console->")
    if (htmlBg === 'rgba(0, 0, 0, 0)' && bodyBg === 'rgba(0, 0, 0, 0)') {
        // html or body backgroundColor is set, so to invertBgColor
        background = invertBgColor('rgba(0,0,0,1)');
    } else if (htmlBg !== 'rgba(0, 0, 0, 0)') {
        // html backgroundColor is not white
        background = invertBgColor(htmlBg)
    } else {
        background = invertBgColor(bodyBg)
    }

    function invertBgColor(color, opacity = 0.9) {
        if (!color || typeof color == "undefined"){
            return
        }
        let reg = /rgba?\((.+?),(.+?),(.+?)(?:,(.+?))?\)/
        let gamma = 1
        let [r, g, b, a] = color.match(reg).slice(1).map(Number)
        let rNum = (255 ** gamma - r ** gamma) * opacity + (r ** gamma) * (1 - opacity)
        let gNum = (255 ** gamma - g ** gamma) * opacity + (g ** gamma) * (1 - opacity)
        let bNum = (255 ** gamma - b ** gamma) * opacity + (b ** gamma) * (1 - opacity)

        let invertedR = ~~(rNum ** (1 / gamma))
        let invertedG = ~~(gNum ** (1 / gamma))
        let invertedB = ~~(bNum ** (1 / gamma))
        let newColor = `rgba(${ invertedR }, ${ invertedG }, ${ invertedB }, ${ a || opacity})`
        return newColor
    }

    let style = ""
    if (isInIframe) {
        style =
        `
            svg, img, video, canvas {
                filter: hue-rotate(180deg) invert(100%);
            }
        `
    } else {
        style =
        `
            :root {
                filter: invert(90%) hue-rotate(180deg);
                background-color: ${background} !important;
            }
            svg, img, video, canvas {
                filter: hue-rotate(180deg) invert(100%);
            }
        `
    }

    let styleEle = document.createElement('style');
    styleEle.setAttribute("class","dark-mode")
    styleEle.textContent = style
    document.head.appendChild(styleEle)
})();
