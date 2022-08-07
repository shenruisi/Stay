(function () {
    "use strict";
    let startTime = new Date().getTime();
    console.log("fallback---startTime-", startTime);
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

    let darkStayAround = window.localStorage.getItem("is_stay_around");
    if(darkStayAround && darkStayAround !== "" && darkStayAround !== "null" && darkStayAround !== "undefined" && "a" === darkStayAround){
        darkModeInit(darkStayAround);
        fetchDarkStayAround()
    }else{
        browser.runtime.sendMessage({from: "darkmode", operate: "FETCH_DARK_STAY"}, (response) => {
            darkStayAround = response.body;
            window.localStorage.setItem("is_stay_around", darkStayAround);
            console.log("cleanupDarkmode---1-", (startTime - new Date().getTime()), ",darkStayAround=",darkStayAround);
            darkModeInit(darkStayAround);
        });
    }
   
    async function fetchDarkStayAround(){
        browser.runtime.sendMessage({ from: "darkmode", operate: "GET_STAY_AROUND" }, function (response) {
            let isStayAround = response.body;
            console.log("cleanupDarkmode---2-", (new Date().getTime() - startTime), ",isStayAround=",isStayAround);
            window.localStorage.setItem("is_stay_around", isStayAround);
        });
    }

    console.log("fallback---endTime-", new Date().getTime());
    function darkModeInit(isStayAround){
        if (
            isStayAround !== "" && isStayAround === "a" &&
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
