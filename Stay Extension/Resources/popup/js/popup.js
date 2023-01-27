(()=>{"use strict";var e={3366:(e,t,s)=>{var a=s(9242),i=s(3396),o=s(7139);const l={class:"stay-popup-warpper"},r={class:"tab-content"},n=["href"];function d(e,t,s,a,d,c){const p=(0,i.up)("Header"),u=(0,i.up)("MatchedScript"),m=(0,i.up)("DarkMode"),g=(0,i.up)("Sniffer"),b=(0,i.up)("UpgradePro"),w=(0,i.up)("ConsolePusher"),v=(0,i.up)("TabMenu");return(0,i.wg)(),(0,i.iD)("div",l,[(0,i.Wm)(p,null,{default:(0,i.w5)((()=>[(0,i.Uk)((0,o.zw)(a.t(e.selectedTab.name)),1)])),_:1}),(0,i._)("div",r,[1==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(u,{key:0})):(0,i.kq)("",!0),2==e.selectedTab.id||3==e.selectedTab.id?((0,i.wg)(),(0,i.iD)(i.HY,{key:1},[e.isStayPro?((0,i.wg)(),(0,i.iD)(i.HY,{key:0},[2==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(m,{key:0,darkmodeToggleStatus:e.darkmodeToggleStatus,siteEnabled:e.siteEnabled},null,8,["darkmodeToggleStatus","siteEnabled"])):(0,i.kq)("",!0),3==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(g,{key:1,browserUrl:e.browserRunUrl},null,8,["browserUrl"])):(0,i.kq)("",!0)],64)):((0,i.wg)(),(0,i.j4)(b,{key:1},{default:(0,i.w5)((()=>[(0,i._)("a",{class:"what-it",href:2==e.selectedTab.id?"https://www.craft.do/s/PHKJvkZL92BTep":"https://www.craft.do/s/sYLNHtYc0n2rrV",target:"_blank"},(0,o.zw)(2==e.selectedTab.id?a.t("what_darkmode"):a.t("what_downloader")),9,n)])),_:1}))],64)):(0,i.kq)("",!0),4==e.selectedTab.id?((0,i.wg)(),(0,i.j4)(w,{key:2})):(0,i.kq)("",!0)]),(0,i.Wm)(v,{tabId:e.selectedTab.id,onSetTabName:a.setTabName},null,8,["tabId","onSetTabName"])])}var c=s(4870);const p={class:"popup-header-wrapper"},u={class:"header-content"};function m(e,t,s,a,o,l){return(0,i.wg)(),(0,i.iD)("div",p,[(0,i._)("div",{class:"stay-icon",onClick:t[0]||(t[0]=(...e)=>a.clickStayAction&&a.clickStayAction(...e))}),(0,i._)("div",u,[(0,i.WI)(e.$slots,"default",{},void 0,!0)])])}const g={name:"headerComp",setup(e,{emit:t,expose:s}){const a=(0,i.f3)("global"),o=a.store,l=(0,c.qj)({staySwitch:o.state.staySwitch}),r=()=>{a.openUrlInSafariPopup("stay://")},n=e=>{l.staySwitch="start"==e?"cease":"start",o.commit("setStaySwitch",l.staySwitch)};return{...(0,c.BK)(l),clickStayAction:r,clickStaySwitchAction:n}}};var b=s(89);const w=(0,b.Z)(g,[["render",m],["__scopeId","data-v-13a89d88"]]),v=w,_=s.p+"img/script-sel.png",y=s.p+"img/script.png",f=s.p+"img/dark-sel.png",k=s.p+"img/dark.png",h=s.p+"img/download-sel.png",S=s.p+"img/download.png",T=s.p+"img/console-sel.png",C=s.p+"img/console.png",M={class:"popup-fotter-wrapper"},L={class:"fotter-box"},U=["onClick"],D={key:0,src:_},x={key:1,class:"unselected",src:y},I={key:0,src:f},P={key:1,class:"unselected",src:k},q={key:0,src:h},z={key:1,class:"unselected",src:S},E={key:0,src:T},A={key:1,class:"unselected",src:C};function H(e,t,s,a,o,l){return(0,i.wg)(),(0,i.iD)("div",M,[(0,i._)("div",L,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.tabList,((t,s)=>((0,i.wg)(),(0,i.iD)("div",{class:"tab-item",key:s,onClick:e=>a.tabClickAction(t.id)},["matched_scripts_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",D)):((0,i.wg)(),(0,i.iD)("img",x))])):(0,i.kq)("",!0),"darkmode_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",I)):((0,i.wg)(),(0,i.iD)("img",P))])):(0,i.kq)("",!0),"downloader_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",q)):((0,i.wg)(),(0,i.iD)("img",z))])):(0,i.kq)("",!0),"console_tab"==t.name?((0,i.wg)(),(0,i.iD)("div",{class:"tab-img",key:t.name},[t.id==e.selectedTabId?((0,i.wg)(),(0,i.iD)("img",E)):((0,i.wg)(),(0,i.iD)("img",A))])):(0,i.kq)("",!0)],8,U)))),128))])])}const j={name:"DarkModeComp",props:["tabId"],setup(e,{emit:t,expose:s}){const a=(0,c.qj)({tabList:[{id:1,selected:1,name:"matched_scripts_tab"},{id:2,selected:0,name:"darkmode_tab"},{id:3,selected:0,name:"downloader_tab"},{id:4,selected:0,name:"console_tab"}],selectedTabId:e.tabId}),i=e=>{e&&(a.selectedTabId=e,a.tabList.forEach((s=>{s.id===e&&t("setTabName",s)})))};return{...(0,c.BK)(a),tabClickAction:i}}},W=(0,b.Z)(j,[["render",H],["__scopeId","data-v-30dbf3ce"]]),F=W,N={class:"popup-darkmode-wrapper"},O={class:"darkmode-pro"},K={class:"darkmode-setting"},R=["status","onClick"],B={class:"darkmode-web"},Q={class:"check-box"},Y=["checked","disabled"],Z={id:"darkmodeAllowNote",class:"darkmode-note"};function V(e,t,s,l,r,n){return(0,i.wg)(),(0,i.iD)("div",N,[(0,i._)("div",O,[(0,i._)("div",K,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.darkmodeSettings,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["setting",{active:e.isSelected}]),status:e.status,key:t,onClick:t=>l.dakmodeSetingClick(e.status)},(0,o.zw)(e.name),11,R)))),128))]),(0,i._)("div",B,[(0,i._)("div",Q,[(0,i._)("input",{id:"allowEnabled",onChange:t[0]||(t[0]=e=>l.changeWebsiteAllowEnabled(e)),checked:s.siteEnabled,disabled:"off"===s.darkmodeToggleStatus,type:"checkbox",class:"allow"},null,40,Y)]),(0,i.wy)((0,i._)("input",{id:"domainInput",class:"website-input","onUpdate:modelValue":t[1]||(t[1]=t=>e.hostName=t),type:"text",disabled:""},null,512),[[a.nr,e.hostName]])]),(0,i._)("div",Z,(0,o.zw)(s.siteEnabled?l.t("darkmode_enabled"):l.t("darkmode_disabled")),1)])])}var G=s(6995);s(541);function $(){let e=navigator.languages&&navigator.languages.length>0?navigator.languages[0]:navigator.language||navigator.userLanguage||"en";return e=e.toLowerCase(),e=e.replace(/-/,"_"),e.length>3&&(e=e.substring(0,3)+e.substring(3).toUpperCase()),e}function J(e){if(!e)return"";try{return new URL(e).hostname.toLowerCase()}catch(t){return e.split("/")[0].toLowerCase()}}function X(e){return e?e.split("/").pop():""}function ee(e){return e?e.split(".").pop():""}function te(e){let t=se(e);if(!t)return"";let s=new RegExp(".(com.cn|com|net.cn|net|org.cn|org|gov.cn|gov|cn|mobi|me|info|name|biz|cc|tv|asia|hk|网络|公司|中国)","g");return t.replace(s,"")}function se(e){try{let t="";const s=e?e.split("/"):"",a=s[2].split("."),i=[];i.unshift(a.pop());while(i.length<2)i.unshift(a.pop()),t=i.join(".");return t}catch(t){return""}}const ae={name:"DarkModeComp",props:["siteEnabled","darkmodeToggleStatus"],setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,G.QT)(),l=(0,i.f3)("global"),r=l.store,n=J(r.state.browserUrl),d=(0,c.qj)({browserUrl:r.state.browserUrl,isStayPro:r.state.isStayPro,hostName:n,darkmodeToggleStatus:e.darkmodeToggleStatus,siteEnabled:e.siteEnabled,darkmodeSettings:[{status:"on",name:a("darkmode_on"),isSelected:"on"===e.darkmodeToggleStatus},{status:"auto",name:a("darkmode_auto"),isSelected:"auto"===e.darkmodeToggleStatus},{status:"off",name:a("darkmode_off"),isSelected:"off"===e.darkmodeToggleStatus}]}),p=e=>{console.log("dakmodeSetingClick-----",e),d.darkmodeToggleStatus!==e&&(d.darkmodeToggleStatus=e,d.darkmodeSettings.forEach((t=>{t.status===e?t.isSelected=!0:t.isSelected=!1})),u())},u=()=>{d.darkmodeToggleStatus&&(console.log("state.darkmodeToggleStatus-----",d.darkmodeToggleStatus),l.browser.runtime.sendMessage({type:"popup",operate:"DARKMODE_SETTING",isStayAround:d.isStayPro?"a":"b",status:d.darkmodeToggleStatus,domain:d.hostName,enabled:d.siteEnabled},(e=>{})))},m=e=>{const t=e.target.checked;d.siteEnabled=t,u()};return{...(0,c.BK)(d),t:a,tm:o,dakmodeSetingClick:p,changeWebsiteAllowEnabled:m}}},ie=(0,b.Z)(ae,[["render",V],["__scopeId","data-v-10675384"]]),oe=ie,le={class:"popup-sniffer-wrapper"},re={key:0,class:"sniffer-video-box"},ne={class:"video-info"},de={class:"img-info"},ce={class:"video"},pe=["src"],ue={key:1,class:"no-img"},me={class:"info"},ge={class:"title"},be={class:"name"},we={class:"download"},ve=["onClick"],_e={class:"video-download-info"},ye={class:"label-txt"},fe={class:"folder select-options"},ke={class:"selected-text"},he=["onUpdate:modelValue","onChange"],Se=["name","value"],Te={class:"label-txt"},Ce={class:"quality select-options"},Me={class:"selected-text"},Le=["onUpdate:modelValue","onChange"],Ue=["name","value"],De={key:1,class:"sniffer-null"},xe={class:"null-title"},Ie={class:"desc-prompt"};function Pe(e,t,s,l,r,n){return(0,i.wg)(),(0,i.iD)("div",le,[e.videoList&&e.videoList.length?((0,i.wg)(),(0,i.iD)("div",re,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.videoList,((t,s)=>((0,i.wg)(),(0,i.iD)("div",{class:"sniffer-video",key:s},[(0,i._)("div",ne,[(0,i._)("div",de,[(0,i._)("div",ce,[t.poster?((0,i.wg)(),(0,i.iD)("img",{key:0,src:t.poster},null,8,pe)):((0,i.wg)(),(0,i.iD)("div",ue,[(0,i._)("span",null,(0,o.zw)(l.getDomain(t.hostUrl)),1)]))]),(0,i._)("div",me,[(0,i._)("div",ge,(0,o.zw)(l.getHostname(t.hostUrl)),1),(0,i._)("div",be,(0,o.zw)(t.title),1)])]),(0,i._)("div",we,[(0,i._)("div",{class:"btn",onClick:e=>l.downloadClickAction(t)},(0,o.zw)(l.t("download")),9,ve)])]),(0,i._)("div",_e,[(0,i._)("div",ye,(0,o.zw)(l.t("save_to_folder"))+" :",1),(0,i._)("div",fe,[(0,i._)("div",ke,(0,o.zw)(t.selectedFolderText),1),(0,i.wy)((0,i._)("select",{class:"select-container",ref_for:!0,ref:`folder_${s}`,"onUpdate:modelValue":e=>t.selectedFolder=e,onChange:e=>l.changeSelectFolder(s,e)},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.folderOptions,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{style:(0,o.j5)({display:e.id?"block":"none"}),name:e.name,key:t,value:e.uuid},(0,o.zw)(e.name),13,Se)))),128))],40,he),[[a.bM,t.selectedFolder]])]),t.qualityList&&t.qualityList.length?((0,i.wg)(),(0,i.iD)(i.HY,{key:0},[(0,i._)("div",Te,(0,o.zw)(l.t("quality"))+" :",1),(0,i._)("div",Ce,[(0,i._)("div",Me,(0,o.zw)(t.selectedQualityText),1),(0,i.wy)((0,i._)("select",{class:"select-container",ref_for:!0,ref:`quality_${s}`,"onUpdate:modelValue":e=>t.selectedQuality=e,onChange:e=>l.changeSelectQuality(s,e)},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(t.qualityList,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{key:t,name:e.qualityLabel,value:e.downloadUrl},(0,o.zw)(e.qualityLabel),9,Ue)))),128))],40,Le),[[a.bM,t.selectedQuality]])])],64)):(0,i.kq)("",!0)])])))),128))])):((0,i.wg)(),(0,i.iD)("div",De,[(0,i._)("div",xe,(0,o.zw)(l.t("sniffer_none")),1),(0,i._)("div",Ie,[(0,i.Uk)((0,o.zw)(l.t("sniffer_none_prompt"))+" ",1),(0,i._)("span",{class:"mail-to",onClick:t[0]||(t[0]=(...e)=>l.contactClick&&l.contactClick(...e))},(0,o.zw)(l.t("contact_us")),1)])]))])}const qe={name:"SnifferComp",props:["browserUrl"],setup(e,{emit:t,expose:s}){const{proxy:a}=(0,i.FN)(),{t:o,tm:l}=(0,G.QT)(),r=(0,i.f3)("global"),n=(0,c.qj)({selectedFolder:"",selectedFolderText:"",folderOptions:[{name:o("select_folder"),uuid:""},{name:"download_video",id:"1"},{name:"stay-download-video",id:"2"}],videoList:[]}),d=()=>{r.browser.runtime.sendMessage({from:"popup",operate:"fetchFolders"},(e=>{console.log("fetchSnifferFolder---response-----",e);try{e.body&&(n.folderOptions=[{name:o("select_folder"),uuid:""},...e.body],e.body.forEach((e=>{e.selected&&(n.selectedFolder=e.uuid,n.selectedFolderText=e.name)})),p())}catch(t){console.log(t)}}))};d();const p=()=>{r.browser.tabs.query({active:!0,currentWindow:!0},(e=>{let t={from:"popup",operate:"snifferFetchVideoInfo"};r.browser.tabs.sendMessage(e[0].id,t,(e=>{if(e.body&&e.body.videoInfoList&&e.body.videoInfoList.length){let t=e.body.videoInfoList;t.forEach((e=>{e.selectedFolder=n.selectedFolder,e.selectedFolderText=n.selectedFolderText,e.qualityList&&e.qualityList.length&&(e.selectedQuality=e.qualityList[0].downloadUrl,e.selectedQualityText=e.qualityList[0].qualityLabel)})),n.videoList=t}else n.videoList=[]}))}))},u=e=>{if(!e.selectedFolder)return void r.toast(o("select_folder"));e.selectedQuality&&(e.downloadUrl=e.selectedQuality);let t=[{title:e.title,downloadUrl:e.downloadUrl,poster:e.poster,hostUrl:J(e.hostUrl),uuid:e.selectedFolder}],s="stay://x-callback-url/snifferVideo?list="+encodeURIComponent(JSON.stringify(t));r.openUrlInSafariPopup(s)},m=(e,t)=>{const s=t.target;console.log(s),n.videoList.forEach(((t,a)=>{e==a&&(t.selectedFolder=s.value,t.selectedFolderText=s.options[s.selectedIndex].text)}))},g=(e,t)=>{const s=t.target;console.log(s,s.value,s.selectedIndex,s.options),n.videoList.forEach(((t,a)=>{e==a&&(t.selectedQuality=s.value,t.selectedQualityText=s.options[s.selectedIndex].text)}))},b=()=>{r.openUrlInSafariPopup(`mailto:feedback@fastclip.app?subject=${o("sniffer_none")}`)};return{...(0,c.BK)(n),t:o,tm:l,getDomain:te,getHostname:J,getFilenameByUrl:X,getLevel2domain:se,getFiletypeByUrl:ee,downloadClickAction:u,changeSelectQuality:g,changeSelectFolder:m,contactClick:b}}},ze=(0,b.Z)(qe,[["render",Pe],["__scopeId","data-v-d4cc1354"]]),Ee=ze,Ae={class:"popup-console-wrapper"},He={class:"console-header"},je={class:"console-time"},We={class:"console-name"},Fe={class:"console-con"},Ne={key:1};function Oe(e,t,s,a,l,r){return(0,i.wg)(),(0,i.iD)("div",Ae,[e.scriptConsole.length?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:0},(0,i.Ko)(e.scriptConsole,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["console-item","error"==e.msgType?"error-log":""]),key:t},[(0,i._)("div",He,[(0,i._)("div",je,(0,o.zw)(e.time),1),(0,i._)("div",We,(0,o.zw)(e.name),1)]),(0,i._)("div",Fe,(0,o.zw)(e.message),1)],2)))),128)):((0,i.wg)(),(0,i.iD)("div",Ne))])}s(7658);const Ke={name:"ConsolePusherComp",setup(e,{emit:t,expose:s}){const a=(0,i.f3)("global"),o=(0,c.qj)({scriptConsole:[]}),l=()=>{a.browser.runtime.sendMessage({from:"popup",operate:"fetchMatchedScriptLog"},(e=>{e&&e.body&&e.body.length>0?e.body.forEach((e=>{e.logList&&e.logList.length>0&&e.logList.forEach((t=>{let s=t.msgType?t.msgType:"log",a=t&&t.time?t.time:"",i={uuid:e.uuid,name:e.name,time:a,msgType:s,message:t.msg};o.scriptConsole.push(i)}))})):o.scriptConsole=[]}))};return l(),{...(0,c.BK)(o)}}},Re=(0,b.Z)(Ke,[["render",Oe],["__scopeId","data-v-0808f314"]]),Be=Re,Qe=e=>((0,i.dD)("data-v-47578202"),e=e(),(0,i.Cn)(),e),Ye={class:"upgrade-pro-warpper"},Ze=Qe((()=>(0,i._)("div",{class:"upgrade-img"},null,-1))),Ve={class:"what-con"};function Ge(e,t,s,a,l,r){return(0,i.wg)(),(0,i.iD)("div",Ye,[Ze,(0,i._)("div",{class:"upgrade-btn",onClick:t[0]||(t[0]=(...e)=>a.upgradeAction&&a.upgradeAction(...e))},(0,o.zw)(a.t("upgrade_pro")),1),(0,i._)("div",Ve,[(0,i.WI)(e.$slots,"default",{},void 0,!0)])])}const $e={name:"UpgradeProComp",setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,G.QT)(),l=(0,i.f3)("global"),r=(0,c.qj)({}),n=()=>{l.openUrlInSafariPopup("stay://x-callback-url/pay?")};return{...(0,c.BK)(r),t:a,tm:o,upgradeAction:n}}},Je=(0,b.Z)($e,[["render",Ge],["__scopeId","data-v-47578202"]]),Xe=Je,et={class:"popup-matched-wrapper"},tt={key:0,class:"matched-script-box"},st={class:"tab-wrapper"},at={class:"tab-text"},it={class:"tab-text"},ot={class:"matched-script-content"},lt={key:1,class:"null-data"},rt={class:"null-text"};function nt(e,t,s,a,l,r){const n=(0,i.up)("ScriptItem"),d=(0,i.up)("RegisterMenuItem");return(0,i.wg)(),(0,i.iD)("div",et,[e.scriptStateList&&e.scriptStateList.length?((0,i.wg)(),(0,i.iD)("div",tt,[(0,i._)("div",st,[(0,i._)("div",{class:(0,o.C_)(["tab activated",{active:"activated"==e.showTab}]),onClick:t[0]||(t[0]=e=>a.tabACtion("activated"))},[(0,i._)("div",at,(0,o.zw)(a.t("state_actived")),1)],2),(0,i._)("div",{class:(0,o.C_)(["tab stopped",{active:"stopped"==e.showTab}]),onClick:t[1]||(t[1]=e=>a.tabACtion("stopped"))},[(0,i._)("div",it,(0,o.zw)(a.t("state_stopped")),1)],2)]),(0,i._)("div",ot,["activated"==e.showTab?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:0},(0,i.Ko)(e.activatedScriptList,((t,s)=>((0,i.wg)(),(0,i.j4)(n,{key:s,tabState:e.showTab,scriptItem:t,onHandleState:a.handleState,onHandleWebsiteDisabled:a.handleWebsiteDisabled,onHandleWebsite:a.handleWebsite,onHandleRegisterMenu:a.handleRegisterMenu},null,8,["tabState","scriptItem","onHandleState","onHandleWebsiteDisabled","onHandleWebsite","onHandleRegisterMenu"])))),128)):(0,i.kq)("",!0),"stopped"==e.showTab?((0,i.wg)(!0),(0,i.iD)(i.HY,{key:1},(0,i.Ko)(e.stoppedScriptList,((e,t)=>((0,i.wg)(),(0,i.j4)(n,{key:t,scriptItem:e,onHandleState:a.handleState,onHandleWebsiteDisabled:a.handleWebsiteDisabled,onHandleWebsite:a.handleWebsite,onHandleRegisterMenu:a.handleRegisterMenu},null,8,["scriptItem","onHandleState","onHandleWebsiteDisabled","onHandleWebsite","onHandleRegisterMenu"])))),128)):(0,i.kq)("",!0)])])):((0,i.wg)(),(0,i.iD)("div",lt,[(0,i._)("div",rt,(0,o.zw)(a.t("null_scripts")),1),(0,i._)("div",{class:"install-more",onClick:t[2]||(t[2]=e=>a.installMoreUserscript())},(0,o.zw)(a.t("install_more")),1)])),e.showMenu?((0,i.wg)(),(0,i.j4)(d,{key:2,registerMenu:e.registerMenuMap[e.uuid],onCloseMenuPopup:a.closeMenuPopup},null,8,["registerMenu","onCloseMenuPopup"])):(0,i.kq)("",!0)])}const dt=s.p+"img/stop-icon.png",ct=s.p+"img/start-icon.png",pt={class:"script-item-box"},ut={key:0,class:"script-icon"},mt=["src"],gt={class:"state"},bt={key:0,src:dt,alt:""},wt={key:1,src:ct,alt:""},vt={class:"author overflow"},_t={class:"desc overflow"},yt={class:"website-cell"},ft={class:"select-options"},kt={class:"selected-text"},ht=["value"],St={class:"action-cell"};function Tt(e,t,s,l,r,n){return(0,i.wg)(),(0,i.iD)("div",pt,[(0,i._)("div",{class:(0,o.C_)(["script-item",{disabled:e.script.disableChecked}])},[(0,i._)("div",{class:(0,o.C_)(["script-info",e.script.active?"activated":"stopped"]),style:(0,o.j5)({paddingLeft:e.script.iconUrl?"60px":"0px"})},[e.script.iconUrl?((0,i.wg)(),(0,i.iD)("div",ut,[(0,i._)("img",{src:e.script.iconUrl},null,8,mt)])):(0,i.kq)("",!0),((0,i.wg)(),(0,i.iD)("div",{class:"active-state",key:e.script.uuid,onClick:t[0]||(t[0]=t=>l.activeStateClick(e.script))},[(0,i._)("div",gt,[e.script.active?((0,i.wg)(),(0,i.iD)("img",bt)):((0,i.wg)(),(0,i.iD)("img",wt))])])),(0,i._)("div",vt,(0,o.zw)(e.script.author+"@"+e.script.name),1),(0,i._)("div",_t,(0,o.zw)(e.script.description),1)],6),(0,i._)("div",yt,[(0,i._)("div",{class:(0,o.C_)(["check-box",{active:e.script.disableChecked}])},[(0,i.wy)((0,i._)("input",{ref:e.script.uuid,"onUpdate:modelValue":t[1]||(t[1]=t=>e.script.disableChecked=t),onChange:t[2]||(t[2]=t=>l.changeWebsiteDisabled(e.script.uuid,t)),type:"checkbox",class:"allow"},null,544),[[a.e8,e.script.disableChecked]])],2),(0,i._)("div",{class:"website",onClick:t[3]||(t[3]=t=>l.disabledUrlClick(e.script.uuid))},(0,o.zw)(l.t("disable_website")),1),(0,i._)("div",ft,[(0,i._)("div",kt,(0,o.zw)(e.website),1),(0,i.wy)((0,i._)("select",{class:"select-container","onUpdate:modelValue":t[4]||(t[4]=t=>e.script.disabledUrl=t),onChange:t[5]||(t[5]=t=>l.changeSelectWebsite(e.script.uuid,t))},[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.websiteList,((e,t)=>((0,i.wg)(),(0,i.iD)("option",{key:t,value:e.disabledUrl},(0,o.zw)(e.website),9,ht)))),128))],544),[[a.bM,e.script.disabledUrl]])])]),(0,i._)("div",St,[e.script.grants.length&&(e.script.grants.includes("GM.registerMenuCommand")||e.script.grants.includes("GM_registerMenuCommand"))?((0,i.wg)(),(0,i.iD)("div",{key:0,class:"cell-icon menu",onClick:t[6]||(t[6]=t=>l.showRegisterMenu(e.script.uuid,e.script.active))},(0,o.zw)(l.t("menu")),1)):(0,i.kq)("",!0),(0,i._)("div",{class:"cell-icon open-app",onClick:t[7]||(t[7]=t=>l.openInAPP(e.script.uuid))},(0,o.zw)(l.t("open_app")),1),e.script.active?(0,i.kq)("",!0):((0,i.wg)(),(0,i.iD)("div",{key:1,class:"cell-icon manually",onClick:t[8]||(t[8]=t=>l.runManually(e.script.uuid,e.script.name))},(0,o.zw)(l.t("run_manually")),1))])],2)])}const Ct={name:"ScriptItemComp",props:["scriptItem"],components:{},setup(e,{emit:t,expose:s}){const{proxy:a}=(0,i.FN)(),{t:o,tm:l}=(0,G.QT)(),r=(0,i.f3)("global"),n=r.store,d=J(n.state.browserUrl),p=(new URL(n.state.browserUrl).origin,/^\*[://]*.+[/]\*$/g),u=(0,c.qj)({browserUrl:n.state.browserUrl,script:{...e.scriptItem,disableChecked:!!e.scriptItem.disabledUrl,disabledUrl:e.scriptItem.disabledUrl?e.scriptItem.disabledUrl:`*://${d}/*`},hostName:d,website:e.scriptItem.disabledUrl?p.test(e.scriptItem.disabledUrl)?d:e.scriptItem.disabledUrl:d,websiteList:[{website:d,disabledUrl:`*://${d}/*`},{disabledUrl:n.state.browserUrl,website:n.state.browserUrl}],showMenu:!1}),m=e=>{if(e.disableChecked)return;let s=e.uuid,a=e.active;s&&""!=s&&"string"==typeof s&&(r.browser.runtime.sendMessage({from:"popup",operate:"setScriptActive",uuid:s,active:!a},(e=>{})),u.script.active=!a,g(),t("handleState",s,!a))},g=()=>{r.browser.runtime.sendMessage({from:"popup",operate:"refreshTargetTabs"})},b=e=>{a.$refs[e].dispatchEvent(new MouseEvent("click"))},w=(e,s)=>{const a=s.target,i=a.value;u.script.disabledUrl=i,u.website=a.options[a.selectedIndex].text,_(e),t("handleWebsite",e,i)},v=(e,s)=>{const a=s.target.checked;u.script.disableChecked=a,_(e),t("handleWebsiteDisabled",e,a)},_=e=>{u.websiteList.forEach((t=>{let s=!1;u.script.disableChecked&&u.script.disabledUrl==t.disabledUrl&&(s=!0),r.browser.runtime.sendMessage({from:"popup",operate:"setDisabledWebsites",on:s,uuid:e,website:t.disabledUrl},(e=>{console.log("setDisabledWebsites response,",e)}))}))},y=e=>{let t="stay://x-callback-url/userscript?id="+e;r.openUrlInSafariPopup(t)},f=(e,s)=>{s?(r.browser.runtime.sendMessage({from:"popup",uuid:e,operate:"fetchRegisterMenuCommand"}),t("handleRegisterMenu",e)):r.toast(o("toast_keep_active"))},k=(e,t)=>{e&&""!=e&&"string"==typeof e&&(r.browser.runtime.sendMessage({from:"popup",operate:"exeScriptManually",uuid:e},(e=>{console.log("exeScriptManually response,",e)})),r.toast({title:t,subTitle:o("run_manually")}))};return{...(0,c.BK)(u),t:o,tm:l,activeStateClick:m,disabledUrlClick:b,changeSelectWebsite:w,changeWebsiteDisabled:v,showRegisterMenu:f,runManually:k,openInAPP:y}}},Mt=(0,b.Z)(Ct,[["render",Tt],["__scopeId","data-v-d262eac0"]]),Lt=Mt,Ut={class:"popup-menu-wrapper"},Dt={class:"register-menu-warpper"},xt={class:"register-menu"},It={class:"menu-close"},Pt={class:"menu-item-box"},qt={key:0,class:"menu-content"},zt=["onClick"],Et={key:1,class:"menu-content none-menu"};function At(e,t,s,l,r,n){const d=(0,i.up)("DaisyLoading");return(0,i.wg)(),(0,i.j4)(a.uT,{name:"show"},{default:(0,i.w5)((()=>[(0,i._)("div",Ut,[e.loading?((0,i.wg)(),(0,i.j4)(d,{key:0,style:{position:"absolute",top:"2px",right:"16px"},size:.2},null,8,["size"])):(0,i.kq)("",!0),(0,i._)("div",Dt,[(0,i._)("div",xt,[(0,i._)("div",It,[(0,i._)("div",{class:"close",onClick:t[0]||(t[0]=(...e)=>l.closeMenuPopup&&l.closeMenuPopup(...e))},(0,o.zw)(l.t("menu_close")),1)]),(0,i._)("div",Pt,[e.registerMenuList.length?((0,i.wg)(),(0,i.iD)("div",qt,[((0,i.wg)(!0),(0,i.iD)(i.HY,null,(0,i.Ko)(e.registerMenuList,((e,t)=>((0,i.wg)(),(0,i.iD)("div",{class:"menu-item",key:t,onClick:t=>l.handleRegisterMenuClickAction(e.id,e.uuid)},(0,o.zw)(e.caption),9,zt)))),128))])):((0,i.wg)(),(0,i.iD)("div",Et,(0,o.zw)(l.t("null_register_menu")),1))])])])])])),_:1})}const Ht=(0,i.uE)('<div class="line1" data-v-35472348></div><div class="line2" data-v-35472348></div><div class="line3" data-v-35472348></div><div class="line4" data-v-35472348></div><div class="line5" data-v-35472348></div><div class="line6" data-v-35472348></div><div class="line7" data-v-35472348></div><div class="line8" data-v-35472348></div><div class="line9" data-v-35472348></div><div class="line10" data-v-35472348></div><div class="line11" data-v-35472348></div><div class="line12" data-v-35472348></div>',12),jt=[Ht];function Wt(e,t,s,a,l,r){return(0,i.wg)(),(0,i.iD)("div",{class:(0,o.C_)(["__loading-warpper",e.props.class]),style:(0,o.j5)(e.props.style)},[(0,i._)("div",{class:"__loading-con",style:(0,o.j5)({zoom:s.size})},jt,4)],6)}const Ft={name:"DaisyLoadingComp",props:["class","style","size"],setup(e,t){const s=(0,c.qj)({size:e.size||.2,props:e});return{...(0,c.BK)(s)}}},Nt=(0,b.Z)(Ft,[["render",Wt],["__scopeId","data-v-35472348"]]),Ot=Nt,Kt={name:"MenuItemComp",components:{DaisyLoading:Ot},props:["registerMenu"],setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,G.QT)(),l=(0,i.f3)("global"),r=(0,c.qj)({loading:!0,registerMenuList:e.registerMenu||[]});(0,i.YP)(e,(e=>{e.registerMenu&&(r.registerMenuList=e.registerMenu,r.loading=!1)}),{immediate:!0,deep:!0});const n=(e,t)=>{console.log(e),l.browser.runtime.sendMessage({from:"popup",operate:"execRegisterMenuCommand",id:e,uuid:t},(e=>{e.id&&e.uuid&&window.close()})),d()},d=()=>{t("closeMenuPopup")};return{...(0,c.BK)(r),t:a,tm:o,handleRegisterMenuClickAction:n,closeMenuPopup:d}}},Rt=(0,b.Z)(Kt,[["render",At],["__scopeId","data-v-4e1e5222"]]),Bt=Rt,Qt={name:"MatchedScriptComp",components:{ScriptItem:Lt,RegisterMenuItem:Bt},setup(e,{emit:t,expose:s}){const{t:a,tm:o}=(0,G.QT)(),l=(0,i.f3)("global"),r=l.store,n=(0,c.qj)({browserUrl:r.state.browserUrl,showTab:"activated",scriptStateList:[],activatedScriptList:[],stoppedScriptList:[],showMenu:!1,uuid:"",registerMenuMap:{}}),d=e=>{n.showTab=e,p()},p=()=>{n.stoppedScriptList=n.stoppedScriptList.filter((e=>{if(!e.active)return e;n.activatedScriptList.push(e)})),n.activatedScriptList=n.activatedScriptList.filter((e=>{if(e.active)return e;n.stoppedScriptList.push(e)}))},u=()=>{l.browser.runtime.sendMessage({from:"bootstrap",operate:"fetchScripts",url:n.browserUrl,digest:"yes"},(e=>{try{n.scriptStateList=e.body,n.activatedScriptList=[],n.stoppedScriptList=[],n.scriptStateList.forEach((e=>{e.active?n.activatedScriptList.push(e):n.stoppedScriptList.push(e)}))}catch(t){console.log(t)}}))},m=()=>{n.browserUrl?u():l.browser.tabs.getSelected(null,(e=>{n.browserUrl=e.url,r.commit("setBrowserUrl",n.browserUrl),u()}))};m();const g=(e,t,{type:s,value:a})=>{e.forEach((e=>{e.uuid===t&&("website"===s?e.disabledUrl=a:"active"===s?e.active=a:"disabledUrl"===s&&(e.disableChecked=a))}))},b=(e,t)=>{"activated"==n.showTab?g(n.activatedScriptList,e,{type:"active",value:t}):g(n.stoppedScriptList,e,{type:"active",value:t}),g(n.scriptStateList,e,{type:"active",value:t})},w=(e,t)=>{"activated"==n.showTab?g(n.activatedScriptList,e,{type:"website",value:t}):g(n.stoppedScriptList,e,{type:"website",value:t}),g(n.scriptStateList,e,{type:"website",value:t})},v=(e,t)=>{"activated"==n.showTab?g(n.activatedScriptList,e,{type:"disabledUrl",value:t}):g(n.stoppedScriptList,e,{type:"disabledUrl",value:t}),g(n.scriptStateList,e,{type:"disabledUrl",value:t})},_=e=>{n.uuid=e,n.showMenu=!0},y=()=>{n.showMenu=!1,n.uuid=""};l.browser.runtime.onMessage.addListener(((e,t,s)=>{const a=e.from,i=e.operate;return"content"==a&&"giveRegisterMenuCommand"==i&&(n.uuid=e.uuid,n.registerMenuMap[n.uuid]=e.data),!0}));const f=()=>{let e="https://stayfork.app";window.open(e)};return{...(0,c.BK)(n),t:a,tm:o,tabACtion:d,handleState:b,handleWebsite:w,handleWebsiteDisabled:v,handleRegisterMenu:_,closeMenuPopup:y,installMoreUserscript:f}}},Yt=(0,b.Z)(Qt,[["render",nt],["__scopeId","data-v-78a47a07"]]),Zt=Yt,Vt={name:"popupView",components:{Header:v,TabMenu:F,ConsolePusher:Be,Sniffer:Ee,DarkMode:oe,UpgradePro:Xe,MatchedScript:Zt},setup(e,{emit:t,attrs:s,slots:a}){const{t:o,tm:l,locale:r}=(0,G.QT)(),n=(0,i.f3)("global"),d=n.store,p=d.state.localeLan;r.value=d.state.localeLan;const u=(0,c.qj)({selectedTab:d.state.selectedTab,localLan:p,browserUrl:"",isStayPro:d.state.isStayPro,darkmodeToggleStatus:"on",siteEnabled:!0}),m=e=>{u.selectedTab=e,d.commit("setSelectedTab",u.selectedTab)};n.browser.runtime.onMessage.addListener(((e,t,s)=>{const a=e.from,i=e.operate;return"background"===a&&"giveDarkmodeConfig"==i&&(u.isStayPro="a"==e.isStayAround,d.commit("setIsStayPro",u.isStayPro),u.darkmodeToggleStatus=e.darkmodeToggleStatus,u.siteEnabled=e.enabled),!0}));const g=()=>{n.browser.tabs.getSelected(null,(e=>{u.browserUrl=e.url,d.commit("setBrowserUrl",u.browserUrl)})),n.browser.runtime.sendMessage({type:"popup",operate:"FETCH_DARKMODE_CONFIG"},(e=>{}))};return g(),{...(0,c.BK)(u),t:o,tm:l,setTabName:m}}},Gt=(0,b.Z)(Vt,[["render",d]]),$t=Gt;var Jt=s(8874),Xt=s(2415);const es={namespaced:!0,state:()=>({name:""}),mutations:{SET_NAME:(e,t)=>{e.name=t}},actions:{setName:({commit:e},t)=>{e("SET_NAME",t)}}},ts=(0,Jt.MT)({state:{localeLan:$().indexOf("zh_")>-1?"zh":"en",staySwitch:"start",isStayPro:!1,browserUrl:"",selectedTab:{id:1,name:"matched_scripts_tab"}},getters:{localLanGetter:e=>e.localeLan,staySwitchGetter:e=>e.staySwitch,isStayProGetter:e=>e.isStayPro,browserUrlGetter:e=>e.browserUrl,selectedTabGetter:e=>e.selectedTab},mutations:{setLocalLan:(e,t)=>{e.localeLan=t},setStaySwitch:(e,t)=>{e.staySwitch=t},setIsStayPro:(e,t)=>{e.isStayPro=t},setBrowserUrl:(e,t)=>{e.browserUrl=t},setSelectedTab:(e,t)=>{e.selectedTab=t}},actions:{setLocalLanAsync:({commit:e},t)=>{e("setLocalLan",t)},setStaySwitchAsync:({commit:e},t)=>{e("setStaySwitch",t)},setIsStayProAsync:({commit:e},t)=>{e("setIsStayPro",t)},setrowserUrlAsync:({commit:e},t)=>{e("setBrowserUrl",t)},setSelectedTabAsync:({commit:e},t)=>{e("setSelectedTab",t)}},modules:{moudleA:es},plugins:[(0,Xt.Z)({storage:window.localStorage,key:"stay-popup-vuex-store-persistence",paths:["moudleA","staySwitch","selectedTab","isStayPro"]})]}),ss={en:{matched_scripts_tab:"Matched",console_tab:"Console",darkmode_tab:"Dark Mode",state_actived:"Activated",state_manually:"Manually Executed",state_stopped:"Stopped",null_scripts:"No available scripts were matched",null_register_menu:"No register menu item",menu_close:"Close",toast_keep_active:"Please keep the script activated",run_manually:"RUN MANUALLY",upgrade_pro:"Upgrade to Stay Pro",darkmode_off:"Off",darkmode_auto:"Auto",darkmode_on:"On",darkmode_enabled:"Enabled for current website",darkmode_disabled:"Disabled for current website",download_text:"User script manager",downloader_tab:"Downloader",sniffer_none:"No videos found",sniffer_none_prompt:"Unable to get video on current site?",contact_us:"Contact Us",download:"DOWNLOAD",save_to_folder:"Save to folder",quality:"Quality",select_folder:"Select Folder",disable_website:"Disable on this website",menu:"MENU",open_app:"OPEN IN APP",install_more:"Install more userscripts from Stay Fork",what_downloader:"What is a downloader?",what_darkmode:"What is a dark mode?"},zh:{matched_scripts_tab:"已匹配脚本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"已激活",state_manually:"手动执行",state_stopped:"已停止",null_scripts:"未匹配到可用脚本",null_register_menu:"无注册菜单项",menu_close:"关闭",toast_keep_active:"请保持脚本处于激活状态",run_manually:"手动执行",upgrade_pro:"升级Stay专业版",darkmode_off:"关",darkmode_auto:"自动",darkmode_on:"开",darkmode_enabled:"启用当前网站",darkmode_disabled:"禁用当前网站",download_text:"用户脚本管理",downloader_tab:"下载器",sniffer_none:"没有发现视频",sniffer_none_prompt:"无法获取当前站点上的视频？",contact_us:"联系我们",download:"下载",save_to_folder:"保存到文件夹",quality:"画质",select_folder:"选择文件夹",disable_website:"在此网站上禁用",menu:"菜单",open_app:"在应用里打开",install_more:"从Stay Fork安装更多用户脚本",what_downloader:"什么是下载器？",what_darkmode:" 什么是暗黑模式？"},zh_HK:{matched_scripts_tab:"已匹配腳本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"已激活",state_manually:"手動執行",state_stopped:"已停止",null_scripts:"未匹配到可用腳本",null_register_menu:"無註冊菜單項",menu_close:"關閉",toast_keep_active:"請保持腳本處於激活狀態",run_manually:"手動執行",upgrade_pro:"升級Stay專業版",darkmode_off:"關",darkmode_auto:"自動",darkmode_on:"開",darkmode_enabled:"啟用當前網站",darkmode_disabled:"禁用當前網站",download_text:"用戶腳本管理",downloader_tab:"下載器",sniffer_none:"沒有發現視頻",sniffer_none_prompt:"無法獲取當前站點上的視頻？",contact_us:"联系我们",download:"下載",save_to_folder:"保存到文件夾",quality:"畫質",select_folder:"選擇文件夾",disable_website:"在此網站上禁用",menu:"菜單",open_app:"在應用裡打開",install_more:"從Stay Fork安裝更多用戶腳本",what_downloader:"什麼是下載器？",what_darkmode:" 什麼是暗黑模式？"}},as=(0,G.o)({fallbackLocale:"ch",globalInjection:!0,allowComposition:!0,legacy:!1,locale:"en",messages:ss}),is=as,os={class:"m-notice"},ls=["innerHTML"],rs=["innerHTML"];function ns(e,t,s,o,l,r){return(0,i.wg)(),(0,i.j4)(a.uT,{name:"show"},{default:(0,i.w5)((()=>[(0,i.wy)((0,i._)("div",os,[(0,i._)("div",{class:"m-msg",innerHTML:s.title},null,8,ls),s.subTitle?((0,i.wg)(),(0,i.iD)("div",{key:0,class:"m-msg",innerHTML:s.subTitle},null,8,rs)):(0,i.kq)("",!0)],512),[[a.F8,e.showNotice]])])),_:1})}const ds={name:"ToastComp",props:{title:{type:String,default:"加载中..."},subTitle:{type:String}},setup(){const e=(0,c.qj)({showNotice:!1});return(0,i.bv)((()=>{e.showNotice=!0})),{...(0,c.BK)(e)}}},cs=(0,b.Z)(ds,[["render",ns],["__scopeId","data-v-5dd969de"]]),ps=cs,us=document.createElement("div");document.body.appendChild(us);let ms=null;const gs=e=>{let t,s,o;"string"!==typeof e&&"undefined"!==typeof e&&e?(s=e.subTitle,t=e.title||"加载中...",o=e.duration||3500):(s="",t=e||"加载中...",o=3500);const l=(0,i.Wm)(ps,{title:t,subTitle:s});(0,a.sY)(l,us),clearTimeout(ms),ms=setTimeout((()=>{(0,a.sY)(null,us)}),o)};let bs;"undefined"!==typeof window.browser&&(bs=window.browser),"undefined"!==typeof window.chrome&&(bs=window.chrome);const ws=bs,vs=(0,a.ri)($t),_s=e=>{document.body.addEventListener("click",(t=>{e(t)}))},ys=(e,t="")=>{ws.tabs.query({active:!0,currentWindow:!0},(a=>{let i={from:"popup",operate:"windowOpen",openUrl:e,target:t};s.g.browser.tabs.sendMessage(a[0].id,i,(e=>{}))})),window.close()};if(vs.provide("global",{store:ts,browser:ws,toast:gs,globalClick:_s,openUrlInSafariPopup:ys}),vs.use(is).use(ts).mount("#app"),!navigator.userAgent.match(/(iPhone|iPod|Android|ios|iOS|Backerry|WebOS|Symbian|Windows Phone|Phone)/i)){document.body.style.height="480px",document.body.style.width="400px";let e=document.querySelectorAll(".popup-fotter-wrapper .fotter-box .tab-item .tab-img");e.forEach((e=>{e.style.top=0}))}}},t={};function s(a){var i=t[a];if(void 0!==i)return i.exports;var o=t[a]={exports:{}};return e[a](o,o.exports,s),o.exports}s.m=e,(()=>{var e=[];s.O=(t,a,i,o)=>{if(!a){var l=1/0;for(c=0;c<e.length;c++){a=e[c][0],i=e[c][1],o=e[c][2];for(var r=!0,n=0;n<a.length;n++)(!1&o||l>=o)&&Object.keys(s.O).every((e=>s.O[e](a[n])))?a.splice(n--,1):(r=!1,o<l&&(l=o));if(r){e.splice(c--,1);var d=i();void 0!==d&&(t=d)}}return t}o=o||0;for(var c=e.length;c>0&&e[c-1][2]>o;c--)e[c]=e[c-1];e[c]=[a,i,o]}})(),(()=>{s.n=e=>{var t=e&&e.__esModule?()=>e["default"]:()=>e;return s.d(t,{a:t}),t}})(),(()=>{s.d=(e,t)=>{for(var a in t)s.o(t,a)&&!s.o(e,a)&&Object.defineProperty(e,a,{enumerable:!0,get:t[a]})}})(),(()=>{s.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()})(),(()=>{s.o=(e,t)=>Object.prototype.hasOwnProperty.call(e,t)})(),(()=>{s.j=42})(),(()=>{s.p=""})(),(()=>{var e={42:0};s.O.j=t=>0===e[t];var t=(t,a)=>{var i,o,l=a[0],r=a[1],n=a[2],d=0;if(l.some((t=>0!==e[t]))){for(i in r)s.o(r,i)&&(s.m[i]=r[i]);if(n)var c=n(s)}for(t&&t(a);d<l.length;d++)o=l[d],s.o(e,o)&&e[o]&&e[o][0](),e[o]=0;return s.O(c)},a=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];a.forEach(t.bind(null,0)),a.push=t.bind(null,a.push.bind(a))})();var a=s.O(void 0,[998],(()=>s(3366)));a=s.O(a)})();