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
            document.documentElement instanceof HTMLHtmlElement 
        ) {
            // alert("insert CSS");
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
