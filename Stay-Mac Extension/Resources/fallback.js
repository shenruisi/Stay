(function () {
    "use strict";
    const DARK_MODE_CONFIG = {
        isStayAround: "b",
        siteListDisabled: [],
        toggleStatus:"on", //on,off,auto
    };
    function getDomain(url) {
        try {
            return new URL(url).hostname.toLowerCase();
        } catch (error) {
            return url.split("/")[0].toLowerCase();
        }
    }
    let browserDomain = getDomain(window.location.href);
    let startTime = new Date().getTime();
    console.log("cleanupDarkmode---1-", startTime);
    // browser.runtime.sendMessage({from: "darkmode", operate: "FETCH_DARK_SETTING"}, (response) => {
    //     let darkmodeSetting = response.body;
    //     if(!(typeof darkmodeSetting === "object" && darkmodeSetting != null && JSON.stringify(darkmodeSetting) !== '{}')){
    //         darkmodeSetting = DARK_MODE_CONFIG
    //     }
    //     console.log("cleanupDarkmode---2-", (startTime - new Date().getTime()), ",darkmodeSetting=",darkmodeSetting);
    //     // darkModeInit(darkmodeSetting);
        
    // });


    // browser.runtime.sendMessage({ from: "darkmode", operate: "GET_STAY_AROUND" }, function (response) {
    //     let isStayAround = response.body;
    //     console.log("cleanupDarkmode---2-", (new Date().getTime() - startTime), ",isStayAround=",isStayAround);
    //     isStayAround = "a";
    //     darkModeInit(isStayAround)
    // });
    darkModeInit()
    function darkModeInit(){
        // let darkmodeConfig = DARK_MODE_CONFIG;
        // let darkmodeConfig = await readLocalStorage(DARK_MODE_CONFIG);
        // (
        //     // 系统暗黑模式，且stay dark Mode 非关闭状态且不屏蔽网站
        //     (matchMedia("(prefers-color-scheme: dark)").matches && "off" !== darkmodeConfig.toggleStatus && !darkmodeConfig.siteListDisabled.includes(browserDomain)) ||
        //     // 系统非暗黑模式，且stay dark Mode 开启状态且不屏蔽网站
        //     (!matchMedia("(prefers-color-scheme: dark)").matches && "on" === darkmodeConfig.toggleStatus && !darkmodeConfig.siteListDisabled.includes(browserDomain))
        // )
        if (
            document.documentElement instanceof HTMLHtmlElement && 
            matchMedia("(prefers-color-scheme: dark)") &&
            !document.querySelector(".darkreader--fallback")
        ) {
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
    }
})();
