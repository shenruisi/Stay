/**
 * This file guarantees call GM api in a sandbox.
 */


const GM_log = (message) => {
    
};


const GM_getValue = (key) => {
    browser.runtime.sendMessage({ from: "gm-apis", operate: "GM_getValue", key:key })
};

