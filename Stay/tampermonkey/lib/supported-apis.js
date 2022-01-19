'use strict';
const GM_APIS = new Set(["GM_log","GM_deleteValue","GM_getValue","GM_listValues","GM_setValue"]);
const UserScriptUnsupport_TAGS = new Set(["source","connect","resource"]);
const RunAtUnsupport_ATTRS = new Set(["context-menu"]);
