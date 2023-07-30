
/**
 * dark mode config
 *
 *
 */
(function () {
  'use strict';
  const isFetchSupported = typeof fetch === 'function';
  const userAgent =
    typeof navigator === 'undefined'
      ? 'some useragent'
      : navigator.userAgent.toLowerCase();
  const isChromium =
        userAgent.includes('chrome') || userAgent.includes('chromium');
  const isThunderbird = userAgent.includes('thunderbird');
  const isSafari = userAgent.includes('safari') || isThunderbird;
  // const userAgentData = navigator.userAgent;
  const platform = navigator.platform;
  const isMacOS = platform.toLowerCase().startsWith('mac');
  const isCSSColorSchemePropSupported = (() => {
    if (typeof document === 'undefined') {
      return false;
    }
    const el = document.createElement('div');
    el.setAttribute('style', 'color-scheme: dark');
    return el.style && el.style.colorScheme === 'dark';
  })();
  const isXMLHttpRequestSupported = typeof XMLHttpRequest === 'function';

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

  function isIPV6(url) {
    const openingBracketIndex = url.indexOf('[');
    if (openingBracketIndex < 0) {
      return false;
    }
    const queryIndex = url.indexOf('?');
    if (queryIndex >= 0 && openingBracketIndex > queryIndex) {
      return false;
    }
    return true;
  }
  // eslint-disable-next-line no-useless-escape
  const ipV6HostRegex = /\[.*?\](\:\d+)?/;
  function compareIPV6(firstURL, secondURL) {
    const firstHost = firstURL.match(ipV6HostRegex)[0];
    const secondHost = secondURL.match(ipV6HostRegex)[0];
    return firstHost === secondHost;
  }



  function isURLMatched(url, urlTemplate) {
    const isFirstIPV6 = isIPV6(url);
    const isSecondIPV6 = isIPV6(urlTemplate);
    if (isFirstIPV6 && isSecondIPV6) {
      return compareIPV6(url, urlTemplate);
    } else if (!isFirstIPV6 && !isSecondIPV6) {
      const regex = createUrlRegex(urlTemplate);
      return Boolean(url.match(regex));
    }
    return false;
  }
  function createUrlRegex(urlTemplate) {
    urlTemplate = urlTemplate.trim();
    const exactBeginning = urlTemplate[0] === '^';
    const exactEnding = urlTemplate[urlTemplate.length - 1] === '$';
    urlTemplate = urlTemplate
      .replace(/^\^/, '')
      .replace(/\$$/, '')
      .replace(/^.*?\/{2,3}/, '')
      .replace(/\?.*$/, '')
      .replace(/\/$/, '');
    let slashIndex;
    let beforeSlash;
    let afterSlash;
    if ((slashIndex = urlTemplate.indexOf('/')) >= 0) {
      beforeSlash = urlTemplate.substring(0, slashIndex);
      afterSlash = urlTemplate.replace(/\$/g, '').substring(slashIndex);
    } else {
      beforeSlash = urlTemplate.replace(/\$/g, '');
    }
    let result = exactBeginning
      ? '^(.*?\\:\\/{2,3})?'
      : '^(.*?\\:\\/{2,3})?([^/]*?\\.)?';
    const hostParts = beforeSlash.split('.');
    result += '(';
    for (let i = 0; i < hostParts.length; i++) {
      if (hostParts[i] === '*') {
        hostParts[i] = '[^\\.\\/]+?';
      }
    }
    result += hostParts.join('\\.');
    result += ')';
    if (afterSlash) {
      result += '(';
      result += afterSlash.replace('/', '\\/');
      result += ')';
    }
    result += exactEnding ? '(\\/?(\\?[^/]*?)?)$' : '(\\/?.*?)$';
    return new RegExp(result, 'i');
  }
  function isPDF(url) {
    if (url.includes('.pdf')) {
      if (url.includes('?')) {
        url = url.substring(0, url.lastIndexOf('?'));
      }
      if (url.includes('#')) {
        url = url.substring(0, url.lastIndexOf('#'));
      }

      // eslint-disable-next-line no-useless-escape
      if ((url.match(/(wikipedia|wikimedia).org/i) && url.match(/(wikipedia|wikimedia)\.org\/.*\/[a-z]+\:[^\:\/]+\.pdf/i)) ||
            (url.match(/timetravel\.mementoweb\.org\/reconstruct/i) &&
                url.match(/\.pdf$/i))) {
        return false;
      }
      if (url.endsWith('.pdf')) {
        for (let i = url.length; i > 0; i--) {
          if (url[i] === '=') {
            return false;
          } else if (url[i] === '/') {
            return true;
          }
        }
      } else {
        return false;
      }
    }
    return false;
  }
  function isURLInList(url, list) {
    for (let i = 0; i < list.length; i++) {
      if (isURLMatched(url, list[i])) {
        return true;
      }
    }
    return false;
  }
  function isURLEnabled(
    url,
    userSettings,
    {isProtected, isInDarkList, isDarkThemeDetected}
  ) {
    if (isProtected && !userSettings.enableForProtectedPages) {
      return false;
    }
    if (isThunderbird) {
      return true;
    }
    if (isPDF(url)) {
      return userSettings.stay_enableForPDF;
    }
    const isURLInUserList = isURLInList(url, userSettings.siteListEnabled);
    const isURLInEnabledList = isURLInList(
      url,
      userSettings.siteListEnabled
    );
    if (userSettings.applyToListedOnly) {
      return isURLInEnabledList || isURLInUserList;
    }
    if (isURLInEnabledList) {
      return true;
    }
    if (
      isInDarkList ||
        (userSettings.stay_detectDarkTheme && isDarkThemeDetected)
    ) {
      return false;
    }
    return !isURLInUserList;
  }
  function isFullyQualifiedDomain(candidate) {
    return /^[a-z0-9.-]+$/.test(candidate);
  }
  function parseSitesFixesConfig(text, options) {
    const sites = [];
    const blocks = text.replace(/\r/g, '').split(/^\s*={2,}\s*$/gm);
    blocks.forEach((block) => {
      const lines = block.split('\n');
      const commandIndices = [];
      lines.forEach((ln, i) => {
        if (ln.match(/^[A-Z]+(\s[A-Z]+){0,2}$/)) {
          commandIndices.push(i);
        }
      });
      if (commandIndices.length === 0) {
        return;
      }
      const siteFix = {
        url: parseArray(lines.slice(0, commandIndices[0]).join('\n'))
      };
      commandIndices.forEach((commandIndex, i) => {
        const command = lines[commandIndex].trim();
        const valueText = lines
          .slice(
            commandIndex + 1,
            i === commandIndices.length - 1
              ? lines.length
              : commandIndices[i + 1]
          )
          .join('\n');
        const prop = options.getCommandPropName(command);
        if (!prop) {
          return;
        }
        const value = options.parseCommandValue(command, valueText);
        siteFix[prop] = value;
      });
      sites.push(siteFix);
    });
    return sites;
  }
  function parseSiteFixConfig(text, options, recordStart, recordEnd) {
    const block = text.substring(recordStart, recordEnd);
    return parseSitesFixesConfig(block, options)[0];
  }

  /**
   *
   * @param {String} url
   * @param {OBject} index
   *
   * @return true:有配置，false:没有配置
   */
  function checkDomainHasConfig(url, index){
    let recordIds = handleCheckDomainHasConfig(url, index);
    if(recordIds.length && recordIds.length == 2 && (recordIds.join('') == '0873' || recordIds.join('') == '8730')){
      return false;
    }else{
      return true;
    }
  }

  /**
   *
   * @param {String} url
   * @param {OBject} index
   *
   * @return 匹配域名的id集合， 默认[0,873]
   */
  function handleCheckDomainHasConfig(url, index){
    if(!url){
      url = window.location.href;
    }
    if(!index || !Object.keys(index)){
      index = this.config.DYNAMIC_THEME_FIXES_INDEX;
    }
    const domain = getDomain(url);
    let recordIds = [];
    for (const pattern of Object.keys(index.domainPatterns)) {
      if (isURLMatched(url, pattern)) {
        recordIds = recordIds.concat(index.domainPatterns[pattern]);
      }
    }

    const labels = domain.split('.');
    for (let i = 0; i < labels.length; i++) {
      const substring = labels.slice(i).join('.');
      if (index.domains[substring] && isURLMatched(url, substring)) {
        recordIds = recordIds.concat(index.domains[substring]);
      }
    }

    return recordIds;
  }
  function getSitesFixesFor(url, text, index, options) {
    // console.log("getSitesFixesFor---text.size()===", text.length)
    const records = [];
    let recordIds = [];
    recordIds = handleCheckDomainHasConfig(url, index);
    // console.log('---------recordIds------',recordIds);
    const set = new Set();
    for (const id of recordIds) {
      if (set.has(id)) {
        continue;
      }
      set.add(id);
      if (!index.cache[id]) {
        const [start, end] = decodeOffset(index.offsets, id);
        index.cache[id] = parseSiteFixConfig(text, options, start, end);
      }
      records.push(index.cache[id]);
    }
    return records;
  }
  const dynamicThemeFixesCommands = {
    'INVERT': 'invert',
    'CSS': 'css',
    'IGNORE INLINE STYLE': 'ignoreInlineStyle',
    'IGNORE IMAGE ANALYSIS': 'ignoreImageAnalysis'
  };
  function getDynamicThemeFixesFor(url, frameURL, text, index, enabledForPDF) {
    // console.log("getDynamicThemeFixesFor---text.size()===", text, index)
    const fixes = getSitesFixesFor(frameURL || url, text, index, {
      commands: Object.keys(dynamicThemeFixesCommands),
      getCommandPropName: (command) => dynamicThemeFixesCommands[command],
      parseCommandValue: (command, value) => {
        if (command === 'CSS') {
          return value.trim();
        }
        return parseArray(value);
      }
    });
    // console.log("getDynamicThemeFixesFor-------fixes----",fixes);
    if (fixes.length === 0 || fixes[0].url[0] !== '*') {
      return null;
    }
    const genericFix = fixes[0];
    // console.log("getDynamicThemeFixesFor-------genericFix.css----",genericFix.css);
    const common = {
      url: genericFix.url,
      invert: genericFix.invert || [],
      css: genericFix.css || '',
      ignoreInlineStyle: genericFix.ignoreInlineStyle || [],
      ignoreImageAnalysis: genericFix.ignoreImageAnalysis || []
    };
    if (enabledForPDF) {
      if (isChromium) {
        common.css += '\nembed[type="application/pdf"][src="about:blank"] { filter: invert(100%) contrast(90%); }';
      } else {
        common.css += '\nembed[type="application/pdf"] { filter: invert(100%) contrast(90%); }';
      }
    }
    const sortedBySpecificity = fixes
      .slice(1)
      .map((theme) => {
        return {
          specificity: isURLInList(frameURL || url, theme.url)
            ? theme.url[0].length
            : 0,
          theme
        };
      })
      .filter(({specificity}) => specificity > 0)
      .sort((a, b) => b.specificity - a.specificity);
    if (sortedBySpecificity.length === 0) {
      return common;
    }
    // console.log("getDynamicThemeFixesFor-------sortedBySpecificity----",sortedBySpecificity);
    const match = sortedBySpecificity[0].theme;
    return {
      url: match.url,
      invert: common.invert.concat(match.invert || []),
      css: [common.css, match.css].filter((s) => s).join('\n'),
      ignoreInlineStyle: common.ignoreInlineStyle.concat(
        match.ignoreInlineStyle || []
      ),
      ignoreImageAnalysis: common.ignoreImageAnalysis.concat(
        match.ignoreImageAnalysis || []
      )
    };
  }

  function getDomain(url) {
    if(!url){
      url = window.location.href;
    }
    try {
      return new URL(url).hostname.toLowerCase();
    } catch (error) {
      return url.split('/')[0].toLowerCase();
    }
  }

  let ThemeEngines = {
    cssFilter: 'cssFilter',
    svgFilter: 'svgFilter',
    staticTheme: 'staticTheme',
    dynamicTheme: 'dynamicTheme'
  };

  const DEFAULT_COLORS = {
    darkScheme: {
      background: '#181a1b',
      text: '#e8e6e3'
    },
    lightScheme: {
      background: '#dcdad7',
      text: '#181a1b'
    }
  };
  const DEFAULT_THEME = {
    mode: 1,
    brightness: 100,
    contrast: 100,
    grayscale: 0,
    sepia: 0,
    useFont: false,
    fontFamily: isMacOS ? 'Helvetica Neue': 'Segoe UI',
    textStroke: 0,
    engine: ThemeEngines.dynamicTheme,
    stylesheet: '',
    darkSchemeBackgroundColor: DEFAULT_COLORS.darkScheme.background,
    darkSchemeTextColor: DEFAULT_COLORS.darkScheme.text,
    lightSchemeBackgroundColor: DEFAULT_COLORS.lightScheme.background,
    lightSchemeTextColor: DEFAULT_COLORS.lightScheme.text,
    scrollbarColor: isMacOS ? '' : 'auto',
    selectionColor: 'auto',
    styleSystemControls: !isCSSColorSchemePropSupported,
    lightColorScheme: 'Default',
    // Default,Eco,Eyecare
    darkColorScheme: 'Default',
    immediateModify: false
  };
  const DEFAULT_COLORSCHEME = {
    light: {
      Default: {
        backgroundColor: DEFAULT_COLORS.lightScheme.background,
        textColor: DEFAULT_COLORS.lightScheme.text
      }
    },
    dark: {
      Default: {
        backgroundColor: DEFAULT_COLORS.darkScheme.background,
        textColor: DEFAULT_COLORS.darkScheme.text
      }
    }
  };

  const ECO_COLORSCHEME = {
    lightScheme: DEFAULT_COLORS.lightScheme,
    darkScheme: {
      background: '#000000',
      text: '#969696'
    }
  };
  const EYECARE_COLORSCHEME = {
    lightScheme: DEFAULT_COLORS.lightScheme,
    darkScheme: {
      background: '#ffffcc',
      text: '#695011'
    }
  };

  const DEFAULT_SETTINGS = {
    isStayAround: '',
    siteListDisabled: [],
    siteListEnabled:[], // 暂时没用
    toggleStatus:'auto', //on,off,auto
    // 当toggleStatus=auto的时候，automation默认等于time
    stay_automation: 'system',
    // 当toggleStatus=auto的时候, 如果选择系统配色方案，又分为跟随系统的OnOff,还是Scheme（暗黑/明亮模式）
    stay_automationBehaviour: 'Scheme',
    stay_syncSettings: true,
    auto_time: {
      activation: '18:00',
      deactivation: '9:00'
    },
    auto_location: {
      latitude: null,
      longitude: null
    },
    // DEFAULT_THEME中darkColorScheme：Default,Eco,Eyecare
    stay_theme: DEFAULT_THEME,
    stay_presets: [],
    stay_customThemes: [],
    stay_detectDarkTheme: false,
    stay_enableForPDF: true,
    currentTabUrl:'',
    frameUrl:'',
  };

  const CONFIG_URLs = {
    darkSites: {
      remote: 'https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/dark-sites.config',
      local: '../../config/dark-sites.config'
    },
    dynamicThemeFixes: {
      remote: 'https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/dynamic-theme-fixes.config',
      local: '../../config/dynamic-theme-fixes.config'
    },
    inversionFixes: {
      remote: 'https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/inversion-fixes.config',
      local: '../../config/inversion-fixes.config'
    },
    staticThemes: {
      remote: 'https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/static-themes.config',
      local: '../../config/static-themes.config'
    },
    colorSchemes: {
      remote: 'https://raw.githubusercontent.com/darkreader/darkreader/master/src/config/color-schemes.drconf',
      local: '../../config/color-schemes.drconf'
    }
  };

  const SEPERATOR = '='.repeat(32);
  const backgroundPropertyLength = 'background: '.length;
  const textPropertyLength = 'text: '.length;
  const humanizeNumber = (number) => {
    if (number > 3) {
      return `${number}th`;
    }
    switch (number) {
      case 0:
        return '0';
      case 1:
        return '1st';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
    }
  };
  const isValidHexColor = (color) => {
    return /^#([0-9a-fA-F]{3}){1,2}$/.test(color);
  };
  function ParseColorSchemeConfig(config) {
    const sections = config.split(`${SEPERATOR}\n\n`);
    const definedColorSchemeNames = new Set();
    let lastDefinedColorSchemeName = '';
    const definedColorSchemes = {
      light: {},
      dark: {}
    };
    let interrupt = false;
    let error = null;
    const throwError = (message) => {
      if (!interrupt) {
        interrupt = true;
        error = message;
      }
    };
    sections.forEach((section) => {
      if (interrupt) {
        return;
      }
      const lines = section.split('\n');
      const name = lines[0];
      if (!name) {
        throwError('No color scheme name was found.');
        return;
      }
      if (definedColorSchemeNames.has(name)) {
        throwError(
          `The color scheme name "${name}" is already defined.`
        );
        return;
      }
      if (
        lastDefinedColorSchemeName &&
                lastDefinedColorSchemeName !== 'Default' &&
                name.localeCompare(lastDefinedColorSchemeName) < 0
      ) {
        throwError(
          `The color scheme name "${name}" is not in alphabetical order.`
        );
        return;
      }
      lastDefinedColorSchemeName = name;
      definedColorSchemeNames.add(name);
      if (lines[1]) {
        throwError(
          `The second line of the color scheme "${name}" is not empty.`
        );
        return;
      }
      const checkVariant = (lineIndex, isSecondVariant) => {
        const variant = lines[lineIndex];
        if (!variant) {
          throwError(
            `The third line of the color scheme "${name}" is not defined.`
          );
          return;
        }
        if (
          variant !== 'LIGHT' &&
                    variant !== 'DARK' &&
                    isSecondVariant &&
                    variant === 'Light'
        ) {
          throwError(
            `The ${humanizeNumber(
              lineIndex
            )} line of the color scheme "${name}" is not a valid variant.`
          );
          return;
        }
        const firstProperty = lines[lineIndex + 1];
        if (!firstProperty) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 1
            )} line of the color scheme "${name}" is not defined.`
          );
          return;
        }
        if (!firstProperty.startsWith('background: ')) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 1
            )} line of the color scheme "${name}" is not background-color property.`
          );
          return;
        }
        const backgroundColor = firstProperty.slice(
          backgroundPropertyLength
        );
        if (!isValidHexColor(backgroundColor)) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 1
            )} line of the color scheme "${name}" is not a valid hex color.`
          );
          return;
        }
        const secondProperty = lines[lineIndex + 2];
        if (!secondProperty) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 2
            )} line of the color scheme "${name}" is not defined.`
          );
          return;
        }
        if (!secondProperty.startsWith('text: ')) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 2
            )} line of the color scheme "${name}" is not text-color property.`
          );
          return;
        }
        const textColor = secondProperty.slice(textPropertyLength);
        if (!isValidHexColor(textColor)) {
          throwError(
            `The ${humanizeNumber(
              lineIndex + 2
            )} line of the color scheme "${name}" is not a valid hex color.`
          );
          return;
        }
        return {
          backgroundColor,
          textColor,
          variant
        };
      };
      const firstVariant = checkVariant(2, false);
      const isFirstVariantLight = firstVariant.variant === 'LIGHT';
      delete firstVariant.variant;
      if (interrupt) {
        return;
      }
      let secondVariant = null;
      let isSecondVariantLight = false;
      if (lines[6]) {
        secondVariant = checkVariant(6, true);
        isSecondVariantLight = secondVariant.variant === 'LIGHT';
        delete secondVariant.variant;
        if (interrupt) {
          return;
        }
        if (lines.length > 11 || lines[9] || lines[10]) {
          throwError(
            `The color scheme "${name}" doesn't end with 1 new line.`
          );
          return;
        }
      } else if (lines.length > 7) {
        throwError(
          `The color scheme "${name}" doesn't end with 1 new line.`
        );
        return;
      }
      if (secondVariant) {
        if (isFirstVariantLight === isSecondVariantLight) {
          throwError(
            `The color scheme "${name}" has the same variant twice.`
          );
          return;
        }
        if (isFirstVariantLight) {
          definedColorSchemes.light[name] = firstVariant;
          definedColorSchemes.dark[name] = secondVariant;
        } else {
          definedColorSchemes.light[name] = secondVariant;
          definedColorSchemes.dark[name] = firstVariant;
        }
      } else if (isFirstVariantLight) {
        definedColorSchemes.light[name] = firstVariant;
      } else {
        definedColorSchemes.dark[name] = firstVariant;
      }
    });
    return {result: definedColorSchemes, error: error};
  }
  function parseArray(text) {
    return text
      .replace(/\r/g, '')
      .split('\n')
      .map((s) => s.trim())
      .filter((s) => s);
  }
  async function readText(params) {
    return new Promise((resolve, reject) => {
      if (isXMLHttpRequestSupported) {
        const request = new XMLHttpRequest();
        request.overrideMimeType('text/plain');
        request.open('GET', params.url, true);
        request.onload = () => {
          if (request.status >= 200 && request.status < 300) {
            resolve(request.responseText);
          } else {
            reject(
              new Error(
                `${request.status}: ${request.statusText}`
              )
            );
          }
        };
        request.onerror = () =>
          reject(
            new Error(`${request.status}: ${request.statusText}`)
          );
        if (params.timeout) {
          request.timeout = params.timeout;
          request.ontimeout = () =>
            reject(
              new Error('File loading stopped due to timeout')
            );
        }
        request.send();
      } else if (isFetchSupported) {
        let abortController;
        let signal;
        let timedOut = false;
        if (params.timeout) {
          abortController = new AbortController();
          signal = abortController.signal;
          setTimeout(() => {
            abortController.abort();
            timedOut = true;
          }, params.timeout);
        }
        fetch(params.url, {signal})
          .then((response) => {
            if (response.status >= 200 && response.status < 300) {
              resolve(response.text());
            } else {
              reject(
                new Error(
                  `${response.status}: ${response.statusText}`
                )
              );
            }
          })
          .catch((error) => {
            if (timedOut) {
              reject(
                new Error('File loading stopped due to timeout')
              );
            } else {
              reject(error);
            }
          });
      } else {
        reject(
          new Error(
            'Neither XMLHttpRequest nor Fetch API are accessible!'
          )
        );
      }
    });
  }
  const REMOTE_TIMEOUT_MS = getDuration({seconds: 10});
  class ConfigManager {
    constructor() {
      this.raw = {
        darkSites: null,
        dynamicThemeFixes: null,
        inversionFixes: null,
        staticThemes: null,
        colorSchemes: null
      };
      this.overrides = {
        darkSites: null,
        dynamicThemeFixes: null,
        inversionFixes: null,
        staticThemes: null
      };
      this.DYNAMIC_THEME_FIXES_INDEX = {
        // eslint-disable-next-line max-len
        'domains': {'01net.com':3,'10fastfingers.com':4,'10minutemail.com':5,'123-3d.nl':6,'123accu.nl':6,'123inkt.nl':6,'123led.nl':6,'123schoon.nl':6,'123mathe.de':7,'1337x.st':8,'1337x.to':8,'x1337x.eu':8,'x1337x.se':8,'x1337x.ws':8,'1917.com':9,'1fichier.com':10,'3.basecamp.com':12,'300gospodarka.pl':13,'300polityka.pl':13,'37.com':14,'3dmark.com':15,'40ton.net':16,'4t-niagara.com':17,'9game.cn':18,'a11ywithlindsey.com':19,'aad.org':20,'abandonia.com':21,'abcnews.go.com':22,'abiturma.de':23,'ableton.com':24,'about.gitlab.com':25,'academy.abeka.com':26,'academy.dqlab.id':27,'access.ing.de':28,'access.wgu.edu':29,'my.wgu.edu':29,'accessiblepalette.com':30,'accesswire.com':31,'account.live.com':32,'account.microsoft.com':33,'account.orchid.com':34,'account.proton.me':35,'account.protonvpn.com':35,'account.ui.com':36,'account.xiaomi.com':37,'accounts.google.com':38,'accounts.hetzner.com':39,'dns.hetzner.com':39,'konsoleh.hetzner.com':39,'robot.hetzner.com':39,'accounts.spotify.com':40,'accounts.zoho.com':41,'accuweather.com':42,'acer.com':43,'acmicpc.net':44,'acorn.utoronto.ca':45,'actioncardapp.com':46,'ad.nl':47,'ada.org':48,'adata.com':49,'addons.mozilla.org':50,'adguard-dns.io':51,'adguard-vpn.com':52,'adguard.com':53,'admin.migadu.com':54,'afterpay.com':55,'aftonbladet.se':56,'ai2.appinventor.mit.edu':57,'aiming.pro':58,'akademy.kde.org':59,'edu.kde.org':59,'dot.kde.org':59,'forum.kde.org':59,'akasa.com':60,'akcemed.pl':61,'akinator.com':62,'alamy.com':63,'aldi.us':64,'alertus.com':65,'alexpage.de':66,'alfredapp.com':67,'algorithm-wiki.org':68,'alipay.com':70,'aljazeera.com':71,'allconnect.com':72,'allegro.pl':73,'allegrolokalnie.pl':74,'allmacworld.com':76,'allrecipes.com':77,'allspice.io':78,'alphacoders.com':79,'alphashooters.com':80,'alpine.com':81,'alt.hololive.tv':82,'altlinux.org':83,'amalgamatedbank.com':84,'amap.com':85,'amazingmarvin.com':86,'amazon.cn':88,'ametek.com':89,'amfam.com':90,'amtrak.com':91,'androidcentral.com':92,'androidpolice.com':93,'ang.pl':94,'angrymetalguy.com':95,'anibrain.ai':96,'anilibria.tv':97,'anilist.co':98,'ankiweb.net':99,'annas-archive.org':100,'anon-co-eu.com':101,'anon-co.com':102,'answers.opencv.org':103,'answers.unity.com':104,'antagning.se':105,'antistorm.eu':106,'antywirus-nod32.pl':107,'anytype.io':108,'aol.com':109,'aosogrenci.anadolu.edu.tr':110,'apartmentlist.com':111,'apartments.com':112,'apclassroom.collegeboard.org':113,'api.kde.org':114,'apidocs.snyk.io':115,'apie.lrt.lt':116,'apkpure.com':117,'apnews.com':118,'app.betrybe.com':119,'app.codesignal.com':120,'app.corellium.com':121,'app.daily.dev':122,'app.datadoghq.com':123,'app.grammarly.com':124,'app.kognity.com':125,'app.mysms.com':126,'app.roll20.net':127,'app.standardnotes.org':128,'app.timelyapp.com':129,'app.traderepublic.com':130,'app.youneedabudget.com':131,'apple.com':[132,133],'apps.microsoft.com':134,'aprs-map.info':135,'aprs.fi':136,'apteka.ru':137,'aras.com':138,'archenoah-kelkheim.de':139,'architekturaibiznes.pl':140,'archive.org':141,'arelion.com':142,'ario-player.sourceforge.net':143,'ars.particify.de':144,'arstechnica.com':145,'artofproblemsolving.com':146,'artsy.net':147,'arxiv.org':148,'asahichinese-j.com':149,'asahilinux.org':150,'asana.com':151,'asciinema.org':152,'askjohnmackay.com':153,'askvg.com':154,'askwoody.com':155,'assetstore.unity.com':156,'astro.build':157,'astroproxy.com':158,'asus.com':159,'atcoder.jp':160,'atlas.herzen.spb.ru':161,'guide.herzen.spb.ru':161,'job.herzen.spb.ru':161,'atlassian.net':162,'audible.com':163,'audio-technica.com':164,'audycje.tokfm.pl':165,'auth.adguard.com':166,'auth0.com':167,'autodesk.com':168,'autoweek.com':169,'avanti24.pl':170,'avast.com':171,'avg.com':172,'avito.ru':173,'avlab.pl':174,'aws.amazon.com':175,'azuresynapse.net':176,'azurlane.koumakan.jp':177,'bab.la':178,'babyem.co.uk':179,'babylonbee.com':180,'bahnhof.net':181,'baike.baidu.com':182,'bakabt.me':183,'balena.io':184,'bandcamp.com':185,'allochiria.com':185,'bandshed.net':186,'banki.ru':187,'bankier.pl':188,'bankier.tv':188,'bankofamerica.com':189,'barnesandnoble.com':190,'basecamp.com':191,'bayfiles.com':192,'bbc.co.uk':194,'bbc.com':[194,195],'bbs.chinauos.com':196,'bbs.deepin.org':196,'bbs.thinkpad.com':197,'club.lenovo.com.cn':197,'behance.net':198,'benevity.com':199,'berlingske.dk':200,'bestbuy.ca':201,'bestbuy.com':202,'bestchange.ru':203,'bet.com':204,'cmt.com':204,'logotv.com':204,'paramountnetwork.com':204,'southpark.cc.com':204,'vh1.com':204,'betanews.com':205,'bettercap.org':206,'bfi.org.uk':207,'bgp.he.net':208,'bible.optina.ru':209,'bibliotecapleyades.net':210,'bienici.com':211,'bigocheatsheet.com':212,'biletywielkopolskie.pl':213,'biliomask.com':214,'binance.com':215,'bing.com':216,'biorxiv.org':217,'bitbay.net':218,'bitbucket.org':219,'bitcoinprice.com':220,'bitcoinwisdom.com':221,'bitly.com':222,'bitwarden.com':223,'bitwit.tech':224,'biznes.pap.pl':225,'blackboard.com':227,'blahdns.com':228,'blaupunkt.com':229,'blog.arelion.com':230,'blog.cloudflare.com':231,'blog.documentfoundation.org':232,'blog.doist.com':233,'blog.mozilla.org':234,'blog.nightly.mozilla.org':235,'blog.scssoft.com':236,'blogger.com':237,'blogs.windows.com':238,'bloomberg.com':239,'blueberryroasters.pl':240,'bluemic.com':241,'boardgamearena.com':242,'boardgamegeek.com':243,'bol.com':244,'bol.de':245,'bonfire.com':246,'book.douban.com':247,'booking.com':248,'booking.uz.gov.ua':249,'books.zoho.eu':251,'boredpanda.com':252,'boringcompany.com':253,'bostonacoustics.com':254,'bowerswilkins.com':255,'boxberry.ru':256,'bpmn.io':257,'br.de':258,'brainly.com':259,'brainly.pl':260,'brave.com':261,'breadfinancial.com':262,'breitbart.com':263,'brightspace.avans.nl':264,'brightspace.rug.nl':265,'brightspace.com':265,'brightspace.algonquincollege.com':265,'brilliant.org':266,'broadcom.com':267,'browser.kagi.com':268,'browserleaks.com':269,'bsi.bund.de':270,'buffer.com':271,'bugreplay.com':272,'bugs.chromium.org':273,'bugs.mojang.com':274,'bugs.python.org':275,'build-electronic-circuits.com':276,'bulbagarden.net':277,'bulk.com':278,'bulldogjob.pl':[279,280],'burmester.de':281,'burnaware.com':282,'businessinsider.com':283,'businessinsider.com.au':283,'businessinsider.com.pl':283,'businessinsider.co.za':283,'businessinsider.es':283,'businessinsider.jp':283,'businessinsider.mx':283,'insider.com':283,'it.businessinsider.com':283,'businesswire.com':284,'buzzsprout.com':285,'c60.la.coocan.jp':286,'caddy.community':287,'caddyserver.com':288,'cadence.com':289,'caf.fr':290,'caiyunapp.com':291,'cake.avris.it':292,'caldigit.com':293,'calendar.google.com':294,'calibre-ebook.com':295,'calvinklein.us':296,'canakit.com':297,'candidates.ibo.org':298,'canva.com':299,'canvas.usask.ca':301,'caramba-switcher.com':302,'cargurus.com':303,'carmax.com':304,'castbox.fm':305,'castos.com':306,'catalog.update.microsoft.com':307,'catt.rs':308,'cbpp.org':309,'cbsnews.com':310,'cdaction.pl':311,'cdc.gov':312,'cdimage.ubuntu.com':313,'cdn5.dcbstatic.com':314,'cdn77.com':315,'cdp.contentdelivery.nu':316,'cdrtools.sourceforge.net':317,'celio.com':318,'ceneo.pl':319,'central.proxyvote.com':320,'centrum24.pl':321,'centrumxp.pl':322,'cfos-emobility.de':323,'cfos.de':324,'changkun.de':325,'charitynavigator.org':326,'chase.com':327,'cheapshark.com':328,'check.spamhaus.org':329,'checkout.minecraft.net':330,'chem.libretexts.org':331,'chessprogramming.org':332,'chilkatsoft.com':333,'chinadigitaltimes.net':334,'chinauos.com':335,'chipotle.com':336,'christinamin9-ancientromancivilisation.weebly.com':337,'chromeenterprise.google':338,'chromestatus.com':339,'chtoes.li':340,'churchofjesuschrist.org':341,'ci.appveyor.com':342,'cinedrome.ch':343,'circleci.com':344,'circt.llvm.org':345,'mlir.llvm.org':345,'circuit-diagram.org':346,'cisce.org':347,'citilink.ru':348,'cityam.com':349,'citybuzz.pl':350,'citymapper.com':351,'classroom.google.com':352,'cleantechnica.com':353,'clever.com':354,'click.endnote.com':[355,356],'clients.servarica.com':357,'cloud.databricks.com':358,'pages.databricks.com':358,'cloudflare.com':359,'cloudhostnews.com':360,'cloudinfrastructuremap.com':361,'cloudlinux.com':362,'cloudways.com':363,'cnbc.com':364,'cnki.net':365,'cnn.com':366,'cobaltstrike.com':367,'cobalt-strike.github.io':367,'code.qt.io':368,'code.visual':369,'io.com':369,'codeberg.org':370,'codeberg-test.org':370,'codecademy.com':371,'codeforces.com':372,'codewars.com':373,'codingame.com':374,'codio.com':375,'coinbase.com':376,'coindesk.com':377,'colasoft.com':378,'coliss.com':379,'color-hex.com':380,'colorhunt.co':381,'colorpicker.me':382,'colors.dopely.top':383,'comenius.susqu.edu':384,'comicfury.com':385,'comingsoon.net':386,'comixology.com':387,'comma.ai':388,'commons.wikimedia.org':389,'commonvoice.mozilla.org':390,'commscope.com':391,'community.cloudflare.com':392,'community.notepad-plus-plus.org':393,'community.ntppool.org':394,'community.progress.com':395,'compass.pressekompass.net':396,'computerhope.com':397,'comsol.com':398,'confectioneryproduction.com':399,'consent.yahoo.com':401,'console.cloud.google.com':403,'consumerlab.com':404,'contacts.google.com':405,'containertoolbx.org':406,'convertio.co':407,'cookiepedia.co.uk':408,'coolblue.be':409,'coolblue.nl':409,'hotorangemedia.nl':409,'coolors.co':410,'coopgames.eu':411,'coosp.etr.u-szeged.hu':412,'copitosystem.com':413,'corriere.it':414,'corsair.com':415,'costplusdrugs.com':416,'courses.fit.cvut.cz':417,'covims.org':418,'cowkrakowie.pl':419,'cplusplus.com':420,'cppm3144.itdhosting.de':421,'cqksy.cn':422,'crates.io':423,'creative.com':424,'creditkarma.com':425,'crowdin.com':426,'crunchbase.com':427,'crutchfield.com':428,'cryptostorm.is':429,'cs61a.org':430,'css-tricks.com':431,'cubawiki.com.ar':432,'curseforge.com':433,'cxp.cengage.com':434,'cyberlink.com':435,'cynkra.com':436,'cyprus-mail.com':437,'czasnastopy.pl':438,'czypada.pl':439,'czyztak.pl':440,'d.hatena.ne.jp':441,'d2l.ai':442,'daily.afisha.ru':443,'dailydot.com':444,'dailyexpose.uk':445,'dailymotion.com':446,'dailywritingtips.com':447,'daltonmaag.com':448,'danyk.cz':449,'darcs.net':450,'darksky.net':451,'dash.cloudflare.com':452,'dashboard.thechurchapp.org':453,'datacamp.com':454,'daum.net':455,'dawn.com':456,'deadpixeltest.org':457,'deadroots.net':458,'debian.org':459,'debijbel.nl':460,'decathlon.in':461,'decathlon.pl':462,'deccanchronicle.com':463,'decisionproblem.com':464,'deepl.com':465,'deeplearningbook.org':466,'deezer.com':467,'deftpdf.com':468,'dell.com':469,'delphipraxis.net':470,'dennisbareis.com':471,'deno.land':472,'dependencywalker.com':473,'designobserver.com':474,'deskmodder.de':475,'desmos.com':476,'detexify.kirelabs.org':477,'dev.azure.com':478,'dev.dota2.com':479,'dev.to':480,'developer.android.com':481,'source.android.com':481,'developer.android.google.cn':481,'tensorflow.org':481,'quantumai.google':481,'cloud.google.com':481,'webrtc.org':481,'developer.apple.com':482,'developer.chrome.com':483,'developer.mozilla.org':484,'developer.roblox.com':485,'developer.salesforce.com':486,'developers.arcgis.com':487,'developers.facebook.com':488,'developers.google.com':489,'devuan.org':490,'dexie.org':491,'dhmo.org':492,'di.com.pl':493,'diamondsdirect.com':494,'dianping.com':495,'dicetower.com':496,'dict.cc':497,'dictionary.cambridge.org':498,'differencebetween.net':499,'digg.com':500,'digi.hu':501,'digitalextremes.zendesk.com':502,'disconnect.me':503,'discord.com':504,'discourse.haskell.org':505,'discover.com':506,'discover.forem.com':507,'discovermagazine.com':508,'discovery.endeavouros.com':509,'discuss.pixls.us':510,'distrowatch.com':513,'ditu.baidu.com':514,'map.baidu.com':514,'maps.baidu.com':514,'djrankings.org':515,'dlagentlemana.pl':516,'dle.rae.es':517,'dmca.com':518,'dmit.io':519,'dnd.su':520,'dnd5e.wikidot.com':521,'dndbeyond.com':522,'dnscrypt.pl':523,'dnsleaktest.com':524,'dnslytics.com':525,'doba.pl':526,'dobreprogramy.pl':527,'doc.qt.io':528,'docs.codacy.com':529,'docs.dagster.io':530,'docs.expo.dev':531,'docs.google.com':[532,533],'docs.manim.community':534,'docs.sentry.io':535,'docs.soliditylang.org':536,'doctorswithoutborders.org':537,'documentfoundation.org':538,'documentliberation.org':539,'donald.pl':541,'doodle.com':542,'doordash.com':543,'dotaunderlords.gamepedia.com':544,'dota2.gamepedia.com':544,'dota2.fandom.com':544,'dou.ua':545,'downloads.khinsider.com':546,'dp.ru':547,'dribbble.com':548,'drive.google.com':[549,550,551],'droid-life.com':552,'dropbox.com':553,'drupal.org':554,'drvhub.net':555,'ds.163.com':556,'dsausa.org':557,'dspguide.com':558,'dtf.ru':559,'duckduckgo.com':560,'duo.google.com':561,'duolingo.com':562,'dvizhcom.ru':563,'dw.com':564,'dynadot.com':565,'dziennik.pl':566,'dziennikbaltycki.pl':567,'dzienniklodzki.pl':567,'dziennikpolski24.pl':567,'echodnia.eu':567,'expressbydgoski.pl':567,'expressilustrowany.pl':567,'gazetakrakowska.pl':567,'gazetalubuska.pl':567,'gazetawroclawska.pl':567,'gk24.pl':567,'gloswielkopolski.pl':[567,769],'gol24.pl':567,'gp24.pl':567,'gra.pl':567,'gs24.pl':567,'i.pl':567,'kurierlubelski.pl':567,'motofakty.pl':567,'naszemiasto.pl':567,'nowiny24.pl':567,'nowosci.com.pl':567,'nto.pl':567,'pomorska.pl':567,'poranny.pl':567,'sportowy24.pl':567,'strefaagro.pl':567,'strefabiznesu.pl':567,'strefaedukacji.pl':567,'stronakobiet.pl':567,'stronazdrowia.pl':567,'telemagazyn.pl':567,'to.com.pl':567,'wspolczesna.pl':567,'dzienniknaukowy.pl':568,'dziennikprawny.pl':569,'e.foundation':570,'ea.com':571,'eapteka.ru':572,'easybib.com':573,'easypost.com':574,'eatthis.com':575,'eblocker.org':576,'ebok.pgnig.pl':577,'ebok.vectra.pl':578,'ebooks.cpm.org':579,'economist.com':580,'edmworldmagazine.com':581,'edmworldshop.com':582,'edstem.org':583,'education.github.com':584,'eduke32.com':585,'edulastic.com':586,'eduserver.ru':587,'eevblog.com':588,'eff.org':589,'elearning.utdallas.edu':590,'electrical-symbols.com':591,'electrical4u.com':592,'electricitymap.org':593,'element.io':594,'elementalmatter.info':595,'elementary.io':596,'eletimes.com':597,'elp.northumbria.ac.uk':598,'emacswiki.org':599,'endeavouros.com':600,'endoflife.date':601,'endomondo.com':602,'enduhub.com':603,'enea.pl':604,'enjen.net':605,'ernestjones.co.uk':606,'esbuild.github.io':607,'eshop-switch.com':608,'eshot.gov.tr':609,'esphome.io':610,'esquire.com':611,'estadao.com.br':612,'etherrag.blogspot.com':613,'etsy.com':614,'eukhost.com':615,'everdermlaser.hu':616,'evernote.com':617,'evga.com':618,'ewybory.eu':619,'exercism.org':620,'exmo.me':621,'expedia.com':622,'experian.com':623,'experiencia.xpi.com.br':624,'explainxkcd.com':625,'expressjs.com':626,'ezgif.com':627,'f-droid.org':628,'facebook.com':629,'fakespot.com':631,'fakt.pl':632,'fanatical.com':633,'fandom.com':634,'fantasy.premierleague.com':635,'farside.ph.utexas.edu':636,'mathpages.com':636,'mathprofi.ru':636,'mathprofi.net':636,'mathworld.wolfram.com':636,'reference.wolfram.com':636,'terrytao.wordpress.com':636,'wolframalpha.com':636,'fast.com':637,'fastmail.com':[638,639],'fau.de':640,'fax.plus':641,'fckng-serious.de':642,'fcmed.pl':643,'fedex.com':644,'fedoraforum.org':645,'feedly.com':646,'feynmanlectures.caltech.edu':647,'ffmpeg.zeranoe.com':648,'fibermap.it':649,'figma.com':650,'fileformat.info':651,'filetransfer.io':652,'filmweb.pl':653,'filterlists.com':654,'final-fantasy.ch':655,'finn.no':656,'fio.fnar.net':657,'firebase.google.com':658,'firefox.com':659,'firefox.net.cn':660,'firstcontributions.github.io':661,'fivepost.ru':662,'fiverr.com':663,'fivethirtyeight.com':664,'flaggenlexikon.de':665,'flashscore.com.tr':666,'flatuicolors.com':667,'flightfinder.fi':668,'flipslibrary.com':669,'flow.polar.com':670,'flowkey.com':671,'fly.io':672,'flyzipline.com':673,'follow.it':674,'fontawesome.com':675,'fontsinuse.com':676,'fontspring.com':677,'fontsquirrel.com':678,'foobar2000.org':679,'food4less.com':680,'foolcontrol.org':681,'forem.com':682,'forms.reform.app':683,'forms.yandex.ru':684,'forsal.pl':685,'forum.dobreprogramy.pl':686,'forum.donanimhaber.com':687,'forum.eset.com':688,'forum.ithardware.pl':688,'forum.kaspersky.com':688,'forums.getpaint.net':688,'forums.laptopvideo2go.com':688,'nieidealny.pl':688,'forum.ivao.aero':689,'forum.kaosx.us':690,'forum.manjaro.org':691,'forum.miranda-ng.org':692,'forum.p300.it':693,'forums.comodo.com':694,'forums.gearsofwar.com':695,'forums.mydigitallife.net':696,'forums.opera.com':697,'forums.operationsports.com':698,'forums.tomshardware.com':699,'forvo.com':700,'fotor.com':701,'fotw.info':702,'frame.work':703,'fredmeyerjewelers.com':704,'freebsdfoundation.org':705,'freecodecamp.org':706,'freecommander.com':707,'freedom.press':708,'freelancer.com':709,'freemaptools.com':710,'freesound.org':711,'freetp.org':712,'fritz.box':713,'fs.blog':714,'fsfe.org':715,'ftp.nluug.nl':716,'fullstackopen.com':717,'funpay.ru':718,'furrychina.com':719,'fusoya.eludevisibility.org':720,'futureplc.com':721,'fz-juelich.de':722,'gadzetomania.pl':723,'gain.tv':724,'gameinformer.com':725,'gamepress.gg':726,'gameranx.com':727,'gamerevolution.com':728,'gamesindustry.biz':729,'gamestop.com':730,'garmin.com':731,'gasbuddy.com':732,'gat.no':733,'gatsbyjs.com':734,'gazeta.pl':735,'plotek.pl':735,'sport.pl':735,'edziecko.pl':735,'moto.pl':[735,1180],'ukrayina.pl':735,'gazetaprawna.pl':736,'gazetaswietokrzyska.pl':737,'ge.globo.com':738,'geekflare.com':739,'geeksforgeeks.org':740,'skinflint.co.uk':741,'cenowarka.pl':741,'genius.com':742,'genshin-impact-map.appsample.com':743,'gentoo.org':744,'geogebra.org':745,'getalt.org':747,'getfedora.org':748,'getlektor.com':749,'getmimo.com':750,'getpocket.com':751,'getsol.us':752,'gg.pl':753,'ggmania.com':754,'ghisler.com':755,'gigabyte.com':756,'git-scm.com':757,'github.com':758,'github.myshopify.com':759,'githubstatus.com':760,'gitlab.com':761,'gitlab.host':761,'code.videolan.org':761,'framagit.org':761,'git.fairkom.net':761,'repo1.dso.mil':761,'gittigidiyor.com':762,'giveawayoftheday.com':763,'giveaways.cavebot.xyz':764,'gizmodo.com':765,'glasswire.com':766,'global.gotomeeting.com':767,'globo.com':768,'gls-pakete.de':770,'gnc.com':771,'gnu.org':772,'godaddy.com':773,'godfathers.com':774,'godoc.org':775,'godzinyotwarcia24.pl':776,'gog-games.com':777,'gog.com':[778,779],'gokulv.netlify.app':780,'golang.org':781,'goodreads.com':782,'googleprojectzero.blogspot.com':785,'goplay.anontpp.com':786,'gorod.gov.spb.ru':787,'gorod.mos.ru':788,'gosuslugi.ru':789,'gotquestions.org':790,'gov.pl':791,'gowork.pl':792,'grammarly.com':793,'gramota.ru':794,'gravatar.com':795,'grc.com':796,'greatergood.com':797,'grocy.info':798,'grubhub.com':799,'gsmchoice.com':800,'mgsm.pl':800,'gsuite.google.com':801,'gu.spb.ru':802,'guancha.cn':803,'guiott.com':804,'guitarcenter.pl':805,'guitarworld.com':806,'gumroad.com':807,'gurushots.com':808,'habitica.com':809,'habr.com':810,'hacdias.com':811,'hackerone.com':812,'hackerrank.com':813,'hampage.hu':814,'handshake.org':815,'handwiki.org':816,'haokan.baidu.com':817,'hbo.com':818,'hbr.org':819,'hbweb.hu':820,'hdgo.cc':821,'vio.to':821,'hdlbits.01xz.net':822,'heise.de':823,'helix.ru':824,'help.ea.com':825,'help.nextdns.io':826,'helzberg.com':827,'heraldscotland.com':828,'heritage.org':829,'hex-rays.com':830,'hh.ru':831,'hindustantimes.com':832,'history.state.gov':833,'hktdc.com':834,'hm.com':835,'wikihmong.com':836,'homebrewery.naturalcrit.com':837,'hooktail.sub.jp':838,'hooktail.org':838,'hootsuite.com':839,'hotel.meituan.com':840,'howbuy.com':841,'howstuffworks.com':842,'hp.com':843,'hs.fi':844,'huawei.com':845,'huba.news':846,'hubs.mozilla.com':847,'hvdic.thivien.net':848,'hyperphysics.phy-astr.gsu.edu':849,'hyperskill.org':850,'hypixel.net':851,'hypothes.is':852,'i-item.jd.com':853,'ica.coop':854,'icloud.com':855,'icofont.com':856,'iconfinder.com':857,'iconify.design':858,'icons8.com':859,'icrc.org':860,'id.unity.com':861,'ieee.org':862,'iett.istanbul':863,'ifixit.com':864,'iflscience.com':865,'ifood.com.br':866,'igurublog.wordpress.com':867,'iliad.it':869,'ilovepdf.com':870,'image-net.org':872,'imdb.com':874,'immobilienscout24.de':875,'inc.com':876,'ind.ie':877,'independent.co.uk':878,'inet.se':879,'infinity-academies.com':880,'infinitysearch.co':881,'info.wyborcza.biz':882,'inforlex.pl':883,'informa.com':884,'informatech.com':885,'inoreader.com':886,'instagram.com':887,'instructables.com':888,'instructure.com':889,'integration.wikimedia.org':890,'interaktywnie.com':891,'interia.pl':892,'internetexchangemap.com':893,'internetowa.tv':894,'interpride.org':895,'investopedia.com':896,'invisioncommunity.com':897,'inwestomat.eu':898,'iopscience.iop.org':899,'ipinfo.io':900,'ipko.pl':901,'iplocation.net':902,'iqiyi.com':903,'irishtimes.com':904,'is.muni.cz':905,'isbgpsafeyet.com':906,'ising.pl':907,'istanbulfm.com.tr':908,'italy-vms.ru':909,'itbiznes.pl':910,'itch.io':911,'item.jd.com':912,'itemfix.com':913,'ithardware.pl':914,'iu-fernstudium.de':915,'iubenda.com':916,'iupts.org':917,'ixbt.com':918,'jacobin.com':919,'jailbreak.fce365.info':920,'jakdojade.pl':921,'jamboard.google.com':922,'jamendo.com':923,'jared.com':924,'kay.com':924,'banter.com':924,'peoplesjewellers.com':924,'zales.com':924,'java.com':925,'jbl.com':926,'jenkins.io':927,'jewishcurrents.org':928,'jisho.org':931,'jobs.github.com':932,'joemonster.org':933,'johnhorgan.org':934,'joincake.com':935,'joplinapp.org':936,'journal.tinkoff.ru':937,'jpl.nasa.gov':938,'jpmorgan.com':939,'jpost.com':940,'jsdelivr.com':941,'jsware.net':942,'juejin.cn':943,'zando.co.za':944,'justhost.ru':945,'justtherecipe.com':946,'juwai.com':947,'jvc.net':948,'k-report.net':949,'kaggle.com':950,'kaggleusercontent.com':950,'kahoot.it':951,'kaldata.com':952,'kali.org':953,'kaos-community-packages.github.io':954,'kaosx.us':955,'kapitanbomba.pl':956,'kartotekaonline.pl':957,'katahiromz.web.fc2.com':958,'kaytrip.com':959,'kbb.com':960,'kcsoftwares.com':961,'keep.google.com':962,'keepa.com':963,'keepass.info':964,'keepassxc.org':965,'kenh14.vn':966,'kenmore.com':967,'kenwood.com':968,'keyserver.pgp.com':969,'kfccoupons.co.nz':970,'khanacademy.org':971,'khronos.org':972,'kiedyprzyjedzie.pl':973,'killedbygoogle.com':974,'kingston.com':975,'kinhmatanna.com':976,'kinoart.ru':977,'kinopoisk.ru':978,'kinsta.com':979,'kinzhal.media':980,'kioxia.com':981,'klubjagiellonski.pl':982,'knaben.eu':983,'knife.media':984,'knowyourmeme.com':985,'ko-fi.com':986,'kohls.com':987,'komorkomat.pl':988,'komputerswiat.pl':989,'konicaminolta.us':990,'konkret24.tvn24.pl':991,'konto.onet.pl':992,'kopalniawiedzy.pl':993,'korso24.pl':994,'korsosanockie.pl':994,'kort.foroyakort.fo':995,'kraken.com':996,'krew.info':997,'krita.org':998,'krytykapolityczna.pl':999,'ksiegowawsieci.pl':1000,'kubuntu.org':1001,'kulinarnyblog.pl':1002,'kyivindependent.com':1003,'labcorp.com':1004,'labfolder.com':1005,'laczynasnapiecie.pl':1006,'lafibre.info':1007,'lajtmobile.pl':1008,'lambda-the-ultimate.org':1009,'lambdalabs.com':1010,'lambdatest.com':1011,'languagetool.org':1012,'laptopmag.com':1013,'laravel.com':1014,'last.fm':1015,'lastpass.com':1016,'latex.wikia.org':1017,'latimes.com':1018,'launchpad.net':1019,'leagueoflegends.com':1020,'lear.com':1021,'learn.inside.dtu.dk':1022,'learnopengl.com':1023,'leetcode.com':1024,'leetcode-cn.com':1024,'legacy.com':1025,'lemonde.fr':1026,'lenovo.com':1027,'lesbonscomptes.com':1028,'letters.gov.spb.ru':1029,'letyshops.com':1030,'lever.co':1031,'lexar.com':1032,'lg.com':1033,'liberte.pl':1034,'sklep.liberte.pl':1034,'libravatar.org':1035,'libretexts.org':1036,'librewolf-community.gitlab.io':1037,'librewolf.com':1038,'librivox.org':1039,'licensing.biz':1040,'lichess.org':1041,'life360.com':1042,'lifelock.com':1043,'lightning.force.com':1044,'lightningmaps.org':1045,'lingvoforum.net':1046,'link.springer.com':1047,'linkedin.com':1048,'linode.com':1049,'linotype.com':1050,'linustechtips.com':1051,'linux-hardware.org':1052,'linuxfoundation.org':1053,'linuxgrandma.blogspot.com':1054,'linuxuprising.com':1055,'lirc.org':1056,'literia.pl':1057,'live.com':1058,'live.myvrspot.com':1059,'liveagent.com':1060,'livemint.com':1061,'liveuamap.com':1062,'lkml.org':1063,'loepenshop.com':1064,'bonjourfoto.nl':1064,'login.assetpanda.com':1065,'login.live.com':1066,'login.yahoo.com':1067,'logowanie.edukacja.olsztyn.eu':1068,'lol.fandom.com':1069,'lovekrakow.pl':1070,'lowendtalk.com':1071,'lowes.com':1072,'lrt.lt':1073,'lsa.umich.edu':1074,'lunapic.com':1075,'luogu.com.cn':1076,'lux.camera':1077,'m.dianping.com':1078,'m.genk.vn':1079,'m.motonet.fi':1080,'m.slashdot.org':1081,'machinelearningmastery.com':1082,'macrumors.com':1083,'madshi.net':1084,'mafreebox.freebox.fr':1085,'magazine.skyeng.ru':1086,'magazynbieganie.pl':1087,'magic.freizeitspieler.de':1088,'magister.net':1089,'mail.eni.it':1090,'mail.google.com':1091,'mail.jwpub.org':1092,'mail.qq.com':1093,'mail.tutanota.com':1094,'mailbox.org':1095,'makeuseof.com':1096,'manage.buyvm.net':1097,'manjaro.org':1098,'manualslib.com':1099,'map.qq.com':1100,'mapa-turystyczna.pl':1101,'maps.metager.de':1102,'marginalrevolution.com':1103,'mariadb.org':1104,'marinij.com':1105,'marketmarketmarket.com':1107,'marketstudios.com':1107,'marketplace.visualstudio.com':1108,'markmcgranaghan.com':1109,'marktplaats.nl':1110,'mastarti.com':1111,'streamguard.cc':1111,'math.semestr.ru':1112,'math.tamu.edu':1113,'mathsisfun.com':1114,'matomo.org':1115,'matrix.org':1116,'matrix.to':1117,'matsci.org':1118,'matters.news':1119,'mcbsys.com':1120,'mcdonalds.com':1121,'medianauka.pl':1122,'mediawiki.org':1123,'medium.com':1124,'medium.freecodecamp.org':1125,'medrxiv.org':1126,'meduza.io':1127,'meet.google.com':1128,'meet.jit.si':1129,'mega.nz':1130,'meituan.com':1131,'memtest.org':1132,'mendeley.com':1133,'mercury.postlight.com':1134,'merriam-webster.com':1135,'messages.android.com':1136,'messages.google.com':1137,'messenger.com':1138,'metacareers.com':1139,'metal.equinix.com':1140,'meteo.imgw.pl':1141,'metrics.torproject.org':1142,'metrobyt-mobile.com':1143,'mewe.com':1144,'microsoft.com':1145,'microsoftedge.microsoft.com':1146,'midkar.com':1147,'mikanani.me':1148,'miktex.org':1149,'mikufan.com':1150,'minecraftskins.com':1151,'minesweeper.online':1152,'minsu.dianping.com':1153,'mint.intuit.com':1154,'miro.com':1155,'mit.edu':1156,'mixcloud.com':1158,'mjtnet.com':1159,'mlb.com':1160,'mnt.ee':1161,'mobiel.nl':1162,'mobile.bg':1163,'moegirl.org.cn':1164,'mojosoft.com.pl':1165,'moluch.ru':1166,'money.pl':1167,'mongodb.com':1168,'monitor.firefox.com':1169,'monokai.pro':1170,'monstercat.com':1171,'monta.ir':1172,'moodle.herzen.spb.ru':1173,'moodle.latech.edu':1174,'moovitapp.com':1175,'morele.net':1176,'morningstar.com':1177,'mos.ru':1178,'motherjones.com':1179,'motorsport.com':1181,'mozilla.net':1182,'mp.weixin.qq.com':1183,'msi.com':1184,'msmgtoolkit.in':1185,'msn.com':1186,'msys2.org':1187,'mt.lv':1188,'mturk.com':1189,'mullvad.net':1190,'multitran.com':1191,'mumble.info':1192,'muratordom.pl':1193,'murena.com':1194,'musclewiki.com':1195,'music.163.com':1196,'music.apple.com':1198,'musictheory.net':1199,'my.account.sony.com':1200,'my.bible.com':1201,'my.cofc.edu':1202,'my.contabo.com':1203,'my.frantech.ca':1204,'my.nextdns.io':1205,'my.nintendo.com':1206,'my.remarkable.com':1207,'my.vega.ua':1208,'my.volia.com':1209,'myabandonware.com':1210,'myaccount.google.com':1211,'myaccount.suse.com':1212,'myalmacoffee.com':1213,'myanimelist.net':1214,'mybrandnewlogo.com':1215,'myfood4less.com':1216,'mymenu.be':1217,'myunidays.com':1218,'mywikis.com':1219,'n.maps.yandex.ru':1220,'mapeditor.yandex.com':1220,'nagatabi-p.jimdofree.com':1221,'nalog.ru':1222,'namecheap.com':1223,'naps2.com':1224,'narimiran.github.io':1225,'narrativ.com':1226,'nasa.gov':1227,'natemat.pl':1228,'aszdziennik.pl':1228,'innpoland.pl':1228,'dadhero.pl':1228,'mamadu.pl':1228,'nationalgeographic.com':1229,'nature.com':1230,'naturemade.com':1231,'nauka.rocks':1232,'navalnews.com':1233,'nba.com':1234,'nbc12.com':1235,'nbcphiladelphia.com':1236,'nbi.ku.dk':1237,'nec.com':1238,'needymeds.org':1239,'nejm.org':1240,'neonet.pl':1241,'neowin.net':1242,'nerdschalk.com':1243,'nerdwallet.com':1244,'nero.com':1245,'netlify.com':1246,'netzpolitik.org':1247,'newegg.com':1248,'news.mit.edu':1249,'news.mynavi.jp':1250,'news.yahoo.com':1251,'news.ycombinator.com':1252,'newyorker.com':1253,'nexojornal.com.br':1254,'nextdns.io':1255,'nextjs.org':1256,'ngrok.com':1257,'nicehash.com':1258,'niestatystyczny.pl':1259,'nirsoft.net':1260,'niser.ac.in':1261,'nixos.org':1262,'nlnet.nl':1263,'nnmclub.to':1264,'nnm-club.me':1264,'nokia.com':1265,'norton.com':1266,'nos.nl':1267,'notebooks.githubusercontent.com':1268,'notion.so':1269,'novartis.com':1270,'novelgames.com':1271,'novinky.cz':1272,'garaz.cz':1272,'seznamzpravy.cz':1272,'nowafarmacja.pl':1273,'nowemedium.pl':1274,'nperf.com':1275,'npmjs.com':1276,'nrc.nl':1277,'ns.nl':1278,'ntlite.com':1279,'nvidia.com':1280,'nvidia.in':1280,'nvidia.pl':1281,'nxos.org':1282,'nymag.com':1283,'nytimes.com':1284,'nzz.ch':1286,'o2.co.uk':1287,'oalevelsolutions.com':1288,'objectclub.jp':1289,'obserwatorgospodarczy.pl':1290,'oclc.org':1291,'odysee.com':1292,'oferteo.pl':1293,'office.com':1294,'oisd.nl':1295,'okonto.pl':1296,'okta.com':1297,'old.reddit.com':1298,'oleole.pl':1299,'olx.pl':1300,'omgubuntu.co.uk':1301,'omni.se':1302,'omnicalculator.com':1303,'omnivox.ca':1304,'one.uf.edu':1305,'onedrive.live.com':1306,'onelook.com':1307,'onet.pl':1308,'plejada.pl':1308,'online.noordhoff.nl':1309,'online.rbb.bg':1310,'onlinelibrary.wiley.com':1311,'onlinetrade.ru':1312,'onlineuniversities.com':1313,'onlyoffice.com':1314,'op.gg':1315,'openai.com':1316,'openanolis.org':1317,'openbenchmarking.org':1318,'opencollective.com':1319,'openebooks.net':1320,'openenglishbible.org':1321,'opengeofiction.net':1322,'openstreetmap.org':1322,'openoffice.org':1323,'openreview.net':1324,'openspeedtest.com':1325,'openstax.org':1326,'openvpn.net':1327,'openwall.com':1328,'openwrt.org':1329,'orf.at':1330,'osu.edu':1331,'ohio-state.edu':1331,'otomoto.pl':1332,'overleaf.com':1333,'overreacted.io':1334,'overwatchleague.com':1335,'ovhcloud.com':1336,'owncube.com':1337,'oxfordlearnersdictionaries.com':1338,'ozbargain.com.au':1339,'ozon.ru':1340,'p30download.com':1341,'pacjent.gov.pl':1342,'packages.ubuntu.com':1343,'palemoon.org':1344,'palshovon.wixsite.com':1345,'pan.baidu.com':1346,'panapply.org':1347,'panerabread.com':1348,'panthema.net':1349,'papaya.rocks':1350,'park-in.gr':1351,'partitionwizard.com':1352,'passport.baidu.com':1353,'passport.bilibili.com':1354,'paste.rs':1355,'patreon.com':1356,'patriotmemory.com':1357,'patuscada.bar':1358,'paulgraham.com':1359,'paypal-doladowania.pl':1360,'payu.com':1361,'pbs.org':1362,'pcdiga.com':1363,'pcgamer.com':1364,'pch24.pl':1365,'pcloud.com':1366,'pcpartpicker.com':1367,'peardeck.com':1368,'pennylane.ai':1369,'peonaviveu.blogspot.com':1370,'perfekcyjnawdomu.pl':1371,'petco.com':1372,'petri.com':1373,'pgatour.com':1374,'phonescoop.com':1375,'photofeeler.com':1376,'phys.nagoya-u.ac.jp':1377,'physics.gmu.edu':1378,'piazza.com':1379,'picknsave.com':1380,'picrew.me':1381,'pilot.wp.pl':1382,'ping.sx':1383,'pipewire.org':1384,'pipiwiki.com':1385,'pixabay.com':1386,'pixaful.com':1387,'pixilart.com':1388,'pixiv.net':1389,'pixlab.pl':1390,'pizzahut.com':1391,'pkg.go.dev':1392,'pkgs.org':1393,'pl.glosbe.com':1394,'planet.gnome.org':1395,'planetagracza.pl':1396,'planetminecraft.com':1397,'plannedparenthood.org':1398,'plantuml.com':1399,'play.google.com':[1400,1401,1402,1403,1404],'playstation.com':1405,'plotkibiznesowe.pl':1406,'plumbingforums.com':1407,'plus.google.com':1408,'pochta.ru':1409,'pocketbase.io':1410,'podium.com':1411,'poeditor.com':1412,'polar.com':1413,'poll.utm.utoronto.ca':1415,'polsatnews.pl':1416,'polskabiega.sport.pl':1417,'polskatimes.pl':1418,'polskiemarki.info':1419,'polymc.org':1420,'polymc.github.io':1420,'poradnikzdrowie.pl':1421,'porkbun.com':1422,'portal-portail.apps.cic.gc.ca':1423,'portal.edukacja.olsztyn.eu':1424,'portal.qiniu.com':1425,'portal.saltyfish.io':1426,'portswigger.net':1427,'positiveintelligence.com':1428,'postani-student.hr':1429,'postnauka.ru':1430,'poszukiwania.pl':1431,'potplayer.daum.net':1432,'pphosted.com':1433,'praca.pl':1434,'prajwalkoirala.com':1436,'pressgazette.co.uk':1437,'primatelabs.com':1438,'printables.com':1439,'privat24.ua':1440,'pro-run.pl':1441,'processon.com':1442,'procyclingstats.com':1443,'producthunt.com':1444,'profile.gigabyte.com':1445,'profiler.firefox.com':1446,'projectstream.it':1447,'pronote.toutatice.fr':1448,'pronto.io':1449,'prospectmagazine.co.uk':1450,'prostovpn.org':1451,'protect-eu.ismartlife.me':1452,'protocol.com':1453,'proton.me':1454,'protonvpn.com':1455,'provantage.com':1456,'proxmox.com':1457,'psemu.pl':1458,'psprices.com':1459,'psychonautwiki.org':1460,'publica.fraunhofer.de':1461,'publicwww.com':1462,'pulumi.com':1463,'pureinfotech.com':1464,'purerave.com':1465,'pushsquare.com':1466,'pyszne.pl':1467,'takeaway.com':1467,'thuisbezorgd.nl':1467,'pythonanywhere.com':1468,'pytorch.org':1469,'pz.gov.pl':1470,'q.utoronto.ca':1471,'qcc.com':1472,'quantrimang.com':1473,'qubes-os.org':1474,'quickbase.com':1475,'quirksmode.org':1476,'quizlet.com':1477,'quora.com':1478,'qwant.com':1479,'rachel53461.wordpress.com':1480,'racketboy.com':1481,'radar-opadow.pl':1482,'radareu.cz':1483,'radeonramdisk.com':1484,'radio17.pl':1485,'radiokolor.pl':1486,'railwaygazette.com':1487,'rain.thecomicseries.com':1488,'rakuten.com':1489,'rapidtables.com':1490,'raspberrypi.com':1491,'raspberrypi.org':1492,'rateyourmusic.com':1493,'rationalwiki.org':1494,'readme.io':1496,'readpaper.com':1497,'readthedocs.io':1498,'realmadridfin.net':1499,'realmicentral.com':1500,'redbubble.com':1501,'reddit.com':1503,'reddit.zendesk.com':1504,'redditstatus.com':1505,'redgamingtech.com':1506,'redhat.com':1507,'redis.io':1508,'redpenreviews.org':1509,'refactoring.guru':1510,'referentiemateriaalvo.noordhoff.nl':1511,'regex101.com':1512,'reheader.glitch.me':1513,'rei.com':1514,'relay.firefox.com':1515,'relive.cc':1516,'rememberthemilk.com':1517,'render.com':1518,'render.githubusercontent.com':1519,'replit.com':1520,'reproducible.archlinux.org':1521,'repubblica.it':1522,'resetera.com':1523,'resmigazete.gov.tr':1524,'respekt.cz':1525,'restaurantji.com':1526,'restoreprivacy.com':1527,'retracmirrors.com':1528,'reuters.com':1529,'rfi.fr':1530,'rg-adguard.net':1531,'richie-bendall.ml':1532,'richiebendallstatus.ml':1533,'riptutorial.com':1534,'roblox.com':1535,'rocksbox.com':1536,'rockylinux.org':1537,'rog.asus.com':1538,'ros.org':1539,'roscidus.com':1540,'roskomsvoboda.org':1541,'rostov.tele2.ru':1542,'rottentomatoes.com':1543,'royalbank.com':1544,'rozetka.com.ua':1545,'rp.pl':1546,'rpcs3.net':1547,'rpm.org':1548,'rpo.gov.pl':1549,'rt.ru':1550,'rte.ie':1551,'rtlnieuws.nl':1552,'rubenfixit.com':1553,'rubjo.github.io':1554,'rudeiczarne.pl':1555,'rumratings.com':1556,'runkit.com':1557,'runtothefinish.com':1558,'rynek-kolejowy.pl':1559,'rynekzdrowia.pl':1560,'rytmy.pl':1561,'sadanduseless.com':1562,'safeweb.norton.com':1563,'saladelcembalo.org':1564,'salsa.debian.org':1565,'samcodes.co.uk':1566,'sanomapro.fi':1568,'santander.pl':1569,'savannah.gnu.org':1570,'sbermegamarket.ru':1571,'science.fandom.com':1574,'science.org':1575,'sciencebasedmedicine.org':1576,'scipy-lectures.org':1577,'scmp.com':1578,'scpclassic.wikidot.com':1579,'scpexplained.wikidot.com':1579,'scpfoundation.net':1579,'scp-wiki.net':1579,'scp-wiki.wikidot.com':1579,'scp-wiki-cn.wikidot.com':1579,'scpwiki.com':1579,'scp-ru.wikidot.com':1579,'scratch-wiki.info':1580,'scratch.mit.edu':1581,'screenconnect.com':1582,'scribd.com':1583,'scribe.rip':1584,'scribe.nixnet.services':1584,'scribe.citizen4.eu':1584,'scribe.bus-hit.me':1584,'scribe.froth.zone':1584,'scribus.net':1585,'script.google.com':1586,'scroll.com':1587,'scroll.morele.net':1588,'se.pl':1589,'sea.playblackdesert.com':1590,'sealegacy.org':1591,'seamonkey-project.org':1592,'sec.sangfor.com':1593,'sec.sangfor.com.cn':1593,'secondlife.com':1594,'secure.ally.com':1595,'secure.fanboy.co.nz':1596,'secureage.com':1597,'security.org':1598,'segmentfault.com':1599,'sejm.gov.pl':1600,'sematext.com':1601,'sembr.org':1602,'seminka-chilli.cz':1603,'chilli-shop.sk':1603,'semmle.com':1604,'senscritique.com':1605,'sephora.com':1606,'server.pro':1607,'servercat.net':1608,'setupbits.com':1609,'sf-express.com':1610,'shaneco.com':1611,'share.dmhy.org':1612,'sharedrop.io':1613,'sharepoint.com':1614,'shazam.com':1615,'shells.com':1616,'shields.io':1617,'shimadzu.com':1618,'shipstation.com':1619,'shoecarnival.com':1620,'shop.dr-rath.com':1621,'shop.surfboard.com':1622,'shopify.com':1623,'shopify.dev':1623,'shoppy.gg':1624,'shorthistory.org':1625,'signal.org':1626,'signin.nianticlabs.com':1627,'signulous.com':1628,'simepar.br':1629,'similarweb.com':1630,'simplemachines.org':1631,'simply-v.de':1632,'singularlabs.com':1633,'sio2.staszic.waw.pl':1634,'sitecheck.sucuri.net':1635,'sklepbiegacza.pl':1636,'skycash.com':1637,'backpack.github.io':1638,'tianxun.cn':1638,'whoflies.com':1638,'slack.com':1639,'slackware.com':1640,'slader.com':1641,'slashnet.wordpress.com':1642,'slazag.pl':1643,'smap.uthm.edu.my':1644,'smcdsb.elearningontario.ca':1645,'smithsonianmag.com':1646,'smoglab.pl':1647,'smokin-guns.org':1648,'smtp2go.com':1649,'smzdm.com':1650,'snack.expo.io':1651,'snapcraft.io':1652,'snapeda.com':1653,'softorage.com':1654,'softpedia.com':1655,'soha.vn':1656,'soundcloud.com':1658,'souq.com':1659,'source.dot.net':1660,'sourceforge.net':1661,'sourcegraph.com':1662,'sourcing.hktdc.com':1663,'southparkstudios.com':1664,'southpark.de':1664,'soylent.com':1665,'space.bilibili.com':1666,'spaceweather.com':1667,'spanish.kwiziq.com':1668,'spboms.ru':1669,'spc.noaa.gov':1670,'spectrum.com':1671,'spectrum.ieee.org':1672,'spectrum.net':1673,'speed.cloudflare.com':1674,'speeddial2.com':1675,'spidersweb.pl':[1676,1677,1678],'sports.ru':1679,'sporza.be':1680,'spreadprivacy.com':1681,'sqlitebrowser.org':1682,'squareup.com':1683,'ssllabs.com':1684,'sso.qiniu.com':1685,'stablediffusionweb.com':1686,'stackage.org':1687,'stackexchange.com':1688,'askubuntu.com':1688,'mathoverflow.net':1688,'serverfault.com':1688,'stackapps.com':1688,'stackoverflow.com':1688,'superuser.com':1688,'standards.ieee.org':1689,'stardewvalleywiki.com':1690,'stardock.com':1691,'start64.com':1692,'startech.com.bd':1693,'startpage.com':1694,'stat.utels.ua':1695,'station-drivers.com':1696,'stats.stackexchange.com':1697,'status.aws.amazon.com':1698,'status.epicgames.com':1699,'status.npmjs.org':1700,'statusinvest.com.br':1701,'steamdeck.com':1702,'stevendoesstuffs.dev':1703,'stine.uni-hamburg.de':1704,'stm.info':1705,'stockbit.com':1706,'stolichki.ru':1707,'stooq.pl':1708,'store.playstation.com':1710,'store.ubi.com':1711,'storyteller.fit':1712,'storytellphys.wordpress.com':1713,'strava.com':1714,'streamable.com':1715,'student.ladok.se':1716,'studeo.fi':1717,'studio.youtube.com':1718,'studip.uni-passau.de':1719,'studyflix.de':1720,'studysmarter.de':1721,'subdivx.com':1722,'subiektywnieofinansach.pl':1723,'submarinecablemap.com':1724,'subscene.com':1725,'suckless.org':1726,'sugaroutfitters.com':1727,'suggestions.momentumdash.help':1728,'suite.smarttech-prod.com':1729,'suno.com.br':1730,'superbuy.com':1731,'support.apple.com':1732,'support.arkadium.com':1733,'support.discord.com':1734,'support.eset.com':1735,'support.mozilla.org':1736,'surfboard.com':1737,'surveymonkey.com':1738,'sverigesradio.se':1739,'svt.se':1740,'sw.kovidgoyal.net':1741,'swiatrolnika.info':1742,'system76.com':1743,'systemd.io':1744,'t-mobile.pl':1745,'t.bilibili.com':1746,'t.me':1747,'telegram.me':1747,'tableau.com':1748,'tablesgenerator.com':1749,'tabletochki.org':1750,'tails.boum.org':1751,'tailwindcss.com':1752,'take-a-screenshot.org':1753,'taobao.com':1754,'tapology.com':1755,'tarnogorski.info':1756,'tasks.google.com':1757,'tass.ru':1758,'tastoid.com':1759,'tcrf.net':1760,'teamtrees.org':1761,'techmaniak.pl':1762,'activemaniak.pl':1762,'agdmaniak.pl':1762,'appmaniak.pl':1762,'blogomaniak.pl':1762,'fotomaniak.pl':1762,'gizmaniak.pl':1762,'gsmmaniak.pl':1762,'luxmaniak.pl':1762,'mobimaniak.pl':1762,'rtvmaniak.pl':1762,'tabletmaniak.pl':1762,'technologyreview.com':1763,'techpowerup.com':1764,'techspot.com':1765,'telegeography.com':1766,'teleman.pl':1767,'telerik.com':1768,'teltarif.de':1769,'tenforums.com':1770,'tenor.com':1771,'terazwy.pl':1772,'terms.archlinux.org':1773,'terraform.io':1774,'terraria.wiki.gg':1775,'tesco.com':1776,'tesla.com':1777,'testudo.umd.edu':1778,'the-conjugation.com':1779,'the-race.com':1780,'the5to9.xyz':1781,'theatlantic.com':1782,'theatlas.com':1783,'thecamels.org':1784,'thecanadianencyclopedia.ca':1785,'thecode.media':1786,'thedailybeast.com':1787,'thefreedictionary.com':1788,'thefreelibrary.com':1789,'theguardian.com':1790,'theinformation.com':1791,'theins.ru':1792,'thejakartapost.com':1793,'thelancet.com':1794,'themoscowtimes.com':1795,'moscowtimes.ru':1795,'themoviedb.org':1796,'thenounproject.com':1797,'theoatmeal.com':1798,'theonion.com':1799,'thepaper.cn':1800,'thepiratebay.org':1801,'thereader.mitpress.mit.edu':1802,'theverge.com':1804,'thewindowsclub.com':1805,'thompsonstein.com':1806,'thriftbooks.com':1807,'thronemaster.net':1808,'thunderbird.net':1809,'ti.com':1810,'tianocore.org':1811,'tieba.baidu.com':1812,'time.com':1813,'tinder.com':1814,'titantv.com':1815,'tizen.org':1816,'tjournal.ru':1817,'tns-e.ru':1818,'to-do.live.com':1819,'todoist.com':1820,'tokfm.pl':1821,'tonsky.me':1822,'torguard.net':1823,'tosdr.org':1824,'totylkoteoria.pl':1825,'toutatice.fr':1826,'towersemi.com':1827,'towhee.io':1828,'town-of-salem.fandom.com':1829,'trac.ffmpeg.org':1830,'tracfone.com':1831,'track.toggl.com':1832,'trailhead.salesforce.com':1833,'transifex.com':1834,'translifeline.org':1841,'transport.orgp.spb.ru':1842,'transum.org':1843,'trello.com':1844,'trendmicro.com':1845,'trezor.io':1846,'tribunemag.co.uk':1847,'trip101.com':1848,'trojmiasto.pl':1849,'truestory.pl':1850,'truity.com':1851,'tug.org':1852,'tutorialspoint.com':1853,'tuwroclaw.com':1854,'tuxcare.com':1855,'tuxedocomputers.com':1856,'tvland.com':1858,'tvn24.pl':1859,'tvrain.ru':1860,'tvtropes.org':1861,'tweakers.net':1862,'twit.tv':1863,'twitch.tv':1864,'twitter.com':1865,'twosigma.com':1866,'tygodnikkrag.pl':1867,'typescriptlang.org':1868,'ubereats.com':1869,'ubisoft.com':1870,'ubuntu.com':1871,'ubuntubudgie.org':1872,'udemy.com':1873,'ultimate-guitar.com':1874,'umweltinstitut.org':1875,'un.org':1876,'understandingwar.org':1877,'uokik.gov.pl':1878,'uol.com.br':1879,'uottawa.brightspace.com':1880,'ups.com':1881,'uptimerobot.com':1882,'upwork.com':1883,'urbandecay.com':1884,'urbandictionary.com':1885,'urpredditodicittadinanza.lavoro.gov.it':1886,'usbank.com':1887,'userstyles.world':1888,'uspassporthelpguide.com':1889,'usps.com':1890,'uteka.ru':1891,'v.qq.com':1892,'v2ex.com':1893,'vaccines.gov':1894,'vacunas.gov':1894,'vaccines.procon.org':1895,'valgrind.org':1896,'vandale.nl':1897,'vanguard.com':1898,'vbulletin.com':1899,'vc.ru':1900,'vcalc.com':1901,'vcb-s.com':1902,'vechevoikolokol.ru':1903,'vendors.paddle.com':1904,'venture.com':1905,'ventusky.com':1906,'vercel.com':1907,'verstka.media':1908,'versus.com':1909,'vfsglobal.cn':1910,'vg24.pl':1911,'vice.com':1912,'videolan.org':1913,'videoman.gr':1914,'vimeo.com':1915,'virtualbox.org':1916,'virustotal.com':1917,'vitaexpress.ru':1918,'vivaldi.com':1919,'vivaldi.net':1920,'vjudge.net':1921,'vk.com':1922,'vmware.com':1923,'vnexpress.net':1924,'vod.tvp.pl':1925,'votecompass.mzalendo.com':1926,'vox.com':1927,'vpn.getadblock.com':1928,'vrt.be':1929,'vshojo.com':1930,'vtimes.io':1931,'vultr.com':1932,'w.atwiki.jp':1933,'w3.org':1934,'wacom.com':1935,'wakamaifondue.com':1936,'walbrzych24.com':1937,'wallet.myalgo.com':1938,'walmart.com':1939,'wanikani.com':1940,'warframe.com':1941,'wasd.tv':1942,'washingtonpost.com':1943,'waze.com':1944,'weather.com':1945,'weather.com.cn':1946,'web.archive.org':1947,'web.dev':1948,'web.microsoftstream.com':1949,'web.telegram.org':1950,'web.whatsapp.com':1951,'webaim.org':1952,'webassign.net':1953,'webbrowsertools.com':1954,'webkitgtk.org':1955,'weblate.org':1956,'webmd.com':1957,'webpagetest.org':1958,'webroot.com':1959,'webtoons.com':1960,'wego.here.com':1961,'weightwatchers.com':1962,'wellandgood.com':1963,'wellrx.com':1964,'wenxuecity.com':1965,'wepe.com.cn':1966,'wesbos.com':1967,'westerndigital.com':1968,'westlaw.com':1969,'what-if.xkcd.com':1970,'whatsapp.com':1971,'whitemad.pl':1972,'who.int':1973,'whois.arin.net':1974,'whois.com':1975,'wiadomoscihandlowe.pl':1976,'wielkopolskiebilety.pl':1977,'wiemy.to':1978,'wiesci24.pl':1979,'wiki.facepunch.com':1980,'wiki.mozilla.org':1981,'wiki.teamfortress.com':1982,'wiki.ubuntuusers.de':1983,'wiki.unity3d.com':1984,'wikibooks.org':1985,'wikidata.org':1986,'wikimapia.org':1987,'wikimedia.de':1988,'wikimedia.org':1989,'wikimediafoundation.org':1990,'wikimediastatus.net':1991,'wikinews.org':1992,'wikiquote.org':1992,'wikipedia.org':1993,'wikiless.org':1993,'wikisource.org':1994,'wikiversity.org':1994,'wikivoyage.org':1994,'wikitech.wikimedia.org':1995,'wikiwand.com':1996,'wiktionary.org':1997,'wildberries.ru':1998,'willthompson.co.uk':1999,'windows.php.net':2000,'windscribe.com':2001,'winzip.com':2002,'wired.co.uk':2003,'wired.com':2003,'wireshark.org':2004,'wirtualnemedia.pl':2005,'wmar2news.com':2006,'word-view.officeapps.live.com':2007,'wordnik.com':2008,'wordpress.com':2009,'workona.com':2010,'worldcubeassociation.org':2011,'worldometers.info':2012,'worldtimebuddy.com':2013,'wowturkey.com':2014,'wpshout.com':2015,'writefreely.org':2016,'wszystkoconajwazniejsze.pl':2017,'wuffs.org':2018,'wunderground.com':2019,'wvpublic.org':2020,'www.123cha.com':2021,'www.adjust.com':2022,'www.androidauthority.com':2023,'www.bilibili.com':2024,'www.bromite.org':2025,'www.encyclopedia-titanica.org':2027,'www.federica.unina.it':2028,'www.flickr.com':2029,'www.freepascal.org':2030,'www.freeriderhd.com':2031,'www.gamer.com.tw':2032,'www.hapo.org':2034,'www.inu-manga.com':2035,'www.jetbrains.com':2036,'www.jiqizhixin.com':2037,'www.khirevich.com':2038,'www.linuxcollections.com':2039,'www.liqpay.ua':2040,'www.mayoclinic.org':2041,'www.menti.com':2042,'www.minecraft.net':2043,'www.mozilla.org':2044,'www.msn.cn':2045,'www.oschina.net':2046,'www.phoronix.com':2047,'www.photopea.com':2048,'www.physics.utoronto.ca':2049,'www.pixivision.net':2050,'www.pravda.com.ua':2051,'www.psytec.co.jp':2052,'www.qt.io':2053,'www.rbc.ua':2054,'www.realtek.com':2055,'www.scien.cx':2056,'www.searchenginejournal.com':2057,'www.sentienceinstitute.org':2058,'www.soepub.com':2059,'www.soepub.net':2059,'www.songsterr.com':2060,'www.sport5.co.il':2061,'www.statshunters.com':2062,'www.stern.de':2063,'www.storm.mg':2064,'www.tandfonline.com':2065,'www.thisoldhouse.com':2066,'www.thivien.net':2067,'www.tiktok.com':2068,'www.tinkoff.ru':2069,'www.tumblr.com':2070,'www.typingclub.com':2071,'www.w3schools.com':2072,'www.wikihow.com':2073,'www.windy.com':2074,'wx.qq.com':2075,'wx2.qq.com':2075,'wxwidgets.org':2076,'wyborcza.pl':2077,'wyborcza.biz':2077,'wysokieobcasy.pl':2078,'x-kom.pl':2079,'xcite.com':2080,'xda-developers.com':2081,'xfree86.org':2082,'xiph.org':2083,'y.qq.com':2084,'yadi.sk':2085,'yamicsoft.com':2086,'yandex.ru':[2091,2092],'yelp.com':2093,'yeniakit.com.tr':2094,'yettel.rs':2095,'yle.fi':2096,'yougetsignal.com':2097,'youla.ru':2098,'youmath.it':2099,'youtube.com':2100,'yscec.yonsei.ac.kr':2101,'yuque.com':2102,'zacznijzyc.net':2103,'zadania.info':2104,'zaid-ajaj.github.io':2105,'zdic.net':2106,'zdw.krakow.pl':2107,'zendesk.com':2108,'zenn.dev':2109,'zeptovm.com':2110,'zerossl.com':2111,'zfsbootmenu.org':2112,'zhihu.com':2113,'zhixue.com':2114,'zippyshare.com':2115,'znanium.com':2116,'zorin.com':2117,'zrzutka.pl':2118,'zybooks.com':2119},
        // eslint-disable-next-line max-len
        'domainPatterns':{'*':0,'*.bitrix24.ru':1,'*.service-now.com':2,'2gis.*':11,'aliexpress.*':69,'allestoringen.*':75,'downdetector.*':75,'downdetector.*.*':75,'xn--allestrungen-9ib.*':75,'amazon.*':87,'amazon.*.*':87,'bbb.*':193,'blablacar.*':226,'blablacar.*.*':226,'books.google.*':250,'canvas.*.edu':300,'*.azuredatabricks.net':358,'confluence.*':400,'console-openshift-console.*':402,'disk.yandex.*':511,'docviewer.yandex.*':511,'disney.*':512,'dominos.*':540,'fairtradeoriginal.*':630,'geizhals.*':741,'get.google.*':746,'get.google.*.*':746,'github.*.*':758,'gitlab.*.*':761,'gitlab.*.*.*':761,'google.*':[783,784],'google.*.*':784,'hmong.*':836,'*.hp.com':843,'ikea.*':868,'ilyabirman.*':871,'':873,'jira.*.com':929,'jira.*.services':930,'jumia.*':944,'jumia.*.*':944,'market.yandex.*':1106,'mitx.*':1157,'music.amazon.*':1197,'nzbget.*':1285,'polarion*':1414,'practicum.yandex.*':1435,'lieferando.*':1467,'justeat.*':1467,'just-eat.*':1467,'read.amazon.*':1495,'lire.amazon.*':1495,'redcross.*':1502,'samsung.*':1567,'scholar.google.*':1572,'scholar.google.*.*':1572,'sci-hub.*':1573,'skyscanner.*':1638,'skyscanner.*.*':1638,'sony.*':1657,'store.google.*':1709,'theregister.*':1803,'theregister.*.*':1803,'translate.google.*':1835,'translate.google.*.*':1835,'translate.yandex.*':[1836,1837,1838,1839,1840],'tv.yandex.*':1857,'www.ebay.*':2026,'www.ebay.*.*':2026,'www.google.*':2033,'www.google.*.*':2033,'yandex.*':[2087,2088,2089,2090],'*.youmath.it':2099},
      };
    }
    async loadConfig({key, name, local, localURL, remoteURL}) {
      let $config;
      const loadLocal = async () => await readText({url: localURL});
      const configRaw = readLocalStorage(this.raw);
      if(configRaw && configRaw[key]){
        $config = configRaw[key]
        this.raw[key] = $config
        return $config;
      }else{
        if (local) {
          $config = await loadLocal();
        } else {
          try {
            $config = await readText({
              url: `${remoteURL}?nocache=${Date.now()}`,
              timeout: REMOTE_TIMEOUT_MS
            });
          } catch (err) {
            console.error(`${name} remote load error`, err);
            $config = await loadLocal();
          }
          this.raw[key] = $config
          writeLocalStorage(this.raw);
        }
      }
      return $config;
    }
    async loadColorSchemes({local}) {
      // let stayImg = browser.runtime.getURL("images/icon-256.png");
      const config = await this.loadConfig({
        key: 'colorSchemes',
        name: 'Color Schemes',
        local,
        localURL: browser.runtime.getURL(CONFIG_URLs.colorSchemes.local),
        remoteURL: CONFIG_URLs.colorSchemes.remote
      });
      this.raw.colorSchemes = config;
      this.handleColorSchemes();
    }
    async loadDarkSites({local}) {
      const sites = await this.loadConfig({
        key: 'darkSites',
        name: 'Dark Sites',
        local,
        localURL:browser.runtime.getURL(CONFIG_URLs.darkSites.local),
        remoteURL: CONFIG_URLs.darkSites.remote
      });
      this.raw.darkSites = sites;
      this.handleDarkSites();
    }
    async loadDynamicThemeFixes({local}) {
      const fixes = await this.loadConfig({
        key: 'dynamicThemeFixes',
        name: 'Dynamic Theme Fixes',
        local,
        localURL: browser.runtime.getURL(CONFIG_URLs.dynamicThemeFixes.local),
        remoteURL: CONFIG_URLs.dynamicThemeFixes.remote
      });
      //   console.log("loadDynamicThemeFixes-----",fixes.length, fixes);
      this.raw.dynamicThemeFixes = fixes;
      this.handleDynamicThemeFixes();
    }
    async loadInversionFixes({local}) {
      const fixes = await this.loadConfig({
        key: 'inversionFixes',
        name: 'Inversion Fixes',
        local,
        localURL: browser.runtime.getURL(CONFIG_URLs.inversionFixes.local),
        remoteURL: CONFIG_URLs.inversionFixes.remote
      });
      this.raw.inversionFixes = fixes;
      this.handleInversionFixes();
    }
    async loadStaticThemes({local}) {
      const themes = await this.loadConfig({
        key: 'staticThemes',
        name: 'Static Themes',
        local,
        localURL:browser.runtime.getURL(CONFIG_URLs.staticThemes.local),
        remoteURL: CONFIG_URLs.staticThemes.remote
      });
      this.raw.staticThemes = themes;
      this.handleStaticThemes();
    }
    async startLoadConfig(config) {
      if(checkDomainHasConfig(window.location.href, this.DYNAMIC_THEME_FIXES_INDEX)){
        await Promise.all([
          // this.loadColorSchemes(config),
          // this.loadDarkSites(config),
          this.loadDynamicThemeFixes(config),
          // this.loadInversionFixes(config),
          // this.loadStaticThemes(config)
        ]).catch((err) => console.error('Fatality', err));
      }
    }
    handleColorSchemes() {
      const $config = this.raw.colorSchemes;
      const {result, error} = ParseColorSchemeConfig($config);
      if (error) {
        this.COLOR_SCHEMES_RAW = DEFAULT_COLORSCHEME;
        return;
      }
      this.COLOR_SCHEMES_RAW = result;
    }
    handleDarkSites() {
      const $sites = this.overrides.darkSites || this.raw.darkSites;
      this.DARK_SITES = parseArray($sites);
    }
    handleDynamicThemeFixes() {
      const $fixes = this.overrides.dynamicThemeFixes || this.raw.dynamicThemeFixes;
      this.DYNAMIC_THEME_FIXES_INDEX = indexSitesFixesConfig($fixes);
      // console.log('this.DYNAMIC_THEME_FIXES_INDEX-----', JSON.stringify(this.DYNAMIC_THEME_FIXES_INDEX));
      this.DYNAMIC_THEME_FIXES_RAW = $fixes;
    }
    handleInversionFixes() {
      const $fixes = this.overrides.inversionFixes || this.raw.inversionFixes;
      this.INVERSION_FIXES_INDEX = indexSitesFixesConfig($fixes);
      this.INVERSION_FIXES_RAW = $fixes;
    }
    handleStaticThemes() {
      const $themes = this.overrides.staticThemes || this.raw.staticThemes;
      this.STATIC_THEMES_INDEX = indexSitesFixesConfig($themes);
      this.STATIC_THEMES_RAW = $themes;
    }
  }

  function encodeOffsets(offsets) {
    return offsets
      .map(([offset, length]) => {
        const stringOffset = offset.toString(36);
        const stringLength = length.toString(36);
        return (
          '0'.repeat(4 - stringOffset.length) +
                    stringOffset +
                    '0'.repeat(3 - stringLength.length) +
                    stringLength
        );
      })
      .join('');
  }
  function decodeOffset(offsets, index) {
    const base = (4 + 3) * index;
    const offset = parseInt(offsets.substring(base + 0, base + 4), 36);
    const length = parseInt(offsets.substring(base + 4, base + 4 + 3), 36);
    return [offset, offset + length];
  }
  function indexSitesFixesConfig(text) {
    const domains = {};
    const domainPatterns = {};
    const offsets = [];
    function processBlock(recordStart, recordEnd, index) {
      const block = text.substring(recordStart, recordEnd);
      const lines = block.split('\n');
      const commandIndices = [];
      lines.forEach((ln, i) => {
        if (ln.match(/^[A-Z]+(\s[A-Z]+){0,2}$/)) {
          commandIndices.push(i);
        }
      });
      if (commandIndices.length === 0) {
        return;
      }
      const urls = parseArray(
        lines.slice(0, commandIndices[0]).join('\n')
      );
      for (const url of urls) {
        const domain = getDomain(url);
        if (isFullyQualifiedDomain(domain)) {
          if (!domains[domain]) {
            domains[domain] = index;
          } else if (
            typeof domains[domain] === 'number' &&
                        domains[domain] !== index
          ) {
            domains[domain] = [domains[domain], index];
          } else if (
            typeof domains[domain] === 'object' &&
                        !domains[domain].includes(index)
          ) {
            domains[domain].push(index);
          }
          continue;
        }
        if (!domainPatterns[domain]) {
          domainPatterns[domain] = index;
        } else if (
          typeof domainPatterns[domain] === 'number' &&
                    domainPatterns[domain] !== index
        ) {
          domainPatterns[domain] = [domainPatterns[domain], index];
        } else if (
          typeof domainPatterns[domain] === 'object' &&
                    !domainPatterns[domain].includes(index)
        ) {
          domainPatterns[domain].push(index);
        }
      }
      offsets.push([recordStart, recordEnd - recordStart]);
    }
    let recordStart = 0;
    const delimiterRegex = /^\s*={2,}\s*$/gm;
    let delimiter;
    let count = 0;
    while ((delimiter = delimiterRegex.exec(text))) {
      const nextDelimiterStart = delimiter.index;
      const nextDelimiterEnd = delimiter.index + delimiter[0].length;
      processBlock(recordStart, nextDelimiterStart, count);
      recordStart = nextDelimiterEnd;
      count++;
    }
    processBlock(recordStart, text.length, count);
    return {
      offsets: encodeOffsets(offsets),
      domains,
      domainPatterns,
      cache: {}
    };
  }
  async function readLocalStorage(defaults) {
    return new Promise((resolve) => {
      browser.storage.local.get(defaults, (local) => {
        // console.log("readLocalStorage--------------====defaults=",defaults, ",-----local=======", local);
        if (browser.runtime.lastError) {
          console.error(browser.runtime.lastError.message);
          resolve(defaults);
          return;
        }
        resolve(local);
      });
    });
  }
  async function writeLocalStorage(values) {
    return new Promise((resolve) => {
      browser.storage.local.set(values, () => {
        resolve();
      });
    });
  }
  async function readSyncStorage(defaults) {
    return new Promise((resolve) => {
      browser.storage.sync.get(null, (sync) => {
        if (browser.runtime.lastError) {
          console.error(browser.runtime.lastError.message);
          resolve(null);
          return;
        }
        for (const key in sync) {
          if (!sync[key]) {
            continue;
          }
          const metaKeysCount = sync[key].__meta_split_count;
          if (!metaKeysCount) {
            continue;
          }
          let string = '';
          for (let i = 0; i < metaKeysCount; i++) {
            string += sync[`${key}_${i.toString(36)}`];
            delete sync[`${key}_${i.toString(36)}`];
          }
          try {
            sync[key] = JSON.parse(string);
          } catch (error) {
            console.error(
              `sync[${key}]: Could not parse record from sync storage: ${string}`
            );
            resolve(null);
            return;
          }
        }
        sync = {
          ...defaults,
          ...sync
        };
        resolve(sync);
      });
    });
  }
  function prepareSyncStorage(values) {
    for (const key in values) {
      const value = values[key];
      // console.log(value,",values---------", values)
      if( !value || typeof value == 'undefined' ){
        continue;
      }
      const string = value && typeof value !== 'undefined' ? JSON.stringify(value) : '';
      const totalLength = string.length + key.length;
      if (totalLength > browser.storage.sync.QUOTA_BYTES_PER_ITEM) {
        const maxLength = browser.storage.sync.QUOTA_BYTES_PER_ITEM - key.length - 1 - 2;
        const minimalKeysNeeded = Math.ceil(string.length / maxLength);
        for (let i = 0; i < minimalKeysNeeded; i++) {
          values[`${key}_${i.toString(36)}`] = string.substring(
            i * maxLength,
            (i + 1) * maxLength
          );
        }
        values[key] = {
          __meta_split_count: minimalKeysNeeded
        };
      }
    }
    return values;
  }
  async function writeSyncStorage(values) {
    return new Promise((resolve, reject) => {
      const packaged = prepareSyncStorage(values);
      browser.storage.sync.set(packaged, () => {
        if (browser.runtime.lastError) {
          reject(browser.runtime.lastError);
          return;
        }
        resolve();
      });
    });
  }
  function getDurationInMinutes(time) {
    return getDuration(time) / 1000 / 60;
  }
  function getSunsetSunriseUTCTime(latitude, longitude, date) {
    const dec31 = Date.UTC(date.getUTCFullYear(), 0, 0, 0, 0, 0, 0);
    const oneDay = getDuration({days: 1});
    const dayOfYear = Math.floor((date.getTime() - dec31) / oneDay);
    const zenith = 90.83333333333333;
    const D2R = Math.PI / 180;
    const R2D = 180 / Math.PI;
    const lnHour = longitude / 15;
    function getTime(isSunrise) {
      const t = dayOfYear + ((isSunrise ? 6 : 18) - lnHour) / 24;
      const M = 0.9856 * t - 3.289;
      let L =
                M +
                1.916 * Math.sin(M * D2R) +
                0.02 * Math.sin(2 * M * D2R) +
                282.634;
      if (L > 360) {
        L -= 360;
      } else if (L < 0) {
        L += 360;
      }
      let RA = R2D * Math.atan(0.91764 * Math.tan(L * D2R));
      if (RA > 360) {
        RA -= 360;
      } else if (RA < 0) {
        RA += 360;
      }
      const Lquadrant = Math.floor(L / 90) * 90;
      const RAquadrant = Math.floor(RA / 90) * 90;
      RA += Lquadrant - RAquadrant;
      RA /= 15;
      const sinDec = 0.39782 * Math.sin(L * D2R);
      const cosDec = Math.cos(Math.asin(sinDec));
      const cosH =
                (Math.cos(zenith * D2R) - sinDec * Math.sin(latitude * D2R)) /
                (cosDec * Math.cos(latitude * D2R));
      if (cosH > 1) {
        return {
          alwaysDay: false,
          alwaysNight: true,
          time: 0
        };
      } else if (cosH < -1) {
        return {
          alwaysDay: true,
          alwaysNight: false,
          time: 0
        };
      }
      const H =
                (isSunrise
                  ? 360 - R2D * Math.acos(cosH)
                  : R2D * Math.acos(cosH)) / 15;
      const T = H + RA - 0.06571 * t - 6.622;
      let UT = T - lnHour;
      if (UT > 24) {
        UT -= 24;
      } else if (UT < 0) {
        UT += 24;
      }
      return {
        alwaysDay: false,
        alwaysNight: false,
        time: Math.round(UT * getDuration({hours: 1}))
      };
    }
    const sunriseTime = getTime(true);
    const sunsetTime = getTime(false);
    if (sunriseTime.alwaysDay || sunsetTime.alwaysDay) {
      return {
        alwaysDay: true
      };
    } else if (sunriseTime.alwaysNight || sunsetTime.alwaysNight) {
      return {
        alwaysNight: true
      };
    }
    return {
      sunriseTime: sunriseTime.time,
      sunsetTime: sunsetTime.time
    };
  }
  function isInTimeIntervalUTC(time0, time1, timestamp) {
    if (time1 < time0) {
      return timestamp <= time1 || time0 <= timestamp;
    }
    return time0 < timestamp && timestamp < time1;
  }
  function isNightAtLocation(latitude, longitude, date = new Date()) {
    const time = getSunsetSunriseUTCTime(latitude, longitude, date);
    if (time.alwaysDay) {
      return false;
    } else if (time.alwaysNight) {
      return true;
    }
    const sunriseTime = time.sunriseTime;
    const sunsetTime = time.sunsetTime;
    const currentTime =
            date.getUTCHours() * getDuration({hours: 1}) +
            date.getUTCMinutes() * getDuration({minutes: 1}) +
            date.getUTCSeconds() * getDuration({seconds: 1}) +
            date.getUTCMilliseconds();
    return isInTimeIntervalUTC(sunsetTime, sunriseTime, currentTime);
  }
  function nextTimeChangeAtLocation(latitude, longitude, date = new Date()) {
    const time = getSunsetSunriseUTCTime(latitude, longitude, date);
    if (time.alwaysDay) {
      return date.getTime() + getDuration({days: 1});
    } else if (time.alwaysNight) {
      return date.getTime() + getDuration({days: 1});
    }
    const [firstTimeOnDay, lastTimeOnDay] =
            time.sunriseTime < time.sunsetTime
              ? [time.sunriseTime, time.sunsetTime]
              : [time.sunsetTime, time.sunriseTime];
    const currentTime =
            date.getUTCHours() * getDuration({hours: 1}) +
            date.getUTCMinutes() * getDuration({minutes: 1}) +
            date.getUTCSeconds() * getDuration({seconds: 1}) +
            date.getUTCMilliseconds();
    if (currentTime <= firstTimeOnDay) {
      return Date.UTC(
        date.getUTCFullYear(),
        date.getUTCMonth(),
        date.getUTCDate(),
        0,
        0,
        0,
        firstTimeOnDay
      );
    }
    if (currentTime <= lastTimeOnDay) {
      return Date.UTC(
        date.getUTCFullYear(),
        date.getUTCMonth(),
        date.getUTCDate(),
        0,
        0,
        0,
        lastTimeOnDay
      );
    }
    return Date.UTC(
      date.getUTCFullYear(),
      date.getUTCMonth(),
      date.getUTCDate() + 1,
      0,
      0,
      0,
      firstTimeOnDay
    );
  }
  function parse24HTime(time) {
    return time.split(':').map((x) => parseInt(x));
  }
  /**
     *
     * @param {array} time1
     * @param {array} time2
     * @returns 0:时间一样，-1：同一天时间内，1：隔天区间
     */
  function compareTime(time1, time2) {
    if (time1[0] === time2[0] && time1[1] === time2[1]) {
      return 0;
    }
    if (
      time1[0] < time2[0] ||
            (time1[0] === time2[0] && time1[1] < time2[1])
    ) {
      return -1;
    }
    return 1;
  }
  function nextTimeInterval(time0, time1, date = new Date()) {
    const a = parse24HTime(time0);
    const b = parse24HTime(time1);
    const t = [date.getHours(), date.getMinutes()];
    if (compareTime(a, b) > 0) {
      return nextTimeInterval(time1, time0, date);
    }
    if (compareTime(a, b) === 0) {
      return null;
    }
    if (compareTime(t, a) < 0) {
      date.setHours(a[0]);
      date.setMinutes(a[1]);
      date.setSeconds(0);
      date.setMilliseconds(0);
      return date.getTime();
    }
    if (compareTime(t, b) < 0) {
      date.setHours(b[0]);
      date.setMinutes(b[1]);
      date.setSeconds(0);
      date.setMilliseconds(0);
      return date.getTime();
    }
    return new Date(
      date.getFullYear(),
      date.getMonth(),
      date.getDate() + 1,
      a[0],
      a[1]
    ).getTime();
  }
  /**
     * 判断预设自动时间是否到点
     * @param {date} time0  startTime
     * @param {date} time1  endTime
     * @param {date} date   currentTime
     * @returns true:到达预设时间范围内，false:不在预设时间范围呢
     */
  function isInTimeIntervalLocal(time0, time1, date = new Date()) {
    const a = parse24HTime(time0);
    const b = parse24HTime(time1);
    const t = [date.getHours(), date.getMinutes()];
    // 正常区间内, 是否到了设置时间范围
    if (compareTime(a, b) > 0) {
      // 判断当前时间是否已经到了设置时间
      return compareTime(a, t) <= 0 || compareTime(t, b) < 0;
    }
    return compareTime(a, t) <= 0 && compareTime(t, b) < 0;
  }
  const matchesMediaQuery = (query) => {
    return Boolean(window.matchMedia(query).matches);
  };
  const matchesDarkTheme = () => matchesMediaQuery('(prefers-color-scheme: dark)');
  const matchesLightTheme = () => matchesMediaQuery('(prefers-color-scheme: light)');
  const isColorSchemeSupported = matchesDarkTheme() || matchesLightTheme();
  function isSystemDarkModeEnabled() {
    if (!isColorSchemeSupported) {
      return false;
    }
    return matchesDarkTheme();
  }
  function createValidator() {
    const errors = [];
    function validateProperty(obj, key, validator, fallback) {
      if (!obj.hasOwnProperty.call(key) || validator(obj[key])) {
        return;
      }
      errors.push(
        `Unexpected value for "${key}": ${JSON.stringify(obj[key])}`
      );
      obj[key] = fallback[key];
    }
    function validateArray(obj, key, validator) {
      if (!obj.hasOwnProperty.call(key)) {
        return;
      }
      const wrongValues = new Set();
      const arr = obj[key];
      for (let i = 0; i < arr.length; i++) {
        if (!validator(arr[i])) {
          wrongValues.add(arr[i]);
          arr.splice(i, 1);
          i--;
        }
      }
      if (wrongValues.size > 0) {
        errors.push(
          `Array "${key}" has wrong values: ${Array.from(wrongValues)
            .map((v) => JSON.stringify(v))
            .join('; ')}`
        );
      }
    }
    return {validateProperty, validateArray, errors};
  }
  function isPlainObject(x) {
    return typeof x === 'object' && x != null && !Array.isArray(x);
  }
  function isBoolean(x) {
    return typeof x === 'boolean';
  }
  function isArray(x) {
    return Array.isArray(x);
  }
  function isString(x) {
    return typeof x === 'string';
  }
  function isNonEmptyString(x) {
    return x && isString(x);
  }
  function isNonEmptyArrayOfNonEmptyStrings(x) {
    return (
      Array.isArray(x) &&
            x.length > 0 &&
            x.every((s) => isNonEmptyString(s))
    );
  }
  function isRegExpMatch(regexp) {
    return (x) => {
      return isString(x) && x.match(regexp) != null;
    };
  }
  const isTime = isRegExpMatch(
    /^((0?[0-9])|(1[0-9])|(2[0-3])):([0-5][0-9])$/
  );
  function isNumber(x) {
    return typeof x === 'number' && !isNaN(x);
  }
  function isNumberBetween(min, max) {
    return (x) => {
      return isNumber(x) && x >= min && x <= max;
    };
  }
  function isOneOf(...values) {
    return (x) => values.includes(x);
  }
  function hasRequiredProperties(obj, keys) {
    return keys.every((key) => obj.hasOwnProperty.call(key));
  }
  function validateSettings(settings) {
    if (!isPlainObject(settings)) {
      return {
        errors: ['Settings are not a plain object'],
        settings: DEFAULT_SETTINGS
      };
    }
    const {validateProperty, validateArray, errors} = createValidator();
    const isValidPresetTheme = (theme) => {
      if (!isPlainObject(theme)) {
        return false;
      }
      const {errors: themeErrors} = validateTheme(theme);
      return themeErrors.length === 0;
    };
    validateProperty(settings, 'toggleStatus', isString, DEFAULT_SETTINGS);
    validateProperty(settings, 'currentTabUrl', isString, DEFAULT_SETTINGS);
    validateProperty(settings, 'frameUrl', isString, DEFAULT_SETTINGS);
    validateProperty(settings, 'isStayAround', isString, DEFAULT_SETTINGS);
    validateProperty(settings, 'stay_theme', isPlainObject, DEFAULT_SETTINGS);
    const {errors: themeErrors} = validateTheme(settings.stay_theme);
    errors.push(...themeErrors);
    validateProperty(settings, 'stay_presets', isArray, DEFAULT_SETTINGS);
    validateArray(settings, 'stay_presets', (preset) => {
      const presetValidator = createValidator();
      if (
        !(
          isPlainObject(preset) &&
                    hasRequiredProperties(preset, [
                      'id',
                      'name',
                      'urls',
                      'theme'
                    ])
        )
      ) {
        return false;
      }
      presetValidator.validateProperty(
        preset,
        'id',
        isNonEmptyString,
        preset
      );
      presetValidator.validateProperty(
        preset,
        'name',
        isNonEmptyString,
        preset
      );
      presetValidator.validateProperty(
        preset,
        'urls',
        isNonEmptyArrayOfNonEmptyStrings,
        preset
      );
      presetValidator.validateProperty(
        preset,
        'theme',
        isValidPresetTheme,
        preset
      );
      return presetValidator.errors.length === 0;
    });
    validateProperty(settings, 'stay_customThemes', isArray, DEFAULT_SETTINGS);
    validateArray(settings, 'stay_customThemes', (custom) => {
      if (
        !(
          isPlainObject(custom) &&
                    hasRequiredProperties(custom, ['url', 'theme'])
        )
      ) {
        return false;
      }
      const presetValidator = createValidator();
      presetValidator.validateProperty(
        custom,
        'url',
        isNonEmptyArrayOfNonEmptyStrings,
        custom
      );
      presetValidator.validateProperty(
        custom,
        'stay_theme',
        isValidPresetTheme,
        custom
      );
      return presetValidator.errors.length === 0;
    });

    validateProperty(settings, 'stay_syncSettings', isBoolean, DEFAULT_SETTINGS);
    validateProperty(settings, 'siteListDisabled', isArray, DEFAULT_SETTINGS);
    validateArray(settings, 'siteListDisabled', isNonEmptyString);

    validateProperty(
      settings,
      'stay_automation',
      isOneOf('', 'time', 'system', 'location'),
      DEFAULT_SETTINGS
    );
    validateProperty(
      settings,
      'stay_automationBehaviour',
      isOneOf('OnOff', 'Scheme'),
      DEFAULT_SETTINGS
    );
    validateProperty(
      settings,
      'auto_time',
      (time) => {
        if (!isPlainObject(time)) {
          return false;
        }
        const timeValidator = createValidator();
        timeValidator.validateProperty(
          time,
          'activation',
          isTime,
          time
        );
        timeValidator.validateProperty(
          time,
          'deactivation',
          isTime,
          time
        );
        return timeValidator.errors.length === 0;
      },
      DEFAULT_SETTINGS
    );
    validateProperty(
      settings,
      'auto_location',
      (location) => {
        if (!isPlainObject(location)) {
          return false;
        }
        const locValidator = createValidator();
        const isValidLoc = (x) => x === null || isNumber(x);
        locValidator.validateProperty(
          location,
          'latitude',
          isValidLoc,
          location
        );
        locValidator.validateProperty(
          location,
          'longitude',
          isValidLoc,
          location
        );
        return locValidator.errors.length === 0;
      },
      DEFAULT_SETTINGS
    );
    validateProperty(
      settings,
      'stay_detectDarkTheme',
      isBoolean,
      DEFAULT_SETTINGS
    );
    return {errors, settings};
  }
  function validateTheme(theme) {
    if (!isPlainObject(theme)) {
      return {
        errors: ['Theme is not a plain object'],
        theme: DEFAULT_THEME
      };
    }
    const {validateProperty, errors} = createValidator();
    validateProperty(theme, 'mode', isOneOf(0, 1), DEFAULT_THEME);
    validateProperty(
      theme,
      'brightness',
      isNumberBetween(0, 200),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'contrast',
      isNumberBetween(0, 200),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'grayscale',
      isNumberBetween(0, 100),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'sepia',
      isNumberBetween(0, 100),
      DEFAULT_THEME
    );
    validateProperty(theme, 'useFont', isBoolean, DEFAULT_THEME);
    validateProperty(theme, 'fontFamily', isNonEmptyString, DEFAULT_THEME);
    validateProperty(
      theme,
      'textStroke',
      isNumberBetween(0, 1),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'engine',
      isOneOf('dynamicTheme', 'staticTheme', 'cssFilter', 'svgFilter'),
      DEFAULT_THEME
    );
    validateProperty(theme, 'stylesheet', isString, DEFAULT_THEME);
    validateProperty(
      theme,
      'darkSchemeBackgroundColor',
      isRegExpMatch(/^#[0-9a-f]{6}$/i),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'darkSchemeTextColor',
      isRegExpMatch(/^#[0-9a-f]{6}$/i),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'lightSchemeBackgroundColor',
      isRegExpMatch(/^#[0-9a-f]{6}$/i),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'lightSchemeTextColor',
      isRegExpMatch(/^#[0-9a-f]{6}$/i),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'scrollbarColor',
      (x) => x === '' || isRegExpMatch(/^(auto)|(#[0-9a-f]{6})$/i)(x),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'selectionColor',
      isRegExpMatch(/^(auto)|(#[0-9a-f]{6})$/i),
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'styleSystemControls',
      isBoolean,
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'lightColorScheme',
      isNonEmptyString,
      DEFAULT_THEME
    );
    validateProperty(
      theme,
      'darkColorScheme',
      isNonEmptyString,
      DEFAULT_THEME
    );
    validateProperty(theme, 'immediateModify', isBoolean, DEFAULT_THEME);
    return {errors, theme};
  }
  function debounce(delay, fn) {
    let timeoutId = null;
    return (...args) => {
      if (timeoutId) {
        clearTimeout(timeoutId);
      }
      timeoutId = setTimeout(() => {
        timeoutId = null;
        fn(...args);
      }, delay);
    };
  }
  const SAVE_TIMEOUT = 1000;
  class UserStorage {
    constructor() {
      this.saveSettingsIntoStorage = debounce(SAVE_TIMEOUT, async () => {
        if (this.saveStorageBarrier) {
          await this.saveStorageBarrier.entry();
          return;
        }
        this.saveStorageBarrier = new PromiseBarrier();
        const settings = this.settings;
        await writeLocalStorage(settings);
        // console.log("saveSettingsIntoStorage===", settings);
        if (settings.stay_syncSettings) {
          try {
            await writeSyncStorage(settings);

          } catch (err) {
            logWarn(
              'Settings synchronization was disabled due to error:',
              browser.runtime.lastError
            );
            this.set({stay_syncSettings: false});
            await this.saveSyncSetting(false);
          }
        }

        this.saveStorageBarrier.resolve();
        this.saveStorageBarrier = null;
      });
      this.settings = null;
    }
    async loadSettings() {
      this.settings = await this.loadSettingsFromStorage();
      // console.log("loadSettings===",this.settings)
      // let isStayAround = this.settings.isStayAround;
      // let isStayAround = await this.getStayAround();
      // this.settings.isStayAround = isStayAround;
      this.writeStayAroundIntoStorage(this.settings);
      return new Promise((resolve, reject) => {
        resolve(this.settings);
      });
    }

    // 获取isStayAround
    // async getStayAround(){
    //     return new Promise((resolve, reject) => {
    //         browser.runtime.sendNativeMessage("application.id", { type: "p" }, function (response) {
    //             resolve(response.body);
    //         });
    //     });
    // }

    writeStayAroundIntoStorage(settings){
      // let isStayAround = await this.getStayAround();
      // settings = { ...settings, isStayAround };
      this.settings = settings
      // console.log("writeStayAroundIntoStorage=====", settings)
      writeSyncStorage(settings);
      writeLocalStorage(settings);
    }

    fillDefaults(settings) {
      settings.stay_theme = {...DEFAULT_THEME, ...settings.stay_theme};
      settings.auto_time = {...DEFAULT_SETTINGS.auto_time, ...settings.auto_time};
      settings.stay_presets.forEach((preset) => {
        preset.theme = {...DEFAULT_THEME, ...preset.theme};
      });
      settings.stay_customThemes.forEach((site) => {
        site.theme = {...DEFAULT_THEME, ...site.theme};
      });
    }
    async loadSettingsFromStorage() {
      // if (this.loadBarrier) {
      //     const settings = await this.loadBarrier.entry();
      //     console.log("settings--------", settings);
      //     return settings;
      // }
      this.loadBarrier = new PromiseBarrier();
      const local = await readLocalStorage(DEFAULT_SETTINGS);
      // console.log("loadSettingsFromStorage-----", local);
      const {errors: localCfgErrors} = validateSettings(local);
      localCfgErrors.forEach((err) => logWarn(err));
      if (!local.stay_syncSettings) {
        this.fillDefaults(local);
        this.loadBarrier.resolve(local);
        return local;
      }
      const $sync = await readSyncStorage(DEFAULT_SETTINGS);
      if (!$sync) {
        local.stay_syncSettings = false;
        this.settings['stay_syncSettings'] = false;
        this.saveSyncSetting(false);
        this.loadBarrier.resolve(local);
        return local;
      }
      const {errors: syncCfgErrors} = validateSettings($sync);
      syncCfgErrors.forEach((err) => logWarn(err));
      this.fillDefaults($sync);
      this.loadBarrier.resolve($sync);
      return $sync;
    }
    async saveSyncSetting(sync) {
      const obj = {stay_syncSettings: sync};
      await writeLocalStorage(obj);
      try {
        await writeSyncStorage(obj);
      } catch (err) {
        logWarn(
          'Settings synchronization was disabled due to error:',
          browser.runtime.lastError
        );
        this.settings['stay_syncSettings'] = false;
      }
    }
    async saveSettings() {
      await this.saveSettingsIntoStorage();
    }

    set($settings) {
      this.settings = {...this.settings, ...$settings};
      this.saveSettings()
    }
  }

  class PromiseBarrier {
    constructor() {
      this.resolves = [];
      this.rejects = [];
      this.wasResolved = false;
      this.wasRejected = false;
    }
    async entry() {
      if (this.wasResolved) {
        return Promise.resolve(this.resolution);
      }
      if (this.wasRejected) {
        return Promise.reject(this.reason);
      }
      return new Promise((resolve, reject) => {
        this.resolves.push(resolve);
        this.rejects.push(reject);
      });
    }
    async resolve(value) {
      if (this.wasRejected || this.wasResolved) {
        return;
      }
      this.wasResolved = true;
      this.resolution = value;
      this.resolves.forEach((resolve) => resolve(value));
      this.resolves = null;
      this.rejects = null;
      return new Promise((resolve) => setTimeout(() => resolve()));
    }
    async reject(reason) {
      if (this.wasRejected || this.wasResolved) {
        return;
      }
      this.wasRejected = true;
      this.reason = reason;
      this.rejects.forEach((reject) => reject(reason));
      this.resolves = null;
      this.rejects = null;
      return new Promise((resolve) => setTimeout(() => resolve()));
    }
    isPending() {
      return !this.wasResolved && !this.wasRejected;
    }
    isFulfilled() {
      return this.wasResolved;
    }
    isRejected() {
      return this.wasRejected;
    }
  }

  function isNonPersistent() {
    const background = browser.runtime.getManifest().background;
    if ('persistent' in background) {
      return background.persistent === false;
    }
    if ('service_worker' in background) {
      return true;
    }
  }

  function logInfo(...args) {}
  function logWarn(...args) {}

  async function queryTabs(query) {
    return new Promise((resolve) => {
      browser.tabs.query(query, (tabs) => resolve(tabs));
    });
  }

  let StateManagerState;
  (function (StateManagerState) {
    StateManagerState[(StateManagerState['INITIAL'] = 0)] = 'INITIAL';
    StateManagerState[(StateManagerState['DISABLED'] = 1)] = 'DISABLED';
    StateManagerState[(StateManagerState['LOADING'] = 2)] = 'LOADING';
    StateManagerState[(StateManagerState['READY'] = 3)] = 'READY';
    StateManagerState[(StateManagerState['SAVING'] = 4)] = 'SAVING';
    StateManagerState[(StateManagerState['SAVING_OVERRIDE'] = 5)] = 'SAVING_OVERRIDE';
  })(StateManagerState || (StateManagerState = {}));

  class StateManager {
    constructor(localStorageKey, parent, defaults) {
      this.meta = StateManagerState.INITIAL;
      this.loadStateBarrier = null;
      if (!isNonPersistent()) {
        this.meta = StateManagerState.DISABLED;
        return;
      }
      this.localStorageKey = localStorageKey;
      this.parent = parent;
      this.defaults = defaults;
    }
    collectState() {
      const state = {};
      for (const key of Object.keys(this.defaults)) {
        state[key] = this.parent[key] || this.defaults[key];
      }
      return state;
    }
    async saveState() {
      switch (this.meta) {
        case StateManagerState.DISABLED:
          return;
        case StateManagerState.LOADING:
        case StateManagerState.INITIAL:
          if (this.loadStateBarrier) {
            await this.loadStateBarrier.entry();
          }
          this.meta = StateManagerState.SAVING;
          break;
        case StateManagerState.READY:
          this.meta = StateManagerState.SAVING;
          break;
        case StateManagerState.SAVING:
          this.meta = StateManagerState.SAVING_OVERRIDE;
          return;
        case StateManagerState.SAVING_OVERRIDE:
          return;
      }
      browser.storage.local.set(
        {[this.localStorageKey]: this.collectState()},
        () => {
          switch (this.meta) {
            case StateManagerState.INITIAL:
            case StateManagerState.DISABLED:
            case StateManagerState.LOADING:
            case StateManagerState.READY:
            case StateManagerState.SAVING:
              this.meta = StateManagerState.READY;
              break;
            case StateManagerState.SAVING_OVERRIDE:
              this.meta = StateManagerState.READY;
              this.saveState();
          }
        }
      );
    }
    async loadState() {
      switch (this.meta) {
        case StateManagerState.INITIAL:
          this.meta = StateManagerState.LOADING;
          this.loadStateBarrier = new PromiseBarrier();
          return new Promise((resolve) => {
            browser.storage.local.get(
              this.localStorageKey,
              (data) => {
                this.meta = StateManagerState.READY;
                if (data[this.localStorageKey]) {
                  Object.assign(
                    this.parent,
                    data[this.localStorageKey]
                  );
                } else {
                  Object.assign(this.parent, this.defaults);
                }
                this.loadStateBarrier.resolve();
                this.loadStateBarrier = null;
                resolve();
              }
            );
          });
        case StateManagerState.DISABLED:
        case StateManagerState.READY:
        case StateManagerState.SAVING:
        case StateManagerState.SAVING_OVERRIDE:
          return;
        case StateManagerState.LOADING:
          return this.loadStateBarrier.entry();
      }
    }
  }

  function isEnabledUrlState(tabUrl, siteListDisabled){
    let tabDomain = getDomain(tabUrl);
    if(siteListDisabled.includes(tabDomain)){
      return false;
    }else{
      return true;
    }
  }

  async function getCurrentTabUrl(){
    return new Promise((resolve) => {
      browser.tabs.getSelected(null, (tab) => {
        resolve(tab.url);
      });
    });
  }

  class StayDarkModeExtension {
    constructor() {
      this.autoState = '';
      this.wasEnabledOnLastCheck = null;
      this.popupOpeningListener = null;
      this.wasLastColorSchemeDark = null;
      this.startBarrier = null;
      this.stateManager = null;

      this.onColorSchemeChange = ({isDark}) => {
        if (isSafari) {
          this.wasLastColorSchemeDark = isDark;
        }
        if (this.user.settings.stay_automation !== 'system') {
          return;
        }
        this.callWhenSettingsLoaded(() => {
          this.handleAutomationCheck();
        });
      };
      // when automation to dark mode or not
      this.handleAutomationCheck = () => {
        this.updateAutoState();
        const isSwitchedOn = this.isExtensionSwitchedOn();
        if (
          this.wasEnabledOnLastCheck === null ||
                    this.wasEnabledOnLastCheck !== isSwitchedOn ||
                    this.autoState === 'scheme-dark' ||
                    this.autoState === 'scheme-light'
        ) {
          this.wasEnabledOnLastCheck = isSwitchedOn;
          // todo  to sendMessage to dark.user.js

          this.handleTabMessage()

          this.stateManager.saveState();
        }
      };

      this.config = new ConfigManager();
      this.user = new UserStorage();
      this.getAndSentConnectionMessage = (url, frameURL) => {
        // console.log("getAndSentConnectionMessage----settings-",this.user.settings);

        if (this.user.settings) {
          this.updateAutoState();
          // console.log("getAndSentConnectionMessage----settings-");
          this.handleTabMessage(url, frameURL);
        }else{
          // console.log("getAndSentConnectionMessage----settings----else-----");
          this.user.loadSettings().then(()=>{
            this.updateAutoState();
            this.handleTabMessage(url, frameURL)
          });
        }
      }
      this.handleFetchSettingForFallback = async () => {
        if (!this.user.settings) {
          await this.user.loadSettings();
        }
        return new Promise((resolve)=>{
          resolve(this.user.settings)
        })
      }
      this.handleTabMessage = (url, frameUrl=null) => {
        // console.log("this.config====", this.config)
        // console.log("handleTabMessage---this.user.settings=====",this.user.settings, this.autoState);
        let settings = this.user.settings;
        url = url&&url!=null?url:settings.currentTabUrl;
        frameUrl = frameUrl&&frameUrl!=null?frameUrl:settings.frameUrl
        settings = {...settings, ...{currentTabUrl: url, frameUrl: frameUrl}}
        this.user.set(settings);
        // const isStayAround = settings.isStayAround;
        const toggleStatus = settings.toggleStatus;
        let darkSetings = {
          siteListDisabled: settings.siteListDisabled,
          toggleStatus: toggleStatus,
          // isStayAround: isStayAround,
          darkState:'clean_up'
        }
        let message = {
          type: 'bg-clean-up',
          stayDarkSettings: settings,
          darkSetings
        };
        // console.log("handleTabMessage---isStayAround=====",isStayAround, this.autoState);
        // const toggleStatus = settings.toggleStatus;
        const urlIsEnabled = isEnabledUrlState(url, settings.siteListDisabled);
        if(('on' === toggleStatus ||  'scheme-dark' === this.autoState ) && urlIsEnabled){
          // console.log("handleTabMessage---toggleStatus=====",toggleStatus, urlIsEnabled);
          darkSetings.darkState = 'dark_mode';
          const custom = settings.stay_customThemes.find(
            ({url: urlList}) => isURLInList(url, urlList)
          );
          const preset = custom
            ? null
            : settings.stay_presets.find(({urls}) =>
              isURLInList(url, urls)
            );
          let theme = custom ? custom.theme : preset ? preset.theme : settings.stay_theme;
          if ( this.autoState === 'scheme-dark' || this.autoState === 'scheme-light') {
            const mode = this.autoState === 'scheme-dark' ? 1 : 0;
            theme = {...theme, mode};
          }

          const isIFrame = frameUrl != null && frameUrl!='';
          const detectDarkTheme = !isIFrame && settings.stay_detectDarkTheme && !isPDF(url);

          let fixes = {
            ignoreImageAnalysis: [],
            invert: [
              '.jfk-bubble.gtx-bubble',
              '.captcheck_answer_label > input + img',
              'span#closed_text > img[src^="https://www.gstatic.com/images/branding/googlelogo"]',
              'span[data-href^="https://www.hcaptcha.com/"] > #icon',
              '#bit-notification-bar-iframe',
              '::-webkit-calendar-picker-indicator'
            ],
            ignoreInlineStyle: [
              '.sr-wrapper *',
              '.sr-reader *',
              '.diigoHighlight'
            ],
            url: ['*'],
            // eslint-disable-next-line max-len
            css: '.vimvixen-hint{background-color:${#ffd76e}!important;border-color:${#c59d00}!important;color:${#302505}!important;}#vimvixen-console-frame{color-scheme:light!important}::placeholder{opacity:0.5!important;}#edge-translate-panel-body,.MuiTypography-body1,.nfe-quote-text{color:var(--darkreader-neutral-text)!important;}gr-main-header{background-color:${lightblue}!important;}.tou-z65h9k,.tou-mignzq,.tou-1b6i2ox,.tou-lnqlqk{background-color:var(--darkreader-neutral-background)!important;}.tou-75mvi{background-color:${rgb(207,236,245)}!important;}.tou-ta9e87,.tou-1w3fhi0,.tou-1b8t2us,.tou-py7lfi,.tou-1lpmd9d,.tou-1frrtv8,.tou-17ezmgn{background-color:${rgb(245,245,245)}!important;}.tou-uknfeu{background-color:${rgb(250,237,218)}!important;}.tou-6i3zyv{background-color:${rgb(133,195,216)}!important;}div.mermaid-viewer-control-panel.btn{fill:var(--darkreader-neutral-text);background-color:var(--darkreader-neutral-background);}svggrect.er{fill:var(--darkreader-neutral-background)!important;}svggrect.er.entityBox{fill:var(--darkreader-neutral-background)!important;}svggrect.er.attributeBoxOdd{fill:var(--darkreader-neutral-background)!important;}svggrect.er.attributeBoxEven{fill-opacity:0.8!important;fill:var(--darkreader-selection-background);}svgrect.er.relationshipLabelBox{fill:var(--darkreader-neutral-background)!important;}svggg.nodesrect,svggg.nodespolygon{fill:var(--darkreader-neutral-background)!important;}svggrect.task{fill:var(--darkreader-selection-background)!important;}svgline.messageLine0,svgline.messageLine1{stroke:var(--darkreader-neutral-text)!important;}div.mermaid.actor{fill:var(--darkreader-neutral-background)!important;}embed[type="application/pdf"]{filter:invert(100%)contrast(90%);}'
          };

          if(checkDomainHasConfig(url, this.config.DYNAMIC_THEME_FIXES_INDEX)){
            fixes = getDynamicThemeFixesFor(
              url,
              frameUrl,
              this.config.DYNAMIC_THEME_FIXES_RAW,
              this.config.DYNAMIC_THEME_FIXES_INDEX,
              settings.stay_enableForPDF
            );
          }

          // console.log('this.user.settings==fixes===',fixes);
          message = {
            type: 'bg-add-dynamic-theme',
            data: {
              theme,
              fixes,
              isIFrame,
              detectDarkTheme
            },
            stayDarkSettings: settings,
            darkSetings
          };
        }
        //
        // eslint-disable-next-line no-undef
        darkuserJS.handleDarkmodeConfigListenerFromConfigJS(message);
        // console.log("message======",message);
        // browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        //   browser.tabs.sendMessage(
        //     tabs[0].id,
        //     message
        //   );
        // })
      }
      this.handleChangeTheme = (bgColor, textColor) => {
        // console.log('this.handleChangeTheme====', bgColor, textColor)
        let settings = this.user.settings;
        // console.log('handleChangeTheme---this.user.settings=====',settings);
        let url = settings.currentTabUrl;
        let frameUrl = settings.frameUrl
        settings = {...settings, ...{currentTabUrl: url, frameUrl: frameUrl}}
        const custom = settings.stay_customThemes.find(
          ({url: urlList}) => isURLInList(url, urlList)
        );
        const preset = custom
          ? null
          : settings.stay_presets.find(({urls}) =>
            isURLInList(url, urls)
          );
        let theme = custom ? custom.theme : preset ? preset.theme : settings.stay_theme;
        // const isStayAround = settings.isStayAround;
        let darkSetings = {
          siteListDisabled: settings.siteListDisabled,
          toggleStatus: 'on',
          darkState:'dark_mode'
        }
        let message = {
          type: 'bg-clean-up',
          stayDarkSettings: settings,
          darkSetings
        };
        // let theme = settings.stay_theme;
        // console.log('handleChangeTheme---theme=====',theme);
        theme.darkSchemeBackgroundColor = bgColor;
        theme.darkSchemeTextColor = textColor;
        theme = {...theme, mode: 1, };
        const isIFrame = frameUrl != null && frameUrl!='';
        const fixes = getDynamicThemeFixesFor(
          url,
          frameUrl,
          this.config.DYNAMIC_THEME_FIXES_RAW,
          this.config.DYNAMIC_THEME_FIXES_INDEX,
          settings.stay_enableForPDF
        );
        // console.log("this.user.settings==fixes===",fixes);
        message = {
          type: 'bg-add-dynamic-theme-change',
          data: {
            theme,
            fixes,
            isIFrame,
            detectDarkTheme: true
          },
          stayDarkSettings: settings,
          darkSetings
        };
        // console.log('message======',message);
        // eslint-disable-next-line no-undef
        darkuserJS.handleDarkmodeConfigListenerFromConfigJS(message);
        // browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        //   browser.tabs.sendMessage(
        //     tabs[0].id,
        //     message
        //   );
        // })
      }
      this.startBarrier = new PromiseBarrier();
      this.stateManager = new StateManager(
        StayDarkModeExtension.LOCAL_STORAGE_KEY,
        this,
        {
          autoState: '',
          wasEnabledOnLastCheck: null
        }
      );
      this.handleCSFrameConnect = async (sender) =>{
        await this.stateManager.loadState();
        const tabURL = sender.tab.url;
        const {frameId} = sender;
        const senderURL = sender.url;
        let frameUrl = frameId === 0 ? null : senderURL;
        // console.log("handleCSFrameConnect-----tabURL=",tabURL);
        this.getAndSentConnectionMessage(tabURL, frameUrl);
        this.stateManager.saveState();
      }
      this.handleCSFrameConnect_V2 = async () =>{
        await this.stateManager.loadState();
        let tabURL = window.location.href;
        let frameUrl = null;
        this.getAndSentConnectionMessage(tabURL, frameUrl);
        this.stateManager.saveState();
      }
      this.handleDarkModeSettingForPopup = async () => {
        const settings = await this.user.loadSettings();
        browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
          const tabURL = tabs[0].url;
          let browserDomain = getDomain(tabURL);
          let siteListDisabled = settings['siteListDisabled'];
          const enabled = isArray(siteListDisabled)&&siteListDisabled.includes(browserDomain)?false:true;
          browser.runtime.sendMessage({
            from: 'background',
            // isStayAround: settings["isStayAround"],
            darkmodeToggleStatus: settings['toggleStatus'],
            darkmodeColorTheme: settings.stay_theme.darkColorScheme,
            enabled: enabled,
            operate: 'giveDarkmodeConfig'
          });
        });

      }

      this.handleDarkmodeSettingListenerFromUserJS = ({type, operate, data, bgColor, textColor, darkmodeColorTheme, status, enabled}, callback) => {
        if ('darkmode' === type) {
          if('cs-frame-connect' === operate){
            this.handleCSFrameConnect_V2()
          }
          else if('cs-color-scheme-change' === operate){
            this.onColorSchemeChange(data);
          }
          else if ('FETCH_DARK_SETTING' === operate){
            this.handleFetchSettingForFallback().then(settings=>{
              // console.log("addListener____fetch----settings-----", settings);
              this.updateAutoState();
              const tabURL = window.location.href;
              const toggleStatus = settings.toggleStatus;
              // const isStayAround = settings.isStayAround;
              const urlIsEnabled = isEnabledUrlState(tabURL, settings.siteListDisabled);
              let darkState = 'clean_up';
              if(('on' === toggleStatus ||  'scheme-dark' === this.autoState ) && urlIsEnabled){
                darkState = 'dark_mode'
              }
              const darkSetings = {
                siteListDisabled: settings.siteListDisabled,
                toggleStatus: toggleStatus,
                darkState
              }
              callback && callback(darkSetings);
            })
          }
        }
      }

      browser.runtime.onConnect.addListener((port) => {
        // console.log('browser.runtime.onConnect-------',port);
        if(port.name == 'POPUP_DARK_CONFIG_CONNECT') {
          port.onMessage.addListener((res) => {
            console.log('收到长连接消息：', res);
            if(!res){
              return;
            }
            const operator = res.operate;

            if('FETCH_DARKMODE_CONFIG' === operator){
              // console.log("addListener--FETCH_DARKMODE_CONFIG--");
              this.user.loadSettings().then(async (setting) => {
                let browserDomain = getDomain();
                let siteListDisabled = setting['siteListDisabled'];
                const enabled = isArray(siteListDisabled)&&siteListDisabled.includes(browserDomain)?false:true;
                port.postMessage({
                  from: 'background',
                  darkmodeToggleStatus: setting['toggleStatus'],
                  darkmodeColorTheme: setting.stay_theme.darkColorScheme,
                  enabled: enabled,
                  operate: 'FETCH_DARKMODE_CONFIG_RESP'
                });
              });
            }
            else if('DARKMODE_SETTING' === operator){
              let setting = {...this.user.settings};
              const toggleStatus = res.status;
              const darkmodeColorTheme = res.darkmodeColorTheme;
              // let isStayAround = request.isStayAround;
              setting['toggleStatus'] = toggleStatus
              let theme = setting.stay_theme;
              if(darkmodeColorTheme == 'Eco'){
                theme.darkSchemeBackgroundColor = ECO_COLORSCHEME.darkScheme.background;
                theme.darkSchemeTextColor = ECO_COLORSCHEME.darkScheme.text;
                theme.darkColorScheme = 'Eco';
              }else if(darkmodeColorTheme == 'Eyecare'){
                theme.darkSchemeBackgroundColor = EYECARE_COLORSCHEME.darkScheme.background;
                theme.darkSchemeTextColor = EYECARE_COLORSCHEME.darkScheme.text;
                theme.darkColorScheme = 'Eyecare'
              }else if(darkmodeColorTheme == 'Default'){
                theme = {...DEFAULT_THEME};
              }else{
                // pro用户自定义主题色
                theme.darkSchemeBackgroundColor = res.bgColor;
                theme.darkSchemeTextColor = res.textColor;
                theme.darkColorScheme = darkmodeColorTheme;
              }
              setting.stay_theme = theme;
              let siteListDisabled = setting['siteListDisabled'];
              let domain = getDomain();
              let enabled = res.enabled;

              if(enabled){
                if(siteListDisabled.includes(domain)){
                  siteListDisabled.splice(siteListDisabled.indexOf(domain), 1);
                }
              }else{
                if(!siteListDisabled.includes(domain)){
                  siteListDisabled.push(domain)
                }
              }
              setting['siteListDisabled'] = siteListDisabled

              setting.stay_automationBehaviour='Scheme';
              // 默认跟随系统
              setting.stay_automation='system';
              this.changeSettings(setting);
            }
            else if('CHANGE_DARKMODE_THEME' === operator){
              // console.log('CHANGE_DARKMODE_THEME-----', res.backgroundColor, res.textColor)
              this.handleChangeTheme(res.backgroundColor, res.textColor);
            }

          });
        }
      });


    }
    isExtensionSwitchedOn() {
      return (
        this.autoState === 'turn-on' ||
                this.autoState === 'scheme-dark' ||
                this.autoState === 'scheme-light' ||
                (this.autoState === '' && 'on' === this.user.settings.toggleStatus)
      );
    }
    updateAutoState() {
      const {stay_automation, toggleStatus, auto_location, auto_time, stay_automationBehaviour:behavior} = this.user.settings;
      let isAutoDark;
      let nextCheck;
      if('auto' === toggleStatus){
        // console.log("updateAutoState------",stay_automation,behavior);
        switch (stay_automation) {
          // auto模式下根据【时间】来更换暗黑模式还是明亮模式
          case 'time':
            isAutoDark = isInTimeIntervalLocal(
              auto_time.activation,
              auto_time.deactivation
            );
            nextCheck = nextTimeInterval(
              auto_time.activation,
              auto_time.deactivation
            );
            break;
          // auto模式下跟随【系统模式】更换暗黑模式还是明亮模式
          case 'system':
            if (isSafari) {
              isAutoDark = this.wasLastColorSchemeDark == null ? isSystemDarkModeEnabled() : this.wasLastColorSchemeDark;
            } else {
              isAutoDark = isSystemDarkModeEnabled();
            }
            break;
          case 'location': {
            const {latitude, longitude} = auto_location;
            if (latitude != null && longitude != null) {
              isAutoDark = isNightAtLocation(latitude, longitude);
              nextCheck = nextTimeChangeAtLocation(
                latitude,
                longitude
              );
            }
            break;
          }
        }
        let state = '';
        if (stay_automation) {
          if (behavior === 'OnOff') {
            state = isAutoDark ? 'turn-on' : 'turn-off';
          } else if (behavior === 'Scheme') {
            state = isAutoDark ? 'scheme-dark' : 'scheme-light';
          }
        }
        this.autoState = state;
        // if (nextCheck) {
        //   if (nextCheck < Date.now()) {
        //     logWarn(
        //       `Alarm is set in the past: ${nextCheck}. The time is: ${new Date()}. ISO: ${new Date().toISOString()}`
        //     );
        //   } else {
        //     browser.alarms.create(StayDarkModeExtension.ALARM_NAME, {
        //       when: nextCheck
        //     });
        //   }
        // }
      }else{
        this.autoState = ''
      }
    }
    async start() {
      await this.config.startLoadConfig({local: true});
      await this.user.loadSettings();
      // console.log('this.user.settings = ',  this.user.settings);
      this.updateAutoState();

      logInfo('loaded', this.user.settings);

      this.startBarrier.resolve();
      this.handleCSFrameConnect_V2();
    }

    callWhenSettingsLoaded(callback) {
      if (this.user.settings) {
        callback();
        return;
      }
      this.user.loadSettings().then(async () => {
        await this.stateManager.loadState();
        callback();
      });
    }
    // popup上改变了stay Dark mode 设置触发事件
    async onSettingsChanged() {
      if (!this.user.settings) {
        await this.user.loadSettings();
      }
      await this.stateManager.loadState();
      this.wasEnabledOnLastCheck = this.isExtensionSwitchedOn();
      // todo sendMessage to dark.user.js
      // const tabURL = sender.tab.url;
      this.handleTabMessage()
      // browser.tabs.query({ active: true, currentWindow: true }, (tabs) => {
      //     browser.tabs.sendMessage(tabs[0].id,message);
      // });
      this.saveUserSettings();
      this.user.writeStayAroundIntoStorage(this.user.settings)
      this.stateManager.saveState();
    }
    async saveUserSettings() {
      await this.user.saveSettings();
      logInfo('saved', this.user.settings);
    }

    changeSettings(settings) {
      const prev = {...this.user.settings};
      // console.log("settings=====",settings, "------prev==",prev);
      this.user.settings = {...settings}
      // console.log("this.user.settings=====",this.user.settings);
      this.user.set(settings);
      if (
        prev.siteListDisabled.length !== settings.siteListDisabled.length ||
                prev.toggleStatus !== settings.toggleStatus ||
                prev.stay_theme.darkColorScheme !== settings.stay_theme.darkColorScheme
                // prev.automation !== this.user.settings.automation ||
                // prev.time.activation !== this.user.settings.time.activation ||
                // prev.time.deactivation !== this.user.settings.time.deactivation ||
                // prev.location.latitude !== this.user.settings.location.latitude ||
                // prev.location.longitude !== this.user.settings.location.longitude
      ) {
        // console.log("changeSettings-------",settings);
        this.updateAutoState();
      }
      if (prev.stay_syncSettings !== settings.stay_syncSettings) {
        this.user.saveSyncSetting(settings.stay_syncSettings);
      }

      this.onSettingsChanged();
    }


  }
  StayDarkModeExtension.ALARM_NAME = 'auto-time-alarm';
  StayDarkModeExtension.LOCAL_STORAGE_KEY = 'Stay-darkmode-state';

  const stayDarkMode = new StayDarkModeExtension();

  stayDarkMode.start();

  function handleDarkmodeSettingListenerFromUserJS(message){
    stayDarkMode.handleDarkmodeSettingListenerFromUserJS(message)
  }

  window.darkconfigJS = {
    handleDarkmodeSettingListenerFromUserJS: handleDarkmodeSettingListenerFromUserJS
  }
  // browser.storage.local.remove(["time","theme","syncSettings","detectDarkTheme","customThemes","automationBehaviour","automation","presets"])
  // browser.storage.sync.remove(["time","theme","syncSettings","detectDarkTheme","customThemes","automationBehaviour","automation","presets"])
})();
