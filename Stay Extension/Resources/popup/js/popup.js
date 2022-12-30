(()=>{"use strict";var e={377:(e,t,s)=>{var a=s(9242),i=s(3396),o=s(7139);const l={class:"stay-popup-warpper"},n={class:"tab-content"};function r(e,t,s,a,r,d){const c=(0,i.up)("Header"),p=(0,i.up)("MatchedScript"),u=(0,i.up)("DarkMode"),m=(0,i.up)("Sniffer"),g=(0,i.up)("UpgradePro"),b=(0,i.up)("ConsolePusher"),w=(0,i.up)("TabMenu");return(0,i.wg)(),(0,i.iD)("div",l,[(0,i.Wm)(c,null,{default:(0,i.w5)((()=>[(0,i.Uk)((0,o.zw)(a.t(e.selectedTab.name)),1)])),_:1}),(0,i._)("div",n,[1==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(p,{key:0})):(0,i.kq)("",!0),2==e.selectedTab.id||3==e.selectedTab.id?((0,i.wg)(),(0,i.iD)(i.HY,{key:1},[e.isStayPro?((0,i.wg)(),(0,i.iD)(i.HY,{key:0},[2==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(u,{key:0,darkmodeToggleStatus:e.darkmodeToggleStatus,siteEnabled:e.siteEnabled},null,8,["darkmodeToggleStatus","siteEnabled"])):(0,i.kq)("",!0),3==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(m,{key:1,browserUrl:e.browserRunUrl},null,8,["browserUrl"])):(0,i.kq)("",!0)],64)):((0,i.wg)(),(0,i.j4)(g,{key:1}))],64)):(0,i.kq)("",!0),4==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(b,{key:2})):(0,i.kq)("",!0)]),(0,i.Wm)(w,{tabId:e.selectedTab.id,onSetTabName:a.setTabName},null,8,["tabId","onSetTabName"])])}var d=s(4870);const c={class:"popup-header-wrapper"},p={class:"header-content"};function u(e,t,s,a,o,l){return(0,i.wg)(),(0,i.iD)("div",c,[(0,i._)("div",{class:"stay-icon",onClick:t[0]||(t[0]=(...e)=>a.clickStayAction&&a.clickStayAction(...e))}),(0,i._)("div",p,[(0,i.WI)(e.$slots,"default",{},void 0,!0)])])}const m={name:"headerComp",setup(e,{emit:t,expose:s}){const a=(0,i.f3)("global"),o=a.store,l=(0,d.qj)({staySwitch:o.state.staySwitch}),n=()=>{window.open("stay://")},r=e=>{l.staySwitch="start"==e?"cease":"start",o.commit("setStaySwitch",l.staySwitch)};return{...(0,d.BK)(l),clickStayAction:n,clickStaySwitchAction:r}}};var g=s(89);const b=(0,g.Z)(m,[["render",u],["__scopeId","data-v-2af33536"]]),w=b,v=s.p+"img/script-sel.png",_=s.p+"img/script.png",y=s.p+"img/dark-sel.png",f=s.p+"img/dark.png",k=s.p+"img/download-sel.png",h=s.p+"img/download.png",S=s.p+"img/console-sel.png",T=s.p+"img/console.png",C={class:"popup-fotter-wrapper"},L={class:"fotter-box"},M=["onClick"],D={key:0,src:v},U={key:1,class:"unselected",src:_},x={key:0,src:y},I={key:1,class:"unselected",src:f},q={key:0,src:k},z={key:1,class:"unselected",src:h},E={key:0,src:S},P={key:1,class:"unselected",src:T};function A(e,t,s,a,o,l){return(0,i.wg)(),(0,i.iD)("div",C,[(0,i._)("div",L,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.tabList,((t,s)=>((0,i.wg)(),(0,i.iD)("div",{class:"tab-item",key:s,onClick:e=>a.tabClickAction(t.id)},["matched_scripts_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",D)):((0,i.wg)(),(0,i.iD)("img",U))])):(0,i.kq)("",!0),"darkmode_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",x)):((0,i.wg)(),(0,i.iD)("img",I))])):(0,i.kq)("",!0),"downloader_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",q)):((0,i.wg)(),(0,i.iD)("img",z))])):(0,i.kq)("",!0),"console_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",E)):((0,i.wg)(),(0,i.iD)("img",P))])):(0,i.kq)("",!0)],8,M)))),128))])])}const H={name:"DarkModeComp",props:["tabId"],setup(e,{emit:t,expose:s}){const a=(0,d.qj)({tabList:[{id:1,selected:1,name:"matched_scripts_tab"},{id:2,selected:0,name:"darkmode_tab"},{id:3,selected:0,name:"downloader_tab"},{id:4,selected:0,name:"console_tab"}],selectedTabId:e.tabId}),i=e=>{e&&(a.selectedTabId=e,a.tabList.forEach((s=>{s.id===e&&t("setTabName",s)})))};return{...(0,d.BK)(a),tabClickAction:i}}},j=(0,g.Z)(H,[["render",A],["__scopeId","data-v-b79d3ae6"]]),F=j,N={class:"popup-darkmode-wrapper"},W={class:"darkmode-pro"},K={class:"darkmode-setting"},R=["status","onClick"],O={class:"darkmode-web"},Q={class:"check-box"},B=["checked","disabled"],Y={id:"darkmodeAllowNote",class:"darkmode-note"};function Z(e,t,s,l,n,r){return(0,i.wg)(),(0,i.iD)("div",N,[(0,i._)("div",W,[(0,i._)("div",K,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.darkmodeSettings,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["setting",{active:e.isSelected}]),status:e.status,key:t,onClick:t=>l.dakmodeSetingClick(e.status)},(0,o.zw)(e.name),11,R)))),128))]),(0,i._)("div",O,[(0,i._)("div",Q,[(0,i._)("input",{id:"allowEnabled",onChange:t[0]||(t[0]=e=>l.changeWebsiteAllowEnabled(e)),checked:s.siteEnabled,disabled:"off"===s.darkmodeToggleStatus,type:"checkbox",class:"allow"},null,40,B)]),(0,i.wy)((0,i._)("input",{id:"domainInput",class:"website-input","onUpdate:modelValue":t[1]||(t[1]=t=>e.hostName=t),type:"text",disabled:""},null,512),[[a.nr,e.hostName]])]),(0,i._)("div",Y,(0,o.zw)(s.siteEnabled?l.t("darkmode_enabled"):l.t("darkmode_disabled")),1)])])}var V=s(6995);s(541);function G(){let e=navigator.languages&&navigator.languages.length>0?navigator.languages[0]:navigator.language||navigator.userLanguage||"en";return e=e.toLowerCase(),e=e.replace(/-/,"_"),e.length>3&&(e=e.substring(0,3)+e.substring(3).toUpperCase()),e}function $(e){if(!e)return"";try{return new URL(e).hostname.toLowerCase()}catch(t){return e.split("/")[0].toLowerCase()}}function J(e){return e?e.split("/").pop():""}function X(e){return e?e.split(".").pop():""}function ee(e){let t=te(e);if(!t)return"";let s=new RegExp(".(com.cn|com|net.cn|net|org.cn|org|gov.cn|gov|cn|mobi|me|info|name|biz|cc|tv|asia|hk|网络|公司|中国)","g");return t.replace(s,"")}function te(e){try{let t="";const s=e?e.split("/"):"",a=s[2].split("."),i=[];i.unshift(a.pop());while(i.length<2)i.unshift(a.pop()),t=i.join(".");return t}catch(t){return""}}const se={name:"DarkModeComp",props:["siteEnabled","darkmodeToggleStatus"],setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,V.QT)(),l=(0,i.f3)("global"),n=l.store,r=$(n.state.browserUrl),c=(0,d.qj)({browserUrl:n.state.browserUrl,isStayPro:n.state.isStayPro,hostName:r,darkmodeToggleStatus:e.darkmodeToggleStatus,siteEnabled:e.siteEnabled,darkmodeSettings:[{status:"on",name:a("darkmode_on"),isSelected:"on"===e.darkmodeToggleStatus},{status:"auto",name:a("darkmode_auto"),isSelected:"auto"===e.darkmodeToggleStatus},{status:"off",name:a("darkmode_off"),isSelected:"off"===e.darkmodeToggleStatus}]}),p=e=>{console.log("dakmodeSetingClick-----",e),c.darkmodeToggleStatus!==e&&(c.darkmodeToggleStatus=e,c.darkmodeSettings.forEach((t=>{t.status===e?t.isSelected=!0:t.isSelected=!1})),u())},u=()=>{c.darkmodeToggleStatus&&(console.log("state.darkmodeToggleStatus-----",c.darkmodeToggleStatus),l.browser.runtime.sendMessage({type:"popup",operate:"DARKMODE_SETTING",isStayAround:c.isStayPro?"a":"b",status:c.darkmodeToggleStatus,domain:c.hostName,enabled:c.siteEnabled},(e=>{})))},m=e=>{const t=e.target.checked;c.siteEnabled=t,u()};return{...(0,d.BK)(c),t:a,tm:o,dakmodeSetingClick:p,changeWebsiteAllowEnabled:m}}},ae=(0,g.Z)(se,[["render",Z],["__scopeId","data-v-10675384"]]),ie=ae,oe={class:"popup-sniffer-wrapper"},le={key:0,class:"sniffer-video-box"},ne={class:"video-info"},re={class:"img-info"},de={class:"video"},ce=["src"],pe={key:1,class:"no-img"},ue={class:"info"},me={class:"title"},ge={class:"name"},be={class:"download"},we=["onClick"],ve={class:"video-download-info"},_e={class:"label-txt"},ye={class:"folder select-options"},fe={class:"selected-text"},ke=["onUpdate:modelValue","onChange"],he=["name","value"],Se={class:"label-txt"},Te={class:"quality select-options"},Ce={class:"selected-text"},Le=["onUpdate:modelValue","onChange"],Me=["name","value"],De={key:1,class:"sniffer-null"},Ue={class:"null-title"},xe={class:"desc-prompt"};function Ie(e,t,s,l,n,r){return(0,i.wg)(),(0,i.iD)("div",oe,[e.videoList&&e.videoList.length?((0,i.wg)(),(0,i.iD)("div",le,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.videoList,((t,s)=>((0,i.wg)(),(0,i.iD)("div",{class:"sniffer-video",key:s},[(0,i._)("div",ne,[(0,i._)("div",re,[(0,i._)("div",de,[t.poster?((0,i.wg)(),(0,i.iD)("img",{key:0,src:t.poster},null,8,ce)):((0,i.wg)(),(0,i.iD)("div",pe,[(0,i._)("span",null,(0,o.zw)(l.getDomain(t.hostUrl)),1)]))]),(0,i._)("div",ue,[(0,i._)("div",me,(0,o.zw)(l.getHostname(t.hostUrl)),1),(0,i._)("div",ge,(0,o.zw)(t.title),1)])]),(0,i._)("div",be,[(0,i._)("div",{class:"btn",onClick:e=>l.downloadClickAction(t)},(0,o.zw)(l.t("download")),9,we)])]),(0,i._)("div",ve,[(0,i._)("div",_e,(0,o.zw)(l.t("save_to_folder"))+" :",1),(0,i._)("div",ye,[(0,i._)("div",fe,(0,o.zw)(t.selectedFolderText),1),(0,i.wy)((0,i._)("select",{class:"select-container",ref_for:!0,ref:`folder_${s}`,"onUpdate:modelValue":e=>t.selectedFolder=e,onChange:e=>l.changeSelectFolder(s,e)},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.folderOptions,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{style:(0,o.j5)({display:e.id?"block":"none"}),name:e.name,key:t,value:e.uuid},(0,o.zw)(e.name),13,he)))),128))],40,ke),[[a.bM,t.selectedFolder]])]),t.qualityList&&t.qualityList.length?((0,i.wg)(),(0,i.iD)(i.HY,{key:0},[(0,i._)("div",Se,(0,o.zw)(l.t("quality"))+" :",1),(0,i._)("div",Te,[(0,i._)("div",Ce,(0,o.zw)(t.selectedQualityText),1),(0,i.wy)((0,i._)("select",{class:"select-container",ref_for:!0,ref:`quality_${s}`,"onUpdate:modelValue":e=>t.selectedQuality=e,onChange:e=>l.changeSelectQuality(s,e)},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(t.qualityList,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{key:t,name:e.qualityLabel,value:e.downloadUrl},(0,o.zw)(e.qualityLabel),9,Me)))),128))],40,Le),[[a.bM,t.selectedQuality]])])],64)):(0,i.kq)("",!0)])])))),128))])):((0,i.wg)(),(0,i.iD)("div",De,[(0,i._)("div",Ue,(0,o.zw)(l.t("sniffer_none")),1),(0,i._)("div",xe,[(0,i.Uk)((0,o.zw)(l.t("sniffer_none_prompt"))+" ",1),(0,i._)("span",{class:"mail-to",onClick:t[0]||(t[0]=(...e)=>l.contactClick&&l.contactClick(...e))},(0,o.zw)(l.t("contact_us")),1)])]))])}const qe={name:"SnifferComp",props:["browserUrl"],setup(e,{emit:t,expose:s}){const{proxy:a}=(0,i.FN)(),{t:o,tm:l}=(0,V.QT)(),n=(0,i.f3)("global"),r=(0,d.qj)({selectedFolder:"",selectedFolderText:"",folderOptions:[{name:o("select_folder"),uuid:""},{name:"download_video",id:"1"},{name:"stay-download-video",id:"2"}],videoList:[]}),c=()=>{n.browser.runtime.sendMessage({from:"popup",operate:"fetchFolders"},(e=>{console.log("fetchSnifferFolder---response-----",e);try{e.body&&(r.folderOptions=[{name:o("select_folder"),uuid:""},...e.body],e.body.forEach((e=>{e.selected&&(r.selectedFolder=e.uuid,r.selectedFolderText=e.name)})),p())}catch(t){console.log(t)}}))};c();const p=()=>{n.browser.tabs.query({active:!0,currentWindow:!0},(e=>{console.log("--------global.browser.tabs.--snifferFetchVideoInfo-");let t={from:"popup",operate:"snifferFetchVideoInfo"};n.browser.tabs.sendMessage(e[0].id,t,(e=>{if(console.log("snifferFetchVideoInfo---response-----",e),e.body&&e.body.videoInfoList&&e.body.videoInfoList.length){let t=e.body.videoInfoList;t.forEach((e=>{e.selectedFolder=r.selectedFolder,e.selectedFolderText=r.selectedFolderText,e.qualityList&&e.qualityList.length&&(e.selectedQuality=e.qualityList[0].downloadUrl,e.selectedQualityText=e.qualityList[0].qualityLabel)})),r.videoList=t}else r.videoList=[]}))}))},u=e=>{if(!e.selectedFolder)return void n.toast(o("select_folder"));e.selectedQuality&&(e.downloadUrl=e.selectedQuality);let t=[{title:e.title,downloadUrl:e.downloadUrl,poster:e.poster,hostUrl:$(e.hostUrl),uuid:e.selectedFolder}],s="stay://x-callback-url/snifferVideo?list="+encodeURIComponent(JSON.stringify(t));window.open(s)},m=(e,t)=>{const s=t.target;console.log(s),r.videoList.forEach(((t,a)=>{e==a&&(t.selectedFolder=s.value,t.selectedFolderText=s.options[s.selectedIndex].text)}))},g=(e,t)=>{const s=t.target;console.log(s,s.value,s.selectedIndex,s.options),r.videoList.forEach(((t,a)=>{e==a&&(t.selectedQuality=s.value,t.selectedQualityText=s.options[s.selectedIndex].text)}))},b=()=>{window.open(`mailto:feedback@fastclip.app?subject=${o("sniffer_none")}`)};return{...(0,d.BK)(r),t:o,tm:l,getDomain:ee,getHostname:$,getFilenameByUrl:J,getLevel2domain:te,getFiletypeByUrl:X,downloadClickAction:u,changeSelectQuality:g,changeSelectFolder:m,contactClick:b}}},ze=(0,g.Z)(qe,[["render",Ie],["__scopeId","data-v-a72843ca"]]),Ee=ze,Pe={class:"popup-console-wrapper"},Ae={class:"console-header"},He={class:"console-time"},je={class:"console-name"},Fe={class:"console-con"},Ne={key:1};function We(e,t,s,a,l,n){return(0,i.wg)(),(0,i.iD)("div",Pe,[e.scriptConsole.length?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:0},(0,i.Ko)(e.scriptConsole,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["console-item","error"==e.msgType?"error-log":""]),key:t},[(0,i._)("div",Ae,[(0,i._)("div",He,(0,o.zw)(e.time),1),(0,i._)("div",je,(0,o.zw)(e.name),1)]),(0,i._)("div",Fe,(0,o.zw)(e.message),1)],2)))),128)):((0,i.wg)(),(0,i.iD)("div",Ne))])}s(7658);const Ke={name:"ConsolePusherComp",setup(e,{emit:t,expose:s}){const a=(0,i.f3)("global"),o=(0,d.qj)({scriptConsole:[]}),l=()=>{a.browser.runtime.sendMessage({from:"popup",operate:"fetchMatchedScriptLog"},(e=>{e&&e.body&&e.body.length>0?e.body.forEach((e=>{e.logList&&e.logList.length>0&&e.logList.forEach((t=>{let s=t.msgType?t.msgType:"log",a=t&&t.time?t.time:"",i={uuid:e.uuid,name:e.name,time:a,msgType:s,message:t.msg};o.scriptConsole.push(i)}))})):o.scriptConsole=[]}))};return l(),{...(0,d.BK)(o)}}},Re=(0,g.Z)(Ke,[["render",We],["__scopeId","data-v-0808f314"]]),Oe=Re,Qe=e=>((0,i.dD)("data-v-2f65e888"),e=e(),(0,i.Cn)(),e),Be=Qe((()=>(0,i._)("div",{class:"upgrade-img"},null,-1))),Ye={class:"upgrade-btn"};function Ze(e,t,s,a,l,n){return(0,i.wg)(),(0,i.iD)("div",{class:"upgrade-pro-warpper",onClick:t[0]||(t[0]=(...e)=>a.upgradeAction&&a.upgradeAction(...e))},[Be,(0,i._)("div",Ye,(0,o.zw)(a.t("upgrade_pro")),1)])}const Ve={name:"UpgradeProComp",setup(e,{emit:t,expose:s}){const{t:a,tm:i}=(0,V.QT)(),o=(0,d.qj)({}),l=()=>{window.open("stay://x-callback-url/pay?")};return{...(0,d.BK)(o),t:a,tm:i,upgradeAction:l}}},Ge=(0,g.Z)(Ve,[["render",Ze],["__scopeId","data-v-2f65e888"]]),$e=Ge,Je={class:"popup-matched-wrapper"},Xe={key:0,class:"matched-script-box"},et={class:"tab-wrapper"},tt={class:"tab-text"},st={class:"tab-text"},at={class:"matched-script-content"},it={key:1,class:"null-data"};function ot(e,t,s,a,l,n){const r=(0,i.up)("ScriptItem"),d=(0,i.up)("RegisterMenuItem");return(0,i.wg)(),(0,i.iD)("div",Je,[e.scriptStateList&&e.scriptStateList.length?((0,i.wg)(),(0,i.iD)("div",Xe,[(0,i._)("div",et,[(0,i._)("div",{class:(0,o.C_)(["tab activated",{active:"activated"==e.showTab}]),onClick:t[0]||(t[0]=e=>a.tabACtion("activated"))},[(0,i._)("div",tt,(0,o.zw)(a.t("state_actived")),1)],2),(0,i._)("div",{class:(0,o.C_)(["tab stopped",{active:"stopped"==e.showTab}]),onClick:t[1]||(t[1]=e=>a.tabACtion("stopped"))},[(0,i._)("div",st,(0,o.zw)(a.t("state_stopped")),1)],2)]),(0,i._)("div",at,["activated"==e.showTab?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:0},(0,i.Ko)(e.activatedScriptList,((t,s)=>((0,i.wg)(),(0,i.j4)(r,{key:s,tabState:e.showTab,scriptItem:t,onHandleState:a.handleState,onHandleWebsiteDisabled:a.handleWebsiteDisabled,onHandleWebsite:a.handleWebsite,onHandleRegisterMenu:a.handleRegisterMenu},null,8,["tabState","scriptItem","onHandleState","onHandleWebsiteDisabled","onHandleWebsite","onHandleRegisterMenu"])))),128)):(0,i.kq)("",!0),"stopped"==e.showTab?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:1},(0,i.Ko)(e.stoppedScriptList,((e,t)=>((0,i.wg)(),(0,i.j4)(r,{key:t,scriptItem:e,onHandleState:a.handleState,onHandleWebsiteDisabled:a.handleWebsiteDisabled,onHandleWebsite:a.handleWebsite,onHandleRegisterMenu:a.handleRegisterMenu},null,8,["scriptItem","onHandleState","onHandleWebsiteDisabled","onHandleWebsite","onHandleRegisterMenu"])))),128)):(0,i.kq)("",!0)])])):((0,i.wg)(),(0,i.iD)("div",it,(0,o.zw)(a.t("null_scripts")),1)),e.showMenu?((0,i.wg)(),(0,i.j4)(d,{key:2,registerMenu:e.registerMenuMap[e.uuid],onCloseMenuPopup:a.closeMenuPopup},null,8,["registerMenu","onCloseMenuPopup"])):(0,i.kq)("",!0)])}const lt=s.p+"img/stop-icon.png",nt=s.p+"img/start-icon.png",rt={class:"script-item-box"},dt={key:0,class:"script-icon"},ct=["src"],pt={class:"state"},ut={key:0,src:lt,alt:""},mt={key:1,src:nt,alt:""},gt={class:"author overflow"},bt={class:"desc overflow"},wt={class:"website-cell"},vt={class:"select-options"},_t={class:"selected-text"},yt=["value"],ft={class:"action-cell"};function kt(e,t,s,l,n,r){return(0,i.wg)(),(0,i.iD)("div",rt,[(0,i._)("div",{class:(0,o.C_)(["script-item",{disabled:e.script.disableChecked}])},[(0,i._)("div",{class:(0,o.C_)(["script-info",e.script.active?"activated":"stopped"]),style:(0,o.j5)({paddingLeft:e.script.iconUrl?"60px":"0px"})},[e.script.iconUrl?((0,i.wg)(),(0,i.iD)("div",dt,[(0,i._)("img",{src:e.script.iconUrl},null,8,ct)])):(0,i.kq)("",!0),((0,i.wg)(),(0,i.iD)("div",{class:"active-state",key:e.script.uuid,onClick:t[0]||(t[0]=t=>l.activeStateClick(e.script))},[(0,i._)("div",pt,[e.script.active?((0,i.wg)(),(0,i.iD)("img",ut)):((0,i.wg)(),(0,i.iD)("img",mt))])])),(0,i._)("div",gt,(0,o.zw)(e.script.author+"@"+e.script.name),1),(0,i._)("div",bt,(0,o.zw)(e.script.description),1)],6),(0,i._)("div",wt,[(0,i._)("div",{class:(0,o.C_)(["check-box",{active:e.script.disableChecked}])},[(0,i.wy)((0,i._)("input",{ref:e.script.uuid,"onUpdate:modelValue":t[1]||(t[1]=t=>e.script.disableChecked=t),onChange:t[2]||(t[2]=t=>l.changeWebsiteDisabled(e.script.uuid,t)),type:"checkbox",class:"allow"},null,544),[[a.e8,e.script.disableChecked]])],2),(0,i._)("div",{class:"website",onClick:t[3]||(t[3]=t=>l.disabledUrlClick(e.script.uuid))},(0,o.zw)(l.t("disable_website")),1),(0,i._)("div",vt,[(0,i._)("div",_t,(0,o.zw)(e.website),1),(0,i.wy)((0,i._)("select",{class:"select-container","onUpdate:modelValue":t[4]||(t[4]=t=>e.script.disabledUrl=t),onChange:t[5]||(t[5]=t=>l.changeSelectWebsite(e.script.uuid,t))},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.websiteList,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{key:t,value:e.disabledUrl},(0,o.zw)(e.website),9,yt)))),128))],544),[[a.bM,e.script.disabledUrl]])])]),(0,i._)("div",ft,[e.script.grants.length&&(e.script.grants.includes("GM.registerMenuCommand")||e.script.grants.includes("GM_registerMenuCommand"))?((0,i.wg)(),(0,i.iD)("div",{key:0,class:"cell-icon menu",onClick:t[6]||(t[6]=t=>l.showRegisterMenu(e.script.uuid,e.script.active))},(0,o.zw)(l.t("menu")),1)):(0,i.kq)("",!0),e.script.active?(0,i.kq)("",!0):((0,i.wg)(),(0,i.iD)("div",{key:1,class:"cell-icon manually",onClick:t[7]||(t[7]=t=>l.runManually(e.script.uuid,e.script.name))},(0,o.zw)(l.t("run_manually")),1)),(0,i._)("div",{class:"cell-icon open-app",onClick:t[8]||(t[8]=t=>l.openInAPP(e.script.uuid))},(0,o.zw)(l.t("open_app")),1)])],2)])}const ht={name:"ScriptItemComp",props:["scriptItem"],components:{},setup(e,{emit:t,expose:s}){const{proxy:a}=(0,i.FN)(),{t:o,tm:l}=(0,V.QT)(),n=(0,i.f3)("global"),r=n.store,c=$(r.state.browserUrl),p=(new URL(r.state.browserUrl).origin,/^\*[://]*.+[/]\*$/g),u=(0,d.qj)({browserUrl:r.state.browserUrl,script:{...e.scriptItem,disableChecked:!!e.scriptItem.disabledUrl,disabledUrl:e.scriptItem.disabledUrl?e.scriptItem.disabledUrl:`*://${c}/*`},hostName:c,website:e.scriptItem.disabledUrl?p.test(e.scriptItem.disabledUrl)?c:e.scriptItem.disabledUrl:c,websiteList:[{website:c,disabledUrl:`*://${c}/*`},{disabledUrl:r.state.browserUrl,website:r.state.browserUrl}],showMenu:!1}),m=e=>{if(e.disableChecked)return;let s=e.uuid,a=e.active;s&&""!=s&&"string"==typeof s&&(n.browser.runtime.sendMessage({from:"popup",operate:"setScriptActive",uuid:s,active:!a},(e=>{})),u.script.active=!a,g(),t("handleState",s,!a))},g=()=>{n.browser.runtime.sendMessage({from:"popup",operate:"refreshTargetTabs"})},b=e=>{a.$refs[e].dispatchEvent(new MouseEvent("click"))},w=(e,s)=>{const a=s.target,i=a.value;u.script.disabledUrl=i,u.website=a.options[a.selectedIndex].text,_(e),t("handleWebsite",e,i)},v=(e,s)=>{const a=s.target.checked;u.script.disableChecked=a,_(e),t("handleWebsiteDisabled",e,a)},_=e=>{u.websiteList.forEach((t=>{let s=!1;u.script.disableChecked&&u.script.disabledUrl==t.disabledUrl&&(s=!0),n.browser.runtime.sendMessage({from:"popup",operate:"setDisabledWebsites",on:s,uuid:e,website:t.disabledUrl},(e=>{console.log("setDisabledWebsites response,",e)}))}))},y=e=>{window.open("stay://x-callback-url/userscript?id="+e)},f=(e,s)=>{s?(n.browser.runtime.sendMessage({from:"popup",uuid:e,operate:"fetchRegisterMenuCommand"}),t("handleRegisterMenu",e)):n.toast(o("toast_keep_active"))},k=(e,t)=>{e&&""!=e&&"string"==typeof e&&(n.browser.runtime.sendMessage({from:"popup",operate:"exeScriptManually",uuid:e},(e=>{console.log("exeScriptManually response,",e)})),n.toast({title:t,subTitle:o("run_manually")}))};return{...(0,d.BK)(u),t:o,tm:l,activeStateClick:m,disabledUrlClick:b,changeSelectWebsite:w,changeWebsiteDisabled:v,showRegisterMenu:f,runManually:k,openInAPP:y}}},St=(0,g.Z)(ht,[["render",kt],["__scopeId","data-v-eabce0f2"]]),Tt=St,Ct={class:"popup-menu-wrapper"},Lt={class:"register-menu-warpper"},Mt={class:"register-menu"},Dt={class:"menu-close"},Ut={class:"menu-item-box"},xt={key:0,class:"menu-content"},It=["onClick"],qt={key:1,class:"menu-content none-menu"};function zt(e,t,s,l,n,r){const d=(0,i.up)("DaisyLoading");return(0,i.wg)(),(0,i.j4)(a.uT,{name:"show"},{default:(0,i.w5)((()=>[(0,i._)("div",Ct,[e.loading?((0,i.wg)(),(0,i.j4)(d,{key:0,style:{position:"absolute",top:"2px",right:"16px"},size:.2},null,8,["size"])):(0,i.kq)("",!0),(0,i._)("div",Lt,[(0,i._)("div",Mt,[(0,i._)("div",Dt,[(0,i._)("div",{class:"close",onClick:t[0]||(t[0]=(...e)=>l.closeMenuPopup&&l.closeMenuPopup(...e))},(0,o.zw)(l.t("menu_close")),1)]),(0,i._)("div",Ut,[e.registerMenuList.length?((0,i.wg)(),(0,i.iD)("div",xt,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.registerMenuList,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:"menu-item",key:t,onClick:t=>l.handleRegisterMenuClickAction(e.id,e.uuid)},(0,o.zw)(e.caption),9,It)))),128))])):((0,i.wg)(),(0,i.iD)("div",qt,(0,o.zw)(l.t("null_register_menu")),1))])])])])])),_:1})}const Et=(0,i.uE)('<div class="line1" data-v-35472348></div><div class="line2" data-v-35472348></div><div class="line3" data-v-35472348></div><div class="line4" data-v-35472348></div><div class="line5" data-v-35472348></div><div class="line6" data-v-35472348></div><div class="line7" data-v-35472348></div><div class="line8" data-v-35472348></div><div class="line9" data-v-35472348></div><div class="line10" data-v-35472348></div><div class="line11" data-v-35472348></div><div class="line12" data-v-35472348></div>',12),Pt=[Et];function At(e,t,s,a,l,n){return(0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["__loading-warpper",e.props.class]),style:(0,o.j5)(e.props.style)},[(0,i._)("div",{class:"__loading-con",style:(0,o.j5)({zoom:s.size})},Pt,4)],6)}const Ht={name:"DaisyLoadingComp",props:["class","style","size"],setup(e,t){const s=(0,d.qj)({size:e.size||.2,props:e});return{...(0,d.BK)(s)}}},jt=(0,g.Z)(Ht,[["render",At],["__scopeId","data-v-35472348"]]),Ft=jt,Nt={name:"MenuItemComp",components:{DaisyLoading:Ft},props:["registerMenu"],setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,V.QT)(),l=(0,i.f3)("global"),n=(0,d.qj)({loading:!0,registerMenuList:e.registerMenu||[]});(0,i.YP)(e,(e=>{e.registerMenu&&(n.registerMenuList=e.registerMenu,n.loading=!1)}),{immediate:!0,deep:!0});const r=(e,t)=>{console.log(e),l.browser.runtime.sendMessage({from:"popup",operate:"execRegisterMenuCommand",id:e,uuid:t},(e=>{e.id&&e.uuid&&window.close()})),c()},c=()=>{t("closeMenuPopup")};return{...(0,d.BK)(n),t:a,tm:o,handleRegisterMenuClickAction:r,closeMenuPopup:c}}},Wt=(0,g.Z)(Nt,[["render",zt],["__scopeId","data-v-4e1e5222"]]),Kt=Wt,Rt={name:"MatchedScriptComp",components:{ScriptItem:Tt,RegisterMenuItem:Kt},setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,V.QT)(),l=(0,i.f3)("global"),n=l.store,r=(0,d.qj)({browserUrl:n.state.browserUrl,showTab:"activated",scriptStateList:[],activatedScriptList:[],stoppedScriptList:[],showMenu:!1,uuid:"",registerMenuMap:{}}),c=e=>{r.showTab=e,p()},p=()=>{r.stoppedScriptList=r.stoppedScriptList.filter((e=>{if(!e.active)return e;r.activatedScriptList.push(e)})),r.activatedScriptList=r.activatedScriptList.filter((e=>{if(e.active)return e;r.stoppedScriptList.push(e)}))},u=()=>{l.browser.runtime.sendMessage({from:"bootstrap",operate:"fetchScripts",url:r.browserUrl,digest:"yes"},(e=>{try{r.scriptStateList=e.body,r.activatedScriptList=[],r.stoppedScriptList=[],r.scriptStateList.forEach((e=>{e.active?r.activatedScriptList.push(e):r.stoppedScriptList.push(e)}))}catch(t){console.log(t)}}))},m=()=>{r.browserUrl?u():l.browser.tabs.getSelected(null,(e=>{r.browserUrl=e.url,n.commit("setBrowserUrl",r.browserUrl),u()}))};m();const g=(e,t,{type:s,value:a})=>{e.forEach((e=>{e.uuid===t&&("website"===s?e.disabledUrl=a:"active"===s?e.active=a:"disabledUrl"===s&&(e.disableChecked=a))}))},b=(e,t)=>{"activated"==r.showTab?g(r.activatedScriptList,e,{type:"active",value:t}):g(r.stoppedScriptList,e,{type:"active",value:t}),g(r.scriptStateList,e,{type:"active",value:t})},w=(e,t)=>{"activated"==r.showTab?g(r.activatedScriptList,e,{type:"website",value:t}):g(r.stoppedScriptList,e,{type:"website",value:t}),g(r.scriptStateList,e,{type:"website",value:t})},v=(e,t)=>{"activated"==r.showTab?g(r.activatedScriptList,e,{type:"disabledUrl",value:t}):g(r.stoppedScriptList,e,{type:"disabledUrl",value:t}),g(r.scriptStateList,e,{type:"disabledUrl",value:t})},_=e=>{r.uuid=e,r.showMenu=!0},y=()=>{r.showMenu=!1,r.uuid=""};return l.browser.runtime.onMessage.addListener(((e,t,s)=>{const a=e.from,i=e.operate;return"content"==a&&"giveRegisterMenuCommand"==i&&(r.uuid=e.uuid,r.registerMenuMap[r.uuid]=e.data),!0})),{...(0,d.BK)(r),t:a,tm:o,tabACtion:c,handleState:b,handleWebsite:w,handleWebsiteDisabled:v,handleRegisterMenu:_,closeMenuPopup:y}}},Ot=(0,g.Z)(Rt,[["render",ot],["__scopeId","data-v-4566685d"]]),Qt=Ot,Bt={name:"popupView",components:{Header:w,TabMenu:F,ConsolePusher:Oe,Sniffer:Ee,DarkMode:ie,UpgradePro:$e,MatchedScript:Qt},setup(e,{emit:t,attrs:s,slots:a}){const{t:o,tm:l}=(0,V.QT)(),n=(0,i.f3)("global"),r=n.store,c=r.state.localeLan;console.log("localLan====",c,r.state.selectedTab);const p=(0,d.qj)({selectedTab:r.state.selectedTab,localLan:c,browserUrl:"",isStayPro:r.state.isStayPro,darkmodeToggleStatus:"on",siteEnabled:!0}),u=e=>{p.selectedTab=e,r.commit("setSelectedTab",p.selectedTab)};n.browser.runtime.onMessage.addListener(((e,t,s)=>{const a=e.from,i=e.operate;return"background"===a&&"giveDarkmodeConfig"==i&&(console.log("giveDarkmodeConfig==res==",e),p.isStayPro="a"==e.isStayAround,r.commit("setIsStayPro",p.isStayPro),p.darkmodeToggleStatus=e.darkmodeToggleStatus,p.siteEnabled=e.enabled),!0}));const m=()=>{n.browser.tabs.getSelected(null,(e=>{console.log("fetchStayProConfig----tab-----",e),p.browserUrl=e.url,r.commit("setBrowserUrl",p.browserUrl)})),n.browser.runtime.sendMessage({type:"popup",operate:"FETCH_DARKMODE_CONFIG"},(e=>{}))};return m(),{...(0,d.BK)(p),t:o,tm:l,setTabName:u}}},Yt=(0,g.Z)(Bt,[["render",r]]),Zt=Yt;var Vt=s(8874),Gt=s(2415);const $t={namespaced:!0,state:()=>({name:""}),mutations:{SET_NAME:(e,t)=>{e.name=t}},actions:{setName:({commit:e},t)=>{e("SET_NAME",t)}}},Jt=(0,Vt.MT)({state:{localeLan:G().indexOf("zh_")>-1?"zh":"en",staySwitch:"start",isStayPro:!1,browserUrl:"",selectedTab:{id:1,name:"matched_scripts_tab"}},getters:{localLanGetter:e=>e.localeLan,staySwitchGetter:e=>e.staySwitch,isStayProGetter:e=>e.isStayPro,browserUrlGetter:e=>e.browserUrl,selectedTabGetter:e=>e.selectedTab},mutations:{setLocalLan:(e,t)=>{e.localeLan=t},setStaySwitch:(e,t)=>{e.staySwitch=t},setIsStayPro:(e,t)=>{e.isStayPro=t},setBrowserUrl:(e,t)=>{e.browserUrl=t},setSelectedTab:(e,t)=>{e.selectedTab=t}},actions:{setLocalLanAsync:({commit:e},t)=>{e("setLocalLan",t)},setStaySwitchAsync:({commit:e},t)=>{e("setStaySwitch",t)},setIsStayProAsync:({commit:e},t)=>{e("setIsStayPro",t)},setrowserUrlAsync:({commit:e},t)=>{e("setBrowserUrl",t)},setSelectedTabAsync:({commit:e},t)=>{e("setSelectedTab",t)}},modules:{moudleA:$t},plugins:[(0,Gt.Z)({storage:window.localStorage,key:"stay-popup-vuex-store-persistence",paths:["moudleA","localeLan","staySwitch","selectedTab"]})]}),Xt={en:{matched_scripts_tab:"Matched",console_tab:"Console",darkmode_tab:"Dark Mode",state_actived:"Activated",state_manually:"Manually Executed",state_stopped:"Stopped",null_scripts:"no available scripts were matched",null_register_menu:"No register menu item",menu_close:"Close",toast_keep_active:"Please keep the script activated",run_manually:"RUN MANUALLY",upgrade_pro:"Upgrade to Stay Pro",darkmode_off:"Off",darkmode_auto:"Auto",darkmode_on:"On",darkmode_enabled:"Enabled for current website",darkmode_disabled:"Disabled for current website",download_text:"User script manager",downloader_tab:"Downloader",sniffer_none:"No videos found",sniffer_none_prompt:"Unable to get video on current site?",contact_us:"Contact Us",download:"DOWNLOAD",save_to_folder:"Save to folder",quality:"Quality",select_folder:"Select Folder",disable_website:"Disable on this website",menu:"MENU",open_app:"OPEN IN APP"},zh:{matched_scripts_tab:"已匹配脚本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"已激活",state_manually:"手动执行",state_stopped:"已停止",null_scripts:"未匹配到可用脚本",null_register_menu:"无注册菜单项",menu_close:"关闭",toast_keep_active:"请保持脚本处于激活状态",run_manually:"手动执行",upgrade_pro:"升级Stay专业版",darkmode_off:"关",darkmode_auto:"自动",darkmode_on:"开",darkmode_enabled:"启用当前网站",darkmode_disabled:"禁用当前网站",download_text:"用户脚本管理",downloader_tab:"下载器",sniffer_none:"没有发现视频",sniffer_none_prompt:"无法获取当前站点上的视频？",contact_us:"联系我们",download:"下载",save_to_folder:"保存到文件夹",quality:"画质",select_folder:"选择文件夹",disable_website:"在此网站上禁用",menu:"菜单",open_app:"在应用里打开"},zh_HK:{matched_scripts_tab:"已匹配腳本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"已激活",state_manually:"手動執行",state_stopped:"已停止",null_scripts:"未匹配到可用腳本",null_register_menu:"無註冊菜單項",menu_close:"關閉",toast_keep_active:"請保持腳本處於激活狀態",run_manually:"手動執行",upgrade_pro:"升級Stay專業版",darkmode_off:"關",darkmode_auto:"自動",darkmode_on:"開",darkmode_enabled:"啟用當前網站",darkmode_disabled:"禁用當前網站",download_text:"用戶腳本管理",downloader_tab:"下載器",sniffer_none:"沒有發現視頻",sniffer_none_prompt:"無法獲取當前站點上的視頻？",contact_us:"联系我们",download:"下載",save_to_folder:"保存到文件夾",quality:"畫質",select_folder:"選擇文件夾",disable_website:"在此網站上禁用",menu:"菜單",open_app:"在應用裡打開"}},es=(0,V.o)({fallbackLocale:"ch",globalInjection:!0,allowComposition:!0,legacy:!1,locale:"en",messages:Xt}),ts=es,ss={class:"m-notice"},as=["innerHTML"],is=["innerHTML"];function os(e,t,s,o,l,n){return(0,i.wg)(),(0,i.j4)(a.uT,{name:"show"},{default:(0,i.w5)((()=>[(0,i.wy)((0,i._)("div",ss,[(0,i._)("div",{class:"m-msg",innerHTML:s.title},null,8,as),s.subTitle?((0,i.wg)(),(0,i.iD)("div",{key:0,class:"m-msg",innerHTML:s.subTitle},null,8,is)):(0,i.kq)("",!0)],512),[[a.F8,e.showNotice]])])),_:1})}const ls={name:"ToastComp",props:{title:{type:String,default:"加载中..."},subTitle:{type:String}},setup(){const e=(0,d.qj)({showNotice:!1});return(0,i.bv)((()=>{e.showNotice=!0})),{...(0,d.BK)(e)}}},ns=(0,g.Z)(ls,[["render",os],["__scopeId","data-v-5dd969de"]]),rs=ns,ds=document.createElement("div");document.body.appendChild(ds);let cs=null;const ps=e=>{let t,s,o;"string"!==typeof e&&"undefined"!==typeof e&&e?(s=e.subTitle,t=e.title||"加载中...",o=e.duration||3500):(s="",t=e||"加载中...",o=3500);const l=(0,i.Wm)(rs,{title:t,subTitle:s});(0,a.sY)(l,ds),clearTimeout(cs),cs=setTimeout((()=>{(0,a.sY)(null,ds)}),o)};let us;"undefined"!==typeof window.browser&&(us=window.browser),"undefined"!==typeof window.chrome&&(us=window.chrome);const ms=us,gs=(0,a.ri)(Zt),bs=e=>{document.body.addEventListener("click",(t=>{e(t)}))};gs.provide("global",{store:Jt,browser:ms,toast:ps,globalClick:bs}),gs.use(ts).use(Jt).mount("#app")}},t={};function s(a){var i=t[a];if(void 0!==i)return i.exports;var o=t[a]={exports:{}};return e[a](o,o.exports,s),o.exports}s.m=e,(()=>{var e=[];s.O=(t,a,i,o)=>{if(!a){var l=1/0;for(c=0;c<e.length;c++){a=e[c][0],i=e[c][1],o=e[c][2];for(var n=!0,r=0;r<a.length;r++)(!1&o||l>=o)&&Object.keys(s.O).every((e=>s.O[e](a[r])))?a.splice(r--,1):(n=!1,o<l&&(l=o));if(n){e.splice(c--,1);var d=i();void 0!==d&&(t=d)}}return t}o=o||0;for(var c=e.length;c>0&&e[c-1][2]>o;c--)e[c]=e[c-1];e[c]=[a,i,o]}})(),(()=>{s.n=e=>{var t=e&&e.__esModule?()=>e["default"]:()=>e;return s.d(t,{a:t}),t}})(),(()=>{s.d=(e,t)=>{for(var a in t)s.o(t,a)&&!s.o(e,a)&&Object.defineProperty(e,a,{enumerable:!0,get:t[a]})}})(),(()=>{s.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()})(),(()=>{s.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t)})(),(()=>{s.j=42})(),(()=>{s.p=""})(),(()=>{var e={42:0};s.O.j=t=>0===e[t];var t=(t,a)=>{var i,o,l=a[0],n=a[1],r=a[2],d=0;if(l.some((t=>0!==e[t]))){for(i in n)s.o(n,i)&&(s.m[i]=n[i]);if(r)var c=r(s)}for(t&&t(a);d<l.length;d++)o=l[d],s.o(e,o)&&e[o]&&e[o][0](),e[o]=0;return s.O(c)},a=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];a.forEach(t.bind(null,0)),a.push=t.bind(null,a.push.bind(a))})();var a=s.O(void 0,[998],(()=>s(377)));a=s.O(a)})();