(function () {
    "use strict";
    let darkmodeSetting = window.localStorage.getItem("FETCH_DARK_SETTING");
    if(darkmodeSetting && darkmodeSetting!=="" && darkmodeSetting !== "null" && darkmodeSetting !== "undefined"){
        darkModeInit(darkmodeSetting);
        fetchDarkStayAround();
    }else{
        browser.runtime.sendMessage({type: "darkmode", operate: "FETCH_DARK_SETTING"}, (response) => {
            // console.log("FETCH_DARK_SETTING----",response);
            if(response && response.body){
                darkmodeSetting = response.body;
                window.localStorage.setItem("FETCH_DARK_SETTING", darkmodeSetting);
            }
            darkModeInit(darkmodeSetting);
        });
    }

    async function fetchDarkStayAround(){
        browser.runtime.sendMessage({ type: "darkmode", operate: "FETCH_DARK_SETTING" }, function (response) {
            let darkmodeSetting = response.body;
            // console.log("FETCH_DARK_SETTING--darkmodeSetting--",response);
            // console.log("cleanupDarkmode---2-", (new Date().getTime() - startTime), ",darkmodeSetting=",darkmodeSetting);
            window.localStorage.setItem("FETCH_DARK_SETTING", darkmodeSetting);
        });
    }

    // console.log("fallback---endTime-", new Date().getTime());
    function darkModeInit(darkmodeSetting){
        if (
            darkmodeSetting !== "" && darkmodeSetting === "dark_mode" &&
            !document.querySelector(".darkreader--fallback") &&
            !(document.querySelector(".noir") && document.querySelector(".noir-root")) &&
            document.documentElement instanceof HTMLHtmlElement 
        ) {
            // alert("insert CSS");
            // console.log("insert CSSinsert CSSinsert CSSinsert CSSinsert CSS");
            const css =
                'html, body, body :not(iframe):not(div[style^="position:absolute;top:0;left:-"]) { background-color: #181a1b !important; border-color: #776e62 !important; color: #e8e6e3 !important; } html, body { opacity: 1 !important; transition: none !important; }';
            const fallback = document.createElement("style");
            fallback.classList.add("darkreader");
            fallback.classList.add("darkreader--fallback");
            fallback.media = "screen";
            fallback.textContent = css;
            if (document.head) {
                document.head.append(fallback);
            } else {
                const root = document.documentElement;
                root.append(fallback);
                const observer = new MutationObserver(() => {
                    if (document.head) {
                        observer.disconnect();
                        if (fallback.isConnected) {
                            document.head.append(fallback);
                        }
                    }
                });
                observer.observe(root, {childList: true});
            }
        }
        if(darkmodeSetting === "dark_mode" && document.querySelector(".noir") && document.querySelector(".noir-root")){
            function languageCode() {
                let lang = (navigator.languages && navigator.languages.length > 0) ? navigator.languages[0]
                    : (navigator.language || navigator.userLanguage /* IE */ || 'en');
                lang = lang.toLowerCase();
                lang = lang.replace(/-/, "_"); // some browsers report language as en-US instead of en_US
                if (lang.length > 3) {
                    lang = lang.substring(0, 3) + lang.substring(3).toUpperCase();
                }
                if (lang == "zh_TW" || lang == "zh_MO"){
                    lang = "zh_HK"
                }
                return lang;
            }
            const langMessage = {
                "en_US": {
                    "conflicts":"Stay dark mode conflicts with other extensions, please select the dark mode extension appropriately"
                },
                "zh_CN": {
                    "conflicts":"Stay暗黑模式与其他扩展插件有冲突，请适当选用暗黑模式扩展插件"
                },
                "zh_HK": {
                    "conflicts":"Stay黯黑模式與其他擴展插件有衝突，請適當選用暗黑模式擴展程序"
                },
            }
            alert(langMessage[languageCode()].conflicts);
        }
    }
})();
