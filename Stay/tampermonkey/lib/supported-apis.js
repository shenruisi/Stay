'use strict';
const GM_APIS = new Set([
    "GM_log",
    "GM_deleteValue",
    "GM.deleteValue",
    "GM_getValue",
    "GM.getValue",
    "GM_listValues",
    "GM.listValues",
    "GM_setValue",
    "GM.setValue",
    "GM_registerMenuCommand",
    "GM.registerMenuCommand",
    "GM_addStyle",
    "GM.addStyle",
    "none",
    "None",
    "unsafeWindow"
]);
const UserScriptUnsupport_TAGS = new Set(["source","connect"]);
const RunAtUnsupport_ATTRS = new Set(["context-menu"]);
