(function () {
    "use strict";
    let startTime = new Date().getTime();
    console.log("fallback---startTime-", startTime);
    function getDomain(url) {
        try {
            return new URL(url).hostname.toLowerCase();
        } catch (error) {
            return url.split("/")[0].toLowerCase();
        }
    }
    let browserDomain = getDomain(window.location.href);

    let darkStayAround = window.localStorage.getItem("is_stay_around");
    let darkmodeSettingStr = window.localStorage.getItem("FETCH_DARK_SETTING");
    let darkmodeSetting;
    if(darkmodeSettingStr && darkmodeSettingStr!=="" && darkmodeSettingStr !== "null" && darkmodeSettingStr !== "undefined"  ){
        darkmodeSetting = JSON.parse(darkmodeSettingStr);
        darkModeInit(darkmodeSetting);
        fetchDarkStayAround();
    }else{
        browser.runtime.sendMessage({from: "darkmode", operate: "FETCH_DARK_SETTING"}, (response) => {
            if(response.body && JSON.stringify(response.body)!="{}"){
                darkmodeSetting = response.body;
                window.localStorage.setItem("FETCH_DARK_SETTING", JSON.stringify(darkmodeSetting));
            }
            window.localStorage.setItem("stay_dark_toggle_status", toggleStatus);
            console.log("cleanupDarkmode---1-", (startTime - new Date().getTime()), ",darkStayAround=",darkStayAround);
            darkModeInit(darkmodeSetting);
        });
    }

    async function fetchDarkStayAround(){
        browser.runtime.sendMessage({ from: "darkmode", operate: "FETCH_DARK_SETTING" }, function (response) {
            let darkmodeSetting = response.body;
            console.log("cleanupDarkmode---2-", (new Date().getTime() - startTime), ",darkmodeSetting=",darkmodeSetting);
            window.localStorage.setItem("FETCH_DARK_SETTING", JSON.stringify(darkmodeSetting));
        });
    }

    console.log("fallback---endTime-", new Date().getTime());
    function darkModeInit(darkmodeSetting){
        if (
            darkmodeSetting.isStayAround !== "" && darkmodeSetting.isStayAround === "a" &&
            document.documentElement instanceof HTMLHtmlElement && 
            matchMedia("(prefers-color-scheme: dark)").matches &&
            !document.querySelector(".darkreader--fallback") &&
            darkmodeSetting.toggleStatus!="off" &&
            !darkmodeSetting.siteListDisabled.includes(browserDomain)
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
