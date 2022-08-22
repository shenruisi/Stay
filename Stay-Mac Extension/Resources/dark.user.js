// ==UserScript==
// @name         暗黑模式V2
// @namespace    http://stay.app/
// @version      2.0
// @description  支持浏览器网页暗黑模式
// @author       Stay²
// @match        *://*/*
// @include      http://*
// @include      https://*
// @grant        GM_log
// @run-at       document-start
// ==/UserScript==

(function () {
    "use strict";
    // console.log("darkUser---startTime-1=", new Date().getTime());
    /*! *****************************************************************************
    Dark Reader v4.9.42  https://darkreader.org/
    Copyright (c) Microsoft Corporation.

    Permission to use, copy, modify, and/or distribute this software for any
    purpose with or without fee is hereby granted.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
    REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
    AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
    LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
    OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
    ***************************************************************************** */
    const userAgent =
        typeof navigator === "undefined"
            ? "some useragent"
            : navigator.userAgent.toLowerCase();
    const platform =
        typeof navigator === "undefined"
            ? "some platform"
            : navigator.platform.toLowerCase();
    const isChromium =
        userAgent.includes("chrome") || userAgent.includes("chromium");
    const isThunderbird = userAgent.includes("thunderbird");
    const isSafari = userAgent.includes("safari") || isThunderbird;
    userAgent.includes("vivaldi");
    userAgent.includes("yabrowser");
    userAgent.includes("opr") || userAgent.includes("opera");
    userAgent.includes("edg");
    // const isSafari = userAgent.includes("safari") && !isChromium;
    platform.startsWith("win");
    platform.startsWith("mac");
    userAgent.includes("mobile");
    var isWindows = platform.startsWith('win');
    var isMacOS = platform.startsWith('mac');
    var ThemeEngines = {
        cssFilter: 'cssFilter',
        svgFilter: 'svgFilter',
        staticTheme: 'staticTheme',
        dynamicTheme: 'dynamicTheme',
    };
    var DEFAULT_COLORS = {
        darkScheme: {
            background: '#181a1b',
            text: '#e8e6e3',
        },
        lightScheme: {
            background: '#dcdad7',
            text: '#181a1b',
        },
    };

    var DEFAULT_THEME = {
        mode: 1,
        brightness: 100,
        contrast: 100,
        grayscale: 0,
        sepia: 0,
        useFont: false,
        fontFamily: isMacOS ? 'Helvetica Neue' : isWindows ? 'Segoe UI' : 'Open Sans',
        textStroke: 0,
        engine: ThemeEngines.dynamicTheme,
        stylesheet: '',
        darkSchemeBackgroundColor: DEFAULT_COLORS.darkScheme.background,
        darkSchemeTextColor: DEFAULT_COLORS.darkScheme.text,
        lightSchemeBackgroundColor: DEFAULT_COLORS.lightScheme.background,
        lightSchemeTextColor: DEFAULT_COLORS.lightScheme.text,
        scrollbarColor: isMacOS ? '' : 'auto',
        selectionColor: 'auto',
        styleSystemControls: true,
        lightColorScheme: 'Default',
        darkColorScheme: 'Default',
        immediateModify: false
    };
    const MessageType = {
        UI_GET_DATA: "ui-get-data",
        UI_GET_ACTIVE_TAB_INFO: "ui-get-active-tab-info",
        UI_SUBSCRIBE_TO_CHANGES: "ui-subscribe-to-changes",
        UI_UNSUBSCRIBE_FROM_CHANGES: "ui-unsubscribe-from-changes",
        UI_CHANGE_SETTINGS: "ui-change-settings",
        UI_SET_THEME: "ui-set-theme",
        UI_SET_SHORTCUT: "ui-set-shortcut",
        UI_TOGGLE_URL: "ui-toggle-url",
        UI_MARK_NEWS_AS_READ: "ui-mark-news-as-read",
        UI_LOAD_CONFIG: "ui-load-config",
        UI_APPLY_DEV_DYNAMIC_THEME_FIXES: "ui-apply-dev-dynamic-theme-fixes",
        UI_RESET_DEV_DYNAMIC_THEME_FIXES: "ui-reset-dev-dynamic-theme-fixes",
        UI_APPLY_DEV_INVERSION_FIXES: "ui-apply-dev-inversion-fixes",
        UI_RESET_DEV_INVERSION_FIXES: "ui-reset-dev-inversion-fixes",
        UI_APPLY_DEV_STATIC_THEMES: "ui-apply-dev-static-themes",
        UI_RESET_DEV_STATIC_THEMES: "ui-reset-dev-static-themes",
        UI_SAVE_FILE: "ui-save-file",
        UI_REQUEST_EXPORT_CSS: "ui-request-export-css",
        BG_CHANGES: "bg-changes",
        BG_ADD_CSS_FILTER: "bg-add-css-filter",
        BG_ADD_STATIC_THEME: "bg-add-static-theme",
        BG_ADD_SVG_FILTER: "bg-add-svg-filter",
        BG_ADD_DYNAMIC_THEME: "bg-add-dynamic-theme",
        BG_EXPORT_CSS: "bg-export-css",
        BG_UNSUPPORTED_SENDER: "bg-unsupported-sender",
        BG_CLEAN_UP: "bg-clean-up",
        BG_RELOAD: "bg-reload",
        BG_FETCH_RESPONSE: "bg-fetch-response",
        BG_UI_UPDATE: "bg-ui-update",
        BG_CSS_UPDATE: "bg-css-update",
        CS_COLOR_SCHEME_CHANGE: "cs-color-scheme-change",
        CS_FRAME_CONNECT: "cs-frame-connect",
        CS_FRAME_FORGET: "cs-frame-forget",
        CS_FRAME_FREEZE: "cs-frame-freeze",
        CS_FRAME_RESUME: "cs-frame-resume",
        CS_EXPORT_CSS_RESPONSE: "cs-export-css-response",
        CS_FETCH: "cs-fetch",
        CS_DARK_THEME_DETECTED: "cs-dark-theme-detected",
    };
    let isIFrame = (function () {
        try {
            return window.self !== window.top;
        }
        catch (err) {
            console.warn(err);
            return true;
        }
    })();
    const isCSSColorSchemePropSupported = (() => {
        if (typeof document === "undefined") {
            return false;
        }
        const el = document.createElement("div");
        el.setAttribute("style", "color-scheme: dark");
        return el.style && el.style.colorScheme === "dark";
    })();
    function logInfo(...args) { }
    function logWarn(...args) { }
    var FilterMode;
    (function (FilterMode) {
        FilterMode[(FilterMode.light = 0)] = "light";
        FilterMode[(FilterMode.dark = 1)] = "dark";
    })(FilterMode || (FilterMode = {}));
    function throttle(callback) {
        let pending = false;
        let frameId = null;
        let lastArgs;
        const throttled = (...args) => {
            lastArgs = args;
            if (frameId) {
                pending = true;
            } else {
                callback(...lastArgs);
                frameId = requestAnimationFrame(() => {
                    frameId = null;
                    if (pending) {
                        callback(...lastArgs);
                        pending = false;
                    }
                });
            }
        };
        const cancel = () => {
            cancelAnimationFrame(frameId);
            pending = false;
            frameId = null;
        };
        return Object.assign(throttled, { cancel });
    }
    function createAsyncTasksQueue() {
        const tasks = [];
        let frameId = null;
        function runTasks() {
            let task;
            while ((task = tasks.shift())) {
                task();
            }
            frameId = null;
        }
        function add(task) {
            tasks.push(task);
            if (!frameId) {
                frameId = requestAnimationFrame(runTasks);
            }
        }
        function cancel() {
            tasks.splice(0);
            cancelAnimationFrame(frameId);
            frameId = null;
        }
        return { add, cancel };
    }

    function isArrayLike(items) {
        return items.length != null;
    }
    function forEach(items, iterator) {
        if (isArrayLike(items)) {
            for (let i = 0, len = items.length; i < len; i++) {
                iterator(items[i]);
            }
        } else {
            for (const item of items) {
                iterator(item);
            }
        }
    }
    function push(array, addition) {
        forEach(addition, (a) => array.push(a));
    }
    function toArray(items) {
        const results = [];
        for (let i = 0, len = items.length; i < len; i++) {
            results.push(items[i]);
        }
        return results;
    }

    function getDuration(time) {
        let duration = 0;
        if (time.seconds) {
            duration += time.seconds * 1000;
        }
        if (time.minutes) {
            duration += time.minutes * 60 * 1000;
        }
        if (time.hours) {
            duration += time.hours * 60 * 60 * 1000;
        }
        if (time.days) {
            duration += time.days * 24 * 60 * 60 * 1000;
        }
        return duration;
    }

    function createNodeAsap({
        selectNode,
        createNode,
        updateNode,
        selectTarget,
        createTarget,
        isTargetMutation
    }) {
        const target = selectTarget();
        if (target) {
            const prev = selectNode();
            if (prev) {
                updateNode(prev);
            } else {
                createNode(target);
            }
        } else {
            const observer = new MutationObserver((mutations) => {
                const mutation = mutations.find(isTargetMutation);
                if (mutation) {
                    unsubscribe();
                    const target = selectTarget();
                    selectNode() || createNode(target);
                }
            });
            const ready = () => {
                if (document.readyState !== "complete") {
                    return;
                }
                unsubscribe();
                const target = selectTarget() || createTarget();
                selectNode() || createNode(target);
            };
            const unsubscribe = () => {
                document.removeEventListener("readystatechange", ready);
                observer.disconnect();
            };
            if (document.readyState === "complete") {
                ready();
            } else {
                document.addEventListener("readystatechange", ready);
                observer.observe(document, { childList: true, subtree: true });
            }
        }
    }
    function removeNode(node) {
        node && node.parentNode && node.parentNode.removeChild(node);
    }
    function watchForNodePosition(node, mode, onRestore = Function.prototype) {
        const MAX_ATTEMPTS_COUNT = 10;
        const RETRY_TIMEOUT = getDuration({ seconds: 2 });
        const ATTEMPTS_INTERVAL = getDuration({ seconds: 10 });
        const prevSibling = node.previousSibling;
        let parent = node.parentNode;
        if (!parent) {
            throw new Error(
                "Unable to watch for node position: parent element not found"
            );
        }
        if (mode === "prev-sibling" && !prevSibling) {
            throw new Error(
                "Unable to watch for node position: there is no previous sibling"
            );
        }
        let attempts = 0;
        let start = null;
        let timeoutId = null;
        const restore = throttle(() => {
            if (timeoutId) {
                return;
            }
            attempts++;
            const now = Date.now();
            if (start == null) {
                start = now;
            } else if (attempts >= MAX_ATTEMPTS_COUNT) {
                if (now - start < ATTEMPTS_INTERVAL) {
                    timeoutId = setTimeout(() => {
                        start = null;
                        attempts = 0;
                        timeoutId = null;
                        restore();
                    }, RETRY_TIMEOUT);
                    return;
                }
                start = now;
                attempts = 1;
            }
            if (mode === "parent") {
                if (prevSibling && prevSibling.parentNode !== parent) {
                    stop();
                    return;
                }
            }
            if (mode === "prev-sibling") {
                if (prevSibling.parentNode == null) {
                    stop();
                    return;
                }
                if (prevSibling.parentNode !== parent) {
                    updateParent(prevSibling.parentNode);
                }
            }
            parent.insertBefore(
                node,
                prevSibling ? prevSibling.nextSibling : parent.firstChild
            );
            observer.takeRecords();
            onRestore && onRestore();
        });
        const observer = new MutationObserver(() => {
            if (
                (mode === "parent" && node.parentNode !== parent) ||
                (mode === "prev-sibling" &&
                    node.previousSibling !== prevSibling)
            ) {
                restore();
            }
        });
        const run = () => {
            observer.observe(parent, { childList: true });
        };
        const stop = () => {
            clearTimeout(timeoutId);
            observer.disconnect();
            restore.cancel();
        };
        const skip = () => {
            observer.takeRecords();
        };
        const updateParent = (parentNode) => {
            parent = parentNode;
            stop();
            run();
        };
        run();
        return { run, stop, skip };
    }
    function iterateShadowHosts(root, iterator) {
        if (root == null) {
            return;
        }
        const walker = document.createTreeWalker(
            root,
            NodeFilter.SHOW_ELEMENT,
            {
                acceptNode(node) {
                    return node.shadowRoot == null
                        ? NodeFilter.FILTER_SKIP
                        : NodeFilter.FILTER_ACCEPT;
                }
            }
        );
        for (
            let node = root.shadowRoot ? walker.currentNode : walker.nextNode();
            node != null;
            node = walker.nextNode()
        ) {
            iterator(node);
            iterateShadowHosts(node.shadowRoot, iterator);
        }
    }
    function setIsDOMReady(newFunc) {
        isDOMReady = newFunc;
    }
    function isDOMReady() {
        return (
            document.readyState === "complete" ||
            document.readyState === "interactive"
        );
    }
    const readyStateListeners = new Set();
    function addDOMReadyListener(listener) {
        readyStateListeners.add(listener);
    }
    function removeDOMReadyListener(listener) {
        readyStateListeners.delete(listener);
    }
    function isReadyStateComplete() {
        return document.readyState === "complete";
    }
    const readyStateCompleteListeners = new Set();
    function addReadyStateCompleteListener(listener) {
        readyStateCompleteListeners.add(listener);
    }
    function cleanReadyStateCompleteListeners() {
        readyStateCompleteListeners.clear();
    }
    if (!isDOMReady()) {
        const onReadyStateChange = () => {
            if (isDOMReady()) {
                readyStateListeners.forEach((listener) => listener());
                readyStateListeners.clear();
                if (isReadyStateComplete()) {
                    document.removeEventListener(
                        "readystatechange",
                        onReadyStateChange
                    );
                    readyStateCompleteListeners.forEach((listener) =>
                        listener()
                    );
                    readyStateCompleteListeners.clear();
                }
            }
        };
        document.addEventListener("readystatechange", onReadyStateChange);
    }
    const HUGE_MUTATIONS_COUNT = 1000;
    function isHugeMutation(mutations) {
        if (mutations.length > HUGE_MUTATIONS_COUNT) {
            return true;
        }
        let addedNodesCount = 0;
        for (let i = 0; i < mutations.length; i++) {
            addedNodesCount += mutations[i].addedNodes.length;
            if (addedNodesCount > HUGE_MUTATIONS_COUNT) {
                return true;
            }
        }
        return false;
    }
    function getElementsTreeOperations(mutations) {
        const additions = new Set();
        const deletions = new Set();
        const moves = new Set();
        mutations.forEach((m) => {
            forEach(m.addedNodes, (n) => {
                if (n instanceof Element && n.isConnected) {
                    additions.add(n);
                }
            });
            forEach(m.removedNodes, (n) => {
                if (n instanceof Element) {
                    if (n.isConnected) {
                        moves.add(n);
                        additions.delete(n);
                    } else {
                        deletions.add(n);
                    }
                }
            });
        });
        const duplicateAdditions = [];
        const duplicateDeletions = [];
        additions.forEach((node) => {
            if (additions.has(node.parentElement)) {
                duplicateAdditions.push(node);
            }
        });
        deletions.forEach((node) => {
            if (deletions.has(node.parentElement)) {
                duplicateDeletions.push(node);
            }
        });
        duplicateAdditions.forEach((node) => additions.delete(node));
        duplicateDeletions.forEach((node) => deletions.delete(node));
        return { additions, moves, deletions };
    }
    const optimizedTreeObservers = new Map();
    const optimizedTreeCallbacks = new WeakMap();
    function createOptimizedTreeObserver(root, callbacks) {
        let observer;
        let observerCallbacks;
        let domReadyListener;
        if (optimizedTreeObservers.has(root)) {
            observer = optimizedTreeObservers.get(root);
            observerCallbacks = optimizedTreeCallbacks.get(observer);
        } else {
            let hadHugeMutationsBefore = false;
            let subscribedForReadyState = false;
            observer = new MutationObserver((mutations) => {
                if (isHugeMutation(mutations)) {
                    if (!hadHugeMutationsBefore || isDOMReady()) {
                        observerCallbacks.forEach(({ onHugeMutations }) =>
                            onHugeMutations(root)
                        );
                    } else if (!subscribedForReadyState) {
                        domReadyListener = () =>
                            observerCallbacks.forEach(({ onHugeMutations }) =>
                                onHugeMutations(root)
                            );
                        addDOMReadyListener(domReadyListener);
                        subscribedForReadyState = true;
                    }
                    hadHugeMutationsBefore = true;
                } else {
                    const elementsOperations =
                        getElementsTreeOperations(mutations);
                    observerCallbacks.forEach(({ onMinorMutations }) =>
                        onMinorMutations(elementsOperations)
                    );
                }
            });
            observer.observe(root, { childList: true, subtree: true });
            optimizedTreeObservers.set(root, observer);
            observerCallbacks = new Set();
            optimizedTreeCallbacks.set(observer, observerCallbacks);
        }
        observerCallbacks.add(callbacks);
        return {
            disconnect() {
                observerCallbacks.delete(callbacks);
                if (domReadyListener) {
                    removeDOMReadyListener(domReadyListener);
                }
                if (observerCallbacks.size === 0) {
                    observer.disconnect();
                    optimizedTreeCallbacks.delete(observer);
                    optimizedTreeObservers.delete(root);
                }
            }
        };
    }

    function createOrUpdateStyle$1(css, type) {
        createNodeAsap({
            selectNode: () => document.getElementById("dark-reader-style"),
            createNode: (target) => {
                document.documentElement.setAttribute(
                    "data-darkreader-mode",
                    type
                );
                const style = document.createElement("style");
                style.id = "dark-reader-style";
                style.type = "text/css";
                style.textContent = css;
                target.appendChild(style);
            },
            updateNode: (existing) => {
                if (
                    css.replace(/^\s+/gm, "") !==
                    existing.textContent.replace(/^\s+/gm, "")
                ) {
                    existing.textContent = css;
                }
            },
            selectTarget: () => document.head,
            createTarget: () => {
                const head = document.createElement("head");
                document.documentElement.insertBefore(
                    head,
                    document.documentElement.firstElementChild
                );
                return head;
            },
            isTargetMutation: (mutation) =>
                mutation.target.nodeName.toLowerCase() === "head"
        });
    }
    function removeSVGFilter() {
        removeNode(document.getElementById("dark-reader-svg"));
    }
    function removeStyle() {
        removeNode(document.getElementById("dark-reader-style"));
        document.documentElement.removeAttribute("data-darkreader-mode");
    }
    const isShadowDomSupported = typeof ShadowRoot === "function";
    const isMatchMediaChangeEventListenerSupported =
        typeof MediaQueryList === "function" &&
        typeof MediaQueryList.prototype.addEventListener === "function";
    (() => {
        const m = userAgent.match(/chrom[e|ium]\/([^ ]+)/);
        if (m && m[1]) {
            return m[1];
        }
        return "";
    })();
    const isDefinedSelectorSupported = (() => {
        try {
            document.querySelector(":defined");
            return true;
        } catch (err) {
            return false;
        }
    })();
    globalThis.chrome &&
        globalThis.chrome.runtime &&
        globalThis.chrome.runtime.getManifest &&
        globalThis.chrome.runtime.getManifest().manifest_version === 3;

    let anchor;
    const parsedURLCache = new Map();
    function fixBaseURL($url) {
        if (!anchor) {
            anchor = document.createElement("a");
        }
        anchor.href = $url;
        return anchor.href;
    }
    function parseURL($url, $base = null) {
        const key = `${$url}${$base ? `;${$base}` : ""}`;
        if (parsedURLCache.has(key)) {
            return parsedURLCache.get(key);
        }
        if ($base) {
            const parsedURL = new URL($url, fixBaseURL($base));
            parsedURLCache.set(key, parsedURL);
            return parsedURL;
        }
        const parsedURL = new URL(fixBaseURL($url));
        parsedURLCache.set($url, parsedURL);
        return parsedURL;
    }
    function getAbsoluteURL($base, $relative) {
        if ($relative.match(/^data\\?\:/)) {
            return $relative;
        }
        if (/^\/\//.test($relative)) {
            return `${location.protocol}${$relative}`;
        }
        const b = parseURL($base);
        const a = parseURL($relative, b.href);
        return a.href;
    }
    function isRelativeHrefOnAbsolutePath(href) {
        if (href.startsWith("data:")) {
            return true;
        }
        const url = parseURL(href);
        if (url.protocol !== location.protocol) {
            return false;
        }
        if (url.hostname !== location.hostname) {
            return false;
        }
        if (url.port !== location.port) {
            return false;
        }
        return url.pathname === location.pathname;
    }

    function iterateCSSRules(rules, iterate, onMediaRuleError) {
        forEach(rules, (rule) => {
            if (rule.selectorText) {
                iterate(rule);
            } else if (rule.href) {
                try {
                    iterateCSSRules(
                        rule.styleSheet.cssRules,
                        iterate,
                        onMediaRuleError
                    );
                } catch (err) {
                    onMediaRuleError && onMediaRuleError();
                }
            } else if (rule.media) {
                const media = Array.from(rule.media);
                const isScreenOrAll = media.some(
                    (m) => m.startsWith("screen") || m.startsWith("all")
                );
                const isPrintOrSpeech = media.some(
                    (m) => m.startsWith("print") || m.startsWith("speech")
                );
                if (isScreenOrAll || !isPrintOrSpeech) {
                    iterateCSSRules(rule.cssRules, iterate, onMediaRuleError);
                }
            } else if (rule.conditionText) {
                if (CSS.supports(rule.conditionText)) {
                    iterateCSSRules(rule.cssRules, iterate, onMediaRuleError);
                }
            } else;
        });
    }
    const shorthandVarDependantProperties = [
        "background",
        "border",
        "border-color",
        "border-bottom",
        "border-left",
        "border-right",
        "border-top",
        "outline",
        "outline-color"
    ];
    const shorthandVarDepPropRegexps = isSafari
        ? shorthandVarDependantProperties.map((prop) => {
            const regexp = new RegExp(`${prop}:\\s*(.*?)\\s*;`);
            return [prop, regexp];
        })
        : null;
    function iterateCSSDeclarations(style, iterate) {
        forEach(style, (property) => {
            const value = style.getPropertyValue(property).trim();
            if (!value) {
                return;
            }
            iterate(property, value);
        });
        const cssText = style.cssText;
        if (cssText.includes("var(")) {
            if (isSafari) {
                shorthandVarDepPropRegexps.forEach(([prop, regexp]) => {
                    const match = cssText.match(regexp);
                    if (match && match[1]) {
                        const val = match[1].trim();
                        iterate(prop, val);
                    }
                });
            } else {
                shorthandVarDependantProperties.forEach((prop) => {
                    const val = style.getPropertyValue(prop);
                    if (val && val.includes("var(")) {
                        iterate(prop, val);
                    }
                });
            }
        }
    }
    const cssURLRegex = /url\((('.+?')|(".+?")|([^\)]*?))\)/g;
    const cssImportRegex =
        /@import\s*(url\()?(('.+?')|(".+?")|([^\)]*?))\)?;?/g;
    function getCSSURLValue(cssURL) {
        return cssURL
            .replace(/^url\((.*)\)$/, "$1")
            .trim()
            .replace(/^"(.*)"$/, "$1")
            .replace(/^'(.*)'$/, "$1");
    }
    function getCSSBaseBath(url) {
        const cssURL = parseURL(url);
        return `${cssURL.origin}${cssURL.pathname
            .replace(/\?.*$/, "")
            .replace(/(\/)([^\/]+)$/i, "$1")}`;
    }
    function replaceCSSRelativeURLsWithAbsolute($css, cssBasePath) {
        return $css.replace(cssURLRegex, (match) => {
            const pathValue = getCSSURLValue(match);
            return `url("${getAbsoluteURL(cssBasePath, pathValue)}")`;
        });
    }
    const cssCommentsRegex = /\/\*[\s\S]*?\*\//g;
    function removeCSSComments($css) {
        return $css.replace(cssCommentsRegex, "");
    }
    const fontFaceRegex = /@font-face\s*{[^}]*}/g;
    function replaceCSSFontFace($css) {
        return $css.replace(fontFaceRegex, "");
    }

    function hslToRGB({ h, s, l, a = 1 }) {
        if (s === 0) {
            const [r, b, g] = [l, l, l].map((x) => Math.round(x * 255));
            return { r, g, b, a };
        }
        const c = (1 - Math.abs(2 * l - 1)) * s;
        const x = c * (1 - Math.abs(((h / 60) % 2) - 1));
        const m = l - c / 2;
        const [r, g, b] = (
            h < 60
                ? [c, x, 0]
                : h < 120
                    ? [x, c, 0]
                    : h < 180
                        ? [0, c, x]
                        : h < 240
                            ? [0, x, c]
                            : h < 300
                                ? [x, 0, c]
                                : [c, 0, x]
        ).map((n) => Math.round((n + m) * 255));
        return { r, g, b, a };
    }
    function rgbToHSL({ r: r255, g: g255, b: b255, a = 1 }) {
        const r = r255 / 255;
        const g = g255 / 255;
        const b = b255 / 255;
        const max = Math.max(r, g, b);
        const min = Math.min(r, g, b);
        const c = max - min;
        const l = (max + min) / 2;
        if (c === 0) {
            return { h: 0, s: 0, l, a };
        }
        let h =
            (max === r
                ? ((g - b) / c) % 6
                : max === g
                    ? (b - r) / c + 2
                    : (r - g) / c + 4) * 60;
        if (h < 0) {
            h += 360;
        }
        const s = c / (1 - Math.abs(2 * l - 1));
        return { h, s, l, a };
    }
    function toFixed(n, digits = 0) {
        const fixed = n.toFixed(digits);
        if (digits === 0) {
            return fixed;
        }
        const dot = fixed.indexOf(".");
        if (dot >= 0) {
            const zerosMatch = fixed.match(/0+$/);
            if (zerosMatch) {
                if (zerosMatch.index === dot + 1) {
                    return fixed.substring(0, dot);
                }
                return fixed.substring(0, zerosMatch.index);
            }
        }
        return fixed;
    }
    function rgbToString(rgb) {
        const { r, g, b, a } = rgb;
        if (a != null && a < 1) {
            return `rgba(${toFixed(r)}, ${toFixed(g)}, ${toFixed(b)}, ${toFixed(
                a,
                2
            )})`;
        }
        return `rgb(${toFixed(r)}, ${toFixed(g)}, ${toFixed(b)})`;
    }
    function rgbToHexString({ r, g, b, a }) {
        return `#${(a != null && a < 1
            ? [r, g, b, Math.round(a * 255)]
            : [r, g, b]
        )
            .map((x) => {
                return `${x < 16 ? "0" : ""}${x.toString(16)}`;
            })
            .join("")}`;
    }
    function hslToString(hsl) {
        const { h, s, l, a } = hsl;
        if (a != null && a < 1) {
            return `hsla(${toFixed(h)}, ${toFixed(s * 100)}%, ${toFixed(
                l * 100
            )}%, ${toFixed(a, 2)})`;
        }
        return `hsl(${toFixed(h)}, ${toFixed(s * 100)}%, ${toFixed(l * 100)}%)`;
    }
    const rgbMatch = /^rgba?\([^\(\)]+\)$/;
    const hslMatch = /^hsla?\([^\(\)]+\)$/;
    const hexMatch = /^#[0-9a-f]+$/i;
    function parse($color) {
        const c = $color.trim().toLowerCase();
        if (c.match(rgbMatch)) {
            return parseRGB(c);
        }
        if (c.match(hslMatch)) {
            return parseHSL(c);
        }
        if (c.match(hexMatch)) {
            return parseHex(c);
        }
        if (knownColors.has(c)) {
            return getColorByName(c);
        }
        if (systemColors.has(c)) {
            return getSystemColor(c);
        }
        if ($color === "transparent") {
            return { r: 0, g: 0, b: 0, a: 0 };
        }
        throw new Error(`Unable to parse ${$color}`);
    }
    function getNumbers($color) {
        const numbers = [];
        let prevPos = 0;
        let isMining = false;
        const startIndex = $color.indexOf("(");
        $color = $color.substring(startIndex + 1, $color.length - 1);
        for (let i = 0; i < $color.length; i++) {
            const c = $color[i];
            if ((c >= "0" && c <= "9") || c === "." || c === "+" || c === "-") {
                isMining = true;
            } else if (isMining && (c === " " || c === ",")) {
                numbers.push($color.substring(prevPos, i));
                isMining = false;
                prevPos = i + 1;
            } else if (!isMining) {
                prevPos = i + 1;
            }
        }
        if (isMining) {
            numbers.push($color.substring(prevPos, $color.length));
        }
        return numbers;
    }
    function getNumbersFromString(str, range, units) {
        const raw = getNumbers(str);
        const unitsList = Object.entries(units);
        const numbers = raw
            .map((r) => r.trim())
            .map((r, i) => {
                let n;
                const unit = unitsList.find(([u]) => r.endsWith(u));
                if (unit) {
                    n =
                        (parseFloat(r.substring(0, r.length - unit[0].length)) /
                            unit[1]) *
                        range[i];
                } else {
                    n = parseFloat(r);
                }
                if (range[i] > 1) {
                    return Math.round(n);
                }
                return n;
            });
        return numbers;
    }
    const rgbRange = [255, 255, 255, 1];
    const rgbUnits = { "%": 100 };
    function parseRGB($rgb) {
        const [r, g, b, a = 1] = getNumbersFromString($rgb, rgbRange, rgbUnits);
        return { r, g, b, a };
    }
    const hslRange = [360, 1, 1, 1];
    const hslUnits = { "%": 100, "deg": 360, "rad": 2 * Math.PI, "turn": 1 };
    function parseHSL($hsl) {
        const [h, s, l, a = 1] = getNumbersFromString($hsl, hslRange, hslUnits);
        return hslToRGB({ h, s, l, a });
    }
    function parseHex($hex) {
        const h = $hex.substring(1);
        switch (h.length) {
            case 3:
            case 4: {
                const [r, g, b] = [0, 1, 2].map((i) =>
                    parseInt(`${h[i]}${h[i]}`, 16)
                );
                const a =
                    h.length === 3 ? 1 : parseInt(`${h[3]}${h[3]}`, 16) / 255;
                return { r, g, b, a };
            }
            case 6:
            case 8: {
                const [r, g, b] = [0, 2, 4].map((i) =>
                    parseInt(h.substring(i, i + 2), 16)
                );
                const a =
                    h.length === 6 ? 1 : parseInt(h.substring(6, 8), 16) / 255;
                return { r, g, b, a };
            }
        }
        throw new Error(`Unable to parse ${$hex}`);
    }
    function getColorByName($color) {
        const n = knownColors.get($color);
        return {
            r: (n >> 16) & 255,
            g: (n >> 8) & 255,
            b: (n >> 0) & 255,
            a: 1
        };
    }
    function getSystemColor($color) {
        const n = systemColors.get($color);
        return {
            r: (n >> 16) & 255,
            g: (n >> 8) & 255,
            b: (n >> 0) & 255,
            a: 1
        };
    }


    const isCharDigit = (char) => char >= "0" && char <= "9";
    const getAmountOfDigits = (number) => Math.floor(Math.log10(number)) + 1;
    function lowerCalcExpression(color) {
        let searchIndex = 0;
        const replaceBetweenIndices = (start, end, replacement) => {
            color =
                color.substring(0, start) + replacement + color.substring(end);
        };
        const getNumber = () => {
            let resultNumber = 0;
            for (let i = 1; i < 4; i++) {
                const char = color[searchIndex + i];
                if (char === " ") {
                    break;
                }
                if (isCharDigit(char)) {
                    resultNumber *= 10;
                    resultNumber += Number(char);
                } else {
                    break;
                }
            }
            const lenDigits = getAmountOfDigits(resultNumber);
            searchIndex += lenDigits;
            const possibleType = color[searchIndex + 1];
            if (possibleType !== "%") {
                return;
            }
            searchIndex++;
            return resultNumber;
        };
        while ((searchIndex = color.indexOf("calc(")) !== 0) {
            const startIndex = searchIndex;
            searchIndex += 4;
            const firstNumber = getNumber();
            if (!firstNumber) {
                break;
            }
            if (color[searchIndex + 1] !== " ") {
                break;
            }
            searchIndex++;
            const operation = color[searchIndex + 1];
            if (operation !== "+" && operation !== "-") {
                break;
            }
            searchIndex++;
            if (color[searchIndex + 1] !== " ") {
                break;
            }
            searchIndex++;
            const secondNumber = getNumber();
            if (!secondNumber) {
                break;
            }
            let replacement;
            if (operation === "+") {
                replacement = `${firstNumber + secondNumber}%`;
            } else {
                replacement = `${firstNumber - secondNumber}%`;
            }
            replaceBetweenIndices(startIndex, searchIndex + 2, replacement);
        }
        return color;
    }
    const knownColors = new Map(
        Object.entries({
            aliceblue: 0xf0f8ff,
            antiquewhite: 0xfaebd7,
            aqua: 0x00ffff,
            aquamarine: 0x7fffd4,
            azure: 0xf0ffff,
            beige: 0xf5f5dc,
            bisque: 0xffe4c4,
            black: 0x000000,
            blanchedalmond: 0xffebcd,
            blue: 0x0000ff,
            blueviolet: 0x8a2be2,
            brown: 0xa52a2a,
            burlywood: 0xdeb887,
            cadetblue: 0x5f9ea0,
            chartreuse: 0x7fff00,
            chocolate: 0xd2691e,
            coral: 0xff7f50,
            cornflowerblue: 0x6495ed,
            cornsilk: 0xfff8dc,
            crimson: 0xdc143c,
            cyan: 0x00ffff,
            darkblue: 0x00008b,
            darkcyan: 0x008b8b,
            darkgoldenrod: 0xb8860b,
            darkgray: 0xa9a9a9,
            darkgrey: 0xa9a9a9,
            darkgreen: 0x006400,
            darkkhaki: 0xbdb76b,
            darkmagenta: 0x8b008b,
            darkolivegreen: 0x556b2f,
            darkorange: 0xff8c00,
            darkorchid: 0x9932cc,
            darkred: 0x8b0000,
            darksalmon: 0xe9967a,
            darkseagreen: 0x8fbc8f,
            darkslateblue: 0x483d8b,
            darkslategray: 0x2f4f4f,
            darkslategrey: 0x2f4f4f,
            darkturquoise: 0x00ced1,
            darkviolet: 0x9400d3,
            deeppink: 0xff1493,
            deepskyblue: 0x00bfff,
            dimgray: 0x696969,
            dimgrey: 0x696969,
            dodgerblue: 0x1e90ff,
            firebrick: 0xb22222,
            floralwhite: 0xfffaf0,
            forestgreen: 0x228b22,
            fuchsia: 0xff00ff,
            gainsboro: 0xdcdcdc,
            ghostwhite: 0xf8f8ff,
            gold: 0xffd700,
            goldenrod: 0xdaa520,
            gray: 0x808080,
            grey: 0x808080,
            green: 0x008000,
            greenyellow: 0xadff2f,
            honeydew: 0xf0fff0,
            hotpink: 0xff69b4,
            indianred: 0xcd5c5c,
            indigo: 0x4b0082,
            ivory: 0xfffff0,
            khaki: 0xf0e68c,
            lavender: 0xe6e6fa,
            lavenderblush: 0xfff0f5,
            lawngreen: 0x7cfc00,
            lemonchiffon: 0xfffacd,
            lightblue: 0xadd8e6,
            lightcoral: 0xf08080,
            lightcyan: 0xe0ffff,
            lightgoldenrodyellow: 0xfafad2,
            lightgray: 0xd3d3d3,
            lightgrey: 0xd3d3d3,
            lightgreen: 0x90ee90,
            lightpink: 0xffb6c1,
            lightsalmon: 0xffa07a,
            lightseagreen: 0x20b2aa,
            lightskyblue: 0x87cefa,
            lightslategray: 0x778899,
            lightslategrey: 0x778899,
            lightsteelblue: 0xb0c4de,
            lightyellow: 0xffffe0,
            lime: 0x00ff00,
            limegreen: 0x32cd32,
            linen: 0xfaf0e6,
            magenta: 0xff00ff,
            maroon: 0x800000,
            mediumaquamarine: 0x66cdaa,
            mediumblue: 0x0000cd,
            mediumorchid: 0xba55d3,
            mediumpurple: 0x9370db,
            mediumseagreen: 0x3cb371,
            mediumslateblue: 0x7b68ee,
            mediumspringgreen: 0x00fa9a,
            mediumturquoise: 0x48d1cc,
            mediumvioletred: 0xc71585,
            midnightblue: 0x191970,
            mintcream: 0xf5fffa,
            mistyrose: 0xffe4e1,
            moccasin: 0xffe4b5,
            navajowhite: 0xffdead,
            navy: 0x000080,
            oldlace: 0xfdf5e6,
            olive: 0x808000,
            olivedrab: 0x6b8e23,
            orange: 0xffa500,
            orangered: 0xff4500,
            orchid: 0xda70d6,
            palegoldenrod: 0xeee8aa,
            palegreen: 0x98fb98,
            paleturquoise: 0xafeeee,
            palevioletred: 0xdb7093,
            papayawhip: 0xffefd5,
            peachpuff: 0xffdab9,
            peru: 0xcd853f,
            pink: 0xffc0cb,
            plum: 0xdda0dd,
            powderblue: 0xb0e0e6,
            purple: 0x800080,
            rebeccapurple: 0x663399,
            red: 0xff0000,
            rosybrown: 0xbc8f8f,
            royalblue: 0x4169e1,
            saddlebrown: 0x8b4513,
            salmon: 0xfa8072,
            sandybrown: 0xf4a460,
            seagreen: 0x2e8b57,
            seashell: 0xfff5ee,
            sienna: 0xa0522d,
            silver: 0xc0c0c0,
            skyblue: 0x87ceeb,
            slateblue: 0x6a5acd,
            slategray: 0x708090,
            slategrey: 0x708090,
            snow: 0xfffafa,
            springgreen: 0x00ff7f,
            steelblue: 0x4682b4,
            tan: 0xd2b48c,
            teal: 0x008080,
            thistle: 0xd8bfd8,
            tomato: 0xff6347,
            turquoise: 0x40e0d0,
            violet: 0xee82ee,
            wheat: 0xf5deb3,
            white: 0xffffff,
            whitesmoke: 0xf5f5f5,
            yellow: 0xffff00,
            yellowgreen: 0x9acd32
        })
    );
    const systemColors = new Map(
        Object.entries({
            "ActiveBorder": 0x3b99fc,
            "ActiveCaption": 0x000000,
            "AppWorkspace": 0xaaaaaa,
            "Background": 0x6363ce,
            "ButtonFace": 0xffffff,
            "ButtonHighlight": 0xe9e9e9,
            "ButtonShadow": 0x9fa09f,
            "ButtonText": 0x000000,
            "CaptionText": 0x000000,
            "GrayText": 0x7f7f7f,
            "Highlight": 0xb2d7ff,
            "HighlightText": 0x000000,
            "InactiveBorder": 0xffffff,
            "InactiveCaption": 0xffffff,
            "InactiveCaptionText": 0x000000,
            "InfoBackground": 0xfbfcc5,
            "InfoText": 0x000000,
            "Menu": 0xf6f6f6,
            "MenuText": 0xffffff,
            "Scrollbar": 0xaaaaaa,
            "ThreeDDarkShadow": 0x000000,
            "ThreeDFace": 0xc0c0c0,
            "ThreeDHighlight": 0xffffff,
            "ThreeDLightShadow": 0xffffff,
            "ThreeDShadow": 0x000000,
            "Window": 0xececec,
            "WindowFrame": 0xaaaaaa,
            "WindowText": 0x000000,
            "-webkit-focus-ring-color": 0xe59700
        }).map(([key, value]) => [key.toLowerCase(), value])
    );

    function getSRGBLightness(r, g, b) {
        return (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
    }

    function hasBuiltInDarkTheme() {
        const drStyles = document.querySelectorAll(".darkreader");
        drStyles.forEach((style) => (style.disabled = true));
        const rootColor = parse(
            getComputedStyle(document.documentElement).backgroundColor
        );
        const bodyColor = document.body
            ? parse(getComputedStyle(document.body).backgroundColor)
            : {r: 0, g: 0, b: 0, a: 0};
        const rootLightness =
            1 -
            rootColor.a +
            rootColor.a *
                getSRGBLightness(rootColor.r, rootColor.g, rootColor.b);
        const finalLightness =
            (1 - bodyColor.a) * rootLightness +
            bodyColor.a *
                getSRGBLightness(bodyColor.r, bodyColor.g, bodyColor.b);
        const darkThemeDetected = finalLightness < 0.5;
        drStyles.forEach((style) => (style.disabled = false));
        return darkThemeDetected;
    }
    function runCheck(callback) {
        const darkThemeDetected = hasBuiltInDarkTheme();
        callback(darkThemeDetected);
    }
    function hasSomeStyle() {
        if (
            document.documentElement.style.backgroundColor ||
            (document.body && document.body.style.backgroundColor)
        ) {
            return true;
        }
        for (const style of document.styleSheets) {
            if (
                style &&
                style.ownerNode &&
                !style.ownerNode.classList.contains("darkreader")
            ) {
                return true;
            }
        }
        return false;
    }
    let observer$1;
    let readyStateListener;
    function runDarkThemeDetector(callback) {
        stopDarkThemeDetector();
        if (document.body && hasSomeStyle()) {
            runCheck(callback);
            return;
        }
        observer$1 = new MutationObserver(() => {
            if (document.body && hasSomeStyle()) {
                stopDarkThemeDetector();
                runCheck(callback);
            }
        });
        observer$1.observe(document.documentElement, {childList: true});
        if (document.readyState !== "complete") {
            readyStateListener = () => {
                if (document.readyState === "complete") {
                    stopDarkThemeDetector();
                    runCheck(callback);
                }
            };
            document.addEventListener("readystatechange", readyStateListener);
        }
    }
    function stopDarkThemeDetector() {
        if (observer$1) {
            observer$1.disconnect();
            observer$1 = null;
        }
        if (readyStateListener) {
            document.removeEventListener(
                "readystatechange",
                readyStateListener
            );
            readyStateListener = null;
        }
    }

    function scale(x, inLow, inHigh, outLow, outHigh) {
        return ((x - inLow) * (outHigh - outLow)) / (inHigh - inLow) + outLow;
    }
    function clamp(x, min, max) {
        return Math.min(max, Math.max(min, x));
    }
    function multiplyMatrices(m1, m2) {
        const result = [];
        for (let i = 0, len = m1.length; i < len; i++) {
            result[i] = [];
            for (let j = 0, len2 = m2[0].length; j < len2; j++) {
                let sum = 0;
                for (let k = 0, len3 = m1[0].length; k < len3; k++) {
                    sum += m1[i][k] * m2[k][j];
                }
                result[i][j] = sum;
            }
        }
        return result;
    }

    function getMatches(regex, input, group = 0) {
        const matches = [];
        let m;
        while ((m = regex.exec(input))) {
            matches.push(m[group]);
        }
        return matches;
    }
    function formatCSS(text) {
        function trimLeft(text) {
            return text.replace(/^\s+/, "");
        }
        function getIndent(depth) {
            if (depth === 0) {
                return "";
            }
            return " ".repeat(4 * depth);
        }
        if (text.length < 50000) {
            const emptyRuleRegexp = /[^{}]+{\s*}/;
            while (emptyRuleRegexp.test(text)) {
                text = text.replace(emptyRuleRegexp, "");
            }
        }
        const css = text
            .replace(/\s{2,}/g, " ")
            .replace(/\{/g, "{\n")
            .replace(/\}/g, "\n}\n")
            .replace(/\;(?![^\(|\"]*(\)|\"))/g, ";\n")
            .replace(/\,(?![^\(|\"]*(\)|\"))/g, ",\n")
            .replace(/\n\s*\n/g, "\n")
            .split("\n");
        let depth = 0;
        const formatted = [];
        for (let x = 0, len = css.length; x < len; x++) {
            const line = `${css[x]}\n`;
            if (line.includes("{")) {
                formatted.push(getIndent(depth++) + trimLeft(line));
            } else if (line.includes("}")) {
                formatted.push(getIndent(--depth) + trimLeft(line));
            } else {
                formatted.push(getIndent(depth) + trimLeft(line));
            }
        }
        return formatted.join("").trim();
    }
    function getParenthesesRange(input, searchStartIndex = 0) {
        const length = input.length;
        let depth = 0;
        let firstOpenIndex = -1;
        for (let i = searchStartIndex; i < length; i++) {
            if (depth === 0) {
                const openIndex = input.indexOf("(", i);
                if (openIndex < 0) {
                    break;
                }
                firstOpenIndex = openIndex;
                depth++;
                i = openIndex;
            } else {
                const closingIndex = input.indexOf(")", i);
                if (closingIndex < 0) {
                    break;
                }
                const openIndex = input.indexOf("(", i);
                if (openIndex < 0 || closingIndex < openIndex) {
                    depth--;
                    if (depth === 0) {
                        return { start: firstOpenIndex, end: closingIndex + 1 };
                    }
                    i = closingIndex;
                } else {
                    depth++;
                    i = openIndex;
                }
            }
        }
        return null;
    }

    function createFilterMatrix(config) {
        let m = Matrix.identity();
        if (config.sepia !== 0) {
            m = multiplyMatrices(m, Matrix.sepia(config.sepia / 100));
        }
        if (config.grayscale !== 0) {
            m = multiplyMatrices(m, Matrix.grayscale(config.grayscale / 100));
        }
        if (config.contrast !== 100) {
            m = multiplyMatrices(m, Matrix.contrast(config.contrast / 100));
        }
        if (config.brightness !== 100) {
            m = multiplyMatrices(m, Matrix.brightness(config.brightness / 100));
        }
        if (config.mode === 1) {
            m = multiplyMatrices(m, Matrix.invertNHue());
        }
        return m;
    }
    function applyColorMatrix([r, g, b], matrix) {
        const rgb = [[r / 255], [g / 255], [b / 255], [1], [1]];
        const result = multiplyMatrices(matrix, rgb);
        return [0, 1, 2].map((i) =>
            clamp(Math.round(result[i][0] * 255), 0, 255)
        );
    }
    const Matrix = {
        identity() {
            return [
                [1, 0, 0, 0, 0],
                [0, 1, 0, 0, 0],
                [0, 0, 1, 0, 0],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        },
        invertNHue() {
            return [
                [0.333, -0.667, -0.667, 0, 1],
                [-0.667, 0.333, -0.667, 0, 1],
                [-0.667, -0.667, 0.333, 0, 1],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        },
        brightness(v) {
            return [
                [v, 0, 0, 0, 0],
                [0, v, 0, 0, 0],
                [0, 0, v, 0, 0],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        },
        contrast(v) {
            const t = (1 - v) / 2;
            return [
                [v, 0, 0, 0, t],
                [0, v, 0, 0, t],
                [0, 0, v, 0, t],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        },
        sepia(v) {
            return [
                [
                    0.393 + 0.607 * (1 - v),
                    0.769 - 0.769 * (1 - v),
                    0.189 - 0.189 * (1 - v),
                    0,
                    0
                ],
                [
                    0.349 - 0.349 * (1 - v),
                    0.686 + 0.314 * (1 - v),
                    0.168 - 0.168 * (1 - v),
                    0,
                    0
                ],
                [
                    0.272 - 0.272 * (1 - v),
                    0.534 - 0.534 * (1 - v),
                    0.131 + 0.869 * (1 - v),
                    0,
                    0
                ],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        },
        grayscale(v) {
            return [
                [
                    0.2126 + 0.7874 * (1 - v),
                    0.7152 - 0.7152 * (1 - v),
                    0.0722 - 0.0722 * (1 - v),
                    0,
                    0
                ],
                [
                    0.2126 - 0.2126 * (1 - v),
                    0.7152 + 0.2848 * (1 - v),
                    0.0722 - 0.0722 * (1 - v),
                    0,
                    0
                ],
                [
                    0.2126 - 0.2126 * (1 - v),
                    0.7152 - 0.7152 * (1 - v),
                    0.0722 + 0.9278 * (1 - v),
                    0,
                    0
                ],
                [0, 0, 0, 1, 0],
                [0, 0, 0, 0, 1]
            ];
        }
    };

    function getBgPole(theme) {
        const isDarkScheme = theme.mode === 1;
        const prop = isDarkScheme
            ? "darkSchemeBackgroundColor"
            : "lightSchemeBackgroundColor";
        return theme[prop];
    }
    function getFgPole(theme) {
        const isDarkScheme = theme.mode === 1;
        const prop = isDarkScheme
            ? "darkSchemeTextColor"
            : "lightSchemeTextColor";
        return theme[prop];
    }
    const colorModificationCache = new Map();
    const colorParseCache$1 = new Map();
    function parseToHSLWithCache(color) {
        if (colorParseCache$1.has(color)) {
            return colorParseCache$1.get(color);
        }
        const rgb = parse(color);
        const hsl = rgbToHSL(rgb);
        colorParseCache$1.set(color, hsl);
        return hsl;
    }
    function clearColorModificationCache() {
        colorModificationCache.clear();
        colorParseCache$1.clear();
    }
    const rgbCacheKeys = ["r", "g", "b", "a"];
    const themeCacheKeys$1 = [
        "mode",
        "brightness",
        "contrast",
        "grayscale",
        "sepia",
        "darkSchemeBackgroundColor",
        "darkSchemeTextColor",
        "lightSchemeBackgroundColor",
        "lightSchemeTextColor"
    ];
    function getCacheId(rgb, theme) {
        let resultId = "";
        rgbCacheKeys.forEach((key) => {
            resultId += `${rgb[key]};`;
        });
        themeCacheKeys$1.forEach((key) => {
            resultId += `${theme[key]};`;
        });
        return resultId;
    }
    function modifyColorWithCache(
        rgb,
        theme,
        modifyHSL,
        poleColor,
        anotherPoleColor
    ) {
        let fnCache;
        if (colorModificationCache.has(modifyHSL)) {
            fnCache = colorModificationCache.get(modifyHSL);
        } else {
            fnCache = new Map();
            colorModificationCache.set(modifyHSL, fnCache);
        }
        const id = getCacheId(rgb, theme);
        if (fnCache.has(id)) {
            return fnCache.get(id);
        }
        const hsl = rgbToHSL(rgb);
        const pole = poleColor == null ? null : parseToHSLWithCache(poleColor);
        const anotherPole =
            anotherPoleColor == null
                ? null
                : parseToHSLWithCache(anotherPoleColor);
        const modified = modifyHSL(hsl, pole, anotherPole);
        const { r, g, b, a } = hslToRGB(modified);
        const matrix = createFilterMatrix(theme);
        const [rf, gf, bf] = applyColorMatrix([r, g, b], matrix);
        const color =
            a === 1
                ? rgbToHexString({ r: rf, g: gf, b: bf })
                : rgbToString({ r: rf, g: gf, b: bf, a });
        fnCache.set(id, color);
        return color;
    }
    function noopHSL(hsl) {
        return hsl;
    }
    function modifyColor(rgb, theme) {
        return modifyColorWithCache(rgb, theme, noopHSL);
    }
    function modifyLightSchemeColor(rgb, theme) {
        const poleBg = getBgPole(theme);
        const poleFg = getFgPole(theme);
        return modifyColorWithCache(
            rgb,
            theme,
            modifyLightModeHSL,
            poleFg,
            poleBg
        );
    }
    function modifyLightModeHSL({ h, s, l, a }, poleFg, poleBg) {
        const isDark = l < 0.5;
        let isNeutral;
        if (isDark) {
            isNeutral = l < 0.2 || s < 0.12;
        } else {
            const isBlue = h > 200 && h < 280;
            isNeutral = s < 0.24 || (l > 0.8 && isBlue);
        }
        let hx = h;
        let sx = l;
        if (isNeutral) {
            if (isDark) {
                hx = poleFg.h;
                sx = poleFg.s;
            } else {
                hx = poleBg.h;
                sx = poleBg.s;
            }
        }
        const lx = scale(l, 0, 1, poleFg.l, poleBg.l);
        return { h: hx, s: sx, l: lx, a };
    }
    const MAX_BG_LIGHTNESS = 0.4;
    function modifyBgHSL({ h, s, l, a }, pole) {
        const isDark = l < 0.5;
        const isBlue = h > 200 && h < 280;
        const isNeutral = s < 0.12 || (l > 0.8 && isBlue);
        if (isDark) {
            const lx = scale(l, 0, 0.5, 0, MAX_BG_LIGHTNESS);
            if (isNeutral) {
                const hx = pole.h;
                const sx = pole.s;
                return { h: hx, s: sx, l: lx, a };
            }
            return { h, s, l: lx, a };
        }
        const lx = scale(l, 0.5, 1, MAX_BG_LIGHTNESS, pole.l);
        if (isNeutral) {
            const hx = pole.h;
            const sx = pole.s;
            return { h: hx, s: sx, l: lx, a };
        }
        let hx = h;
        const isYellow = h > 60 && h < 180;
        if (isYellow) {
            const isCloserToGreen = h > 120;
            if (isCloserToGreen) {
                hx = scale(h, 120, 180, 135, 180);
            } else {
                hx = scale(h, 60, 120, 60, 105);
            }
        }
        return { h: hx, s, l: lx, a };
    }
    function modifyBackgroundColor(rgb, theme) {
        if (theme.mode === 0) {
            return modifyLightSchemeColor(rgb, theme);
        }
        const pole = getBgPole(theme);
        return modifyColorWithCache(
            rgb,
            { ...theme, mode: 0 },
            modifyBgHSL,
            pole
        );
    }
    const MIN_FG_LIGHTNESS = 0.55;
    function modifyBlueFgHue(hue) {
        return scale(hue, 205, 245, 205, 220);
    }
    function modifyFgHSL({ h, s, l, a }, pole) {
        const isLight = l > 0.5;
        const isNeutral = l < 0.2 || s < 0.24;
        const isBlue = !isNeutral && h > 205 && h < 245;
        if (isLight) {
            const lx = scale(l, 0.5, 1, MIN_FG_LIGHTNESS, pole.l);
            if (isNeutral) {
                const hx = pole.h;
                const sx = pole.s;
                return { h: hx, s: sx, l: lx, a };
            }
            let hx = h;
            if (isBlue) {
                hx = modifyBlueFgHue(h);
            }
            return { h: hx, s, l: lx, a };
        }
        if (isNeutral) {
            const hx = pole.h;
            const sx = pole.s;
            const lx = scale(l, 0, 0.5, pole.l, MIN_FG_LIGHTNESS);
            return { h: hx, s: sx, l: lx, a };
        }
        let hx = h;
        let lx;
        if (isBlue) {
            hx = modifyBlueFgHue(h);
            lx = scale(l, 0, 0.5, pole.l, Math.min(1, MIN_FG_LIGHTNESS + 0.05));
        } else {
            lx = scale(l, 0, 0.5, pole.l, MIN_FG_LIGHTNESS);
        }
        return { h: hx, s, l: lx, a };
    }
    function modifyForegroundColor(rgb, theme) {
        if (theme.mode === 0) {
            return modifyLightSchemeColor(rgb, theme);
        }
        const pole = getFgPole(theme);
        return modifyColorWithCache(
            rgb,
            { ...theme, mode: 0 },
            modifyFgHSL,
            pole
        );
    }
    function modifyBorderHSL({ h, s, l, a }, poleFg, poleBg) {
        const isDark = l < 0.5;
        const isNeutral = l < 0.2 || s < 0.24;
        let hx = h;
        let sx = s;
        if (isNeutral) {
            if (isDark) {
                hx = poleFg.h;
                sx = poleFg.s;
            } else {
                hx = poleBg.h;
                sx = poleBg.s;
            }
        }
        const lx = scale(l, 0, 1, 0.5, 0.2);
        return { h: hx, s: sx, l: lx, a };
    }
    function modifyBorderColor(rgb, theme) {
        if (theme.mode === 0) {
            return modifyLightSchemeColor(rgb, theme);
        }
        const poleFg = getFgPole(theme);
        const poleBg = getBgPole(theme);
        return modifyColorWithCache(
            rgb,
            { ...theme, mode: 0 },
            modifyBorderHSL,
            poleFg,
            poleBg
        );
    }
    function modifyShadowColor(rgb, filter) {
        return modifyBackgroundColor(rgb, filter);
    }
    function modifyGradientColor(rgb, filter) {
        return modifyBackgroundColor(rgb, filter);
    }

    function createTextStyle(config) {
        const lines = [];
        lines.push(
            '*:not(pre, pre *, code, .far, .fa, .glyphicon, [class*="vjs-"], .fab, .fa-github, .fas, .material-icons, .icofont, .typcn, mu, [class*="mu-"], .glyphicon, .icon) {'
        );
        if (config.useFont && config.fontFamily) {
            lines.push(`  font-family: ${config.fontFamily} !important;`);
        }
        if (config.textStroke > 0) {
            lines.push(
                `  -webkit-text-stroke: ${config.textStroke}px !important;`
            );
            lines.push(`  text-stroke: ${config.textStroke}px !important;`);
        }
        lines.push("}");
        return lines.join("\n");
    }

    function getCSSFilterValue(config) {
        const filters = [];
        if (config.mode === FilterMode.dark) {
            filters.push("invert(100%) hue-rotate(180deg)");
        }
        if (config.brightness !== 100) {
            filters.push(`brightness(${config.brightness}%)`);
        }
        if (config.contrast !== 100) {
            filters.push(`contrast(${config.contrast}%)`);
        }
        if (config.grayscale !== 0) {
            filters.push(`grayscale(${config.grayscale}%)`);
        }
        if (config.sepia !== 0) {
            filters.push(`sepia(${config.sepia}%)`);
        }
        if (filters.length === 0) {
            return null;
        }
        return filters.join(" ");
    }

    function toSVGMatrix(matrix) {
        return matrix
            .slice(0, 4)
            .map((m) => m.map((m) => m.toFixed(3)).join(" "))
            .join(" ");
    }
    function getSVGFilterMatrixValue(config) {
        return toSVGMatrix(createFilterMatrix(config));
    }

    let counter = 0;
    const resolvers$1 = new Map();
    const rejectors = new Map();
    async function bgFetch(request) {
        return new Promise((resolve, reject) => {
            const id = ++counter;
            resolvers$1.set(id, resolve);
            rejectors.set(id, reject);
            browser.runtime.sendMessage({
                from: "bootstrap",
                operate: MessageType.CS_FETCH,
                data: request,
                id
            });
        });
    }

    async function getOKResponse(url, mimeType, origin) {
        const response = await fetch(url, {
            cache: "force-cache",
            credentials: "omit",
            referrer: origin
        });
        if (
            isSafari &&
            mimeType === "text/css" &&
            url.startsWith("safari-web-extension://") &&
            url.endsWith(".css")
        ) {
            return response;
        }
        if (
            mimeType &&
            !response.headers.get("Content-Type").startsWith(mimeType)
        ) {
            throw new Error(`Mime type mismatch when loading ${url}`);
        }
        if (!response.ok) {
            throw new Error(
                `Unable to load ${url} ${response.status} ${response.statusText}`
            );
        }
        return response;
    }
    async function loadAsDataURL(url, mimeType) {
        const response = await getOKResponse(url, mimeType);
        return await readResponseAsDataURL(response);
    }
    async function readResponseAsDataURL(response) {
        const blob = await response.blob();
        const dataURL = await new Promise((resolve) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result);
            reader.readAsDataURL(blob);
        });
        return dataURL;
    }

    class AsyncQueue {
        constructor() {
            this.queue = [];
            this.timerId = null;
            this.frameDuration = 1000 / 60;
        }
        addToQueue(entry) {
            this.queue.push(entry);
            this.startQueue();
        }
        stopQueue() {
            if (this.timerId !== null) {
                cancelAnimationFrame(this.timerId);
                this.timerId = null;
            }
            this.queue = [];
        }
        startQueue() {
            if (this.timerId) {
                return;
            }
            this.timerId = requestAnimationFrame(() => {
                this.timerId = null;
                const start = Date.now();
                let cb;
                while ((cb = this.queue.shift())) {
                    cb();
                    if (Date.now() - start >= this.frameDuration) {
                        this.startQueue();
                        break;
                    }
                }
            });
        }
    }

    const imageManager = new AsyncQueue();
    async function getImageDetails(url) {
        return new Promise(async (resolve, reject) => {
            let dataURL;
            if (url.startsWith("data:")) {
                dataURL = url;
            } else {
                try {
                    dataURL = await getImageDataURL(url);
                } catch (error) {
                    reject(error);
                    return;
                }
            }
            try {
                const image = await urlToImage(dataURL);
                imageManager.addToQueue(() => {
                    resolve({
                        src: url,
                        dataURL,
                        width: image.naturalWidth,
                        height: image.naturalHeight,
                        ...analyzeImage(image)
                    });
                });
            } catch (error) {
                reject(error);
            }
        });
    }
    async function getImageDataURL(url) {
        const parsedURL = new URL(url);
        if (parsedURL.origin === location.origin) {
            return await loadAsDataURL(url);
        }
        return await bgFetch({ url, responseType: "data-url" });
    }
    async function urlToImage(url) {
        return new Promise((resolve, reject) => {
            const image = new Image();
            image.onload = () => resolve(image);
            image.onerror = () => reject(`Unable to load image ${url}`);
            image.src = url;
        });
    }
    const MAX_ANALIZE_PIXELS_COUNT = 32 * 32;
    let canvas;
    let context;
    function createCanvas() {
        const maxWidth = MAX_ANALIZE_PIXELS_COUNT;
        const maxHeight = MAX_ANALIZE_PIXELS_COUNT;
        canvas = document.createElement("canvas");
        canvas.width = maxWidth;
        canvas.height = maxHeight;
        context = canvas.getContext("2d");
        if (context) {
            context.imageSmoothingEnabled = false;
        }
    }
    function removeCanvas() {
        canvas = null;
        context = null;
    }
    const MAX_IMAGE_SIZE = 5 * 1024 * 1024;
    function analyzeImage(image) {
        if (!canvas) {
            createCanvas();
        }
        if (!context) {
            return {
                isDark: false,
                isLight: true,
                isTransparent: false,
                isLarge: true,
                isTooLarge: false
            };
        }
        const { naturalWidth, naturalHeight } = image;
        if (naturalHeight === 0 || naturalWidth === 0) {
            logWarn(`logWarn(Image is empty ${image.currentSrc})`);
            return null;
        }
        const size = naturalWidth * naturalHeight * 4;
        if (size > MAX_IMAGE_SIZE) {
            return {
                isDark: false,
                isLight: false,
                isTransparent: false,
                isLarge: false,
                isTooLarge: false
            };
        }
        const naturalPixelsCount = naturalWidth * naturalHeight;
        const k = Math.min(
            1,
            Math.sqrt(MAX_ANALIZE_PIXELS_COUNT / naturalPixelsCount)
        );
        const width = Math.ceil(naturalWidth * k);
        const height = Math.ceil(naturalHeight * k);
        context.clearRect(0, 0, width, height);
        context.drawImage(
            image,
            0,
            0,
            naturalWidth,
            naturalHeight,
            0,
            0,
            width,
            height
        );
        const imageData = context.getImageData(0, 0, width, height);
        const d = imageData.data;
        const TRANSPARENT_ALPHA_THRESHOLD = 0.05;
        const DARK_LIGHTNESS_THRESHOLD = 0.4;
        const LIGHT_LIGHTNESS_THRESHOLD = 0.7;
        let transparentPixelsCount = 0;
        let darkPixelsCount = 0;
        let lightPixelsCount = 0;
        let i, x, y;
        let r, g, b, a;
        let l;
        for (y = 0; y < height; y++) {
            for (x = 0; x < width; x++) {
                i = 4 * (y * width + x);
                r = d[i + 0] / 255;
                g = d[i + 1] / 255;
                b = d[i + 2] / 255;
                a = d[i + 3] / 255;
                if (a < TRANSPARENT_ALPHA_THRESHOLD) {
                    transparentPixelsCount++;
                } else {
                    l = 0.2126 * r + 0.7152 * g + 0.0722 * b;
                    if (l < DARK_LIGHTNESS_THRESHOLD) {
                        darkPixelsCount++;
                    }
                    if (l > LIGHT_LIGHTNESS_THRESHOLD) {
                        lightPixelsCount++;
                    }
                }
            }
        }
        const totalPixelsCount = width * height;
        const opaquePixelsCount = totalPixelsCount - transparentPixelsCount;
        const DARK_IMAGE_THRESHOLD = 0.7;
        const LIGHT_IMAGE_THRESHOLD = 0.7;
        const TRANSPARENT_IMAGE_THRESHOLD = 0.1;
        const LARGE_IMAGE_PIXELS_COUNT = 800 * 600;
        return {
            isDark: darkPixelsCount / opaquePixelsCount >= DARK_IMAGE_THRESHOLD,
            isLight:
                lightPixelsCount / opaquePixelsCount >= LIGHT_IMAGE_THRESHOLD,
            isTransparent:
                transparentPixelsCount / totalPixelsCount >=
                TRANSPARENT_IMAGE_THRESHOLD,
            isLarge: naturalPixelsCount >= LARGE_IMAGE_PIXELS_COUNT,
            isTooLarge: false
        };
    }
    function getFilteredImageDataURL({ dataURL, width, height }, theme) {
        const matrix = getSVGFilterMatrixValue(theme);
        const svg = [
            `<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="${width}" height="${height}">`,
            "<defs>",
            '<filter id="darkreader-image-filter">',
            `<feColorMatrix type="matrix" values="${matrix}" />`,
            "</filter>",
            "</defs>",
            `<image width="${width}" height="${height}" filter="url(#darkreader-image-filter)" xlink:href="${dataURL}" />`,
            "</svg>"
        ].join("");
        return `data:image/svg+xml;base64,${btoa(svg)}`;
    }
    function cleanImageProcessingCache() {
        imageManager && imageManager.stopQueue();
        removeCanvas();
    }

    function getPriority(ruleStyle, property) {
        return Boolean(ruleStyle && ruleStyle.getPropertyPriority(property));
    }
    function getModifiableCSSDeclaration(
        property,
        value,
        rule,
        variablesStore,
        ignoreImageSelectors,
        isCancelled
    ) {
        if (property.startsWith("--")) {
            const modifier = getVariableModifier(
                variablesStore,
                property,
                value,
                rule,
                ignoreImageSelectors,
                isCancelled
            );
            if (modifier) {
                return {
                    property,
                    value: modifier,
                    important: getPriority(rule.style, property),
                    sourceValue: value
                };
            }
        } else if (value.includes("var(")) {
            const modifier = getVariableDependantModifier(
                variablesStore,
                property,
                value
            );
            if (modifier) {
                return {
                    property,
                    value: modifier,
                    important: getPriority(rule.style, property),
                    sourceValue: value
                };
            }
        } else if (
            (property.includes("color") &&
                property !== "-webkit-print-color-adjust") ||
            property === "fill" ||
            property === "stroke" ||
            property === "stop-color"
        ) {
            const modifier = getColorModifier(property, value);
            if (modifier) {
                return {
                    property,
                    value: modifier,
                    important: getPriority(rule.style, property),
                    sourceValue: value
                };
            }
        } else if (
            property === "background-image" ||
            property === "list-style-image"
        ) {
            const modifier = getBgImageModifier(
                value,
                rule,
                ignoreImageSelectors,
                isCancelled
            );
            if (modifier) {
                return {
                    property,
                    value: modifier,
                    important: getPriority(rule.style, property),
                    sourceValue: value
                };
            }
        } else if (property.includes("shadow")) {
            const modifier = getShadowModifier(value);
            if (modifier) {
                return {
                    property,
                    value: modifier,
                    important: getPriority(rule.style, property),
                    sourceValue: value
                };
            }
        }
        return null;
    }
    function joinSelectors(...selectors) {
        return selectors.filter(Boolean).join(", ");
    }
    function getModifiedUserAgentStyle(theme, isIFrame, styleSystemControls) {
        const lines = [];
        if (!isIFrame) {
            lines.push("html {");
            lines.push(
                `    background-color: ${modifyBackgroundColor(
                    {r: 255, g: 255, b: 255},
                    theme
                )} !important;`
            );
            lines.push("}");
        }
        if (isCSSColorSchemePropSupported) {
            lines.push("html {");
            lines.push(
                `    color-scheme: ${
                    theme.mode === 1 ? "dark" : "dark light"
                } !important;`
            );
            lines.push("}");
        }
        const bgSelectors = joinSelectors(
            isIFrame ? "" : "html, body",
            styleSystemControls ? "input, textarea, select, button" : ""
        );
        if (bgSelectors) {
            lines.push(`${bgSelectors} {`);
            lines.push(
                `    background-color: ${modifyBackgroundColor(
                    {r: 255, g: 255, b: 255},
                    theme
                )};`
            );
            lines.push("}");
        }
        lines.push(
            `${joinSelectors(
                "html, body",
                styleSystemControls ? "input, textarea, select, button" : ""
            )} {`
        );
        lines.push(
            `    border-color: ${modifyBorderColor(
                {r: 76, g: 76, b: 76},
                theme
            )};`
        );
        lines.push(
            `    color: ${modifyForegroundColor({r: 0, g: 0, b: 0}, theme)};`
        );
        lines.push("}");
        lines.push("a {");
        lines.push(
            `    color: ${modifyForegroundColor({r: 0, g: 64, b: 255}, theme)};`
        );
        lines.push("}");
        lines.push("table {");
        lines.push(
            `    border-color: ${modifyBorderColor(
                {r: 128, g: 128, b: 128},
                theme
            )};`
        );
        lines.push("}");
        lines.push("::placeholder {");
        lines.push(
            `    color: ${modifyForegroundColor(
                {r: 169, g: 169, b: 169},
                theme
            )};`
        );
        lines.push("}");
        lines.push("input:-webkit-autofill,");
        lines.push("textarea:-webkit-autofill,");
        lines.push("select:-webkit-autofill {");
        lines.push(
            `    background-color: ${modifyBackgroundColor(
                {r: 250, g: 255, b: 189},
                theme
            )} !important;`
        );
        lines.push(
            `    color: ${modifyForegroundColor(
                {r: 0, g: 0, b: 0},
                theme
            )} !important;`
        );
        lines.push("}");
        if (theme.scrollbarColor) {
            lines.push(getModifiedScrollbarStyle(theme));
        }
        if (theme.selectionColor) {
            lines.push(getModifiedSelectionStyle(theme));
        }
        return lines.join("\n");
    }
    function getSelectionColor(theme) {
        let backgroundColorSelection;
        let foregroundColorSelection;
        if (theme.selectionColor === "auto") {
            backgroundColorSelection = modifyBackgroundColor(
                { r: 0, g: 96, b: 212 },
                { ...theme, grayscale: 0 }
            );
            foregroundColorSelection = modifyForegroundColor(
                { r: 255, g: 255, b: 255 },
                { ...theme, grayscale: 0 }
            );
        } else {
            const rgb = parse(theme.selectionColor);
            const hsl = rgbToHSL(rgb);
            backgroundColorSelection = theme.selectionColor;
            if (hsl.l < 0.5) {
                foregroundColorSelection = "#FFF";
            } else {
                foregroundColorSelection = "#000";
            }
        }
        return { backgroundColorSelection, foregroundColorSelection };
    }
    function getModifiedSelectionStyle(theme) {
        const lines = [];
        const modifiedSelectionColor = getSelectionColor(theme);
        const backgroundColorSelection =
            modifiedSelectionColor.backgroundColorSelection;
        const foregroundColorSelection =
            modifiedSelectionColor.foregroundColorSelection;
        ["::selection", "::-moz-selection"].forEach((selection) => {
            lines.push(`${selection} {`);
            lines.push(
                `    background-color: ${backgroundColorSelection} !important;`
            );
            lines.push(`    color: ${foregroundColorSelection} !important;`);
            lines.push("}");
        });
        return lines.join("\n");
    }
    function getModifiedScrollbarStyle(theme) {
        const lines = [];
        let colorTrack;
        let colorIcons;
        let colorThumb;
        let colorThumbHover;
        let colorThumbActive;
        let colorCorner;
        if (theme.scrollbarColor === "auto") {
            colorTrack = modifyBackgroundColor({ r: 241, g: 241, b: 241 }, theme);
            colorIcons = modifyForegroundColor({ r: 96, g: 96, b: 96 }, theme);
            colorThumb = modifyBackgroundColor({ r: 176, g: 176, b: 176 }, theme);
            colorThumbHover = modifyBackgroundColor(
                { r: 144, g: 144, b: 144 },
                theme
            );
            colorThumbActive = modifyBackgroundColor(
                { r: 96, g: 96, b: 96 },
                theme
            );
            colorCorner = modifyBackgroundColor(
                { r: 255, g: 255, b: 255 },
                theme
            );
        } else {
            const rgb = parse(theme.scrollbarColor);
            const hsl = rgbToHSL(rgb);
            const isLight = hsl.l > 0.5;
            const lighten = (lighter) => ({
                ...hsl,
                l: clamp(hsl.l + lighter, 0, 1)
            });
            const darken = (darker) => ({
                ...hsl,
                l: clamp(hsl.l - darker, 0, 1)
            });
            colorTrack = hslToString(darken(0.4));
            colorIcons = hslToString(isLight ? darken(0.4) : lighten(0.4));
            colorThumb = hslToString(hsl);
            colorThumbHover = hslToString(lighten(0.1));
            colorThumbActive = hslToString(lighten(0.2));
        }
        lines.push("::-webkit-scrollbar {");
        lines.push(`    background-color: ${colorTrack};`);
        lines.push(`    color: ${colorIcons};`);
        lines.push("}");
        lines.push("::-webkit-scrollbar-thumb {");
        lines.push(`    background-color: ${colorThumb};`);
        lines.push("}");
        lines.push("::-webkit-scrollbar-thumb:hover {");
        lines.push(`    background-color: ${colorThumbHover};`);
        lines.push("}");
        lines.push("::-webkit-scrollbar-thumb:active {");
        lines.push(`    background-color: ${colorThumbActive};`);
        lines.push("}");
        lines.push("::-webkit-scrollbar-corner {");
        lines.push(`    background-color: ${colorCorner};`);
        lines.push("}");
        if (isSafari) {
            lines.push("* {");
            lines.push(`    scrollbar-color: ${colorThumb} ${colorTrack};`);
            lines.push("}");
        }
        return lines.join("\n");
    }
    function getModifiedFallbackStyle(filter, { strict }) {
        const lines = [];
        const isMicrosoft = location.hostname.endsWith("microsoft.com");
        lines.push(
            `html, body, ${strict
                ? `body :not(iframe)${isMicrosoft
                    ? ':not(div[style^="position:absolute;top:0;left:-"]'
                    : ""
                }`
                : "body > :not(iframe)"
            } {`
        );
        lines.push(
            `    background-color: ${modifyBackgroundColor(
                { r: 255, g: 255, b: 255 },
                filter
            )} !important;`
        );
        lines.push(
            `    border-color: ${modifyBorderColor(
                { r: 64, g: 64, b: 64 },
                filter
            )} !important;`
        );
        lines.push(
            `    color: ${modifyForegroundColor(
                { r: 0, g: 0, b: 0 },
                filter
            )} !important;`
        );
        lines.push("}");
        return lines.join("\n");
    }
    const unparsableColors = new Set([
        "inherit",
        "transparent",
        "initial",
        "currentcolor",
        "none",
        "unset"
    ]);
    const colorParseCache = new Map();
    function parseColorWithCache($color) {
        $color = $color.trim();
        if (colorParseCache.has($color)) {
            return colorParseCache.get($color);
        }
        if ($color.includes("calc(")) {
            $color = lowerCalcExpression($color);
        }
        const color = parse($color);
        colorParseCache.set($color, color);
        return color;
    }
    function tryParseColor($color) {
        try {
            return parseColorWithCache($color);
        } catch (err) {
            return null;
        }
    }
    function getColorModifier(prop, value) {
        if (unparsableColors.has(value.toLowerCase())) {
            return value;
        }
        try {
            const rgb = parseColorWithCache(value);
            if (prop.includes("background")) {
                return (filter) => modifyBackgroundColor(rgb, filter);
            }
            if (prop.includes("border") || prop.includes("outline")) {
                return (filter) => modifyBorderColor(rgb, filter);
            }
            return (filter) => modifyForegroundColor(rgb, filter);
        } catch (err) {
            return null;
        }
    }
    const gradientRegex =
        /[\-a-z]+gradient\(([^\(\)]*(\(([^\(\)]*(\(.*?\)))*[^\(\)]*\))){0,15}[^\(\)]*\)/g;
    const imageDetailsCache = new Map();
    const awaitingForImageLoading = new Map();
    function shouldIgnoreImage(selectorText, selectors) {
        if (!selectorText || selectors.length === 0) {
            return false;
        }
        if (selectors.some((s) => s === "*")) {
            return true;
        }
        const ruleSelectors = selectorText.split(/,\s*/g);
        for (let i = 0; i < selectors.length; i++) {
            const ignoredSelector = selectors[i];
            if (ruleSelectors.some((s) => s === ignoredSelector)) {
                return true;
            }
        }
        return false;
    }
    function getBgImageModifier(
        value,
        rule,
        ignoreImageSelectors,
        isCancelled
    ) {
        try {
            const gradients = getMatches(gradientRegex, value);
            const urls = getMatches(cssURLRegex, value);
            if (urls.length === 0 && gradients.length === 0) {
                return value;
            }
            const getIndices = (matches) => {
                let index = 0;
                return matches.map((match) => {
                    const valueIndex = value.indexOf(match, index);
                    index = valueIndex + match.length;
                    return { match, index: valueIndex };
                });
            };
            const matches = getIndices(urls)
                .map((i) => ({ type: "url", ...i }))
                .concat(
                    getIndices(gradients).map((i) => ({ type: "gradient", ...i }))
                )
                .sort((a, b) => a.index - b.index);
            const getGradientModifier = (gradient) => {
                const match = gradient.match(/^(.*-gradient)\((.*)\)$/);
                const type = match[1];
                const content = match[2];
                const partsRegex =
                    /([^\(\),]+(\([^\(\)]*(\([^\(\)]*\)*[^\(\)]*)?\))?[^\(\),]*),?/g;
                const colorStopRegex =
                    /^(from|color-stop|to)\(([^\(\)]*?,\s*)?(.*?)\)$/;
                const parts = getMatches(partsRegex, content, 1).map((part) => {
                    part = part.trim();
                    let rgb = tryParseColor(part);
                    if (rgb) {
                        return (filter) => modifyGradientColor(rgb, filter);
                    }
                    const space = part.lastIndexOf(" ");
                    rgb = tryParseColor(part.substring(0, space));
                    if (rgb) {
                        return (filter) =>
                            `${modifyGradientColor(
                                rgb,
                                filter
                            )} ${part.substring(space + 1)}`;
                    }
                    const colorStopMatch = part.match(colorStopRegex);
                    if (colorStopMatch) {
                        rgb = tryParseColor(colorStopMatch[3]);
                        if (rgb) {
                            return (filter) =>
                                `${colorStopMatch[1]}(${colorStopMatch[2]
                                    ? `${colorStopMatch[2]}, `
                                    : ""
                                }${modifyGradientColor(rgb, filter)})`;
                        }
                    }
                    return () => part;
                });
                return (filter) => {
                    return `${type}(${parts
                        .map((modify) => modify(filter))
                        .join(", ")})`;
                };
            };
            const getURLModifier = (urlValue) => {
                var _a;
                if (
                    shouldIgnoreImage(rule.selectorText, ignoreImageSelectors)
                ) {
                    return null;
                }
                let url = getCSSURLValue(urlValue);
                const { parentStyleSheet } = rule;
                const baseURL =
                    parentStyleSheet && parentStyleSheet.href
                        ? getCSSBaseBath(parentStyleSheet.href)
                        : ((_a = parentStyleSheet.ownerNode) === null ||
                            _a === void 0
                            ? void 0
                            : _a.baseURI) || location.origin;
                url = getAbsoluteURL(baseURL, url);
                const absoluteValue = `url("${url}")`;
                return async (filter) => {
                    let imageDetails;
                    if (imageDetailsCache.has(url)) {
                        imageDetails = imageDetailsCache.get(url);
                    } else {
                        try {
                            if (awaitingForImageLoading.has(url)) {
                                const awaiters =
                                    awaitingForImageLoading.get(url);
                                imageDetails = await new Promise((resolve) =>
                                    awaiters.push(resolve)
                                );
                                if (!imageDetails) {
                                    return null;
                                }
                            } else {
                                awaitingForImageLoading.set(url, []);
                                imageDetails = await getImageDetails(url);
                                imageDetailsCache.set(url, imageDetails);
                                awaitingForImageLoading
                                    .get(url)
                                    .forEach((resolve) =>
                                        resolve(imageDetails)
                                    );
                                awaitingForImageLoading.delete(url);
                            }
                            if (isCancelled()) {
                                return null;
                            }
                        } catch (err) {
                            logWarn(err);
                            if (awaitingForImageLoading.has(url)) {
                                awaitingForImageLoading
                                    .get(url)
                                    .forEach((resolve) => resolve(null));
                                awaitingForImageLoading.delete(url);
                            }
                            return absoluteValue;
                        }
                    }
                    const bgImageValue =
                        getBgImageValue(imageDetails, filter) || absoluteValue;
                    return bgImageValue;
                };
            };
            const getBgImageValue = (imageDetails, filter) => {
                const {
                    isDark,
                    isLight,
                    isTransparent,
                    isLarge,
                    isTooLarge,
                    width
                } = imageDetails;
                let result;
                if (isTooLarge) {
                    result = `url("${imageDetails.src}")`;
                } else if (
                    isDark &&
                    isTransparent &&
                    filter.mode === 1 &&
                    !isLarge &&
                    width > 2
                ) {
                    logInfo(`Inverting dark image ${imageDetails.src}`);
                    const inverted = getFilteredImageDataURL(imageDetails, {
                        ...filter,
                        sepia: clamp(filter.sepia + 10, 0, 100)
                    });
                    result = `url("${inverted}")`;
                } else if (isLight && !isTransparent && filter.mode === 1) {
                    if (isLarge) {
                        result = "none";
                    } else {
                        logInfo(`Dimming light image ${imageDetails.src}`);
                        const dimmed = getFilteredImageDataURL(
                            imageDetails,
                            filter
                        );
                        result = `url("${dimmed}")`;
                    }
                } else if (filter.mode === 0 && isLight && !isLarge) {
                    logInfo(`Applying filter to image ${imageDetails.src}`);
                    const filtered = getFilteredImageDataURL(imageDetails, {
                        ...filter,
                        brightness: clamp(filter.brightness - 10, 5, 200),
                        sepia: clamp(filter.sepia + 10, 0, 100)
                    });
                    result = `url("${filtered}")`;
                } else {
                    result = null;
                }
                return result;
            };
            const modifiers = [];
            let index = 0;
            matches.forEach(({ match, type, index: matchStart }, i) => {
                const prefixStart = index;
                const matchEnd = matchStart + match.length;
                index = matchEnd;
                modifiers.push(() => value.substring(prefixStart, matchStart));
                modifiers.push(
                    type === "url"
                        ? getURLModifier(match)
                        : getGradientModifier(match)
                );
                if (i === matches.length - 1) {
                    modifiers.push(() => value.substring(matchEnd));
                }
            });
            return (filter) => {
                const results = modifiers
                    .filter(Boolean)
                    .map((modify) => modify(filter));
                if (results.some((r) => r instanceof Promise)) {
                    return Promise.all(results).then((asyncResults) => {
                        return asyncResults.join("");
                    });
                }
                return results.join("");
            };
        } catch (err) {
            return null;
        }
    }
    function getShadowModifierWithInfo(value) {
        try {
            let index = 0;
            const colorMatches = getMatches(
                /(^|\s)(?!calc)([a-z]+\(.+?\)|#[0-9a-f]+|[a-z]+)(.*?(inset|outset)?($|,))/gi,
                value,
                2
            );
            let notParsed = 0;
            const modifiers = colorMatches.map((match, i) => {
                const prefixIndex = index;
                const matchIndex = value.indexOf(match, index);
                const matchEnd = matchIndex + match.length;
                index = matchEnd;
                const rgb = tryParseColor(match);
                if (!rgb) {
                    notParsed++;
                    return () => value.substring(prefixIndex, matchEnd);
                }
                return (filter) =>
                    `${value.substring(
                        prefixIndex,
                        matchIndex
                    )}${modifyShadowColor(rgb, filter)}${i === colorMatches.length - 1
                        ? value.substring(matchEnd)
                        : ""
                    }`;
            });
            return (filter) => {
                const modified = modifiers
                    .map((modify) => modify(filter))
                    .join("");
                return {
                    matchesLength: colorMatches.length,
                    unparseableMatchesLength: notParsed,
                    result: modified
                };
            };
        } catch (err) {
            return null;
        }
    }
    function getShadowModifier(value) {
        const shadowModifier = getShadowModifierWithInfo(value);
        if (!shadowModifier) {
            return null;
        }
        return (theme) => shadowModifier(theme).result;
    }
    function getVariableModifier(
        variablesStore,
        prop,
        value,
        rule,
        ignoredImgSelectors,
        isCancelled
    ) {
        return variablesStore.getModifierForVariable({
            varName: prop,
            sourceValue: value,
            rule,
            ignoredImgSelectors,
            isCancelled
        });
    }
    function getVariableDependantModifier(variablesStore, prop, value) {
        return variablesStore.getModifierForVarDependant(prop, value);
    }
    function cleanModificationCache() {
        colorParseCache.clear();
        clearColorModificationCache();
        imageDetailsCache.clear();
        cleanImageProcessingCache();
        awaitingForImageLoading.clear();
    }

    const VAR_TYPE_BGCOLOR = 1 << 0;
    const VAR_TYPE_TEXTCOLOR = 1 << 1;
    const VAR_TYPE_BORDERCOLOR = 1 << 2;
    const VAR_TYPE_BGIMG = 1 << 3;
    class VariablesStore {
        constructor() {
            this.varTypes = new Map();
            this.rulesQueue = [];
            this.definedVars = new Set();
            this.varRefs = new Map();
            this.unknownColorVars = new Set();
            this.unknownBgVars = new Set();
            this.undefinedVars = new Set();
            this.initialVarTypes = new Map();
            this.changedTypeVars = new Set();
            this.typeChangeSubscriptions = new Map();
            this.unstableVarValues = new Map();
        }
        clear() {
            this.varTypes.clear();
            this.rulesQueue.splice(0);
            this.definedVars.clear();
            this.varRefs.clear();
            this.unknownColorVars.clear();
            this.unknownBgVars.clear();
            this.undefinedVars.clear();
            this.initialVarTypes.clear();
            this.changedTypeVars.clear();
            this.typeChangeSubscriptions.clear();
            this.unstableVarValues.clear();
        }
        isVarType(varName, typeNum) {
            return (
                this.varTypes.has(varName) &&
                (this.varTypes.get(varName) & typeNum) > 0
            );
        }
        addRulesForMatching(rules) {
            this.rulesQueue.push(rules);
        }
        matchVariablesAndDependants() {
            this.changedTypeVars.clear();
            this.initialVarTypes = new Map(this.varTypes);
            this.collectRootVariables();
            this.collectVariablesAndVarDep(this.rulesQueue);
            this.rulesQueue.splice(0);
            this.collectRootVarDependants();
            this.varRefs.forEach((refs, v) => {
                refs.forEach((r) => {
                    if (this.varTypes.has(v)) {
                        this.resolveVariableType(r, this.varTypes.get(v));
                    }
                });
            });
            this.unknownColorVars.forEach((v) => {
                if (this.unknownBgVars.has(v)) {
                    this.unknownColorVars.delete(v);
                    this.unknownBgVars.delete(v);
                    this.resolveVariableType(v, VAR_TYPE_BGCOLOR);
                } else if (
                    this.isVarType(
                        v,
                        VAR_TYPE_BGCOLOR |
                        VAR_TYPE_TEXTCOLOR |
                        VAR_TYPE_BORDERCOLOR
                    )
                ) {
                    this.unknownColorVars.delete(v);
                } else {
                    this.undefinedVars.add(v);
                }
            });
            this.unknownBgVars.forEach((v) => {
                const hasColor =
                    this.findVarRef(v, (ref) => {
                        return (
                            this.unknownColorVars.has(ref) ||
                            this.isVarType(
                                ref,
                                VAR_TYPE_TEXTCOLOR | VAR_TYPE_BORDERCOLOR
                            )
                        );
                    }) != null;
                if (hasColor) {
                    this.itarateVarRefs(v, (ref) => {
                        this.resolveVariableType(ref, VAR_TYPE_BGCOLOR);
                    });
                } else if (
                    this.isVarType(v, VAR_TYPE_BGCOLOR | VAR_TYPE_BGIMG)
                ) {
                    this.unknownBgVars.delete(v);
                } else {
                    this.undefinedVars.add(v);
                }
            });
            this.changedTypeVars.forEach((varName) => {
                if (this.typeChangeSubscriptions.has(varName)) {
                    this.typeChangeSubscriptions
                        .get(varName)
                        .forEach((callback) => {
                            callback();
                        });
                }
            });
            this.changedTypeVars.clear();
        }
        getModifierForVariable(options) {
            return (theme) => {
                const {
                    varName,
                    sourceValue,
                    rule,
                    ignoredImgSelectors,
                    isCancelled
                } = options;
                const getDeclarations = () => {
                    const declarations = [];
                    const addModifiedValue = (
                        typeNum,
                        varNameWrapper,
                        colorModifier
                    ) => {
                        if (!this.isVarType(varName, typeNum)) {
                            return;
                        }
                        const property = varNameWrapper(varName);
                        let modifiedValue;
                        if (isVarDependant(sourceValue)) {
                            if (isConstructedColorVar(sourceValue)) {
                                let value = insertVarValues(
                                    sourceValue,
                                    this.unstableVarValues
                                );
                                if (!value) {
                                    value =
                                        typeNum === VAR_TYPE_BGCOLOR
                                            ? "#ffffff"
                                            : "#000000";
                                }
                                modifiedValue = colorModifier(value, theme);
                            } else {
                                modifiedValue = replaceCSSVariablesNames(
                                    sourceValue,
                                    (v) => varNameWrapper(v),
                                    (fallback) => colorModifier(fallback, theme)
                                );
                            }
                        } else {
                            modifiedValue = colorModifier(sourceValue, theme);
                        }
                        declarations.push({
                            property,
                            value: modifiedValue
                        });
                    };
                    addModifiedValue(
                        VAR_TYPE_BGCOLOR,
                        wrapBgColorVariableName,
                        tryModifyBgColor
                    );
                    addModifiedValue(
                        VAR_TYPE_TEXTCOLOR,
                        wrapTextColorVariableName,
                        tryModifyTextColor
                    );
                    addModifiedValue(
                        VAR_TYPE_BORDERCOLOR,
                        wrapBorderColorVariableName,
                        tryModifyBorderColor
                    );
                    if (this.isVarType(varName, VAR_TYPE_BGIMG)) {
                        const property = wrapBgImgVariableName(varName);
                        let modifiedValue = sourceValue;
                        if (isVarDependant(sourceValue)) {
                            modifiedValue = replaceCSSVariablesNames(
                                sourceValue,
                                (v) => wrapBgColorVariableName(v),
                                (fallback) => tryModifyBgColor(fallback, theme)
                            );
                        }
                        const bgModifier = getBgImageModifier(
                            modifiedValue,
                            rule,
                            ignoredImgSelectors,
                            isCancelled
                        );
                        modifiedValue =
                            typeof bgModifier === "function"
                                ? bgModifier(theme)
                                : bgModifier;
                        declarations.push({
                            property,
                            value: modifiedValue
                        });
                    }
                    return declarations;
                };
                const callbacks = new Set();
                const addListener = (onTypeChange) => {
                    const callback = () => {
                        const decs = getDeclarations();
                        onTypeChange(decs);
                    };
                    callbacks.add(callback);
                    this.subscribeForVarTypeChange(varName, callback);
                };
                const removeListeners = () => {
                    callbacks.forEach((callback) => {
                        this.unsubscribeFromVariableTypeChanges(
                            varName,
                            callback
                        );
                    });
                };
                return {
                    declarations: getDeclarations(),
                    onTypeChange: { addListener, removeListeners }
                };
            };
        }
        getModifierForVarDependant(property, sourceValue) {
            if (sourceValue.match(/^\s*(rgb|hsl)a?\(/)) {
                const isBg = property.startsWith("background");
                const isText =
                    property === "color" || property === "caret-color";
                return (theme) => {
                    let value = insertVarValues(
                        sourceValue,
                        this.unstableVarValues
                    );
                    if (!value) {
                        value = isBg ? "#ffffff" : "#000000";
                    }
                    const modifier = isBg
                        ? tryModifyBgColor
                        : isText
                            ? tryModifyTextColor
                            : tryModifyBorderColor;
                    return modifier(value, theme);
                };
            }
            if (property === "background-color") {
                return (theme) => {
                    return replaceCSSVariablesNames(
                        sourceValue,
                        (v) => wrapBgColorVariableName(v),
                        (fallback) => tryModifyBgColor(fallback, theme)
                    );
                };
            }
            if (property === "color" || property === "caret-color") {
                return (theme) => {
                    return replaceCSSVariablesNames(
                        sourceValue,
                        (v) => wrapTextColorVariableName(v),
                        (fallback) => tryModifyTextColor(fallback, theme)
                    );
                };
            }
            if (
                property === "background" ||
                property === "background-image" ||
                property === "box-shadow"
            ) {
                return (theme) => {
                    const unknownVars = new Set();
                    const modify = () => {
                        const variableReplaced = replaceCSSVariablesNames(
                            sourceValue,
                            (v) => {
                                if (this.isVarType(v, VAR_TYPE_BGCOLOR)) {
                                    return wrapBgColorVariableName(v);
                                }
                                if (this.isVarType(v, VAR_TYPE_BGIMG)) {
                                    return wrapBgImgVariableName(v);
                                }
                                unknownVars.add(v);
                                return v;
                            },
                            (fallback) => tryModifyBgColor(fallback, theme)
                        );
                        if (property === "box-shadow") {
                            const shadowModifier =
                                getShadowModifierWithInfo(variableReplaced);
                            const modifiedShadow = shadowModifier(theme);
                            if (
                                modifiedShadow.unparseableMatchesLength !==
                                modifiedShadow.matchesLength
                            ) {
                                return modifiedShadow.result;
                            }
                        }
                        return variableReplaced;
                    };
                    const modified = modify();
                    if (unknownVars.size > 0) {
                        return new Promise((resolve) => {
                            const firstUnknownVar = unknownVars
                                .values()
                                .next().value;
                            const callback = () => {
                                this.unsubscribeFromVariableTypeChanges(
                                    firstUnknownVar,
                                    callback
                                );
                                const newValue = modify();
                                resolve(newValue);
                            };
                            this.subscribeForVarTypeChange(
                                firstUnknownVar,
                                callback
                            );
                        });
                    }
                    return modified;
                };
            }
            if (
                property.startsWith("border") ||
                property.startsWith("outline")
            ) {
                if (sourceValue.endsWith(")")) {
                    const colorTypeMatch = sourceValue.match(/((rgb|hsl)a?)\(/);
                    if (colorTypeMatch) {
                        const index = colorTypeMatch.index;
                        return (theme) => {
                            const value = insertVarValues(
                                sourceValue,
                                this.unstableVarValues
                            );
                            if (!value) {
                                return sourceValue;
                            }
                            const beginning = sourceValue.substring(0, index);
                            const color = sourceValue.substring(
                                index,
                                sourceValue.length
                            );
                            const inserted = insertVarValues(
                                color,
                                this.unstableVarValues
                            );
                            const modified = tryModifyBorderColor(
                                inserted,
                                theme
                            );
                            return `${beginning}${modified}`;
                        };
                    }
                }
                return (theme) => {
                    return replaceCSSVariablesNames(
                        sourceValue,
                        (v) => wrapBorderColorVariableName(v),
                        (fallback) => tryModifyTextColor(fallback, theme)
                    );
                };
            }
            return null;
        }
        subscribeForVarTypeChange(varName, callback) {
            if (!this.typeChangeSubscriptions.has(varName)) {
                this.typeChangeSubscriptions.set(varName, new Set());
            }
            const rootStore = this.typeChangeSubscriptions.get(varName);
            if (!rootStore.has(callback)) {
                rootStore.add(callback);
            }
        }
        unsubscribeFromVariableTypeChanges(varName, callback) {
            if (this.typeChangeSubscriptions.has(varName)) {
                this.typeChangeSubscriptions.get(varName).delete(callback);
            }
        }
        collectVariablesAndVarDep(ruleList) {
            ruleList.forEach((rules) => {
                iterateCSSRules(rules, (rule) => {
                    rule.style &&
                        iterateCSSDeclarations(
                            rule.style,
                            (property, value) => {
                                if (isVariable(property)) {
                                    this.inspectVariable(property, value);
                                }
                                if (isVarDependant(value)) {
                                    this.inspectVarDependant(property, value);
                                }
                            }
                        );
                });
            });
        }
        collectRootVariables() {
            iterateCSSDeclarations(
                document.documentElement.style,
                (property, value) => {
                    if (isVariable(property)) {
                        this.inspectVariable(property, value);
                    }
                }
            );
        }
        inspectVariable(varName, value) {
            this.unstableVarValues.set(varName, value);
            if (isVarDependant(value) && isConstructedColorVar(value)) {
                this.unknownColorVars.add(varName);
                this.definedVars.add(varName);
            }
            if (this.definedVars.has(varName)) {
                return;
            }
            this.definedVars.add(varName);
            const color = tryParseColor(value);
            if (color) {
                this.unknownColorVars.add(varName);
            } else if (
                value.includes("url(") ||
                value.includes("linear-gradient(") ||
                value.includes("radial-gradient(")
            ) {
                this.resolveVariableType(varName, VAR_TYPE_BGIMG);
            }
        }
        resolveVariableType(varName, typeNum) {
            const initialType = this.initialVarTypes.get(varName) || 0;
            const currentType = this.varTypes.get(varName) || 0;
            const newType = currentType | typeNum;
            this.varTypes.set(varName, newType);
            if (newType !== initialType || this.undefinedVars.has(varName)) {
                this.changedTypeVars.add(varName);
                this.undefinedVars.delete(varName);
            }
            this.unknownColorVars.delete(varName);
            this.unknownBgVars.delete(varName);
        }
        collectRootVarDependants() {
            iterateCSSDeclarations(
                document.documentElement.style,
                (property, value) => {
                    if (isVarDependant(value)) {
                        this.inspectVarDependant(property, value);
                    }
                }
            );
        }
        inspectVarDependant(property, value) {
            if (isVariable(property)) {
                this.iterateVarDeps(value, (ref) => {
                    if (!this.varRefs.has(property)) {
                        this.varRefs.set(property, new Set());
                    }
                    this.varRefs.get(property).add(ref);
                });
            } else if (
                property === "background-color" ||
                property === "box-shadow"
            ) {
                this.iterateVarDeps(value, (v) =>
                    this.resolveVariableType(v, VAR_TYPE_BGCOLOR)
                );
            } else if (property === "color" || property === "caret-color") {
                this.iterateVarDeps(value, (v) =>
                    this.resolveVariableType(v, VAR_TYPE_TEXTCOLOR)
                );
            } else if (
                property.startsWith("border") ||
                property.startsWith("outline")
            ) {
                this.iterateVarDeps(value, (v) =>
                    this.resolveVariableType(v, VAR_TYPE_BORDERCOLOR)
                );
            } else if (
                property === "background" ||
                property === "background-image"
            ) {
                this.iterateVarDeps(value, (v) => {
                    if (this.isVarType(v, VAR_TYPE_BGCOLOR | VAR_TYPE_BGIMG)) {
                        return;
                    }
                    const isBgColor =
                        this.findVarRef(v, (ref) => {
                            return (
                                this.unknownColorVars.has(ref) ||
                                this.isVarType(
                                    ref,
                                    VAR_TYPE_TEXTCOLOR | VAR_TYPE_BORDERCOLOR
                                )
                            );
                        }) != null;
                    this.itarateVarRefs(v, (ref) => {
                        if (isBgColor) {
                            this.resolveVariableType(ref, VAR_TYPE_BGCOLOR);
                        } else {
                            this.unknownBgVars.add(ref);
                        }
                    });
                });
            }
        }
        iterateVarDeps(value, iterator) {
            const varDeps = new Set();
            iterateVarDependencies(value, (v) => varDeps.add(v));
            varDeps.forEach((v) => iterator(v));
        }
        findVarRef(varName, iterator, stack = new Set()) {
            if (stack.has(varName)) {
                return null;
            }
            stack.add(varName);
            const result = iterator(varName);
            if (result) {
                return varName;
            }
            const refs = this.varRefs.get(varName);
            if (!refs || refs.size === 0) {
                return null;
            }
            for (const ref of refs) {
                const found = this.findVarRef(ref, iterator, stack);
                if (found) {
                    return found;
                }
            }
            return null;
        }
        itarateVarRefs(varName, iterator) {
            this.findVarRef(varName, (ref) => {
                iterator(ref);
                return false;
            });
        }
        setOnRootVariableChange(callback) {
            this.onRootVariableDefined = callback;
        }
        putRootVars(styleElement, theme) {
            const sheet = styleElement.sheet;
            if (sheet.cssRules.length > 0) {
                sheet.deleteRule(0);
            }
            const declarations = new Map();
            iterateCSSDeclarations(
                document.documentElement.style,
                (property, value) => {
                    if (isVariable(property)) {
                        if (this.isVarType(property, VAR_TYPE_BGCOLOR)) {
                            declarations.set(
                                wrapBgColorVariableName(property),
                                tryModifyBgColor(value, theme)
                            );
                        }
                        if (this.isVarType(property, VAR_TYPE_TEXTCOLOR)) {
                            declarations.set(
                                wrapTextColorVariableName(property),
                                tryModifyTextColor(value, theme)
                            );
                        }
                        if (this.isVarType(property, VAR_TYPE_BORDERCOLOR)) {
                            declarations.set(
                                wrapBorderColorVariableName(property),
                                tryModifyBorderColor(value, theme)
                            );
                        }
                        this.subscribeForVarTypeChange(
                            property,
                            this.onRootVariableDefined
                        );
                    }
                }
            );
            const cssLines = [];
            cssLines.push(":root {");
            for (const [property, value] of declarations) {
                cssLines.push(`    ${property}: ${value};`);
            }
            cssLines.push("}");
            const cssText = cssLines.join("\n");
            sheet.insertRule(cssText);
        }
    }
    const variablesStore = new VariablesStore();
    function getVariableRange(input, searchStart = 0) {
        const start = input.indexOf("var(", searchStart);
        if (start >= 0) {
            const range = getParenthesesRange(input, start + 3);
            if (range) {
                return { start, end: range.end };
            }
            return null;
        }
    }
    function getVariablesMatches(input) {
        const ranges = [];
        let i = 0;
        let range;
        while ((range = getVariableRange(input, i))) {
            const { start, end } = range;
            ranges.push({ start, end, value: input.substring(start, end) });
            i = range.end + 1;
        }
        return ranges;
    }
    function replaceVariablesMatches(input, replacer) {
        const matches = getVariablesMatches(input);
        const matchesCount = matches.length;
        if (matchesCount === 0) {
            return input;
        }
        const inputLength = input.length;
        const replacements = matches.map((m) => replacer(m.value));
        const parts = [];
        parts.push(input.substring(0, matches[0].start));
        for (let i = 0; i < matchesCount; i++) {
            parts.push(replacements[i]);
            const start = matches[i].end;
            const end =
                i < matchesCount - 1 ? matches[i + 1].start : inputLength;
            parts.push(input.substring(start, end));
        }
        return parts.join("");
    }
    function getVariableNameAndFallback(match) {
        const commaIndex = match.indexOf(",");
        let name;
        let fallback;
        if (commaIndex >= 0) {
            name = match.substring(4, commaIndex).trim();
            fallback = match.substring(commaIndex + 1, match.length - 1).trim();
        } else {
            name = match.substring(4, match.length - 1).trim();
            fallback = "";
        }
        return { name, fallback };
    }
    function replaceCSSVariablesNames(value, nameReplacer, fallbackReplacer) {
        const matchReplacer = (match) => {
            const { name, fallback } = getVariableNameAndFallback(match);
            const newName = nameReplacer(name);
            if (!fallback) {
                return `var(${newName})`;
            }
            let newFallback;
            if (isVarDependant(fallback)) {
                newFallback = replaceCSSVariablesNames(
                    fallback,
                    nameReplacer,
                    fallbackReplacer
                );
            } else if (fallbackReplacer) {
                newFallback = fallbackReplacer(fallback);
            } else {
                newFallback = fallback;
            }
            return `var(${newName}, ${newFallback})`;
        };
        return replaceVariablesMatches(value, matchReplacer);
    }
    function iterateVarDependencies(value, iterator) {
        replaceCSSVariablesNames(value, (varName) => {
            iterator(varName);
            return varName;
        });
    }
    function wrapBgColorVariableName(name) {
        return `--darkreader-bg${name}`;
    }
    function wrapTextColorVariableName(name) {
        return `--darkreader-text${name}`;
    }
    function wrapBorderColorVariableName(name) {
        return `--darkreader-border${name}`;
    }
    function wrapBgImgVariableName(name) {
        return `--darkreader-bgimg${name}`;
    }
    function isVariable(property) {
        return property.startsWith("--");
    }
    function isVarDependant(value) {
        return value.includes("var(");
    }
    function isConstructedColorVar(value) {
        return value.match(/^\s*(rgb|hsl)a?\(/);
    }
    function tryModifyBgColor(color, theme) {
        const rgb = tryParseColor(color);
        return rgb ? modifyBackgroundColor(rgb, theme) : color;
    }
    function tryModifyTextColor(color, theme) {
        const rgb = tryParseColor(color);
        return rgb ? modifyForegroundColor(rgb, theme) : color;
    }
    function tryModifyBorderColor(color, theme) {
        const rgb = tryParseColor(color);
        return rgb ? modifyBorderColor(rgb, theme) : color;
    }
    function insertVarValues(source, varValues, stack = new Set()) {
        let containsUnresolvedVar = false;
        const matchReplacer = (match) => {
            const { name, fallback } = getVariableNameAndFallback(match);
            if (stack.has(name)) {
                containsUnresolvedVar = true;
                return null;
            }
            stack.add(name);
            const varValue = varValues.get(name) || fallback;
            let inserted = null;
            if (varValue) {
                if (isVarDependant(varValue)) {
                    inserted = insertVarValues(varValue, varValues, stack);
                } else {
                    inserted = varValue;
                }
            }
            if (!inserted) {
                containsUnresolvedVar = true;
                return null;
            }
            return inserted;
        };
        const replaced = replaceVariablesMatches(source, matchReplacer);
        if (containsUnresolvedVar) {
            return null;
        }
        return replaced;
    }

    const overrides = {
        "background-color": {
            customProp: "--darkreader-inline-bgcolor",
            cssProp: "background-color",
            dataAttr: "data-darkreader-inline-bgcolor"
        },
        "background-image": {
            customProp: "--darkreader-inline-bgimage",
            cssProp: "background-image",
            dataAttr: "data-darkreader-inline-bgimage"
        },
        "border-color": {
            customProp: "--darkreader-inline-border",
            cssProp: "border-color",
            dataAttr: "data-darkreader-inline-border"
        },
        "border-bottom-color": {
            customProp: "--darkreader-inline-border-bottom",
            cssProp: "border-bottom-color",
            dataAttr: "data-darkreader-inline-border-bottom"
        },
        "border-left-color": {
            customProp: "--darkreader-inline-border-left",
            cssProp: "border-left-color",
            dataAttr: "data-darkreader-inline-border-left"
        },
        "border-right-color": {
            customProp: "--darkreader-inline-border-right",
            cssProp: "border-right-color",
            dataAttr: "data-darkreader-inline-border-right"
        },
        "border-top-color": {
            customProp: "--darkreader-inline-border-top",
            cssProp: "border-top-color",
            dataAttr: "data-darkreader-inline-border-top"
        },
        "box-shadow": {
            customProp: "--darkreader-inline-boxshadow",
            cssProp: "box-shadow",
            dataAttr: "data-darkreader-inline-boxshadow"
        },
        "color": {
            customProp: "--darkreader-inline-color",
            cssProp: "color",
            dataAttr: "data-darkreader-inline-color"
        },
        "fill": {
            customProp: "--darkreader-inline-fill",
            cssProp: "fill",
            dataAttr: "data-darkreader-inline-fill"
        },
        "stroke": {
            customProp: "--darkreader-inline-stroke",
            cssProp: "stroke",
            dataAttr: "data-darkreader-inline-stroke"
        },
        "outline-color": {
            customProp: "--darkreader-inline-outline",
            cssProp: "outline-color",
            dataAttr: "data-darkreader-inline-outline"
        },
        "stop-color": {
            customProp: "--darkreader-inline-stopcolor",
            cssProp: "stop-color",
            dataAttr: "data-darkreader-inline-stopcolor"
        }
    };
    const overridesList = Object.values(overrides);
    const normalizedPropList = {};
    overridesList.forEach(
        ({ cssProp, customProp }) => (normalizedPropList[customProp] = cssProp)
    );
    const INLINE_STYLE_ATTRS = [
        "style",
        "fill",
        "stop-color",
        "stroke",
        "bgcolor",
        "color"
    ];
    const INLINE_STYLE_SELECTOR = INLINE_STYLE_ATTRS.map(
        (attr) => `[${attr}]`
    ).join(", ");
    function getInlineOverrideStyle() {
        return overridesList
            .map(({ dataAttr, customProp, cssProp }) => {
                return [
                    `[${dataAttr}] {`,
                    `  ${cssProp}: var(${customProp}) !important;`,
                    "}"
                ].join("\n");
            })
            .join("\n");
    }
    function getInlineStyleElements(root) {
        const results = [];
        if (root instanceof Element && root.matches(INLINE_STYLE_SELECTOR)) {
            results.push(root);
        }
        if (
            root instanceof Element ||
            (isShadowDomSupported && root instanceof ShadowRoot) ||
            root instanceof Document
        ) {
            push(results, root.querySelectorAll(INLINE_STYLE_SELECTOR));
        }
        return results;
    }
    const treeObservers = new Map();
    const attrObservers = new Map();
    function watchForInlineStyles(elementStyleDidChange, shadowRootDiscovered) {
        deepWatchForInlineStyles(
            document,
            elementStyleDidChange,
            shadowRootDiscovered
        );
        iterateShadowHosts(document.documentElement, (host) => {
            deepWatchForInlineStyles(
                host.shadowRoot,
                elementStyleDidChange,
                shadowRootDiscovered
            );
        });
    }
    function deepWatchForInlineStyles(
        root,
        elementStyleDidChange,
        shadowRootDiscovered
    ) {
        if (treeObservers.has(root)) {
            treeObservers.get(root).disconnect();
            attrObservers.get(root).disconnect();
        }
        const discoveredNodes = new WeakSet();
        function discoverNodes(node) {
            getInlineStyleElements(node).forEach((el) => {
                if (discoveredNodes.has(el)) {
                    return;
                }
                discoveredNodes.add(el);
                elementStyleDidChange(el);
            });
            iterateShadowHosts(node, (n) => {
                if (discoveredNodes.has(node)) {
                    return;
                }
                discoveredNodes.add(node);
                shadowRootDiscovered(n.shadowRoot);
                deepWatchForInlineStyles(
                    n.shadowRoot,
                    elementStyleDidChange,
                    shadowRootDiscovered
                );
            });
        }
        const treeObserver = createOptimizedTreeObserver(root, {
            onMinorMutations: ({ additions }) => {
                additions.forEach((added) => discoverNodes(added));
            },
            onHugeMutations: () => {
                discoverNodes(root);
            }
        });
        treeObservers.set(root, treeObserver);
        let attemptCount = 0;
        let start = null;
        const ATTEMPTS_INTERVAL = getDuration({ seconds: 10 });
        const RETRY_TIMEOUT = getDuration({ seconds: 2 });
        const MAX_ATTEMPTS_COUNT = 50;
        let cache = [];
        let timeoutId = null;
        const handleAttributeMutations = throttle((mutations) => {
            mutations.forEach((m) => {
                if (INLINE_STYLE_ATTRS.includes(m.attributeName)) {
                    elementStyleDidChange(m.target);
                }
            });
        });
        const attrObserver = new MutationObserver((mutations) => {
            if (timeoutId) {
                cache.push(...mutations);
                return;
            }
            attemptCount++;
            const now = Date.now();
            if (start == null) {
                start = now;
            } else if (attemptCount >= MAX_ATTEMPTS_COUNT) {
                if (now - start < ATTEMPTS_INTERVAL) {
                    timeoutId = setTimeout(() => {
                        start = null;
                        attemptCount = 0;
                        timeoutId = null;
                        const attributeCache = cache;
                        cache = [];
                        handleAttributeMutations(attributeCache);
                    }, RETRY_TIMEOUT);
                    cache.push(...mutations);
                    return;
                }
                start = now;
                attemptCount = 1;
            }
            handleAttributeMutations(mutations);
        });
        attrObserver.observe(root, {
            attributes: true,
            attributeFilter: INLINE_STYLE_ATTRS.concat(
                overridesList.map(({ dataAttr }) => dataAttr)
            ),
            subtree: true
        });
        attrObservers.set(root, attrObserver);
    }
    function stopWatchingForInlineStyles() {
        treeObservers.forEach((o) => o.disconnect());
        attrObservers.forEach((o) => o.disconnect());
        treeObservers.clear();
        attrObservers.clear();
    }
    const inlineStyleCache = new WeakMap();
    const filterProps = [
        "brightness",
        "contrast",
        "grayscale",
        "sepia",
        "mode"
    ];
    function getInlineStyleCacheKey(el, theme) {
        return INLINE_STYLE_ATTRS.map(
            (attr) => `${attr}="${el.getAttribute(attr)}"`
        )
            .concat(filterProps.map((prop) => `${prop}="${theme[prop]}"`))
            .join(" ");
    }
    function shouldIgnoreInlineStyle(element, selectors) {
        for (let i = 0, len = selectors.length; i < len; i++) {
            const ingnoredSelector = selectors[i];
            if (element.matches(ingnoredSelector)) {
                return true;
            }
        }
        return false;
    }
    function overrideInlineStyle(
        element,
        theme,
        ignoreInlineSelectors,
        ignoreImageSelectors
    ) {
        const cacheKey = getInlineStyleCacheKey(element, theme);
        if (cacheKey === inlineStyleCache.get(element)) {
            return;
        }
        const unsetProps = new Set(Object.keys(overrides));
        function setCustomProp(targetCSSProp, modifierCSSProp, cssVal) {
            const { customProp, dataAttr } = overrides[targetCSSProp];
            const mod = getModifiableCSSDeclaration(
                modifierCSSProp,
                cssVal,
                {},
                variablesStore,
                ignoreImageSelectors,
                null
            );
            if (!mod) {
                return;
            }
            let value = mod.value;
            if (typeof value === "function") {
                value = value(theme);
            }
            element.style.setProperty(customProp, value);
            if (!element.hasAttribute(dataAttr)) {
                element.setAttribute(dataAttr, "");
            }
            unsetProps.delete(targetCSSProp);
        }
        if (ignoreInlineSelectors.length > 0) {
            if (shouldIgnoreInlineStyle(element, ignoreInlineSelectors)) {
                unsetProps.forEach((cssProp) => {
                    element.removeAttribute(overrides[cssProp].dataAttr);
                });
                return;
            }
        }
        if (element.hasAttribute("bgcolor")) {
            let value = element.getAttribute("bgcolor");
            if (
                value.match(/^[0-9a-f]{3}$/i) ||
                value.match(/^[0-9a-f]{6}$/i)
            ) {
                value = `#${value}`;
            }
            setCustomProp("background-color", "background-color", value);
        }
        if (element.hasAttribute("color") && element.rel !== "mask-icon") {
            let value = element.getAttribute("color");
            if (
                value.match(/^[0-9a-f]{3}$/i) ||
                value.match(/^[0-9a-f]{6}$/i)
            ) {
                value = `#${value}`;
            }
            setCustomProp("color", "color", value);
        }
        if (element instanceof SVGElement) {
            if (element.hasAttribute("fill")) {
                const SMALL_SVG_LIMIT = 32;
                const value = element.getAttribute("fill");
                if (value !== "none") {
                    if (!(element instanceof SVGTextElement)) {
                        const handleSVGElement = () => {
                            const { width, height } =
                                element.getBoundingClientRect();
                            const isBg =
                                width > SMALL_SVG_LIMIT ||
                                height > SMALL_SVG_LIMIT;
                            setCustomProp(
                                "fill",
                                isBg ? "background-color" : "color",
                                value
                            );
                        };
                        if (isReadyStateComplete()) {
                            handleSVGElement();
                        } else {
                            addReadyStateCompleteListener(handleSVGElement);
                        }
                    } else {
                        setCustomProp("fill", "color", value);
                    }
                }
            }
            if (element.hasAttribute("stop-color")) {
                setCustomProp(
                    "stop-color",
                    "background-color",
                    element.getAttribute("stop-color")
                );
            }
        }
        if (element.hasAttribute("stroke")) {
            const value = element.getAttribute("stroke");
            setCustomProp(
                "stroke",
                element instanceof SVGLineElement ||
                    element instanceof SVGTextElement
                    ? "border-color"
                    : "color",
                value
            );
        }
        element.style &&
            iterateCSSDeclarations(element.style, (property, value) => {
                if (property === "background-image" && value.includes("url")) {
                    return;
                }
                if (overrides.hasOwnProperty(property)) {
                    setCustomProp(property, property, value);
                } else {
                    const overridenProp = normalizedPropList[property];
                    if (
                        overridenProp &&
                        !element.style.getPropertyValue(overridenProp) &&
                        !element.hasAttribute(overridenProp)
                    ) {
                        if (
                            overridenProp === "background-color" &&
                            element.hasAttribute("bgcolor")
                        ) {
                            return;
                        }
                        element.style.setProperty(property, "");
                    }
                }
            });
        if (
            element.style &&
            element instanceof SVGTextElement &&
            element.style.fill
        ) {
            setCustomProp(
                "fill",
                "color",
                element.style.getPropertyValue("fill")
            );
        }
        forEach(unsetProps, (cssProp) => {
            element.removeAttribute(overrides[cssProp].dataAttr);
        });
        inlineStyleCache.set(element, getInlineStyleCacheKey(element, theme));
    }

    const metaThemeColorName = "theme-color";
    const metaThemeColorSelector = `meta[name="${metaThemeColorName}"]`;
    let srcMetaThemeColor = null;
    let observer = null;
    function changeMetaThemeColor(meta, theme) {
        srcMetaThemeColor = srcMetaThemeColor || meta.content;
        try {
            const color = parse(srcMetaThemeColor);
            meta.content = modifyBackgroundColor(color, theme);
        } catch (err) { }
    }
    function changeMetaThemeColorWhenAvailable(theme) {
        const meta = document.querySelector(metaThemeColorSelector);
        if (meta) {
            changeMetaThemeColor(meta, theme);
        } else {
            if (observer) {
                observer.disconnect();
            }
            observer = new MutationObserver((mutations) => {
                loop: for (let i = 0; i < mutations.length; i++) {
                    const { addedNodes } = mutations[i];
                    for (let j = 0; j < addedNodes.length; j++) {
                        const node = addedNodes[j];
                        if (
                            node instanceof HTMLMetaElement &&
                            node.name === metaThemeColorName
                        ) {
                            observer.disconnect();
                            observer = null;
                            changeMetaThemeColor(node, theme);
                            break loop;
                        }
                    }
                }
            });
            observer.observe(document.head, { childList: true });
        }
    }
    function restoreMetaThemeColor() {
        if (observer) {
            observer.disconnect();
            observer = null;
        }
        const meta = document.querySelector(metaThemeColorSelector);
        if (meta && srcMetaThemeColor) {
            meta.content = srcMetaThemeColor;
        }
    }

    const themeCacheKeys = [
        "mode",
        "brightness",
        "contrast",
        "grayscale",
        "sepia",
        "darkSchemeBackgroundColor",
        "darkSchemeTextColor",
        "lightSchemeBackgroundColor",
        "lightSchemeTextColor"
    ];
    function getThemeKey(theme) {
        return themeCacheKeys.map((p) => `${p}:${theme[p]}`).join(";");
    }
    const asyncQueue = createAsyncTasksQueue();
    function createStyleSheetModifier() {
        let renderId = 0;
        const rulesTextCache = new Set();
        const rulesModCache = new Map();
        const varTypeChangeCleaners = new Set();
        let prevFilterKey = null;
        let hasNonLoadedLink = false;
        let wasRebuilt = false;
        function shouldRebuildStyle() {
            return hasNonLoadedLink && !wasRebuilt;
        }
        function modifySheet(options) {
            const rules = options.sourceCSSRules;
            const {
                theme,
                ignoreImageAnalysis,
                force,
                prepareSheet,
                isAsyncCancelled
            } = options;
            let rulesChanged = rulesModCache.size === 0;
            const notFoundCacheKeys = new Set(rulesModCache.keys());
            const themeKey = getThemeKey(theme);
            const themeChanged = themeKey !== prevFilterKey;
            if (hasNonLoadedLink) {
                wasRebuilt = true;
            }
            const modRules = [];
            iterateCSSRules(
                rules,
                (rule) => {
                    let cssText = rule.cssText;
                    let textDiffersFromPrev = false;
                    notFoundCacheKeys.delete(cssText);
                    if (rule.parentRule instanceof CSSMediaRule) {
                        cssText += `;${rule.parentRule.media.mediaText}`;
                    }
                    if (!rulesTextCache.has(cssText)) {
                        rulesTextCache.add(cssText);
                        textDiffersFromPrev = true;
                    }
                    if (textDiffersFromPrev) {
                        rulesChanged = true;
                    } else {
                        modRules.push(rulesModCache.get(cssText));
                        return;
                    }
                    const modDecs = [];
                    rule.style &&
                        iterateCSSDeclarations(
                            rule.style,
                            (property, value) => {
                                const mod = getModifiableCSSDeclaration(
                                    property,
                                    value,
                                    rule,
                                    variablesStore,
                                    ignoreImageAnalysis,
                                    isAsyncCancelled
                                );
                                if (mod) {
                                    modDecs.push(mod);
                                }
                            }
                        );
                    let modRule = null;
                    if (modDecs.length > 0) {
                        const parentRule = rule.parentRule;
                        modRule = {
                            selector: rule.selectorText,
                            declarations: modDecs,
                            parentRule
                        };
                        modRules.push(modRule);
                    }
                    rulesModCache.set(cssText, modRule);
                },
                () => {
                    hasNonLoadedLink = true;
                }
            );
            notFoundCacheKeys.forEach((key) => {
                rulesTextCache.delete(key);
                rulesModCache.delete(key);
            });
            prevFilterKey = themeKey;
            if (!force && !rulesChanged && !themeChanged) {
                return;
            }
            renderId++;
            function setRule(target, index, rule) {
                // console.log("target=",target,",rule=",rule,",index=",index);
                const { selector, declarations } = rule;
                const getDeclarationText = (dec) => {
                    const { property, value, important, sourceValue } = dec;
                    return `${property}: ${value == null ? sourceValue : value
                        }${important ? " !important" : ""};`;
                };
                const ruleText = `${selector} { ${declarations.map(getDeclarationText).join(" ")} }`;
                // console.log("target=",target,",ruleText=",ruleText,",index=",index);
                target.insertRule(ruleText, index);
            }
            const asyncDeclarations = new Map();
            const varDeclarations = new Map();
            let asyncDeclarationCounter = 0;
            let varDeclarationCounter = 0;
            const rootReadyGroup = { rule: null, rules: [], isGroup: true };
            const groupRefs = new WeakMap();
            function getGroup(rule) {
                if (rule == null) {
                    return rootReadyGroup;
                }
                if (groupRefs.has(rule)) {
                    return groupRefs.get(rule);
                }
                const group = { rule, rules: [], isGroup: true };
                groupRefs.set(rule, group);
                const parentGroup = getGroup(rule.parentRule);
                parentGroup.rules.push(group);
                return group;
            }
            varTypeChangeCleaners.forEach((clear) => clear());
            varTypeChangeCleaners.clear();
            modRules
                .filter((r) => r)
                .forEach(({ selector, declarations, parentRule }) => {
                    const group = getGroup(parentRule);
                    const readyStyleRule = {
                        selector,
                        declarations: [],
                        isGroup: false
                    };
                    const readyDeclarations = readyStyleRule.declarations;
                    group.rules.push(readyStyleRule);
                    function handleAsyncDeclaration(
                        property,
                        modified,
                        important,
                        sourceValue
                    ) {
                        const asyncKey = ++asyncDeclarationCounter;
                        const asyncDeclaration = {
                            property,
                            value: null,
                            important,
                            asyncKey,
                            sourceValue
                        };
                        readyDeclarations.push(asyncDeclaration);
                        const currentRenderId = renderId;
                        modified.then((asyncValue) => {
                            if (
                                !asyncValue ||
                                isAsyncCancelled() ||
                                currentRenderId !== renderId
                            ) {
                                return;
                            }
                            asyncDeclaration.value = asyncValue;
                            asyncQueue.add(() => {
                                if (
                                    isAsyncCancelled() ||
                                    currentRenderId !== renderId
                                ) {
                                    return;
                                }
                                rebuildAsyncRule(asyncKey);
                            });
                        });
                    }
                    function handleVarDeclarations(
                        property,
                        modified,
                        important,
                        sourceValue
                    ) {
                        const { declarations: varDecs, onTypeChange } = modified;
                        const varKey = ++varDeclarationCounter;
                        const currentRenderId = renderId;
                        const initialIndex = readyDeclarations.length;
                        let oldDecs = [];
                        if (varDecs.length === 0) {
                            const tempDec = {
                                property,
                                value: sourceValue,
                                important,
                                sourceValue,
                                varKey
                            };
                            readyDeclarations.push(tempDec);
                            oldDecs = [tempDec];
                        }
                        varDecs.forEach((mod) => {
                            if (mod.value instanceof Promise) {
                                handleAsyncDeclaration(
                                    mod.property,
                                    mod.value,
                                    important,
                                    sourceValue
                                );
                            } else {
                                const readyDec = {
                                    property: mod.property,
                                    value: mod.value,
                                    important,
                                    sourceValue,
                                    varKey
                                };
                                readyDeclarations.push(readyDec);
                                oldDecs.push(readyDec);
                            }
                        });
                        onTypeChange.addListener((newDecs) => {
                            if (
                                isAsyncCancelled() ||
                                currentRenderId !== renderId
                            ) {
                                return;
                            }
                            const readyVarDecs = newDecs.map((mod) => {
                                return {
                                    property: mod.property,
                                    value: mod.value,
                                    important,
                                    sourceValue,
                                    varKey
                                };
                            });
                            const index = readyDeclarations.indexOf(
                                oldDecs[0],
                                initialIndex
                            );
                            readyDeclarations.splice(
                                index,
                                oldDecs.length,
                                ...readyVarDecs
                            );
                            oldDecs = readyVarDecs;
                            rebuildVarRule(varKey);
                        });
                        varTypeChangeCleaners.add(() =>
                            onTypeChange.removeListeners()
                        );
                    }
                    declarations.forEach(
                        ({ property, value, important, sourceValue }) => {
                            if (typeof value === "function") {
                                const modified = value(theme);
                                if (modified instanceof Promise) {
                                    handleAsyncDeclaration(
                                        property,
                                        modified,
                                        important,
                                        sourceValue
                                    );
                                } else if (property.startsWith("--")) {
                                    handleVarDeclarations(
                                        property,
                                        modified,
                                        important,
                                        sourceValue
                                    );
                                } else {
                                    readyDeclarations.push({
                                        property,
                                        value: modified,
                                        important,
                                        sourceValue
                                    });
                                }
                            } else {
                                readyDeclarations.push({
                                    property,
                                    value,
                                    important,
                                    sourceValue
                                });
                            }
                        }
                    );
                });
            const sheet = prepareSheet();
            function buildStyleSheet() {
                function createTarget(group, parent) {
                    const { rule } = group;
                    if (rule instanceof CSSMediaRule) {
                        const { media } = rule;
                        const index = parent.cssRules.length;
                        parent.insertRule(
                            `@media ${media.mediaText} {}`,
                            index
                        );
                        return parent.cssRules[index];
                    }
                    return parent;
                }
                function iterateReadyRules(group, target, styleIterator) {
                    group.rules.forEach((r) => {
                        if (r.isGroup) {
                            const t = createTarget(r, target);
                            iterateReadyRules(r, t, styleIterator);
                        } else {
                            styleIterator(r, target);
                        }
                    });
                }
                iterateReadyRules(rootReadyGroup, sheet, (rule, target) => {
                    const index = target.cssRules.length;
                    rule.declarations.forEach(({ asyncKey, varKey }) => {
                        if (asyncKey != null) {
                            asyncDeclarations.set(asyncKey, {
                                rule,
                                target,
                                index
                            });
                        }
                        if (varKey != null) {
                            varDeclarations.set(varKey, { rule, target, index });
                        }
                    });
                    setRule(target, index, rule);
                });
            }
            function rebuildAsyncRule(key) {
                // console.log("key====",key,",asyncDeclarations====",asyncDeclarations);
                const { rule, target, index } = asyncDeclarations.get(key);
                target.deleteRule(index);
                setRule(target, index, rule);
                asyncDeclarations.delete(key);
            }
            function rebuildVarRule(key) {
                const { rule, target, index } = varDeclarations.get(key);
                target.deleteRule(index);
                setRule(target, index, rule);
            }
            buildStyleSheet();
        }
        return { modifySheet, shouldRebuildStyle };
    }

    const STYLE_SELECTOR = 'style, link[rel*="stylesheet" i]:not([disabled])';
    function shouldManageStyle(element) {
        return (
            (element instanceof HTMLStyleElement ||
                element instanceof SVGStyleElement ||
                (element instanceof HTMLLinkElement &&
                    element.rel &&
                    element.rel.toLowerCase().includes("stylesheet") &&
                    !element.disabled)) &&
            !element.classList.contains("darkreader") &&
            element.media.toLowerCase() !== "print" &&
            !element.classList.contains("stylus")
        );
    }
    function getManageableStyles(node, results = [], deep = true) {
        if (shouldManageStyle(node)) {
            results.push(node);
        } else if (
            node instanceof Element ||
            (isShadowDomSupported && node instanceof ShadowRoot) ||
            node === document
        ) {
            forEach(node.querySelectorAll(STYLE_SELECTOR), (style) =>
                getManageableStyles(style, results, false)
            );
            if (deep) {
                iterateShadowHosts(node, (host) =>
                    getManageableStyles(host.shadowRoot, results, false)
                );
            }
        }
        return results;
    }
    const syncStyleSet = new WeakSet();
    const corsStyleSet = new WeakSet();
    let canOptimizeUsingProxy$1 = false;
    document.addEventListener("__darkreader__inlineScriptsAllowed", () => {
        canOptimizeUsingProxy$1 = true;
    });
    let loadingLinkCounter = 0;
    const rejectorsForLoadingLinks = new Map();
    function cleanLoadingLinks() {
        rejectorsForLoadingLinks.clear();
    }
    function manageStyle(element, { update, loadingStart, loadingEnd }) {
        const prevStyles = [];
        let next = element;
        while (
            (next = next.nextElementSibling) &&
            next.matches(".darkreader")
        ) {
            prevStyles.push(next);
        }
        let corsCopy =
            prevStyles.find(
                (el) => el.matches(".darkreader--cors") && !corsStyleSet.has(el)
            ) || null;
        let syncStyle =
            prevStyles.find(
                (el) => el.matches(".darkreader--sync") && !syncStyleSet.has(el)
            ) || null;
        let corsCopyPositionWatcher = null;
        let syncStylePositionWatcher = null;
        let cancelAsyncOperations = false;
        let isOverrideEmpty = true;
        const sheetModifier = createStyleSheetModifier();
        const observer = new MutationObserver(() => {
            update();
        });
        const observerOptions = {
            attributes: true,
            childList: true,
            subtree: true,
            characterData: true
        };
        function containsCSSImport() {
            return (
                element instanceof HTMLStyleElement &&
                element.textContent.trim().match(cssImportRegex)
            );
        }
        function hasImports(cssRules, checkCrossOrigin) {
            let result = false;
            if (cssRules) {
                let rule;
                cssRulesLoop: for (
                    let i = 0, len = cssRules.length;
                    i < len;
                    i++
                ) {
                    rule = cssRules[i];
                    if (rule.href) {
                        if (checkCrossOrigin) {
                            if (
                                rule.href.startsWith("http") &&
                                !rule.href.startsWith(location.origin)
                            ) {
                                result = true;
                                break cssRulesLoop;
                            }
                        } else {
                            result = true;
                            break cssRulesLoop;
                        }
                    }
                }
            }
            return result;
        }
        function getRulesSync() {
            if (corsCopy) {
                return corsCopy.sheet.cssRules;
            }
            if (containsCSSImport()) {
                return null;
            }
            const cssRules = safeGetSheetRules();
            if (
                element instanceof HTMLLinkElement &&
                !isRelativeHrefOnAbsolutePath(element.href) &&
                hasImports(cssRules, false)
            ) {
                return null;
            }
            if (hasImports(cssRules, true)) {
                return null;
            }
            return cssRules;
        }
        function insertStyle() {
            if (corsCopy) {
                if (element.nextSibling !== corsCopy) {
                    element.parentNode.insertBefore(
                        corsCopy,
                        element.nextSibling
                    );
                }
                if (corsCopy.nextSibling !== syncStyle) {
                    element.parentNode.insertBefore(
                        syncStyle,
                        corsCopy.nextSibling
                    );
                }
            } else if (element.nextSibling !== syncStyle) {
                element.parentNode.insertBefore(syncStyle, element.nextSibling);
            }
        }
        function createSyncStyle() {
            syncStyle =
                element instanceof SVGStyleElement
                    ? document.createElementNS(
                        "http://www.w3.org/2000/svg",
                        "style"
                    )
                    : document.createElement("style");
            syncStyle.classList.add("darkreader");
            syncStyle.classList.add("darkreader--sync");
            syncStyle.media = "screen";
            if (element.title) {
                syncStyle.title = element.title;
            }
            syncStyleSet.add(syncStyle);
        }
        let isLoadingRules = false;
        let wasLoadingError = false;
        const loadingLinkId = ++loadingLinkCounter;
        async function getRulesAsync() {
            let cssText;
            let cssBasePath;
            if (element instanceof HTMLLinkElement) {
                let [cssRules, accessError] = getRulesOrError();
                if (
                    (!cssRules && !accessError && !isSafari) ||
                    (isSafari && !element.sheet) ||
                    isStillLoadingError(accessError)
                ) {
                    try {
                        logInfo(
                            `Linkelement ${loadingLinkId} is not loaded yet and thus will be await for`,
                            element
                        );
                        await linkLoading(element, loadingLinkId);
                    } catch (err) {
                        wasLoadingError = true;
                    }
                    if (cancelAsyncOperations) {
                        return null;
                    }
                    [cssRules, accessError] = getRulesOrError();
                }
                if (cssRules) {
                    if (isRelativeHrefOnAbsolutePath(element.href)) {
                        return cssRules;
                    } else if (!hasImports(cssRules, false)) {
                        return cssRules;
                    }
                }
                cssText = await loadText(element.href);
                cssBasePath = getCSSBaseBath(element.href);
                if (cancelAsyncOperations) {
                    return null;
                }
            } else if (containsCSSImport()) {
                cssText = element.textContent.trim();
                cssBasePath = getCSSBaseBath(location.href);
            } else {
                return null;
            }
            if (cssText) {
                try {
                    const fullCSSText = await replaceCSSImports(
                        cssText,
                        cssBasePath
                    );
                    corsCopy = createCORSCopy(element, fullCSSText);
                } catch (err) { }
                if (corsCopy) {
                    corsCopyPositionWatcher = watchForNodePosition(
                        corsCopy,
                        "prev-sibling"
                    );
                    return corsCopy.sheet.cssRules;
                }
            }
            return null;
        }
        function details() {
            const rules = getRulesSync();
            if (!rules) {
                if (isLoadingRules || wasLoadingError) {
                    return null;
                }
                isLoadingRules = true;
                loadingStart();
                getRulesAsync()
                    .then((results) => {
                        isLoadingRules = false;
                        loadingEnd();
                        if (results) {
                            update();
                        }
                    })
                    .catch((err) => {
                        isLoadingRules = false;
                        loadingEnd();
                    });
                return null;
            }
            return { rules };
        }
        let forceRenderStyle = false;
        function render(theme, ignoreImageAnalysis) {
            const rules = getRulesSync();
            if (!rules) {
                return;
            }
            cancelAsyncOperations = false;
            function removeCSSRulesFromSheet(sheet) {
                try {
                    if (sheet.replaceSync) {
                        sheet.replaceSync("");
                        return;
                    }
                } catch (err) { }
                for (let i = sheet.cssRules.length - 1; i >= 0; i--) {
                    sheet.deleteRule(i);
                }
            }
            function prepareOverridesSheet() {
                if (!syncStyle) {
                    createSyncStyle();
                }
                syncStylePositionWatcher && syncStylePositionWatcher.stop();
                insertStyle();
                if (syncStyle.sheet == null) {
                    syncStyle.textContent = "";
                }
                const sheet = syncStyle.sheet;
                removeCSSRulesFromSheet(sheet);
                if (syncStylePositionWatcher) {
                    syncStylePositionWatcher.run();
                } else {
                    syncStylePositionWatcher = watchForNodePosition(
                        syncStyle,
                        "prev-sibling",
                        () => {
                            forceRenderStyle = true;
                            buildOverrides();
                        }
                    );
                }
                return syncStyle.sheet;
            }
            function buildOverrides() {
                const force = forceRenderStyle;
                forceRenderStyle = false;
                sheetModifier.modifySheet({
                    prepareSheet: prepareOverridesSheet,
                    sourceCSSRules: rules,
                    theme,
                    ignoreImageAnalysis,
                    force,
                    isAsyncCancelled: () => cancelAsyncOperations
                });
                isOverrideEmpty = syncStyle.sheet.cssRules.length === 0;
                if (sheetModifier.shouldRebuildStyle()) {
                    addReadyStateCompleteListener(() => update());
                }
            }
            buildOverrides();
        }
        function getRulesOrError() {
            try {
                if (element.sheet == null) {
                    return [null, null];
                }
                return [element.sheet.cssRules, null];
            } catch (err) {
                return [null, err];
            }
        }
        function isStillLoadingError(error) {
            return error && error.message && error.message.includes("loading");
        }
        function safeGetSheetRules() {
            const [cssRules, err] = getRulesOrError();
            if (err) {
                return null;
            }
            return cssRules;
        }
        function watchForSheetChanges() {
            watchForSheetChangesUsingProxy();
            if (!isThunderbird && !(canOptimizeUsingProxy$1 && element.sheet)) {
                watchForSheetChangesUsingRAF();
            }
        }
        let rulesChangeKey = null;
        let rulesCheckFrameId = null;
        function getRulesChangeKey() {
            const rules = safeGetSheetRules();
            return rules ? rules.length : null;
        }
        function didRulesKeyChange() {
            return getRulesChangeKey() !== rulesChangeKey;
        }
        function watchForSheetChangesUsingRAF() {
            rulesChangeKey = getRulesChangeKey();
            stopWatchingForSheetChangesUsingRAF();
            const checkForUpdate = () => {
                if (didRulesKeyChange()) {
                    rulesChangeKey = getRulesChangeKey();
                    update();
                }
                if (canOptimizeUsingProxy$1 && element.sheet) {
                    stopWatchingForSheetChangesUsingRAF();
                    return;
                }
                rulesCheckFrameId = requestAnimationFrame(checkForUpdate);
            };
            checkForUpdate();
        }
        function stopWatchingForSheetChangesUsingRAF() {
            cancelAnimationFrame(rulesCheckFrameId);
        }
        let areSheetChangesPending = false;
        function onSheetChange() {
            canOptimizeUsingProxy$1 = true;
            stopWatchingForSheetChangesUsingRAF();
            if (areSheetChangesPending) {
                return;
            }
            function handleSheetChanges() {
                areSheetChangesPending = false;
                if (cancelAsyncOperations) {
                    return;
                }
                update();
            }
            areSheetChangesPending = true;
            if (typeof queueMicrotask === "function") {
                queueMicrotask(handleSheetChanges);
            } else {
                requestAnimationFrame(handleSheetChanges);
            }
        }
        function watchForSheetChangesUsingProxy() {
            element.addEventListener(
                "__darkreader__updateSheet",
                onSheetChange
            );
        }
        function stopWatchingForSheetChangesUsingProxy() {
            element.removeEventListener(
                "__darkreader__updateSheet",
                onSheetChange
            );
        }
        function stopWatchingForSheetChanges() {
            stopWatchingForSheetChangesUsingProxy();
            stopWatchingForSheetChangesUsingRAF();
        }
        function pause() {
            observer.disconnect();
            cancelAsyncOperations = true;
            corsCopyPositionWatcher && corsCopyPositionWatcher.stop();
            syncStylePositionWatcher && syncStylePositionWatcher.stop();
            stopWatchingForSheetChanges();
        }
        function destroy() {
            pause();
            removeNode(corsCopy);
            removeNode(syncStyle);
            loadingEnd();
            if (rejectorsForLoadingLinks.has(loadingLinkId)) {
                const reject = rejectorsForLoadingLinks.get(loadingLinkId);
                rejectorsForLoadingLinks.delete(loadingLinkId);
                reject && reject();
            }
        }
        function watch() {
            observer.observe(element, observerOptions);
            if (element instanceof HTMLStyleElement) {
                watchForSheetChanges();
            }
        }
        const maxMoveCount = 10;
        let moveCount = 0;
        function restore() {
            if (!syncStyle) {
                return;
            }
            moveCount++;
            if (moveCount > maxMoveCount) {
                return;
            }
            insertStyle();
            corsCopyPositionWatcher && corsCopyPositionWatcher.skip();
            syncStylePositionWatcher && syncStylePositionWatcher.skip();
            if (!isOverrideEmpty) {
                forceRenderStyle = true;
                update();
            }
        }
        return {
            details,
            render,
            pause,
            destroy,
            watch,
            restore
        };
    }
    async function linkLoading(link, loadingId) {
        return new Promise((resolve, reject) => {
            const cleanUp = () => {
                link.removeEventListener("load", onLoad);
                link.removeEventListener("error", onError);
                rejectorsForLoadingLinks.delete(loadingId);
            };
            const onLoad = () => {
                cleanUp();
                resolve();
            };
            const onError = () => {
                cleanUp();
                reject(
                    `Linkelement ${loadingId} couldn't be loaded. ${link.href}`
                );
            };
            rejectorsForLoadingLinks.set(loadingId, () => {
                cleanUp();
                reject();
            });
            link.addEventListener("load", onLoad);
            link.addEventListener("error", onError);
            if (!link.href) {
                onError();
            }
        });
    }
    function getCSSImportURL(importDeclaration) {
        return getCSSURLValue(
            importDeclaration.substring(7).trim().replace(/;$/, "")
        );
    }
    async function loadText(url) {
        if (url.startsWith("data:")) {
            return await (await fetch(url)).text();
        }
        return await bgFetch({
            url,
            responseType: "text",
            mimeType: "text/css",
            origin: window.location.origin
        });
    }
    async function replaceCSSImports(cssText, basePath, cache = new Map()) {
        cssText = removeCSSComments(cssText);
        cssText = replaceCSSFontFace(cssText);
        cssText = replaceCSSRelativeURLsWithAbsolute(cssText, basePath);
        const importMatches = getMatches(cssImportRegex, cssText);
        for (const match of importMatches) {
            const importURL = getCSSImportURL(match);
            const absoluteURL = getAbsoluteURL(basePath, importURL);
            let importedCSS;
            if (cache.has(absoluteURL)) {
                importedCSS = cache.get(absoluteURL);
            } else {
                try {
                    importedCSS = await loadText(absoluteURL);
                    cache.set(absoluteURL, importedCSS);
                    importedCSS = await replaceCSSImports(
                        importedCSS,
                        getCSSBaseBath(absoluteURL),
                        cache
                    );
                } catch (err) {
                    importedCSS = "";
                }
            }
            cssText = cssText.split(match).join(importedCSS);
        }
        cssText = cssText.trim();
        return cssText;
    }
    function createCORSCopy(srcElement, cssText) {
        if (!cssText) {
            return null;
        }
        const cors = document.createElement("style");
        cors.classList.add("darkreader");
        cors.classList.add("darkreader--cors");
        cors.media = "screen";
        cors.textContent = cssText;
        srcElement.parentNode.insertBefore(cors, srcElement.nextSibling);
        cors.sheet.disabled = true;
        corsStyleSet.add(cors);
        return cors;
    }

    const observers = [];
    let observedRoots;
    const undefinedGroups = new Map();
    let elementsDefinitionCallback;
    function collectUndefinedElements(root) {
        if (!isDefinedSelectorSupported) {
            return;
        }
        forEach(root.querySelectorAll(":not(:defined)"), (el) => {
            let tag = el.tagName.toLowerCase();
            if (!tag.includes("-")) {
                const extendedTag = el.getAttribute("is");
                if (extendedTag) {
                    tag = extendedTag;
                } else {
                    return;
                }
            }
            if (!undefinedGroups.has(tag)) {
                undefinedGroups.set(tag, new Set());
                customElementsWhenDefined(tag).then(() => {
                    if (elementsDefinitionCallback) {
                        const elements = undefinedGroups.get(tag);
                        undefinedGroups.delete(tag);
                        elementsDefinitionCallback(Array.from(elements));
                    }
                });
            }
            undefinedGroups.get(tag).add(el);
        });
    }
    let canOptimizeUsingProxy = false;
    document.addEventListener("__darkreader__inlineScriptsAllowed", () => {
        canOptimizeUsingProxy = true;
    });
    const resolvers = new Map();
    function handleIsDefined(e) {
        canOptimizeUsingProxy = true;
        if (resolvers.has(e.detail.tag)) {
            const resolve = resolvers.get(e.detail.tag);
            resolve();
        }
    }
    async function customElementsWhenDefined(tag) {
        return new Promise((resolve) => {
            if (
                window.customElements &&
                typeof customElements.whenDefined === "function"
            ) {
                customElements.whenDefined(tag).then(() => resolve());
            } else if (canOptimizeUsingProxy) {
                resolvers.set(tag, resolve);
                document.dispatchEvent(
                    new CustomEvent("__darkreader__addUndefinedResolver", {
                        detail: { tag }
                    })
                );
            } else {
                const checkIfDefined = () => {
                    const elements = undefinedGroups.get(tag);
                    if (elements && elements.size > 0) {
                        if (
                            elements.values().next().value.matches(":defined")
                        ) {
                            resolve();
                        } else {
                            requestAnimationFrame(checkIfDefined);
                        }
                    }
                };
                requestAnimationFrame(checkIfDefined);
            }
        });
    }
    function watchWhenCustomElementsDefined(callback) {
        elementsDefinitionCallback = callback;
    }
    function unsubscribeFromDefineCustomElements() {
        elementsDefinitionCallback = null;
        undefinedGroups.clear();
        document.removeEventListener(
            "__darkreader__isDefined",
            handleIsDefined
        );
    }
    function watchForStyleChanges(currentStyles, update, shadowRootDiscovered) {
        stopWatchingForStyleChanges();
        const prevStyles = new Set(currentStyles);
        const prevStyleSiblings = new WeakMap();
        const nextStyleSiblings = new WeakMap();
        function saveStylePosition(style) {
            prevStyleSiblings.set(style, style.previousElementSibling);
            nextStyleSiblings.set(style, style.nextElementSibling);
        }
        function forgetStylePosition(style) {
            prevStyleSiblings.delete(style);
            nextStyleSiblings.delete(style);
        }
        function didStylePositionChange(style) {
            return (
                style.previousElementSibling !== prevStyleSiblings.get(style) ||
                style.nextElementSibling !== nextStyleSiblings.get(style)
            );
        }
        currentStyles.forEach(saveStylePosition);
        function handleStyleOperations(operations) {
            const { createdStyles, removedStyles, movedStyles } = operations;
            createdStyles.forEach((s) => saveStylePosition(s));
            movedStyles.forEach((s) => saveStylePosition(s));
            removedStyles.forEach((s) => forgetStylePosition(s));
            createdStyles.forEach((s) => prevStyles.add(s));
            removedStyles.forEach((s) => prevStyles.delete(s));
            if (
                createdStyles.size + removedStyles.size + movedStyles.size >
                0
            ) {
                update({
                    created: Array.from(createdStyles),
                    removed: Array.from(removedStyles),
                    moved: Array.from(movedStyles),
                    updated: []
                });
            }
        }
        function handleMinorTreeMutations({ additions, moves, deletions }) {
            const createdStyles = new Set();
            const removedStyles = new Set();
            const movedStyles = new Set();
            additions.forEach((node) =>
                getManageableStyles(node).forEach((style) =>
                    createdStyles.add(style)
                )
            );
            deletions.forEach((node) =>
                getManageableStyles(node).forEach((style) =>
                    removedStyles.add(style)
                )
            );
            moves.forEach((node) =>
                getManageableStyles(node).forEach((style) =>
                    movedStyles.add(style)
                )
            );
            handleStyleOperations({ createdStyles, removedStyles, movedStyles });
            additions.forEach((n) => {
                iterateShadowHosts(n, subscribeForShadowRootChanges);
                collectUndefinedElements(n);
            });
        }
        function handleHugeTreeMutations(root) {
            const styles = new Set(getManageableStyles(root));
            const createdStyles = new Set();
            const removedStyles = new Set();
            const movedStyles = new Set();
            styles.forEach((s) => {
                if (!prevStyles.has(s)) {
                    createdStyles.add(s);
                }
            });
            prevStyles.forEach((s) => {
                if (!styles.has(s)) {
                    removedStyles.add(s);
                }
            });
            styles.forEach((s) => {
                if (
                    !createdStyles.has(s) &&
                    !removedStyles.has(s) &&
                    didStylePositionChange(s)
                ) {
                    movedStyles.add(s);
                }
            });
            handleStyleOperations({ createdStyles, removedStyles, movedStyles });
            iterateShadowHosts(root, subscribeForShadowRootChanges);
            collectUndefinedElements(root);
        }
        function handleAttributeMutations(mutations) {
            const updatedStyles = new Set();
            const removedStyles = new Set();
            mutations.forEach((m) => {
                const { target } = m;
                if (target.isConnected) {
                    if (shouldManageStyle(target)) {
                        updatedStyles.add(target);
                    } else if (
                        target instanceof HTMLLinkElement &&
                        target.disabled
                    ) {
                        removedStyles.add(target);
                    }
                }
            });
            if (updatedStyles.size + removedStyles.size > 0) {
                update({
                    updated: Array.from(updatedStyles),
                    created: [],
                    removed: Array.from(removedStyles),
                    moved: []
                });
            }
        }
        function observe(root) {
            const treeObserver = createOptimizedTreeObserver(root, {
                onMinorMutations: handleMinorTreeMutations,
                onHugeMutations: handleHugeTreeMutations
            });
            const attrObserver = new MutationObserver(handleAttributeMutations);
            attrObserver.observe(root, {
                attributes: true,
                attributeFilter: ["rel", "disabled", "media"],
                subtree: true
            });
            observers.push(treeObserver, attrObserver);
            observedRoots.add(root);
        }
        function subscribeForShadowRootChanges(node) {
            const { shadowRoot } = node;
            if (shadowRoot == null || observedRoots.has(shadowRoot)) {
                return;
            }
            observe(shadowRoot);
            shadowRootDiscovered(shadowRoot);
        }
        observe(document);
        iterateShadowHosts(
            document.documentElement,
            subscribeForShadowRootChanges
        );
        watchWhenCustomElementsDefined((hosts) => {
            const newStyles = [];
            hosts.forEach((host) =>
                push(newStyles, getManageableStyles(host.shadowRoot))
            );
            update({ created: newStyles, updated: [], removed: [], moved: [] });
            hosts.forEach((host) => {
                const { shadowRoot } = host;
                if (shadowRoot == null) {
                    return;
                }
                subscribeForShadowRootChanges(host);
                iterateShadowHosts(shadowRoot, subscribeForShadowRootChanges);
                collectUndefinedElements(shadowRoot);
            });
        });
        document.addEventListener("__darkreader__isDefined", handleIsDefined);
        collectUndefinedElements(document);
    }
    function resetObservers() {
        observers.forEach((o) => o.disconnect());
        observers.splice(0, observers.length);
        observedRoots = new WeakSet();
    }
    function stopWatchingForStyleChanges() {
        resetObservers();
        unsubscribeFromDefineCustomElements();
    }

    function hexify(number) {
        return (number < 16 ? "0" : "") + number.toString(16);
    }
    function generateUID() {
        if ("randomUUID" in crypto) {
            const uuid = crypto.randomUUID();
            return (
                uuid.substring(0, 8) +
                uuid.substring(9, 13) +
                uuid.substring(14, 18) +
                uuid.substring(19, 23) +
                uuid.substring(24)
            );
        }
        return Array.from(crypto.getRandomValues(new Uint8Array(16)))
            .map((x) => hexify(x))
            .join("");
    }

    const adoptedStyleOverrides = new WeakMap();
    const overrideList = new WeakSet();
    function createAdoptedStyleSheetOverride(node) {
        let cancelAsyncOperations = false;
        function injectSheet(sheet, override) {
            const newSheets = [...node.adoptedStyleSheets];
            const sheetIndex = newSheets.indexOf(sheet);
            const existingIndex = newSheets.indexOf(override);
            if (sheetIndex === existingIndex - 1) {
                return;
            }
            if (existingIndex >= 0) {
                newSheets.splice(existingIndex, 1);
            }
            newSheets.splice(sheetIndex + 1, 0, override);
            node.adoptedStyleSheets = newSheets;
        }
        function destroy() {
            cancelAsyncOperations = true;
            const newSheets = [...node.adoptedStyleSheets];
            node.adoptedStyleSheets.forEach((adoptedStyleSheet) => {
                if (overrideList.has(adoptedStyleSheet)) {
                    const existingIndex = newSheets.indexOf(adoptedStyleSheet);
                    if (existingIndex >= 0) {
                        newSheets.splice(existingIndex, 1);
                    }
                    adoptedStyleOverrides.delete(adoptedStyleSheet);
                    overrideList.delete(adoptedStyleSheet);
                }
            });
            node.adoptedStyleSheets = newSheets;
        }
        function render(theme, ignoreImageAnalysis) {
            node.adoptedStyleSheets.forEach((sheet) => {
                if (overrideList.has(sheet)) {
                    return;
                }
                const rules = sheet.rules;
                const override = new CSSStyleSheet();
                function prepareOverridesSheet() {
                    for (let i = override.cssRules.length - 1; i >= 0; i--) {
                        override.deleteRule(i);
                    }
                    injectSheet(sheet, override);
                    adoptedStyleOverrides.set(sheet, override);
                    overrideList.add(override);
                    return override;
                }
                const sheetModifier = createStyleSheetModifier();
                sheetModifier.modifySheet({
                    prepareSheet: prepareOverridesSheet,
                    sourceCSSRules: rules,
                    theme,
                    ignoreImageAnalysis,
                    force: false,
                    isAsyncCancelled: () => cancelAsyncOperations
                });
            });
        }
        return {
            render,
            destroy
        };
    }

    function injectProxy() {
        document.dispatchEvent(
            new CustomEvent("__darkreader__inlineScriptsAllowed")
        );
        const addRuleDescriptor = Object.getOwnPropertyDescriptor(
            CSSStyleSheet.prototype,
            "addRule"
        );
        const insertRuleDescriptor = Object.getOwnPropertyDescriptor(
            CSSStyleSheet.prototype,
            "insertRule"
        );
        const deleteRuleDescriptor = Object.getOwnPropertyDescriptor(
            CSSStyleSheet.prototype,
            "deleteRule"
        );
        const removeRuleDescriptor = Object.getOwnPropertyDescriptor(
            CSSStyleSheet.prototype,
            "removeRule"
        );
        const documentStyleSheetsDescriptor = Object.getOwnPropertyDescriptor(
            Document.prototype,
            "styleSheets"
        );
        const shouldWrapHTMLElement = location.hostname.endsWith("baidu.com");
        const getElementsByTagNameDescriptor = shouldWrapHTMLElement
            ? Object.getOwnPropertyDescriptor(
                Element.prototype,
                "getElementsByTagName"
            )
            : null;
        const cleanUp = () => {
            Object.defineProperty(
                CSSStyleSheet.prototype,
                "addRule",
                addRuleDescriptor
            );
            Object.defineProperty(
                CSSStyleSheet.prototype,
                "insertRule",
                insertRuleDescriptor
            );
            Object.defineProperty(
                CSSStyleSheet.prototype,
                "deleteRule",
                deleteRuleDescriptor
            );
            Object.defineProperty(
                CSSStyleSheet.prototype,
                "removeRule",
                removeRuleDescriptor
            );
            document.removeEventListener("__darkreader__cleanUp", cleanUp);
            document.removeEventListener(
                "__darkreader__addUndefinedResolver",
                addUndefinedResolver
            );
            Object.defineProperty(
                Document.prototype,
                "styleSheets",
                documentStyleSheetsDescriptor
            );
            if (shouldWrapHTMLElement) {
                Object.defineProperty(
                    Element.prototype,
                    "getElementsByTagName",
                    getElementsByTagNameDescriptor
                );
            }
        };
        const addUndefinedResolver = (e) => {
            customElements.whenDefined(e.detail.tag).then(() => {
                document.dispatchEvent(
                    new CustomEvent("__darkreader__isDefined", {
                        detail: { tag: e.detail.tag }
                    })
                );
            });
        };
        document.addEventListener("__darkreader__cleanUp", cleanUp);
        document.addEventListener(
            "__darkreader__addUndefinedResolver",
            addUndefinedResolver
        );
        const updateSheetEvent = new Event("__darkreader__updateSheet");
        function proxyAddRule(selector, style, index) {
            addRuleDescriptor.value.call(this, selector, style, index);
            if (
                this.ownerNode &&
                !this.ownerNode.classList.contains("darkreader")
            ) {
                this.ownerNode.dispatchEvent(updateSheetEvent);
            }
            return -1;
        }
        function proxyInsertRule(rule, index) {
            const returnValue = insertRuleDescriptor.value.call(
                this,
                rule,
                index
            );
            if (
                this.ownerNode &&
                !this.ownerNode.classList.contains("darkreader")
            ) {
                this.ownerNode.dispatchEvent(updateSheetEvent);
            }
            return returnValue;
        }
        function proxyDeleteRule(index) {
            deleteRuleDescriptor.value.call(this, index);
            if (
                this.ownerNode &&
                !this.ownerNode.classList.contains("darkreader")
            ) {
                this.ownerNode.dispatchEvent(updateSheetEvent);
            }
        }
        function proxyRemoveRule(index) {
            removeRuleDescriptor.value.call(this, index);
            if (
                this.ownerNode &&
                !this.ownerNode.classList.contains("darkreader")
            ) {
                this.ownerNode.dispatchEvent(updateSheetEvent);
            }
        }
        function proxyDocumentStyleSheets() {
            const docSheets = documentStyleSheetsDescriptor.get.call(this);
            const filtered = [...docSheets].filter((styleSheet) => {
                return !styleSheet.ownerNode.classList.contains("darkreader");
            });
            return Object.setPrototypeOf(filtered, StyleSheetList.prototype);
        }
        function proxyGetElementsByTagName(tagName) {
            const getCurrentElementValue = () => {
                let elements = getElementsByTagNameDescriptor.value.call(
                    this,
                    tagName
                );
                if (tagName === "style") {
                    elements = Object.setPrototypeOf(
                        [...elements].filter((element) => {
                            return !element.classList.contains("darkreader");
                        }),
                        NodeList.prototype
                    );
                }
                return elements;
            };
            let elements = getCurrentElementValue();
            const NodeListBehavior = {
                get: function (_, property) {
                    return getCurrentElementValue()[Number(property)];
                }
            };
            elements = new Proxy(elements, NodeListBehavior);
            return elements;
        }
        Object.defineProperty(
            CSSStyleSheet.prototype,
            "addRule",
            Object.assign({}, addRuleDescriptor, { value: proxyAddRule })
        );
        Object.defineProperty(
            CSSStyleSheet.prototype,
            "insertRule",
            Object.assign({}, insertRuleDescriptor, { value: proxyInsertRule })
        );
        Object.defineProperty(
            CSSStyleSheet.prototype,
            "deleteRule",
            Object.assign({}, deleteRuleDescriptor, { value: proxyDeleteRule })
        );
        Object.defineProperty(
            CSSStyleSheet.prototype,
            "removeRule",
            Object.assign({}, removeRuleDescriptor, { value: proxyRemoveRule })
        );
        Object.defineProperty(
            Document.prototype,
            "styleSheets",
            Object.assign({}, documentStyleSheetsDescriptor, {
                get: proxyDocumentStyleSheets
            })
        );
        if (shouldWrapHTMLElement) {
            Object.defineProperty(
                Element.prototype,
                "getElementsByTagName",
                Object.assign({}, getElementsByTagNameDescriptor, {
                    value: proxyGetElementsByTagName
                })
            );
        }
    }

    const INSTANCE_ID = generateUID();
    const styleManagers = new Map();
    const adoptedStyleManagers = [];
    let filter = null;
    let fixes = null;
    let ignoredImageAnalysisSelectors = null;
    let ignoredInlineSelectors = null;
    function createOrUpdateStyle(className, root = document.head || document) {
        let element = root.querySelector(`.${className}`);
        if (!element) {
            element = document.createElement("style");
            element.classList.add("darkreader");
            element.classList.add(className);
            element.media = "screen";
            element.textContent = "";
        }
        return element;
    }
    function createOrUpdateScript(className, root = document.head || document) {
        let element = root.querySelector(`.${className}`);
        if (!element) {
            element = document.createElement("script");
            element.classList.add("darkreader");
            element.classList.add(className);
        }
        return element;
    }
    const nodePositionWatchers = new Map();
    function setupNodePositionWatcher(node, alias) {
        nodePositionWatchers.has(alias) &&
            nodePositionWatchers.get(alias).stop();
        nodePositionWatchers.set(alias, watchForNodePosition(node, "parent"));
    }
    function stopStylePositionWatchers() {
        forEach(nodePositionWatchers.values(), (watcher) => watcher.stop());
        nodePositionWatchers.clear();
    }
    function createStaticStyleOverrides() {
        const fallbackStyle = createOrUpdateStyle(
            "darkreader--fallback",
            document
        );
        fallbackStyle.textContent = getModifiedFallbackStyle(filter, {
            strict: true
        });
        document.head.insertBefore(fallbackStyle, document.head.firstChild);
        setupNodePositionWatcher(fallbackStyle, "fallback");
        const userAgentStyle = createOrUpdateStyle("darkreader--user-agent");
        userAgentStyle.textContent = getModifiedUserAgentStyle(
            filter,
            isIFrame,
            filter.styleSystemControls
        );
        document.head.insertBefore(userAgentStyle, fallbackStyle.nextSibling);
        setupNodePositionWatcher(userAgentStyle, "user-agent");
        const textStyle = createOrUpdateStyle("darkreader--text");
        if (filter.useFont || filter.textStroke > 0) {
            textStyle.textContent = createTextStyle(filter);
        } else {
            textStyle.textContent = "";
        }
        document.head.insertBefore(textStyle, fallbackStyle.nextSibling);
        setupNodePositionWatcher(textStyle, "text");
        const invertStyle = createOrUpdateStyle("darkreader--invert");
        if (fixes && Array.isArray(fixes.invert) && fixes.invert.length > 0) {
            invertStyle.textContent = [
                `${fixes.invert.join(", ")} {`,
                `    filter: ${getCSSFilterValue({
                    ...filter,
                    contrast:
                        filter.mode === 0
                            ? filter.contrast
                            : clamp(filter.contrast - 10, 0, 100)
                })} !important;`,
                "}"
            ].join("\n");
        } else {
            invertStyle.textContent = "";
        }
        document.head.insertBefore(invertStyle, textStyle.nextSibling);
        setupNodePositionWatcher(invertStyle, "invert");
        const inlineStyle = createOrUpdateStyle("darkreader--inline");
        inlineStyle.textContent = getInlineOverrideStyle();
        document.head.insertBefore(inlineStyle, invertStyle.nextSibling);
        setupNodePositionWatcher(inlineStyle, "inline");
        const overrideStyle = createOrUpdateStyle("darkreader--override");
        overrideStyle.textContent =
            fixes && fixes.css ? replaceCSSTemplates(fixes.css) : "";
        document.head.appendChild(overrideStyle);
        setupNodePositionWatcher(overrideStyle, "override");
        const variableStyle = createOrUpdateStyle("darkreader--variables");
        const selectionColors = getSelectionColor(filter);
        const {
            darkSchemeBackgroundColor,
            darkSchemeTextColor,
            lightSchemeBackgroundColor,
            lightSchemeTextColor,
            mode
        } = filter;
        let schemeBackgroundColor =
            mode === 0 ? lightSchemeBackgroundColor : darkSchemeBackgroundColor;
        let schemeTextColor =
            mode === 0 ? lightSchemeTextColor : darkSchemeTextColor;
        schemeBackgroundColor = modifyBackgroundColor(
            parse(schemeBackgroundColor),
            filter
        );
        schemeTextColor = modifyForegroundColor(parse(schemeTextColor), filter);
        variableStyle.textContent = [
            `:root {`,
            `   --darkreader-neutral-background: ${schemeBackgroundColor};`,
            `   --darkreader-neutral-text: ${schemeTextColor};`,
            `   --darkreader-selection-background: ${selectionColors.backgroundColorSelection};`,
            `   --darkreader-selection-text: ${selectionColors.foregroundColorSelection};`,
            `}`
        ].join("\n");
        document.head.insertBefore(variableStyle, inlineStyle.nextSibling);
        setupNodePositionWatcher(variableStyle, "variables");
        const rootVarsStyle = createOrUpdateStyle("darkreader--root-vars");
        document.head.insertBefore(rootVarsStyle, variableStyle.nextSibling);
        const proxyScript = createOrUpdateScript("darkreader--proxy");
        proxyScript.append(`(${injectProxy})()`);
        document.head.insertBefore(proxyScript, rootVarsStyle.nextSibling);
        proxyScript.remove();
    }
    const shadowRootsWithOverrides = new Set();
    function createShadowStaticStyleOverrides(root) {
        const inlineStyle = createOrUpdateStyle("darkreader--inline", root);
        inlineStyle.textContent = getInlineOverrideStyle();
        root.insertBefore(inlineStyle, root.firstChild);
        const overrideStyle = createOrUpdateStyle("darkreader--override", root);
        overrideStyle.textContent =
            fixes && fixes.css ? replaceCSSTemplates(fixes.css) : "";
        root.insertBefore(overrideStyle, inlineStyle.nextSibling);
        const invertStyle = createOrUpdateStyle("darkreader--invert", root);
        if (fixes && Array.isArray(fixes.invert) && fixes.invert.length > 0) {
            invertStyle.textContent = [
                `${fixes.invert.join(", ")} {`,
                `    filter: ${getCSSFilterValue({
                    ...filter,
                    contrast:
                        filter.mode === 0
                            ? filter.contrast
                            : clamp(filter.contrast - 10, 0, 100)
                })} !important;`,
                "}"
            ].join("\n");
        } else {
            invertStyle.textContent = "";
        }
        root.insertBefore(invertStyle, overrideStyle.nextSibling);
        shadowRootsWithOverrides.add(root);
    }
    function replaceCSSTemplates($cssText) {
        return $cssText.replace(/\${(.+?)}/g, (_, $color) => {
            const color = tryParseColor($color);
            if (color) {
                return modifyColor(color, filter);
            }
            return $color;
        });
    }
    function cleanFallbackStyle() {
        const fallback = document.querySelector(".darkreader--fallback");
        if (fallback) {
            fallback.textContent = "";
        }
    }
    function createDynamicStyleOverrides() {
        cancelRendering();
        const allStyles = getManageableStyles(document);
        const newManagers = allStyles
            .filter((style) => !styleManagers.has(style))
            .map((style) => createManager(style));
        newManagers
            .map((manager) => manager.details())
            .filter((detail) => detail && detail.rules.length > 0)
            .forEach((detail) => {
                variablesStore.addRulesForMatching(detail.rules);
            });
        variablesStore.matchVariablesAndDependants();
        variablesStore.setOnRootVariableChange(() => {
            variablesStore.putRootVars(
                document.head.querySelector(".darkreader--root-vars"),
                filter
            );
        });
        variablesStore.putRootVars(
            document.head.querySelector(".darkreader--root-vars"),
            filter
        );
        styleManagers.forEach((manager) =>
            manager.render(filter, ignoredImageAnalysisSelectors)
        );
        if (loadingStyles.size === 0) {
            cleanFallbackStyle();
        }
        newManagers.forEach((manager) => manager.watch());
        const inlineStyleElements = toArray(
            document.querySelectorAll(INLINE_STYLE_SELECTOR)
        );
        iterateShadowHosts(document.documentElement, (host) => {
            createShadowStaticStyleOverrides(host.shadowRoot);
            const elements = host.shadowRoot.querySelectorAll(
                INLINE_STYLE_SELECTOR
            );
            if (elements.length > 0) {
                push(inlineStyleElements, elements);
            }
        });
        inlineStyleElements.forEach((el) =>
            overrideInlineStyle(
                el,
                filter,
                ignoredInlineSelectors,
                ignoredImageAnalysisSelectors
            )
        );
        handleAdoptedStyleSheets(document);
    }
    let loadingStylesCounter = 0;
    const loadingStyles = new Set();
    function createManager(element) {
        const loadingStyleId = ++loadingStylesCounter;
        function loadingStart() {
            if (!isDOMReady() || !didDocumentShowUp) {
                loadingStyles.add(loadingStyleId);
                logInfo(
                    `Current amount of styles loading: ${loadingStyles.size}`
                );
                const fallbackStyle = document.querySelector(
                    ".darkreader--fallback"
                );
                if (!fallbackStyle.textContent) {
                    fallbackStyle.textContent = getModifiedFallbackStyle(
                        filter,
                        { strict: false }
                    );
                }
            }
        }
        function loadingEnd() {
            loadingStyles.delete(loadingStyleId);
            logInfo(
                `Removed loadingStyle ${loadingStyleId}, now awaiting: ${loadingStyles.size}`
            );
            if (loadingStyles.size === 0 && isDOMReady()) {
                cleanFallbackStyle();
            }
        }
        function update() {
            const details = manager.details();
            if (!details) {
                return;
            }
            variablesStore.addRulesForMatching(details.rules);
            variablesStore.matchVariablesAndDependants();
            manager.render(filter, ignoredImageAnalysisSelectors);
        }
        const manager = manageStyle(element, {
            update,
            loadingStart,
            loadingEnd
        });
        styleManagers.set(element, manager);
        return manager;
    }
    function removeManager(element) {
        const manager = styleManagers.get(element);
        if (manager) {
            manager.destroy();
            styleManagers.delete(element);
        }
    }
    const throttledRenderAllStyles = throttle((callback) => {
        styleManagers.forEach((manager) =>
            manager.render(filter, ignoredImageAnalysisSelectors)
        );
        adoptedStyleManagers.forEach((manager) =>
            manager.render(filter, ignoredImageAnalysisSelectors)
        );
        callback && callback();
    });
    const cancelRendering = function () {
        throttledRenderAllStyles.cancel();
    };
    function onDOMReady() {
        if (loadingStyles.size === 0) {
            cleanFallbackStyle();
            return;
        }
    }

    let documentVisibilityListener = null;
    let didDocumentShowUp = !document.hidden;
    function watchForDocumentVisibility(callback) {
        const alreadyWatching = Boolean(documentVisibilityListener);
        documentVisibilityListener = () => {
            if (!document.hidden) {
                stopWatchingForDocumentVisibility();
                callback();
                didDocumentShowUp = true;
            }
        };
        if (!alreadyWatching) {
            document.addEventListener(
                "visibilitychange",
                documentVisibilityListener
            );
        }
    }
    function stopWatchingForDocumentVisibility() {
        document.removeEventListener(
            "visibilitychange",
            documentVisibilityListener
        );
        documentVisibilityListener = null;
    }
    function createThemeAndWatchForUpdates() {
        createStaticStyleOverrides();
        function runDynamicStyle() {
            createDynamicStyleOverrides();
            watchForUpdates();
        }
        if (document.hidden && !filter.immediateModify) {
            watchForDocumentVisibility(runDynamicStyle);
        } else {
            runDynamicStyle();
        }
        changeMetaThemeColorWhenAvailable(filter);
    }
    function handleAdoptedStyleSheets(node) {
        if (Array.isArray(node.adoptedStyleSheets)) {
            if (node.adoptedStyleSheets.length > 0) {
                const newManger = createAdoptedStyleSheetOverride(node);
                adoptedStyleManagers.push(newManger);
                newManger.render(filter, ignoredImageAnalysisSelectors);
            }
        }
    }
    function watchForUpdates() {
        const managedStyles = Array.from(styleManagers.keys());
        watchForStyleChanges(
            managedStyles,
            ({ created, updated, removed, moved }) => {
                const stylesToRemove = removed;
                const stylesToManage = created
                    .concat(updated)
                    .concat(moved)
                    .filter((style) => !styleManagers.has(style));
                const stylesToRestore = moved.filter((style) =>
                    styleManagers.has(style)
                );
                stylesToRemove.forEach((style) => removeManager(style));
                const newManagers = stylesToManage.map((style) =>
                    createManager(style)
                );
                newManagers
                    .map((manager) => manager.details())
                    .filter((detail) => detail && detail.rules.length > 0)
                    .forEach((detail) => {
                        variablesStore.addRulesForMatching(detail.rules);
                    });
                variablesStore.matchVariablesAndDependants();
                newManagers.forEach((manager) =>
                    manager.render(filter, ignoredImageAnalysisSelectors)
                );
                newManagers.forEach((manager) => manager.watch());
                stylesToRestore.forEach((style) =>
                    styleManagers.get(style).restore()
                );
            },
            (shadowRoot) => {
                createShadowStaticStyleOverrides(shadowRoot);
                handleAdoptedStyleSheets(shadowRoot);
            }
        );
        watchForInlineStyles(
            (element) => {
                overrideInlineStyle(
                    element,
                    filter,
                    ignoredInlineSelectors,
                    ignoredImageAnalysisSelectors
                );
                if (element === document.documentElement) {
                    const styleAttr = element.getAttribute("style");
                    if (styleAttr.includes("--")) {
                        variablesStore.matchVariablesAndDependants();
                        variablesStore.putRootVars(
                            document.head.querySelector(
                                ".darkreader--root-vars"
                            ),
                            filter
                        );
                    }
                }
            },
            (root) => {
                createShadowStaticStyleOverrides(root);
                const inlineStyleElements = root.querySelectorAll(
                    INLINE_STYLE_SELECTOR
                );
                if (inlineStyleElements.length > 0) {
                    forEach(inlineStyleElements, (el) =>
                        overrideInlineStyle(
                            el,
                            filter,
                            ignoredInlineSelectors,
                            ignoredImageAnalysisSelectors
                        )
                    );
                }
            }
        );
        addDOMReadyListener(onDOMReady);
    }
    function stopWatchingForUpdates() {
        styleManagers.forEach((manager) => manager.pause());
        stopStylePositionWatchers();
        stopWatchingForStyleChanges();
        stopWatchingForInlineStyles();
        removeDOMReadyListener(onDOMReady);
        cleanReadyStateCompleteListeners();
    }
    function createDarkReaderInstanceMarker() {
        const metaElement = document.createElement("meta");
        metaElement.name = "darkreader";
        metaElement.content = INSTANCE_ID;
        document.head.appendChild(metaElement);
    }
    function isAnotherDarkReaderInstanceActive() {
        const meta = document.querySelector('meta[name="darkreader"]');
        if (meta) {
            if (meta.content !== INSTANCE_ID) {
                return true;
            }
            return false;
        }
        createDarkReaderInstanceMarker();
        return false;
    }
    function createOrUpdateDynamicTheme(filterConfig, dynamicThemeFixes, isIframe) {
        filter = filterConfig;
        fixes = dynamicThemeFixes;
        if (fixes) {
            ignoredImageAnalysisSelectors = Array.isArray(
                fixes.ignoreImageAnalysis
            )
                ? fixes.ignoreImageAnalysis
                : [];
            ignoredInlineSelectors = Array.isArray(fixes.ignoreInlineStyle)
                ? fixes.ignoreInlineStyle
                : [];
        } else {
            ignoredImageAnalysisSelectors = [];
            ignoredInlineSelectors = [];
        }
        isIFrame = isIframe;
        if (filter.immediateModify) {
            setIsDOMReady(() => {
                return true;
            });
        }
        if (document.head) {
            if (isAnotherDarkReaderInstanceActive()) {
                return;
            }
            document.documentElement.setAttribute(
                "data-darkreader-mode",
                "dynamic"
            );
            document.documentElement.setAttribute(
                "data-darkreader-scheme",
                filter.mode ? "dark" : "dimmed"
            );
            createThemeAndWatchForUpdates();
        } else {
            if (isSafari) {
                const fallbackStyle = createOrUpdateStyle(
                    "darkreader--fallback"
                );
                document.documentElement.appendChild(fallbackStyle);
                fallbackStyle.textContent = getModifiedFallbackStyle(filter, {
                    strict: true
                });
            }
            const headObserver = new MutationObserver(() => {
                if (document.head) {
                    headObserver.disconnect();
                    if (isAnotherDarkReaderInstanceActive()) {
                        removeDynamicTheme();
                        return;
                    }
                    createThemeAndWatchForUpdates();
                }
            });
            headObserver.observe(document, { childList: true, subtree: true });
        }
    }
    function removeProxy() {
        document.dispatchEvent(new CustomEvent("__darkreader__cleanUp"));
        removeNode(document.head.querySelector(".darkreader--proxy"));
    }
    function removeDynamicTheme() {
        document.documentElement.removeAttribute(`data-darkreader-mode`);
        document.documentElement.removeAttribute(`data-darkreader-scheme`);
        cleanDynamicThemeCache();
        removeNode(document.querySelector(".darkreader--fallback"));
        if (document.head) {
            restoreMetaThemeColor();
            removeNode(document.head.querySelector(".darkreader--user-agent"));
            removeNode(document.head.querySelector(".darkreader--text"));
            removeNode(document.head.querySelector(".darkreader--invert"));
            removeNode(document.head.querySelector(".darkreader--inline"));
            removeNode(document.head.querySelector(".darkreader--override"));
            removeNode(document.head.querySelector(".darkreader--variables"));
            removeNode(document.head.querySelector(".darkreader--root-vars"));
            removeNode(document.head.querySelector('meta[name="darkreader"]'));
            removeProxy();
        }
        shadowRootsWithOverrides.forEach((root) => {
            removeNode(root.querySelector(".darkreader--inline"));
            removeNode(root.querySelector(".darkreader--override"));
        });
        shadowRootsWithOverrides.clear();
        forEach(styleManagers.keys(), (el) => removeManager(el));
        loadingStyles.clear();
        cleanLoadingLinks();
        forEach(document.querySelectorAll(".darkreader"), removeNode);
        adoptedStyleManagers.forEach((manager) => {
            manager.destroy();
        });
        adoptedStyleManagers.splice(0);
    }
    function cleanDynamicThemeCache() {
        variablesStore.clear();
        parsedURLCache.clear();
        stopWatchingForDocumentVisibility();
        cancelRendering();
        stopWatchingForUpdates();
        cleanModificationCache();
    }

    function darkModeInit(){
        if (
            document.documentElement instanceof HTMLHtmlElement &&
            matchMedia("(prefers-color-scheme: dark)").matches 
        ) {
            const css =
                'html, body, body :not(iframe):not(div[style^="position:absolute;top:0;left:-"]) { background-color: #181a1b !important; border-color: #776e62 !important; color: #e8e6e3 !important; } html, body { opacity: 1 !important; transition: none !important; }';
            
            let fallback = document.querySelector(".darkreader--fallback");
            if(fallback){
                fallback.textContent = css;
            }else{
                fallback = document.createElement("style");
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


    function getDomain(url) {
        try {
            return new URL(url).hostname.toLowerCase();
        } catch (error) {
            return url.split("/")[0].toLowerCase();
        }
    }
    let browserDomain = getDomain(window.location.href);

    function setupDarkmode(data) {
        // darkModeInit();
        const {theme, fixes, isIFrame, detectDarkTheme} = data;
        removeStyle();
        createOrUpdateDynamicTheme(theme, fixes, isIFrame);
        if (detectDarkTheme) {
            runDarkThemeDetector((hasDarkTheme) => {
                if (hasDarkTheme) {
                    removeDynamicTheme();
                    // onDarkThemeDetected();
                }
            });
        }
    }

    function onDarkThemeDetected() {
        sendMessage({type: MessageType.CS_DARK_THEME_DETECTED});
    }

    function cleanupDarkmode() {
        cleanFallbackStyle();
        removeStyle();
        removeSVGFilter();
        removeDynamicTheme();
        stopDarkThemeDetector();
    }

    function is_dark() {
        return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
    }

    let unloaded = false;
    // let colorSchemeWatcher = watchForColorSchemeChange(({isDark}) => {
    //     sendMessage({type: MessageType.CS_COLOR_SCHEME_CHANGE, data: {isDark}});
    // });
    function cleanup() {
        unloaded = true;
        // removeEventListener("pagehide", onPageHide);
        // removeEventListener("freeze", onFreeze);
        // removeEventListener("resume", onResume);
        cleanDynamicThemeCache();
        stopDarkThemeDetector();
        // if (colorSchemeWatcher) {
        //     colorSchemeWatcher.disconnect();
        //     colorSchemeWatcher = null;
        // }
    }

    function sendMessage(message) {
        if (unloaded) {
            return;
        }
        try {
            browser.runtime.sendMessage(message, (response) => {
                if (response === "unsupportedSender") {
                    cleanupDarkmode();
                }
            });
        } catch (e) {
            cleanup();
        }
    }

    function watchForColorSchemeChange(callback) {
        const query = matchMedia("(prefers-color-scheme: dark)");
        const onChange = () => callback({isDark: query.matches});
        if (isMatchMediaChangeEventListenerSupported) {
            query.addEventListener("change", onChange);
        } else {
            query.addListener(onChange);
        }
        return {
            disconnect() {
                if (isMatchMediaChangeEventListenerSupported) {
                    query.removeEventListener("change", onChange);
                } else {
                    query.removeListener(onChange);
                }
            }
        };
    }

    // function onPageHide(e) {
    //     if (e.persisted === false) {
    //         sendMessage({type: MessageType.CS_FRAME_FORGET});
    //     }
    // }
    // function onFreeze() {
    //     sendMessage({type: MessageType.CS_FRAME_FREEZE});
    // }
    // function onResume() {
    //     sendMessage({type: MessageType.CS_FRAME_RESUME});
    // }
    // if(isSafari){
    //     addEventListener("pagehide", onPageHide);
    //     addEventListener("freeze", onFreeze);
    //     addEventListener("resume", onResume);
    // }
    
    browser.runtime.sendMessage({type: "darkmode", operate: MessageType.CS_FRAME_CONNECT}, function (response) {});

    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        const { type, data, stayDarkSettings, error, id, from, operate} = request
        // console.log("data===request=",request);
        if (MessageType.BG_FETCH_RESPONSE  === type) {
            const resolve = resolvers$1.get(id);
            const reject = rejectors.get(id);
            resolvers$1.delete(id);
            rejectors.delete(id);
            if (error) {
                reject && reject(error);
            } else {
                resolve && resolve(data);
            }
            
        }else if(MessageType.BG_ADD_DYNAMIC_THEME === type){
            // console.log("data==BG_ADD_DYNAMIC_THEME===",data, stayDarkSettings);
            if((document.querySelector(".noir") && document.querySelector(".noir-root"))){
                cleanupDarkmode();
            }else{
                setupDarkmode(data);
            }
            
        }else if(MessageType.BG_CLEAN_UP === type){
            // console.log("data==BG_CLEAN_UP===",stayDarkSettings);
            cleanupDarkmode();
        }
        return true;
        
    });
   
})();
