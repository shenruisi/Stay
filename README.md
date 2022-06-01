<img width="128px" src="./Material/icon.png" alt="Logo" align="left"/>

# [Stay](https://apps.apple.com/cn/app/stay-%E7%BD%91%E9%A1%B5%E7%BA%AF%E6%B5%8F%E8%A7%88/id1591620171)

[![Views](https://views.whatilearened.today/views/github/shenruisi/Stay.svg)]()
[![iOS System](https://img.shields.io/badge/iOS-15%2B-brightgreen)]()
[![TestFlight](https://img.shields.io/badge/TestFlight-2.1.0-4391E1)](https://testflight.apple.com/join/v5llhUv5)
[![HelloGithub](https://img.shields.io/badge/HelloGithub-vol.70-white)](https://hellogithub.com/periodical/volume/70/)
[![Dev](https://img.shields.io/badge/Develop%20Branch-2.1.x-blueviolet)]()
[![Newsletter](https://img.shields.io/badge/Newsletter-Subscribe-important)](https://www.getrevue.co/profile/shenruisi)

<p align="right">中文 | <a href="README-EN.md">EN</a></p>     

Stay是一个开源的本地iOS Safari扩展脚本管理器（兼容userscript）。

了解Stay的开发计划和版本进度，请查看 [Project of Stay 2](https://github.com/shenruisi/Stay/projects/1)。

## 使用方式
- 使用前准备
  - 前往 设置 > Safari浏览器 > 扩展 > Stay
  - 打开Stay
  - 允许Stay应用于所有网站 
- 通过（直接编写脚本 ｜脚本地址链接 ｜ GreasyFork网站 ｜ 本地文件）等方式将js脚本导入Stay
- 在资料库列表中激活脚本

## 发现脚本
欢迎通过[Embed Script Request](https://github.com/shenruisi/Stay/issues/new?assignees=shenruisi&labels=embed+script+request&template=Embed-Script-Request.yml&title=%5BEmbed+Script+Request%5D%3A+)来推荐好用的扩展脚本。

- [Stay官方脚本](https://github.com/shenruisi/Stay-Offical-Userscript)
- [第三方tg频道 - Act Channel D](https://t.me/ACTCD)

## Metadata
Stay支持的metadata。
- [@name](https://www.tampermonkey.net/documentation.php#_name)([支持多语言](https://wiki.greasespot.net/Metadata_Block#@name))
- [@namespace](https://www.tampermonkey.net/documentation.php#_namespace)
- [@version](https://www.tampermonkey.net/documentation.php#_version)
- [@author](https://www.tampermonkey.net/documentation.php#_author)
- [@description](https://www.tampermonkey.net/documentation.php#_description)([支持多语言](https://wiki.greasespot.net/Metadata_Block#@description))
- [@homepage](https://www.tampermonkey.net/documentation.php#_homepage)
- [@icon](https://www.tampermonkey.net/documentation.php#_icon)(只支持@icon)
- [@updateURL](https://www.tampermonkey.net/documentation.php#_updateURL)
- [@downloadURL](https://www.tampermonkey.net/documentation.php#_downloadURL)
- [@supportURL](https://www.tampermonkey.net/documentation.php#_supportURL)
- [@include](https://www.tampermonkey.net/documentation.php#_include)
- [@match](https://www.tampermonkey.net/documentation.php#_match)
- [@exclude](https://www.tampermonkey.net/documentation.php#_exclude)
- [@require](https://www.tampermonkey.net/documentation.php#_require)
- [@resource](https://www.tampermonkey.net/documentation.php#_resource)(Stay会在创建/更新的时候下载resource)
- [@run-at](https://www.tampermonkey.net/documentation.php#_run_at)(不支持context-menu)
- [@grant](https://www.tampermonkey.net/documentation.php#_grant)
- [@noframes](https://www.tampermonkey.net/documentation.php#_noframes)
- @notes - 版本修改历史

## API
Stay支持的api。
- [unsafeWindow](https://www.tampermonkey.net/documentation.php#unsafeWindow)
- [GM_addStyle](https://www.tampermonkey.net/documentation.php#GM_addStyle)
- [GM_setValue](https://www.tampermonkey.net/documentation.php#GM_setValue) / [GM.setValue](https://wiki.greasespot.net/GM.setValue)
- [GM_getValue](https://www.tampermonkey.net/documentation.php#GM_getValue) / [GM.getValue](https://wiki.greasespot.net/GM.getValue)
- [GM_deleteValue](https://www.tampermonkey.net/documentation.php#GM_deleteValue) / [GM.deleteValue](https://wiki.greasespot.net/GM.deleteValue)
- [GM_listValues](https://www.tampermonkey.net/documentation.php#GM_listValues) / [GM.listValues](https://wiki.greasespot.net/GM.listValues)
- [GM_log](https://www.tampermonkey.net/documentation.php#GM_log)(在Stay的popup面板展示)
- [GM_registerMenuCommand](https://www.tampermonkey.net/documentation.php#GM_registerMenuCommand) / [GM.registerMenuCommand](https://wiki.greasespot.net/GM.registerMenuCommand)
- [GM_unregisterMenuCommand / GM.unregisterMenuCommand](https://www.tampermonkey.net/documentation.php#GM_unregisterMenuCommand)
- [GM_getResourceURL](https://www.tampermonkey.net/documentation.php#GM_getResourceURL) / [GM.getResourceUrl](https://wiki.greasespot.net/GM.getResourceUrl)
- [GM_getResourceText / GM.getResourceText](https://www.tampermonkey.net/documentation.php#GM_getResourceText)
- [GM_xmlhttpRequest](https://www.tampermonkey.net/documentation.php#GM_xmlhttpRequest) / [GM.xmlHttpRequest](https://wiki.greasespot.net/GM.xmlHttpRequest)
- [GM_openInTab](https://www.tampermonkey.net/documentation.php#GM_openInTab) / [GM.openInTab](https://wiki.greasespot.net/GM.openInTab)
- [GM_info](https://www.tampermonkey.net/documentation.php#GM_info) / [GM.info](https://wiki.greasespot.net/GM.info)(scriptHandler值为stay)
- GM_notification / GM.notification(允许grant但未实现)
- window.onurlchange(允许grant但未实现)

## 用户交流
Twitter:[@shenruisi](https://twitter.com/shenruisi)

或者关注公众号`效率先生`，并回复`微信群` 进群沟通。

<img src="./Material/qrcode.jpg" width="256"/>

## 许可证
[MPL](./LICENSE)


## Safari插件开发参考资料
- [Meet Safari Web Extensions on iOS](https://developer.apple.com/videos/play/wwdc2021/10104)
- [CSS Selectors](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors)
- [DOMContentLoaded event](https://developer.mozilla.org/en-US/docs/Web/API/Window/DOMContentLoaded_event)
- [Content scripts](https://developer.chrome.com/docs/extensions/mv3/content_scripts/)
- [Safari web extensions](https://developer.apple.com/documentation/safariservices/safari_web_extensions)
- [crxviewer](https://robwu.nl/crxviewer/)
- [Browser support for JavaScript APIs](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Browser_support_for_JavaScript_APIs)


