(()=>{"use strict";var e={340:(e,A,t)=>{var o=t(9242),a=t(3396),s=t(7139);const r={class:"stay-popup-warpper"},l=(0,a._)("div",{class:"hide-temp"},"hello Stay",-1),n={class:"tab-content"},i={key:0,class:"matched-script"};function d(e,A,t,o,d,c){const p=(0,a.up)("Header"),u=(0,a.up)("DarkMode"),b=(0,a.up)("Sniffer"),w=(0,a.up)("UpgradePro"),g=(0,a.up)("ConsolePusher"),m=(0,a.up)("TabMenu");return(0,a.wg)(),(0,a.iD)("div",r,[l,(0,a.Wm)(p,null,{default:(0,a.w5)((()=>[(0,a.Uk)((0,s.zw)(o.t(e.selectedTab.name)),1)])),_:1}),(0,a._)("div",n,[1==e.selectedTab.id?((0,a.wg)(),(0,a.iD)("div",i," 匹配脚本 ")):(0,a.kq)("",!0),2==e.selectedTab.id||3==e.selectedTab.id?((0,a.wg)(),(0,a.iD)(a.HY,{key:1},[2==e.selectedTab.id?((0,a.wg)(),(0,a.j4)(u,{key:0})):(0,a.kq)("",!0),3==e.selectedTab.id?((0,a.wg)(),(0,a.j4)(b,{key:1,browserUrl:e.browserRunUrl},null,8,["browserUrl"])):((0,a.wg)(),(0,a.j4)(w,{key:2}))],64)):(0,a.kq)("",!0),4==e.selectedTab.id?((0,a.wg)(),(0,a.j4)(g,{key:2})):(0,a.kq)("",!0)]),(0,a.Wm)(m,{tabId:e.selectedTab.id,onSetTabName:o.setTabName},null,8,["tabId","onSetTabName"])])}var c=t(4870);const p={class:"popup-header-wrapper"},u={class:"header-content"};function b(e,A,t,o,r,l){return(0,a.wg)(),(0,a.iD)("div",p,[(0,a._)("div",{class:"stay-icon",onClick:A[0]||(A[0]=(...e)=>o.clickStayAction&&o.clickStayAction(...e))}),(0,a._)("div",u,[(0,a.WI)(e.$slots,"default",{},void 0,!0)]),(0,a._)("div",{class:(0,s.C_)(["stay-switch",e.staySwitch]),onClick:A[1]||(A[1]=A=>o.clickStaySwitchAction(e.staySwitch))},null,2)])}const w={name:"headerComp",setup(e,{emit:A,expose:t}){const o=(0,a.f3)("global"),s=o.store,r=(0,c.qj)({staySwitch:s.state.staySwitch}),l=()=>{window.open("stay://")},n=e=>{r.staySwitch="start"==e?"cease":"start",s.commit("setStaySwitch",r.staySwitch)};return{...(0,c.BK)(r),clickStayAction:l,clickStaySwitchAction:n}}};var g=t(89);const m=(0,g.Z)(w,[["render",b],["__scopeId","data-v-66dae47e"]]),y=m,v="data:image/png;base64,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",f="data:image/png;base64,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",k="data:image/png;base64,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",D="data:image/png;base64,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",B="data:image/png;base64,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",h="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADkAAABCCAYAAADt/X6HAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAOaADAAQAAAABAAAAQgAAAAA5k1t+AAAFy0lEQVRoBe1aX2wURRifb6+1F2r9U4VWbJVYICU1KkGT+mJIjE8+qA/b+wMtZyE+aC7ERLEqJE38Az75UIHEGAm0vdLbPuiDUYkI9MWYaDQ+GL0ipiYqoiYSjOV6tzv+psdyN7u393+XLLlJ2p35/sz3/eabmZ359oh5XIaHh9vTaSMKs0tdXZ3axMRE2m0XyG0Dhf2HwyObdT1zijN2c45OF4gFBjVt8udCuUbXlUZ3WKo/w8juyQMUknwNY/ruUjqN4HkKEgB7rU4Xo1ll6m17C5Jz2/IgZqfVC8qq7ylIq3Gv2k2QXo2023aakXR7hL3qvxlJr0babTvNSLo9wl7134ykVyPtth3bWbKUwfHxcSWVSvUaRmA150ZVuqJf3TDeg9LdjFGCE2/DsVUlYl8pRC+VsluMR6TwQMA4PzU19SsR4ZzvXMo6qqrbopzxIQhuYMTu4ZwHnbsrx6FFYl2bNO3tJSEpLtCX09kU52xtOU1nPv2HK9tZAF1gXDmiaVMfWWUdQUYiOwYy2eV3oLDVqlRrG8b2atrMG4X6Q0PR1wzO9xbS6qvThze0st2JRGLR7KfoxqOq2x8DwG8htNUUbMyz5Ysi/RSjFRGrlMSfWM6w71U1+oCpYQMZj8fbGDMOQaDFFPLfk6/C0jqMpbUyU20gf//j7zGswfX+AyZ7DICDodD2XYIqgRTIifMXZHH/trDWx2wgI5HRHuzFN/oXluw5Xk/rYrFYUIokY8sbZTF/tzAzlXSa90kgDQPvwuusZLPZjTJIxm0pQ79jxibTK4EkTlLb7wCF/wbOf9cdqGKBaYIsNiqlaMToaxwx/i0lUw0PfV1En+J4WVdpSCRxA/gLX6f6NS3xIGMdPbg6vV6XV7hWAODLjN3agz43t7a03l/P4DUEJFwSV5wfBTBNe/diMpnYB6Cv1gpUISWO28oBTTu0MitmZo59h/3jWM391apo0dMtbQagbzKitwrpuOQiIHLB+1qmkfJKMjl9UJZCaHFLt9IqbTcmksR3jY6OdliNziUTY1hTh026rlO7WTefOHpdpRFTDswlp/ebPPOpqrFuHDdHzXa1z4aAxCjffunS5U9V9ZkrX5DzbiAqzwHopKDgxXxTnpOrGaTnaEQHNW0a61AuOYDpzxDLVTKn8lZDQApzuJ49jI31pKru7Cw0n8u/PPk05uQnGAxbtBVOHeDNabPT8UI9UVfVkTsZpc+gOmDlVdNuGEhhFEC34PcOp5G7wWfyfNG0Ib29vS2CWJ7PU80a/yUYbIlZk1HhcGwdZ9l55H/qvjRIix5Jq/2cGSt3MNOF2p70Q0sg+Ojx4+//Vos+0i/rGemfA2D9Z2lFeb6hkcwD4v26sTQfjUaRfqyuhELDmzDQIoL1A7xi2iWQYstnfZkMmw+FdvRVCjMSGblPN/TT0L6jUp1K5FwDKYxjjd5l8OX5SCTSX84ZZNe2ZLOZU9CS1nM5vUr4roIUDiCiazNZOiOi5OSQqkawM/OTeBdKO7OTfLV010HmHOJrRJTC4WGcbeWC5PIjoJwAQNs7VpasveURSDF1WSfWG96j+OyArKD4wxTdaXD2MXiuJs88TSADGE43fFod2ibOpgHUbYeD2uPlrOkpyLwb/JZ83f2aZ9PVfSjOFpogncfGX5xmJP0VL2dvm5F0Hht/caRIIj2R9pf75b0lg6clkMilnSuv5i8JJMrOSSADjFL+glDeW84DKQlkW1tgobyaryTSAwN9i1KOR7iPm8GiuOz6Coqzs1/OaTODUiSFLNLxLzrr+IuDTxV7hMc2kMnkVBJQT/gLThFviR3Fp4r5oiAFMaC0Pous99kiqn4hfUM8eHVG2iIpUMzOHv2pu/u2ezF392HRrvzYzx/o6B8EJ07sqYc07cifps+2jcdkmE+RO13W+eMKZxuQlBK/lMQvRGi1yb9mT6QZREYe/xbg0wJ+DLoQDAY+mJycvHDNfGoadnkE/gd0lbPek8AUQwAAAABJRU5ErkJggg==",S="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA2CAYAAACbZ/oUAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAPKADAAQAAAABAAAANgAAAADBb/H9AAAEnElEQVRoBe2ab2hbVRTAz3kvyRo2Nh1TaV3+tcNRRBEp+AemVLRNIqII/vkyB6KwD4qirP0k7Gvaumllik4cKk6k4qcR44riwDmGKw6qw25pmjaZCzhccdMxkveO54W+kLWvL+8l9/UlXR+Ud3veveec3z333nfPfYFkZPYn/nuCiBBugAuT4SxpnEz7B0nSMEiBL+JpvLZa2SvAOiACXuAeeNd/08YPe0/fPK/LV8t9CXAFDOEylz8C2fNOPL01X5G3eGF54AUwRCgS4JdelEYeywQmW5wXagJXA/I8T4JHHo6lAz9Wy1upbAu4AoZ4iuGHoj3Bb3AMlYq8BQr1AVfAMIMSvr3pNjz04InA1Yq4iQsNAi+QIV4Egvf8Pu/7vWc7LjYxr705XBsE/wPET3xe2v/o2VCmdv2VryEmwkv85nmN8LUswXD/dGhiyWMXBZKE+AJH5TexPpAMRM8pCp1Khme/T3XlomL116+tvH/W9tGprnyMSB1kRx+qX51JS8RJbWW/ZXPwq54JLJrUdPRRGbjaQnJb/n4olQZ5i/kkgfiEAhFzPKL2t/nbDvb+fuuVatsrUV4CrBv9NnJ+O4Cyh0DdySuwT5cLvM9zp37Qtt4/yuAFgXpNVS0LrLdKdWfb1Wv4OhLtJoKNulzUnbeunJnh5wCekdjM7VOi9C6npyaw3nC88+9NRfXybm7wGg/1dl0u6q5labFsqEOUvuX0WAbWFSS30TpJmd2pAuzhoX6HLhdwL8SzYeEdudgvabGg1v/a4UB0JvxxbFeoG2X5aX7fnqzVppme246wkfPJcO5hBGWADw7iRs8typozwkbOx7OBY7Fs+HGvJN/Ni9AxozrNIvOIcuRo51xPidQB3sPsAJ7czXo1DJyMzPXx7mywpKqPNCtktV91AdMzJKcmcs+Sqg4AqfdUK2z2si3gnx/I+f8pKC+mfpl7k9/FkWaHM/LPEnDqztxm9V/1lfmC+ipPzy0OzNECStKQkYOiZaavpfHOP4NFKL6BKrzEEV0v2jgnEefYgRGSg5+u1OG/IfB4Z+4ubcVlwOc5dbQ0Cmx1Bh8Ccv1EbBcfAu7l7lzB6zpgbQPBGdIg24854QOnhkcliRL90+EfnNBvRSfSXpJSn+WfIlJ4xYX7rDSyVwcVBBqTvZ5E37mtp+21FV8bk5HslOAkYMFLvIpIhyQfjPRPhWfEu16fRo94WLzEQ/cAyd7RWLr9r/rccq6VsAWJIfO86u5z6+jGahc1DMyJ+xk2ph3OHXbzcM55YMTjbCQRzQSPcHQJslZNulvPVoQ5mvzlFI7wAXuibzqkAZd/OuAugj3rloC1b8RMdpiP14fi6ZA2hFv2MgXmoXqFU7+DJHv2rZZfARgCc0S118nohg1wYMdk+FLLhtPA8UXArfe914DJVFQG5g31ryBLQ9F7A2PlL/oZ0zat/bB8RNPaCGvem/XAdemhWUUrz77rOh9Q1NJbVuq6VWfRotWYG5wHbuHX2MuNaXG2te1PLc6647z2NWDn+9hdC2sRdrf/nbe+FmHn+9hdCzdchIVuPAA6zsi+C93uxtDc+v+ix2Awxzl7yQAAAABJRU5ErkJggg==",L="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADwAAAA2CAYAAACbZ/oUAAAAAXNSR0IArs4c6QAAAERlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAA6ABAAMAAAABAAEAAKACAAQAAAABAAAAPKADAAQAAAABAAAANgAAAADBb/H9AAAEo0lEQVRoBe2ZX2wURRzH57e9KxESafgjrYkmPCDBBcKDib6IiQ8maIzEuMdViol/IDxIBI3tE0lfr0WqNGA8jK0pu8ftNMQY4oMPRhJ5MMFoJF4FTH2wCQiXgLEBob0dv8t14druXnfvZq+7pZtcdu43v/nN77O/ndmZ3zAt9foPqVT7y0IIYg/ARa9p7aLMSb8rRL1r1qzQ+/v7by9U9gpgB5EuK8Q+Wbq0+bPBwcEbjnSh3F2AHTT6VyGRTSaVj3VdH3Okcb9XAS6jEdEEBncOQ/wQ5/r5BQ9cCQj4b5oUpffkyRPfV8rjVJ4zwh4w55hCPWRtP8V5quShE0lxrcBTMDTKFPERWa0DnPfdiiThDKfqBC5bw6teZEL0JxLsWC6XK87oI1J/pQDfJ6KbmOC+SCZZn2EYo/fl0SlJBi6DARrjmobxr5dz46fo4DLWpKqbR4nYOjj1iETHFNjaiN8eVd20VVW3XC0Ufv1Dov2aTd1dP9vr6B07dm7DGrML5a01W6vSkBidx1jvaWlZls9msxNVVEOtugtc2QPAn7GEsMFfgXxWfaVuLWW8TX8Bvk+IluOcHxuvxUY9bTyBNK1jPWPWh4yJXYh8cz2duLelG1i6firEkiOcD15x15Ev9QR2uuro6Gi7c6e0XzDai6g/7Mgl3m9jlzYkhIKl64kLEu26mpoT2GmlaXuWE43vtQR7D1Fvc+Ty7nR5mBuPyrPnbsmeTX1dnGf/MU0j09a6ci1T2G6MxYu+GvpUItaYBIRvYMdvOzkwnM99rj65fgMx5VXIf3Tq4nD3/UpXg9G09ucYUSfG+IvV9KrVwZErnOdCGCrTew0c4enNy//g6BluGi8h4pvxyTnjphMVmRRgGyad3vWUIHEQX+5nowLn5kfCTRhEhoXKC5ZldU2WJp+3201lBIOYaKhuTcCaZjYRfZ0SwuosWdaWhnpcZ2eBgDXtwENEV98S4qsPsPxcW2ff89LcF7Cmvb2CsZvvMvp7H0BXyfbUnqHtjYVsu2720Jf3pWlvPM7Y5PuYiN7BJ2eZt2atNXQJDhxqbV35ZaOS/67AmrZzkyCrEzNQGii+3oKAyOfwCcuo6rpT3d3dVsC2dalPA7YXENgkdGGu3VaXVc/G9C2xpgznQ995qoRcQXjCysjIxe0lS3Sir6dl94cnWsL45EIwgBq/yLYf1F7it8KFETjzRNCGc+kD9BaRMmBv+0xz6M+59BtVn5ANi2heB+xRe2NvmgPXGgXitx+JExKN4dTxsJ26MechddMwYGwWClPJOWM+k3OhAwPyLDbtmXxeP41y1JfQ955H0ES8ANxpRDVjmvrZe1ZiVPA1hgE5IZgwSCg93NQLMeKb5WpVYMy24wjp8eYkHdZ1Y2xW6xgKXIEBeg2gR5IJdhSHYtdjyOXp8gzg8nkvw3nvsBmP815PMo8KB/jnqRN9zvPxOtH34PIW2yka79rFmtg/AcxP8q50+s3HJq3/DsqzKN+SM4YlWS6tQtJgtyRjoZiRlpcOxbsQjC4Ch/BQI2VyMcKRCkcIzixGOISHGimTD1yEpS48Vq9eXigWixsiFdIZzvwPVKdqUDAqifsAAAAASUVORK5CYII=",E={class:"popup-fotter-wrapper"},U={class:"fotter-box"},R=["onClick"],q={key:0,src:v},C={key:1,src:f},x={key:0,src:k},T={key:1,src:D},K={key:0,src:B},P={key:1,src:h},M={key:0,src:S},O={key:1,src:L};function V(e,A,t,o,s,r){return(0,a.wg)(),(0,a.iD)("div",E,[(0,a._)("div",U,[((0,a.wg)(!0),(0,a.iD)(a.HY,null,(0,a.Ko)(e.tabList,((A,t)=>((0,a.wg)(),(0,a.iD)("div",{class:"tab-item",key:t,onClick:e=>o.tabClickAction(A.id)},["matched_scripts_tab"==A.name?((0,a.wg)(),(0,a.iD)(a.HY,{key:0},[A.id==e.selectedTabId?((0,a.wg)(),(0,a.iD)("img",q)):((0,a.wg)(),(0,a.iD)("img",C))],64)):(0,a.kq)("",!0),"darkmode_tab"==A.name?((0,a.wg)(),(0,a.iD)(a.HY,{key:1},[A.id==e.selectedTabId?((0,a.wg)(),(0,a.iD)("img",x)):((0,a.wg)(),(0,a.iD)("img",T))],64)):(0,a.kq)("",!0),"downloader_tab"==A.name?((0,a.wg)(),(0,a.iD)(a.HY,{key:2},[A.id==e.selectedTabId?((0,a.wg)(),(0,a.iD)("img",K)):((0,a.wg)(),(0,a.iD)("img",P))],64)):(0,a.kq)("",!0),"console_tab"==A.name?((0,a.wg)(),(0,a.iD)(a.HY,{key:3},[A.id==e.selectedTabId?((0,a.wg)(),(0,a.iD)("img",M)):((0,a.wg)(),(0,a.iD)("img",O))],64)):(0,a.kq)("",!0)],8,R)))),128))])])}const W={name:"DarkModeComp",props:["tabId"],setup(e,{emit:A,expose:t}){const o=(0,c.qj)({tabList:[{id:1,selected:1,name:"matched_scripts_tab"},{id:2,selected:0,name:"darkmode_tab"},{id:3,selected:0,name:"downloader_tab"},{id:4,selected:0,name:"console_tab"}],selectedTabId:e.tabId}),a=e=>{e&&(o.selectedTabId=e,o.tabList.forEach((t=>{t.id===e&&A("setTabName",t)})))};return{...(0,c.BK)(o),tabClickAction:a}}},j=(0,g.Z)(W,[["render",V],["__scopeId","data-v-2c2d0702"]]),z=j,G={class:"popup-header-wrapper"};function I(e,A,t,o,s,r){return(0,a.wg)(),(0,a.iD)("div",G)}const Y={name:"DarkModeComp",setup(e,{emit:A,expose:t}){const o=(0,c.qj)({});return{...(0,c.BK)(o)}}},X=(0,g.Z)(Y,[["render",I],["__scopeId","data-v-7622b411"]]),Q=X,N={class:"popup-sniffer-wrapper"},J={key:0,class:"sniffer-video-box"},Z={class:"video-info"},F={class:"img-info"},H={class:"video"},_=["src"],$={key:1,class:"no-img"},ee={class:"info"},Ae={class:"title"},te={class:"name"},oe={class:"download"},ae=["onClick"],se={class:"video-download-info"},re={class:"label-txt"},le={class:"folder select-options"},ne=["value"],ie={class:"label-txt"},de={class:"quality select-options"},ce=["value"],pe={key:1,class:"sniffer-null"};function ue(e,A,t,r,l,n){return(0,a.wg)(),(0,a.iD)("div",N,[e.videoList&&e.videoList.length?((0,a.wg)(),(0,a.iD)("div",J,[((0,a.wg)(!0),(0,a.iD)(a.HY,null,(0,a.Ko)(e.videoList,((t,l)=>((0,a.wg)(),(0,a.iD)("div",{class:"sniffer-video",key:l},[(0,a._)("div",Z,[(0,a._)("div",F,[(0,a._)("div",H,[t.poster?((0,a.wg)(),(0,a.iD)("img",{key:0,src:t.poster},null,8,_)):((0,a.wg)(),(0,a.iD)("div",$,[(0,a._)("span",null,(0,s.zw)(r.getDomain(t.hostUrl)),1)]))]),(0,a._)("div",ee,[(0,a._)("div",Ae,(0,s.zw)(r.getLevel2domain(t.hostUrl)),1),(0,a._)("div",te,(0,s.zw)(t.title+"."+(t.downloadUrl?r.getFiletypeByUrl(t.downloadUrl):"")),1)])]),(0,a._)("div",oe,[(0,a._)("div",{class:"btn",onClick:e=>r.downloadClickAction(t)},(0,s.zw)(r.t("download")),9,ae)])]),(0,a._)("div",se,[(0,a._)("div",re,(0,s.zw)(r.t("save_to_folder"))+" :",1),(0,a._)("div",le,[(0,a.wy)((0,a._)("select",{class:"select-container","onUpdate:modelValue":A[0]||(A[0]=A=>e.selectedFolder=A)},[((0,a.wg)(!0),(0,a.iD)(a.HY,null,(0,a.Ko)(e.folderOptions,((e,A)=>((0,a.wg)(),(0,a.iD)("option",{style:(0,s.j5)({display:e.id?"block":"none"}),key:A,value:e.uuid},(0,s.zw)(e.name),13,ne)))),128))],512),[[o.bM,e.selectedFolder]])]),e.qualityList&&e.qualityList.length?((0,a.wg)(),(0,a.iD)(a.HY,{key:0},[(0,a._)("div",ie,(0,s.zw)(r.t("quality"))+" :",1),(0,a._)("div",de,[(0,a.wy)((0,a._)("select",{class:"select-container","onUpdate:modelValue":A[1]||(A[1]=A=>e.selectedQuality=A)},[((0,a.wg)(!0),(0,a.iD)(a.HY,null,(0,a.Ko)(e.qualityList,((e,A)=>((0,a.wg)(),(0,a.iD)("option",{key:A,value:e.downloadUrl},(0,s.zw)(e.qualityLabel),9,ce)))),128))],512),[[o.bM,e.selectedQuality]])])],64)):(0,a.kq)("",!0)])])))),128))])):((0,a.wg)(),(0,a.iD)("div",pe,(0,s.zw)(r.t("sniffer_none")),1))])}t(541);function be(){let e=navigator.languages&&navigator.languages.length>0?navigator.languages[0]:navigator.language||navigator.userLanguage||"en";return e=e.toLowerCase(),e=e.replace(/-/,"_"),e.length>3&&(e=e.substring(0,3)+e.substring(3).toUpperCase()),e}function we(e){if(!e)return"";try{return new URL(e).hostname.toLowerCase()}catch(A){return e.split("/")[0].toLowerCase()}}function ge(e){return e?e.split("/").pop():""}function me(e){return e?e.split(".").pop():""}function ye(e){let A=ve(e);if(!A)return"";let t=new RegExp(".(com.cn|com|net.cn|net|org.cn|org|gov.cn|gov|cn|mobi|me|info|name|biz|cc|tv|asia|hk|网络|公司|中国)","g");return A.replace(t,"")}function ve(e){try{let A="";const t=e?e.split("/"):"",o=t[2].split("."),a=[];a.unshift(o.pop());while(a.length<2)a.unshift(o.pop()),A=a.join(".");return A}catch(A){return""}}var fe=t(6995);const ke={name:"SnifferComp",props:["browserUrl"],setup(e,{emit:A,expose:t}){const{t:o,tm:s}=(0,fe.QT)(),r=(0,a.f3)("global"),l=(0,c.qj)({browserUrl:e.browserUrl,hostName:we(e.browserUrl),selectedFolder:"",selectedQuality:"",folderOptions:[{name:o("select_folder"),uuid:""},{name:"download_video",id:"1"},{name:"stay-download-video",id:"2"}],videoList:[{poster:"https://f7.baidu.com/it/u=3855037150,2522612002&fm=222&app=108&f=JPEG",downloadUrl:"https://vd2.bdstatic.com/mda-nkea4tasr6ur1ykf/cae_h264/1668497008894896459/mda-nkea4tasr6ur1ykf.mp4",title:"美国军机飞抵台海已人困马乏，赖岳谦：若开战会被解放军碾压",qualityList:[]}]}),n=()=>{r.browser.runtime.sendMessage({from:"popup",operate:"fetchFolders"},(e=>{console.log("fetchSnifferFolder---response-----",e);try{e.body&&(l.folderOptions=[{name:o("select_folder"),uuid:""},...e.body],e.body.forEach((e=>{e.selected&&(l.selectedFolder=e.uuid)})))}catch(A){console.log(A)}}))};n();const i=()=>{r.browser.runtime.sendMessage({from:"popup",operate:"snifferFetchVideoInfo"},(e=>{console.log("snifferFetchVideoInfo---response-----",e);try{e.body&&e.body.videoInfoList&&e.body.videoInfoList.length?l.videoList=e.body.videoInfoList:l.videoList=[]}catch(A){console.log(A)}}))};i();const d=e=>{l.selectedFolder?(e.uuid=l.selectedFolder,l.selectedQuality&&(e.downloadUrl=l.selectedQuality),window.open("stay://x-callback-url/snifferVideo?list="+encodeURIComponent(JSON.stringify(e)))):r.toast(o("select_folder"))};return{...(0,c.BK)(l),t:o,tm:s,getDomain:ye,getFilenameByUrl:ge,getLevel2domain:ve,getFiletypeByUrl:me,downloadClickAction:d}}},De=(0,g.Z)(ke,[["render",ue],["__scopeId","data-v-17078917"]]),Be=De,he={class:"popup-header-wrapper"};function Se(e,A,t,o,s,r){return(0,a.wg)(),(0,a.iD)("div",he)}const Le={name:"ConsolePusherComp",setup(e,{emit:A,expose:t}){const o=(0,c.qj)({});return{...(0,c.BK)(o)}}},Ee=(0,g.Z)(Le,[["render",Se],["__scopeId","data-v-9c56ba12"]]),Ue=Ee,Re=e=>((0,a.dD)("data-v-536dd492"),e=e(),(0,a.Cn)(),e),qe={class:"upgrade-pro-warpper"},Ce=Re((()=>(0,a._)("div",{class:"upgrade-img"},null,-1))),xe={class:"upgrade-btn"};function Te(e,A,t,o,r,l){return(0,a.wg)(),(0,a.iD)("div",qe,[Ce,(0,a._)("div",xe,(0,s.zw)(o.t("upgrade_pro")),1)])}const Ke={name:"UpgradeProComp",setup(e,{emit:A,expose:t}){const{t:o,tm:a}=(0,fe.QT)(),s=(0,c.qj)({});return{...(0,c.BK)(s),t:o,tm:a}}},Pe=(0,g.Z)(Ke,[["render",Te],["__scopeId","data-v-536dd492"]]),Me=Pe,Oe={name:"popupView",components:{Header:y,TabMenu:z,ConsolePusher:Ue,Sniffer:Be,DarkMode:Q,UpgradePro:Me},setup(e,{emit:A,attrs:t,slots:o}){const{t:s,tm:r}=(0,fe.QT)(),l=(0,a.f3)("global"),n=l.store,i=n.state.localeLan;console.log("localLan====",i);const d=(0,c.qj)({selectedTab:{id:1,name:"matched_scripts_tab"},localLan:i,browserUrl:"",isStayPro:n.state.isStayPro,darkmodeToggleStatus:"on",siteEnabled:!0}),p=e=>{d.selectedTab=e};l.browser.runtime.onMessage.addListener(((e,A,t)=>{const o=e.from,a=e.operate;return"background"===o&&"giveDarkmodeConfig"==a&&(console.log("giveDarkmodeConfig==res==",e),d.isStayPro="a"==e.isStayAround,n.commit("setIsStayPro",d.isStayPro),d.darkmodeToggleStatus=e.darkmodeToggleStatus,d.siteEnabled=e.enabled),!0}));const u=()=>{l.browser.tabs.getSelected(null,(e=>{console.log("fetchStayProConfig----tab-----",e),d.browserUrl=e.url,n.commit("setBrowserUrl",d.browserUrl)})),l.browser.runtime.sendMessage({type:"popup",operate:"FETCH_DARKMODE_CONFIG"},(e=>{}))};return u(),{...(0,c.BK)(d),t:s,tm:r,setTabName:p}}},Ve=(0,g.Z)(Oe,[["render",d]]),We=Ve;var je=t(8874),ze=t(2415);const Ge={namespaced:!0,state:()=>({name:""}),mutations:{SET_NAME:(e,A)=>{e.name=A}},actions:{setName:({commit:e},A)=>{e("SET_NAME",A)}}},Ie=(0,je.MT)({state:{localeLan:be().indexOf("zh_")>-1?"zh":"en",staySwitch:"start",isStayPro:!1,browserUrl:""},getters:{localLanGetter:e=>e.localeLan,staySwitchGetter:e=>e.staySwitch,isStayProGetter:e=>e.isStayPro,browserUrlGetter:e=>e.browserUrl},mutations:{setLocalLan:(e,A)=>{e.localeLan=A},setStaySwitch:(e,A)=>{e.staySwitch=A},setIsStayPro:(e,A)=>{e.isStayPro=A},setBrowserUrl:(e,A)=>{e.browserUrl=A}},actions:{setLocalLanAsync:({commit:e},A)=>{e("setLocalLan",A)},setStaySwitchAsync:({commit:e},A)=>{e("setStaySwitch",A)},setIsStayProAsync:({commit:e},A)=>{e("setIsStayPro",A)},setrowserUrlAsync:({commit:e},A)=>{e("setBrowserUrl",A)}},modules:{moudleA:Ge},plugins:[(0,ze.Z)({storage:window.localStorage,key:"stay-popup-vuex-store-persistence",paths:["moudleA","localeLan","staySwitch"]})]}),Ye={en:{matched_scripts_tab:"Matched",console_tab:"Console",darkmode_tab:"Dark Mode",state_actived:"Activated",state_manually:"Manually Executed",state_stopped:"Stopped",null_scripts:"no available scripts were matched",null_register_menu:"No register menu item",menu_close:"Close",toast_keep_active:"Please keep the script activated",run_manually:"Run manually",upgrade_pro:"Upgrade to Stay Pro",darkmode_off:"Off",darkmode_auto:"Auto",darkmode_on:"On",darkmode_enabled:"Enabled for current website",darkmode_disabled:"Disabled for current website",download_text:"User script manager",downloader_tab:"Downloader",sniffer_none:"No video found",download:"DOWNLOAD",save_to_folder:"Save to folder",quality:"Quality",select_folder:"Select Folder"},zh:{matched_scripts_tab:"已匹配脚本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"运行中",state_manually:"手动执行",state_stopped:"已停止",null_scripts:"未匹配到可用脚本",null_register_menu:"无注册菜单项",menu_close:"关闭",toast_keep_active:"请保持脚本处于激活状态",run_manually:"手动执行",upgrade_pro:"升级Stay专业版",darkmode_off:"关",darkmode_auto:"自动",darkmode_on:"开",darkmode_enabled:"启用当前网站",darkmode_disabled:"禁用当前网站",download_text:"用户脚本管理",downloader_tab:"下载器",sniffer_none:"没有发现视频",download:"下载",save_to_folder:"保存到文件夹",quality:"画质",select_folder:"选择文件夹"},zh_HK:{matched_scripts_tab:"已匹配腳本",console_tab:"控制台",darkmode_tab:"暗黑模式",state_actived:"運行中",state_manually:"手動執行",state_stopped:"已停止",null_scripts:"未匹配到可用腳本",null_register_menu:"無註冊菜單項",menu_close:"關閉",toast_keep_active:"請保持腳本處於激活狀態",run_manually:"手動執行",upgrade_pro:"升級Stay專業版",darkmode_off:"關",darkmode_auto:"自動",darkmode_on:"開",darkmode_enabled:"啟用當前網站",darkmode_disabled:"禁用當前網站",download_text:"用戶腳本管理",downloader_tab:"下載器",sniffer_none:"沒有發現視頻",download:"下載",save_to_folder:"保存到文件夾",quality:"畫質",select_folder:"選擇文件夾"}},Xe=(0,fe.o)({fallbackLocale:"ch",globalInjection:!0,allowComposition:!0,legacy:!1,locale:"en",messages:Ye}),Qe=Xe,Ne={class:"m-notice"},Je={class:"m-msg"};function Ze(e,A,t,r,l,n){return(0,a.wg)(),(0,a.j4)(o.uT,{name:"show"},{default:(0,a.w5)((()=>[(0,a.wy)((0,a._)("div",Ne,[(0,a._)("div",Je,(0,s.zw)(t.title),1)],512),[[o.F8,e.showNotice]])])),_:1})}const Fe={name:"ToastComp",props:{title:{type:String,default:"加载中..."}},setup(){const e=(0,c.qj)({showNotice:!1});return(0,a.bv)((()=>{e.showNotice=!0})),{...(0,c.BK)(e)}}},He=(0,g.Z)(Fe,[["render",Ze],["__scopeId","data-v-4cad416a"]]),_e=He,$e=document.createElement("div");document.body.appendChild($e);let eA=null;const AA=e=>{let A,t;"string"!==typeof e&&"undefined"!==typeof e&&e?(A=e.title||"加载中...",t=e.duration||3500):(A=e||"加载中...",t=3500);const s=(0,a.Wm)(_e,{title:A});(0,o.sY)(s,$e),clearTimeout(eA),eA=setTimeout((()=>{(0,o.sY)(null,$e)}),t)};let tA;"undefined"!==typeof window.browser&&(tA=window.browser),"undefined"!==typeof window.chrome&&(tA=window.chrome);const oA=tA,aA=(0,o.ri)(We);aA.provide("global",{store:Ie,browser:oA,toast:AA}),aA.use(Qe).use(Ie).mount("#app")}},A={};function t(o){var a=A[o];if(void 0!==a)return a.exports;var s=A[o]={exports:{}};return e[o](s,s.exports,t),s.exports}t.m=e,(()=>{var e=[];t.O=(A,o,a,s)=>{if(!o){var r=1/0;for(d=0;d<e.length;d++){o=e[d][0],a=e[d][1],s=e[d][2];for(var l=!0,n=0;n<o.length;n++)(!1&s||r>=s)&&Object.keys(t.O).every((e=>t.O[e](o[n])))?o.splice(n--,1):(l=!1,s<r&&(r=s));if(l){e.splice(d--,1);var i=a();void 0!==i&&(A=i)}}return A}s=s||0;for(var d=e.length;d>0&&e[d-1][2]>s;d--)e[d]=e[d-1];e[d]=[o,a,s]}})(),(()=>{t.n=e=>{var A=e&&e.__esModule?()=>e["default"]:()=>e;return t.d(A,{a:A}),A}})(),(()=>{t.d=(e,A)=>{for(var o in A)t.o(A,o)&&!t.o(e,o)&&Object.defineProperty(e,o,{enumerable:!0,get:A[o]})}})(),(()=>{t.g=function(){if("object"===typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(e){if("object"===typeof window)return window}}()})(),(()=>{t.o=(e,A)=>Object.prototype.hasOwnProperty.call(e,A)})(),(()=>{t.j=42})(),(()=>{var e={42:0};t.O.j=A=>0===e[A];var A=(A,o)=>{var a,s,r=o[0],l=o[1],n=o[2],i=0;if(r.some((A=>0!==e[A]))){for(a in l)t.o(l,a)&&(t.m[a]=l[a]);if(n)var d=n(t)}for(A&&A(o);i<r.length;i++)s=r[i],t.o(e,s)&&e[s]&&e[s][0](),e[s]=0;return t.O(d)},o=self["webpackChunkstay_popup"]=self["webpackChunkstay_popup"]||[];o.forEach(A.bind(null,0)),o.push=A.bind(null,o.push.bind(o))})();var o=t.O(void 0,[998],(()=>t(340)));o=t.O(o)})();