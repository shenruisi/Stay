(()=>{var t={9662:(t,e,n)=>{var r=n(614),o=n(6330),i=TypeError;t.exports=function(t){if(r(t))return t;throw i(o(t)+" is not a function")}},9670:(t,e,n)=>{var r=n(111),o=String,i=TypeError;t.exports=function(t){if(r(t))return t;throw i(o(t)+" is not an object")}},1318:(t,e,n)=>{function r(t){return function(e,n,r){var u,s=o(e),c=a(s),p=i(r,c);if(t&&n!=n){for(;p<c;)if((u=s[p++])!=u)return!0}else for(;p<c;p++)if((t||p in s)&&s[p]===n)return t||p||0;return!t&&-1}}var o=n(5656),i=n(1400),a=n(6244);t.exports={includes:r(!0),indexOf:r(!1)}},3658:(t,e,n)=>{"use strict";var r=n(9781),o=n(3157),i=TypeError,a=Object.getOwnPropertyDescriptor;n=r&&!function(){if(void 0!==this)return 1;try{Object.defineProperty([],"length",{writable:!1}).length=1}catch(t){return t instanceof TypeError}}();t.exports=n?function(t,e){if(o(t)&&!a(t,"length").writable)throw i("Cannot set read only .length");return t.length=e}:function(t,e){return t.length=e}},4326:(t,e,n)=>{n=n(1702);var r=n({}.toString),o=n("".slice);t.exports=function(t){return o(r(t),8,-1)}},9920:(t,e,n)=>{var r=n(2597),o=n(3887),i=n(1236),a=n(3070);t.exports=function(t,e,n){for(var u=o(e),s=a.f,c=i.f,p=0;p<u.length;p++){var l=u[p];r(t,l)||n&&r(n,l)||s(t,l,c(e,l))}}},8880:(t,e,n)=>{var r=n(9781),o=n(3070),i=n(9114);t.exports=r?function(t,e,n){return o.f(t,e,i(1,n))}:function(t,e,n){return t[e]=n,t}},9114:t=>{t.exports=function(t,e){return{enumerable:!(1&t),configurable:!(2&t),writable:!(4&t),value:e}}},8052:(t,e,n)=>{var r=n(614),o=n(3070),i=n(6339),a=n(3072);t.exports=function(t,e,n,u){var s=(u=u||{}).enumerable,c=void 0!==u.name?u.name:e;if(r(n)&&i(n,c,u),u.global)s?t[e]=n:a(e,n);else{try{u.unsafe?t[e]&&(s=!0):delete t[e]}catch(t){}s?t[e]=n:o.f(t,e,{value:n,enumerable:!1,configurable:!u.nonConfigurable,writable:!u.nonWritable})}return t}},3072:(t,e,n)=>{var r=n(7854),o=Object.defineProperty;t.exports=function(e,n){try{o(r,e,{value:n,configurable:!0,writable:!0})}catch(t){r[e]=n}return n}},5117:(t,e,n)=>{"use strict";var r=n(6330),o=TypeError;t.exports=function(t,e){if(!delete t[e])throw o("Cannot delete property "+r(e)+" of "+r(t))}},9781:(t,e,n)=>{n=n(7293),t.exports=!n((function(){return 7!=Object.defineProperty({},1,{get:function(){return 7}})[1]}))},4154:t=>{var e="object"==typeof document&&document.all;t.exports={all:e,IS_HTMLDDA:void 0===e&&void 0!==e}},317:(t,e,n)=>{var r=n(7854),o=(n=n(111),r.document),i=n(o)&&n(o.createElement);t.exports=function(t){return i?o.createElement(t):{}}},7207:t=>{var e=TypeError;t.exports=function(t){if(9007199254740991<t)throw e("Maximum allowed index exceeded");return t}},8113:(t,e,n)=>{n=n(5005),t.exports=n("navigator","userAgent")||""},7392:(t,e,n)=>{var r,o,i=n(7854),a=(n=n(8113),i.process);i=i.Deno,a=a&&a.versions||i&&i.version,i=a&&a.v8;!(o=i?0<(r=i.split("."))[0]&&r[0]<4?1:+(r[0]+r[1]):o)&&n&&(!(r=n.match(/Edge\/(\d+)/))||74<=r[1])&&(r=n.match(/Chrome\/(\d+)/))&&(o=+r[1]),t.exports=o},748:t=>{t.exports=["constructor","hasOwnProperty","isPrototypeOf","propertyIsEnumerable","toLocaleString","toString","valueOf"]},2109:(t,e,n)=>{var r=n(7854),o=n(1236).f,i=n(8880),a=n(8052),u=n(3072),s=n(9920),c=n(4705);t.exports=function(t,e){var n,p,l,d=t.target,f=t.global,m=t.stat,y=f?r:m?r[d]||u(d,{}):(r[d]||{}).prototype;if(y)for(n in e){if(p=e[n],l=t.dontCallGetSet?(l=o(y,n))&&l.value:y[n],!c(f?n:d+(m?".":"#")+n,t.forced)&&void 0!==l){if(typeof p==typeof l)continue;s(p,l)}(t.sham||l&&l.sham)&&i(p,"sham",!0),a(y,n,p,t)}}},7293:t=>{t.exports=function(t){try{return!!t()}catch(t){return!0}}},4374:(t,e,n)=>{n=n(7293),t.exports=!n((function(){var t=function(){}.bind();return"function"!=typeof t||t.hasOwnProperty("prototype")}))},6916:(t,e,n)=>{n=n(4374);var r=Function.prototype.call;t.exports=n?r.bind(r):function(){return r.apply(r,arguments)}},6530:(t,e,n)=>{var r=n(9781),o=(n=n(2597),Function.prototype),i=r&&Object.getOwnPropertyDescriptor,a=(n=n(o,"name"),n&&"something"===function(){}.name);r=n&&(!r||i(o,"name").configurable);t.exports={EXISTS:n,PROPER:a,CONFIGURABLE:r}},1702:(t,e,n)=>{n=n(4374);var r=Function.prototype,o=r.call;r=n&&r.bind.bind(o,o);t.exports=n?r:function(t){return function(){return o.apply(t,arguments)}}},5005:(t,e,n)=>{var r=n(7854),o=n(614);t.exports=function(t,e){return arguments.length<2?(n=r[t],o(n)?n:void 0):r[t]&&r[t][e];var n}},8173:(t,e,n)=>{var r=n(9662),o=n(8554);t.exports=function(t,e){return t=t[e],o(t)?void 0:r(t)}},7854:(t,e,n)=>{function r(t){return t&&t.Math==Math&&t}t.exports=r("object"==typeof globalThis&&globalThis)||r("object"==typeof window&&window)||r("object"==typeof self&&self)||r("object"==typeof n.g&&n.g)||function(){return this}()||Function("return this")()},2597:(t,e,n)=>{var r=n(1702),o=n(7908),i=r({}.hasOwnProperty);t.exports=Object.hasOwn||function(t,e){return i(o(t),e)}},3501:t=>{t.exports={}},4664:(t,e,n)=>{var r=n(9781),o=n(7293),i=n(317);t.exports=!r&&!o((function(){return 7!=Object.defineProperty(i("div"),"a",{get:function(){return 7}}).a}))},8361:(t,e,n)=>{var r=n(1702),o=n(7293),i=n(4326),a=Object,u=r("".split);t.exports=o((function(){return!a("z").propertyIsEnumerable(0)}))?function(t){return"String"==i(t)?u(t,""):a(t)}:a},2788:(t,e,n)=>{var r=n(1702),o=n(614),i=(n=n(5465),r(Function.toString));o(n.inspectSource)||(n.inspectSource=function(t){return i(t)}),t.exports=n.inspectSource},9909:(t,e,n)=>{var r,o,i,a,u=n(4811),s=n(7854),c=n(111),p=n(8880),l=n(2597),d=n(5465),f=n(6200),m=(n=n(3501),"Object already initialized"),y=s.TypeError,g=(s=s.WeakMap,u||d.state?((i=d.state||(d.state=new s)).get=i.get,i.has=i.has,i.set=i.set,r=function(t,e){if(i.has(t))throw y(m);return e.facade=t,i.set(t,e),e},o=function(t){return i.get(t)||{}},function(t){return i.has(t)}):(n[a=f("state")]=!0,r=function(t,e){if(l(t,a))throw y(m);return e.facade=t,p(t,a,e),e},o=function(t){return l(t,a)?t[a]:{}},function(t){return l(t,a)}));t.exports={set:r,get:o,has:g,enforce:function(t){return g(t)?o(t):r(t,{})},getterFor:function(t){return function(e){if(c(e)&&(e=o(e)).type===t)return e;throw y("Incompatible receiver, "+t+" required")}}}},3157:(t,e,n)=>{var r=n(4326);t.exports=Array.isArray||function(t){return"Array"==r(t)}},614:(t,e,n)=>{n=n(4154);var r=n.all;t.exports=n.IS_HTMLDDA?function(t){return"function"==typeof t||t===r}:function(t){return"function"==typeof t}},4705:(t,e,n)=>{function r(t,e){return(t=s[u(t)])==p||t!=c&&(i(e)?o(e):!!e)}var o=n(7293),i=n(614),a=/#|\.prototype\./,u=r.normalize=function(t){return String(t).replace(a,".").toLowerCase()},s=r.data={},c=r.NATIVE="N",p=r.POLYFILL="P";t.exports=r},8554:t=>{t.exports=function(t){return null==t}},111:(t,e,n)=>{var r=n(614),o=(n=n(4154),n.all);t.exports=n.IS_HTMLDDA?function(t){return"object"==typeof t?null!==t:r(t)||t===o}:function(t){return"object"==typeof t?null!==t:r(t)}},1913:t=>{t.exports=!1},2190:(t,e,n)=>{var r=n(5005),o=n(614),i=n(7976),a=(n=n(3307),Object);t.exports=n?function(t){return"symbol"==typeof t}:function(t){var e=r("Symbol");return o(e)&&i(e.prototype,a(t))}},6244:(t,e,n)=>{var r=n(7466);t.exports=function(t){return r(t.length)}},6339:(t,e,n)=>{var r=n(7293),o=n(614),i=n(2597),a=n(9781),u=n(6530).CONFIGURABLE,s=n(2788),c=(n=n(9909),n.enforce),p=n.get,l=Object.defineProperty,d=a&&!r((function(){return 8!==l((function(){}),"length",{value:8}).length})),f=String(String).split("String");n=t.exports=function(t,e,n){"Symbol("===String(e).slice(0,7)&&(e="["+String(e).replace(/^Symbol\(([^)]*)\)/,"$1")+"]"),n&&n.getter&&(e="get "+e),n&&n.setter&&(e="set "+e),(!i(t,"name")||u&&t.name!==e)&&(a?l(t,"name",{value:e,configurable:!0}):t.name=e),d&&n&&i(n,"arity")&&t.length!==n.arity&&l(t,"length",{value:n.arity});try{n&&i(n,"constructor")&&n.constructor?a&&l(t,"prototype",{writable:!1}):t.prototype&&(t.prototype=void 0)}catch(t){}return n=c(t),i(n,"source")||(n.source=f.join("string"==typeof e?e:"")),t};Function.prototype.toString=n((function(){return o(this)&&p(this).source||s(this)}),"toString")},4758:t=>{var e=Math.ceil,n=Math.floor;t.exports=Math.trunc||function(t){return t=+t,(0<t?n:e)(t)}},3070:(t,e,n)=>{var r=n(9781),o=n(4664),i=n(3353),a=n(9670),u=n(4948),s=TypeError,c=Object.defineProperty,p=Object.getOwnPropertyDescriptor,l="enumerable",d="configurable",f="writable";e.f=r?i?function(t,e,n){var r;return a(t),e=u(e),a(n),"function"==typeof t&&"prototype"===e&&"value"in n&&f in n&&!n[f]&&(r=p(t,e))&&r[f]&&(t[e]=n.value,n={configurable:(d in n?n:r)[d],enumerable:(l in n?n:r)[l],writable:!1}),c(t,e,n)}:c:function(t,e,n){if(a(t),e=u(e),a(n),o)try{return c(t,e,n)}catch(t){}if("get"in n||"set"in n)throw s("Accessors not supported");return"value"in n&&(t[e]=n.value),t}},1236:(t,e,n)=>{var r=n(9781),o=n(6916),i=n(5296),a=n(9114),u=n(5656),s=n(4948),c=n(2597),p=n(4664),l=Object.getOwnPropertyDescriptor;e.f=r?l:function(t,e){if(t=u(t),e=s(e),p)try{return l(t,e)}catch(t){}if(c(t,e))return a(!o(i.f,t,e),t[e])}},8006:(t,e,n)=>{var r=n(6324),o=n(748).concat("length","prototype");e.f=Object.getOwnPropertyNames||function(t){return r(t,o)}},5181:(t,e)=>{e.f=Object.getOwnPropertySymbols},7976:(t,e,n)=>{n=n(1702),t.exports=n({}.isPrototypeOf)},6324:(t,e,n)=>{var r=n(1702),o=n(2597),i=n(5656),a=n(1318).indexOf,u=n(3501),s=r([].push);t.exports=function(t,e){var n,r=i(t),c=0,p=[];for(n in r)!o(u,n)&&o(r,n)&&s(p,n);for(;e.length>c;)!o(r,n=e[c++])||~a(p,n)||s(p,n);return p}},5296:(t,e)=>{"use strict";var n={}.propertyIsEnumerable,r=Object.getOwnPropertyDescriptor,o=r&&!n.call({1:2},1);e.f=o?function(t){return t=r(this,t),!!t&&t.enumerable}:n},2140:(t,e,n)=>{var r=n(6916),o=n(614),i=n(111),a=TypeError;t.exports=function(t,e){var n,u;if("string"===e&&o(n=t.toString)&&!i(u=r(n,t)))return u;if(o(n=t.valueOf)&&!i(u=r(n,t)))return u;if("string"!==e&&o(n=t.toString)&&!i(u=r(n,t)))return u;throw a("Can't convert object to primitive value")}},3887:(t,e,n)=>{var r=n(5005),o=n(1702),i=n(8006),a=n(5181),u=n(9670),s=o([].concat);t.exports=r("Reflect","ownKeys")||function(t){var e=i.f(u(t)),n=a.f;return n?s(e,n(t)):e}},4488:(t,e,n)=>{var r=n(8554),o=TypeError;t.exports=function(t){if(r(t))throw o("Can't call method on "+t);return t}},6200:(t,e,n)=>{var r=n(2309),o=n(9711),i=r("keys");t.exports=function(t){return i[t]||(i[t]=o(t))}},5465:(t,e,n)=>{var r=n(7854),o=(n=n(3072),"__core-js_shared__");r=r[o]||n(o,{});t.exports=r},2309:(t,e,n)=>{var r=n(1913),o=n(5465);(t.exports=function(t,e){return o[t]||(o[t]=void 0!==e?e:{})})("versions",[]).push({version:"3.26.1",mode:r?"pure":"global",copyright:"© 2014-2022 Denis Pushkarev (zloirock.ru)",license:"https://github.com/zloirock/core-js/blob/v3.26.1/LICENSE",source:"https://github.com/zloirock/core-js"})},6293:(t,e,n)=>{var r=n(7392);n=n(7293);t.exports=!!Object.getOwnPropertySymbols&&!n((function(){var t=Symbol();return!String(t)||!(Object(t)instanceof Symbol)||!Symbol.sham&&r&&r<41}))},1400:(t,e,n)=>{var r=n(9303),o=Math.max,i=Math.min;t.exports=function(t,e){return t=r(t),t<0?o(t+e,0):i(t,e)}},5656:(t,e,n)=>{var r=n(8361),o=n(4488);t.exports=function(t){return r(o(t))}},9303:(t,e,n)=>{var r=n(4758);t.exports=function(t){return t=+t,t!=t||0==t?0:r(t)}},7466:(t,e,n)=>{var r=n(9303),o=Math.min;t.exports=function(t){return 0<t?o(r(t),9007199254740991):0}},7908:(t,e,n)=>{var r=n(4488),o=Object;t.exports=function(t){return o(r(t))}},7593:(t,e,n)=>{var r=n(6916),o=n(111),i=n(2190),a=n(8173),u=n(2140),s=(n=n(5112),TypeError),c=n("toPrimitive");t.exports=function(t,e){if(!o(t)||i(t))return t;var n=a(t,c);if(n){if(n=r(n,t,e=void 0===e?"default":e),!o(n)||i(n))return n;throw s("Can't convert object to primitive value")}return u(t,e=void 0===e?"number":e)}},4948:(t,e,n)=>{var r=n(7593),o=n(2190);t.exports=function(t){return t=r(t,"string"),o(t)?t:t+""}},6330:t=>{var e=String;t.exports=function(t){try{return e(t)}catch(t){return"Object"}}},9711:(t,e,n)=>{n=n(1702);var r=0,o=Math.random(),i=n(1..toString);t.exports=function(t){return"Symbol("+(void 0===t?"":t)+")_"+i(++r+o,36)}},3307:(t,e,n)=>{n=n(6293),t.exports=n&&!Symbol.sham&&"symbol"==typeof Symbol.iterator},3353:(t,e,n)=>{var r=n(9781);n=n(7293);t.exports=r&&n((function(){return 42!=Object.defineProperty((function(){}),"prototype",{value:42,writable:!1}).prototype}))},4811:(t,e,n)=>{var r=n(7854);n=n(614),r=r.WeakMap;t.exports=n(r)&&/native code/.test(String(r))},5112:(t,e,n)=>{var r=n(7854),o=n(2309),i=n(2597),a=n(9711),u=n(6293),s=n(3307),c=o("wks"),p=r.Symbol,l=p&&p.for,d=s?p:p&&p.withoutSetter||a;t.exports=function(t){var e;return i(c,t)&&(u||"string"==typeof c[t])||(e="Symbol."+t,u&&i(p,t)?c[t]=p[t]:c[t]=(s&&l?l:d)(e)),c[t]}},541:(t,e,n)=>{"use strict";var r=n(2109),o=n(7908),i=n(6244),a=n(3658),u=n(5117),s=n(7207),c=(n=1!==[].unshift(0),!function(){try{Object.defineProperty([],"length",{writable:!1}).unshift()}catch(t){return t instanceof TypeError}}());r({target:"Array",proto:!0,arity:1,forced:n||c},{unshift:function(t){var e=o(this),n=i(e),r=arguments.length;if(r){s(n+r);for(var c=n;c--;){var p=c+r;c in e?e[p]=e[c]:u(e,p)}for(var l=0;l<r;l++)e[l]=arguments[l]}return a(e,n+r)}})}},e={};function n(r){var o=e[r];return void 0!==o||(o=e[r]={exports:{}},t[r](o,o.exports,n)),o.exports}n.g=function(){if("object"==typeof globalThis)return globalThis;try{return this||new Function("return this")()}catch(t){if("object"==typeof window)return window}}();{let o;n(541),void 0!==window.browser&&(o=window.browser);const i=o=void 0!==window.chrome?window.chrome:o;function r(t){let e=!1,n=!1,r={},o=null,a=null;const u={parseToDOM(t){var e=document.createElement("template");return"string"==typeof t?(e.innerHTML=t,e.content):t},isMobileOrIpad:function(){const t=navigator.userAgent;return!!["Android","iPhone","SymbianOS","Windows Phone","iPad","iPod"].filter((e=>t.includes(e))).length},sub(t,e){let n,r,o;try{n=t.toString().split(".")[1].length}catch(t){n=0}try{r=e.toString().split(".")[1].length}catch(t){r=0}return o=Math.pow(10,Math.max(n,r)),(this.mul(t,o)-this.mul(e,o))/o},mul(t,e){let n=0,r=t.toString(),o=e.toString();try{n+=r.split(".")[1].length}catch(t){}try{n+=o.split(".")[1].length}catch(t){}return Number(r.replace(".",""))*Number(o.replace(".",""))/Math.pow(10,n)},add(t,e){let n,r,o;try{n=t.toString().split(".")[1].length}catch(t){n=0}try{r=e.toString().split(".")[1].length}catch(t){r=0}return o=Math.pow(10,Math.max(n,r)),(this.mul(t,o)+this.mul(e,o))/o}},s=u.isMobileOrIpad()?"touchstart":"click",c=2;if(async function(){new Promise(((e,n)=>{if(t)i.runtime.sendMessage({from:"popup",operate:"getMakeupTagStatus"},(t=>{t=t&&t.makeupTagStatus?t.makeupTagStatus:"on",r.makeupStatus=t}));else{const t=Math.random().toString(36).substring(2,9),e=n=>{n.data.pid===t&&"GET_MAKEUP_TAG_STATUS_RESP"===n.data.name&&(window.removeEventListener("message",e),n=n.data.makeupTagStatus,r.makeupStatus=n)};window.postMessage({id:t,pid:t,name:"GET_MAKEUP_TAG_STATUS"}),window.addEventListener("message",e)}}))}(),u.isMobileOrIpad()){let t=null,n=null;document.addEventListener("gesturestart",(n=>{1===n.scale&&0===n.rotation&&(t=n.pageX,e||("on"==r.makeupStatus?l():r.makeupStatus="on")),n.preventDefault()})),document.addEventListener("gesturechange",(o=>{1===o.scale&&0===o.rotation&&(n=o.pageX,Math.abs(u.sub(n,t))<=10)&&!e&&("on"==r.makeupStatus?l():r.makeupStatus="on"),o.preventDefault()})),document.addEventListener("gestureend",(e=>{t=null,n=null}))}function p(t){t&&"on"==t?l():(f(),g(),null!=o&&(o.style.display="none",e=!1))}function l(){var t,i;e=!0,document.querySelector("#__stay_select_style")||((t=document.createElement("style")).type="text/css",t.id="__stay_select_style",i=`\n                    .__stay_move_wrapper{\n                        position:fixed;\n                        left:0;\n                        right:0;\n                        top:0;\n                        bottom:0;\n                        z-index:2147483600;\n                        width:100%;\n                        height:100%;\n                        background-color:rgba(0,0,0,0.3);\n                        box-sizing: border-box;\n                    }\n                    .__stay_close_con{\n                        position:absolute;\n                        right: 20px;\n                        top: 20px;\n                        width:26px;\n                        height:26px;\n                        background: url("https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png") 50% 50% no-repeat;\n                        background-size: 40%;\n                        background-color: #ffffff;\n                        border-radius:50%;\n                    }\n                    .__stay_select_target{display:none;position:fixed; box-sizing:border-box;z-index:2147483647; background-color:rgba(0,0,0,0);border: ${c}px solid #B620E0; border-radius: 6px;box-shadow: 1px -1px 20px rgba(0,0,0,0.2);}\n                    .__stay_makeup_menu_wrapper{\n                        width:187px;\n                        position:absolute;\n                        padding: 8px 0;\n                        box-sizing: border-box;\n                    }\n                    .__stay_makeup_menu_item_box{\n                        width:100%;\n                        box-sizing: border-box;\n                        background-color: #ffffff;\n                        padding-left: 12px;\n                        border-radius: 5px;\n                        box-shadow: 0px 2px 10px rgba(0,0,0,0.3);\n                    }\n                    .__stay_menu_item{\n                        height:45px;\n                        border-bottom: 1px solid #e0e0e0;\n                        display:flex;\n                        justify-content: space-between;\n                        align-items: center;\n                        padding-left: 2px;\n                        padding-right: 12px;\n                        font-size: 16px;\n                    }\n                    .__stay_menu_item:last-child {\n                        border-bottom: none;\n                    }\n                    .__stay_menu_item img{\n                        width:15px;\n                    }\n                `,t.appendChild(document.createTextNode(i)),document.head.appendChild(t)),document.querySelector("#__stay_wrapper")?o.style.display="block":((o=document.createElement("div")).id="__stay_wrapper",o.classList.add("__stay_move_wrapper"),(i=document.createElement("div")).id="__stay_close",i.classList.add("__stay_close_con"),o.appendChild(i),document.body.appendChild(o),window.addEventListener("scroll",(()=>{g(),n&&(n=!1,document.querySelector("#__stay_makeup_menu").remove()),d()})),i.addEventListener(s,(t=>{t.stopPropagation(),t.preventDefault(),r.makeupStatus="off"}))),document.querySelector("#__stay_selected_tag")||((a=document.createElement("div")).id="__stay_selected_tag",a.classList.add("__stay_select_target"),document.body.appendChild(a)),d()}function d(){u.isMobileOrIpad()?o.addEventListener("touchstart",h):document.body.addEventListener("mousemove",h)}function f(){u.isMobileOrIpad()?o&&o.removeEventListener("touchstart",h):document.body.removeEventListener("mousemove",h)}function m(t){var e,r,o,i;t.stopPropagation(),t.preventDefault(),n||(n=!0,(t=document.createElement("div")).id="__stay_makeup_menu",t.classList.add("__stay_makeup_menu_wrapper"),t.appendChild(u.parseToDOM(['<div class="__stay_makeup_menu_item_box">','<div class="__stay_menu_item" id="__stay_menu_tag" type="tag"><div>Tag as ad</div><img src="https://res.stayfork.app/scripts/D83C97B84E098F26C669507121FE9EEC/icon.png"></div>','<div class="__stay_menu_item" id="__stay_menu_cancel" type="cancel"><div>Cancel</div><img src="https://res.stayfork.app/scripts/0116C07D465E5D8B7F3F32D2BC6C0946/icon.png"></div>',"</div>"].join(""))),e=document.documentElement.clientHeight,r=a.getBoundingClientRect(),o=document.documentElement.clientWidth,187<=(i=u.add(r.x,r.width))?t.style.right=i<=o?`-${c}px`:u.sub(r.right,o)+"px":r.left+r.width<=187&&r.left<o/2||r.left<=0?t.style.left=`-${c}px`:t.style.left=u.sub(o,r.left)+"px",i=u.add(r.y,r.height),110<=u.sub(e,i)?t.style.top="100%":110<=r.y?t.style.bottom="100%":(t.style.position="fixed",t.style.top="50%",t.style.left="50%",t.style.transform="translate(-50%, -50%)"),a.appendChild(t),document.querySelector("#__stay_makeup_menu #__stay_menu_cancel").addEventListener(s,y),document.querySelector("#__stay_makeup_menu #__stay_menu_tag").addEventListener(s,y))}function y(t){t.preventDefault(),t.stopPropagation(),t=t.currentTarget.getAttribute("type"),"cancel"===t?document.querySelector("#__stay_makeup_menu #__stay_menu_cancel").removeEventListener(s,y):"tag"===t&&document.querySelector("#__stay_makeup_menu #__stay_menu_tag").removeEventListener(s,y),a.removeChild(document.querySelector("#__stay_makeup_menu")),g(),n=!1,d()}function g(){null!=a&&(a.removeEventListener(s,m),a.style.width="0px",a.style.height="0px",a.style.left="0px",a.style.top="0px",a.style.display="none"),null!=o&&(o.style.clipPath="none")}function h(t){t.preventDefault();var e=t.x||t.touches[0].clientX,r=(t=t.y||t.touches[0].clientY,document.elementsFromPoint(e,t));let i=r[0],p=i.getBoundingClientRect();if(r&&1<r.length){if(r.length<3)i=r[1];else if(5<r.length){let t=3;for(i=r[t];p.height>=document.documentElement.clientHeight&&(t-=1,i=r[t],p=i.getBoundingClientRect(),1!=t););}if((p=i.getBoundingClientRect())&&Object.keys(p)){e=p.width,t=p.height;let r=p.left;var l=p.top;for(0==r&&(r=i.offsetLeft)<0&&(r*=-1);a.firstChild;)a.removeChild(a.firstChild);a.style.display="block",n=!1,a.addEventListener(s,m),o.style.clipPath=function(t,e,n,r){return t=u.add(t,c),e=u.add(e,c),n=u.sub(n,u.mul(c,2)),r=u.sub(r,u.mul(c,2)),n=u.add(t,n),r=u.add(e,r),n=`polygon(0 0, 0 ${e}px, ${t}px ${e}px, ${n}px ${e}px, ${n}px ${r}px, ${t}px ${r}px, ${t}px ${e}px, 0 ${e}px, 0 100%,100% 100%, 100% 0)`,n}(r,l,e,t),a.style.width=e+"px",a.style.height=t+"px",a.style.left=r+"px",a.style.top=l+"px",f()}}}Object.defineProperty(r,"makeupStatus",{get:function(){return makeupStatus},set:function(t){p(makeupStatus=t)}})}!async function(){if("a"==await new Promise(((t,e)=>{i.runtime.sendMessage({from:"content_script",operate:"GET_STAY_AROUND"},(e=>{let n="";e.body&&"{}"!=JSON.stringify(e.body)&&(n=e.body),t(n)}))})))try{{var t=window.MutationObserver||window.WebKitMutationObserver||window.MozMutationObserver;let e=window.location.host,n=document.createElement("script"),o=(n.type="text/javascript",n.id="__stay_inject_selecte_ad_tag_js_"+e,`\n\nconst handleInjectSelectedAdTagJS = ${r}\n\nhandleInjectSelectedAdTagJS(false);`);if(n.appendChild(document.createTextNode(o)),document.body)document.body.appendChild(n);else{let e=new t(((t,r)=>{document.body&&(document.body.appendChild(n),e.disconnect())}));e.observe(document.documentElement,{attributes:!0,childList:!0,characterData:!0,subtree:!0})}}document.addEventListener("securitypolicyviolation",(t=>{r(!0)}))}catch(o){}}(),window.addEventListener("message",(t=>{if(t&&t.data&&t.data.name&&"GET_MAKEUP_TAG_STATUS"===t.data.name){let e=t.data.pid;i.runtime.sendMessage({from:"popup",operate:"getMakeupTagStatus"},(t=>{t=t&&t.makeupTagStatus?t.makeupTagStatus:"on",window.postMessage({pid:e,name:"GET_MAKEUP_TAG_STATUS_RESP",makeupTagStatus:t})}))}}))}})();