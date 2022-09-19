(function () {
    "use strict";
    injectFallback()
    function injectFallback(){
        let startTime = new Date().getTime();
        // console.log("fallback,startTime----",startTime);
        function getDomain(url) {
            try {
                return new URL(url).hostname.toLowerCase();
            } catch (error) {
                return url.split("/")[0].toLowerCase();
            }
        }
        
        let browserDomain = getDomain(window.location.href);
        let darkmodeSettingStr = window.localStorage.getItem("FETCH_DARK_SETTING");
        if(darkmodeSettingStr && darkmodeSettingStr!=="" && darkmodeSettingStr !== "null" && darkmodeSettingStr !== "undefined" 
            && darkmodeSettingStr != "clean_up" && darkmodeSettingStr != "dark_mode"){
            let darkmodeSettingStorage = JSON.parse(darkmodeSettingStr);
            let darkmodeSetting = {...darkmodeSettingStorage}
            darkModeInit(darkmodeSetting);
            // console.log("cleanupDarkmode---1-", (startTime - new Date().getTime()), ",darkStayAround=");
        }
        else{
            browser.runtime.sendMessage({from: "darkmode", operate: "FETCH_DARK_SETTING"}, (response) => {
                if(response.body && JSON.stringify(response.body)!="{}"){
                    darkmodeSetting = response.body;
                    window.localStorage.setItem("FETCH_DARK_SETTING", JSON.stringify(darkmodeSetting));
                }
                // console.log("cleanupDarkmode---2-", (startTime - new Date().getTime()), ",darkStayAround=");
                darkModeInit(darkmodeSetting);
            });
        }

        function matchesMediaQuery(query){
            return Boolean(window.matchMedia(query).matches);
        }
        
        function matchesDarkTheme () {
            return matchesMediaQuery("(prefers-color-scheme: dark)");
        } 

        function checkDarkState(darkmodeSetting){
            // console.log("darkmodeSetting.siteListDisabled ====", darkmodeSetting.siteListDisabled , !darkmodeSetting.siteListDisabled.includes(browserDomain))
            if(typeof darkmodeSetting.darkState != "undefined" && darkmodeSetting.darkState !== "" && darkmodeSetting.darkState === "dark_mode"){
                return true;
            }else{
                if(typeof darkmodeSetting.isStayAround != "undefined" && darkmodeSetting.isStayAround !== "" && darkmodeSetting.isStayAround === "a"){
                    if((matchesDarkTheme() && darkmodeSetting.toggleStatus!="off" && darkmodeSetting.siteListDisabled && darkmodeSetting.siteListDisabled!=="[]" && darkmodeSetting.siteListDisabled.length>0 && !darkmodeSetting.siteListDisabled.includes(browserDomain)) 
                        || (!matchesDarkTheme() && darkmodeSetting.toggleStatus ==="on" && darkmodeSetting.siteListDisabled && darkmodeSetting.siteListDisabled!=="[]" && darkmodeSetting.siteListDisabled.length>0 && !darkmodeSetting.siteListDisabled.includes(browserDomain))){
                        return true;
                    }
                }
            }
            return false;
        }

        function darkModeInit(darkmodeSetting){
            if (
                !document.querySelector(".darkreader--fallback") &&
                !(document.querySelector(".noir") && document.querySelector(".noir-root")) &&
                document.documentElement instanceof HTMLHtmlElement && checkDarkState(darkmodeSetting)
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
    }
})();