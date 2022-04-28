<img width="128px" src="./Material/icon.png" alt="Logo" align="left"/>

# [Stay](https://apps.apple.com/cn/app/stay-%E7%BD%91%E9%A1%B5%E7%BA%AF%E6%B5%8F%E8%A7%88/id1591620171)

[![Views](https://views.whatilearened.today/views/github/shenruisi/Stay.svg)]()
[![iOS System](https://img.shields.io/badge/iOS-15%2B-brightgreen)]()
[![TestFlight](https://img.shields.io/badge/TestFlight-2.0.6-4391E1)](https://testflight.apple.com/join/v5llhUv5)
[![HelloGithub](https://img.shields.io/badge/HelloGithub-vol.70-white)](https://hellogithub.com/periodical/volume/70/)
[![Dev](https://img.shields.io/badge/Develop%20Branch-2.1.x-blueviolet)]()
[![Newsletter](https://img.shields.io/badge/Newsletter-Subscribe-important)](https://www.getrevue.co/profile/shenruisi)

<p align="right"><a href="README-EN.md">中文</a> | EN</p>

Stay is an open source iOS Safari extension (Compatible userscript).

Learn more about tasks and development progress, please checkout [Project of Stay 2](https://github.com/shenruisi/Stay/projects/1).

## Usage
- Prepare
  - Go to Settings > Safari > Extensions
  - Trun on Stay
  - Allow Stay for All Websites
- Import js script from (Write script | Link | GreasyFork | Local file)
- Activate script at `Library` tab

## Find a script
Welcome to create a [Embed Script Request](https://github.com/shenruisi/Stay/issues/new?assignees=shenruisi&labels=embed+script+request&template=Embed-Script-Request.yml&title=%5BEmbed+Script+Request%5D%3A+) to promote a great script.

- [Stay offical userscript](https://github.com/shenruisi/Stay-Offical-Userscript)
- [Third party tg channel - Act Channel D](https://t.me/ACTCD)

## Contact us
Twitter:[@shenruisi](https://twitter.com/shenruisi)

Please follow the public account `效率先生`, and reply `微信群` to join the wechat group.

<img src="./Material/qrcode.jpg" width="256"/>

## Metadata
Metadata supported by Stay.
- [@name](https://www.tampermonkey.net/documentation.php#_name)([Localized](https://wiki.greasespot.net/Metadata_Block#@name))
- [@namespace](https://www.tampermonkey.net/documentation.php#_namespace)
- [@version](https://www.tampermonkey.net/documentation.php#_version)
- [@author](https://www.tampermonkey.net/documentation.php#_author)
- [@description](https://www.tampermonkey.net/documentation.php#_description)([Localized](https://wiki.greasespot.net/Metadata_Block#@description))
- [@homepage](https://www.tampermonkey.net/documentation.php#_homepage)
- [@icon](https://www.tampermonkey.net/documentation.php#_icon)(@icon only)
- [@updateURL](https://www.tampermonkey.net/documentation.php#_updateURL)
- [@downloadURL](https://www.tampermonkey.net/documentation.php#_downloadURL)
- [@supportURL](https://www.tampermonkey.net/documentation.php#_supportURL)
- [@include](https://www.tampermonkey.net/documentation.php#_include)
- [@match](https://www.tampermonkey.net/documentation.php#_match)
- [@exclude](https://www.tampermonkey.net/documentation.php#_exclude)
- [@require](https://www.tampermonkey.net/documentation.php#_require)
- [@resource](https://www.tampermonkey.net/documentation.php#_resource)(Download resource at script creating/updating)
- [@run-at](https://www.tampermonkey.net/documentation.php#_run_at)(context-menu not supported)
- [@grant](https://www.tampermonkey.net/documentation.php#_grant)
- [@noframes](https://www.tampermonkey.net/documentation.php#_noframes)
- @notes - Notes of modification history

## API
API supported by Stay.
- [unsafeWindow](https://www.tampermonkey.net/documentation.php#unsafeWindow)
- [GM_addStyle](https://www.tampermonkey.net/documentation.php#GM_addStyle)
- [GM_setValue](https://www.tampermonkey.net/documentation.php#GM_setValue) / [GM.setValue](https://wiki.greasespot.net/GM.setValue)
- [GM_getValue](https://www.tampermonkey.net/documentation.php#GM_getValue) / [GM.getValue](https://wiki.greasespot.net/GM.getValue)
- [GM_deleteValue](https://www.tampermonkey.net/documentation.php#GM_deleteValue) / [GM.deleteValue](https://wiki.greasespot.net/GM.deleteValue)
- [GM_listValues](https://www.tampermonkey.net/documentation.php#GM_listValues) / [GM.listValues](https://wiki.greasespot.net/GM.listValues)
- [GM_log](https://www.tampermonkey.net/documentation.php#GM_log)(Show up at popup view)
- [GM_registerMenuCommand](https://www.tampermonkey.net/documentation.php#GM_registerMenuCommand) / [GM.registerMenuCommand](https://wiki.greasespot.net/GM.registerMenuCommand)
- [GM_unregisterMenuCommand / GM.unregisterMenuCommand](https://www.tampermonkey.net/documentation.php#GM_unregisterMenuCommand)
- [GM_getResourceURL](https://www.tampermonkey.net/documentation.php#GM_getResourceURL) / [GM.getResourceUrl](https://wiki.greasespot.net/GM.getResourceUrl)
- [GM_getResourceText / GM.getResourceText](https://www.tampermonkey.net/documentation.php#GM_getResourceText)
- [GM_xmlhttpRequest](https://www.tampermonkey.net/documentation.php#GM_xmlhttpRequest) / [GM.xmlHttpRequest](https://wiki.greasespot.net/GM.xmlHttpRequest)
- [GM_openInTab](https://www.tampermonkey.net/documentation.php#GM_openInTab) / [GM.openInTab](https://wiki.greasespot.net/GM.openInTab)
- [GM_info](https://www.tampermonkey.net/documentation.php#GM_info) / [GM.info](https://wiki.greasespot.net/GM.info)(scriptHandler is stay)
- GM_notification / GM.notification(Grant allowed but unimplement)
- window.onurlchange(Grant allowed but unimplement)

## LICENSE
[MPL](./LICENSE)


## Safari extension development references
- [Meet Safari Web Extensions on iOS](https://developer.apple.com/videos/play/wwdc2021/10104)
- [CSS Selectors](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Selectors)
- [DOMContentLoaded event](https://developer.mozilla.org/en-US/docs/Web/API/Window/DOMContentLoaded_event)
- [Content scripts](https://developer.chrome.com/docs/extensions/mv3/content_scripts/)
- [Safari web extensions](https://developer.apple.com/documentation/safariservices/safari_web_extensions)
- [crxviewer](https://robwu.nl/crxviewer/)
- [Browser support for JavaScript APIs](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Browser_support_for_JavaScript_APIs)


