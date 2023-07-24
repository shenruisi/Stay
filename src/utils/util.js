/**
 * 邮箱
 * @param {*} s
 */
export function isEmail(s) {
  return /^([a-zA-Z0-9_.-])+@([a-zA-Z0-9_-])+((.[a-zA-Z0-9_-]{2,3}){1,2})$/.test(
    s
  );
}

/**
 * 手机号码
 * @param {*} s
 */
export function isMobilePhone(s) {
  return /^1[0-9]{10}$/.test(s);
}

/**
 * 电话号码
 * @param {*} s
 */
export function isPhone(s) {
  return /^([0-9]{3,4}-)?[0-9]{7,8}$/.test(s);
}

/**
 * URL地址
 * @param {*} s
 */
export function isURL(s) {
  return /^http[s]?:\/\/.*/.test(s);
}

/**
 * 金额
 * 正则验证 限制只输入数字 以及小数点后两位
 */
// 封装正则
export function money() {
  return /^\d*(\.?\d{0,2})/g[0];
}

/**
 *
 * @param {stirng} version1
 * @param {stirng} version2
 * @returns
 * -1: version1<version2
 * 0: version1=version2
 * 1: version1>version2
 */
export function compareVersion(version1, version2) {
  const newVersion1 =
    `${version1}`.split('.').length < 3
      ? `${version1}`.concat('.0')
      : `${version1}`;
  const newVersion2 =
    `${version2}`.split('.').length < 3
      ? `${version2}`.concat('.0')
      : `${version2}`;
  //计算版本号大小,转化大小
  function toNum(a) {
    const c = a.toString().split('.');
    const numPlace = ['', '0', '00', '000', '0000'];
    const r = numPlace.reverse();
    for (let i = 0; i < c.length; i++) {
      const len = c[i].length;
      c[i] = r[len] + c[i];
    }
    return c.join('');
  }

  //检测版本号是否需要更新
  function checkPlugin(a, b) {
    const numA = toNum(a);
    const numB = toNum(b);
    return numA > numB ? 1 : numA < numB ? -1 : 0;
  }
  return checkPlugin(newVersion1, newVersion2);
}

/*正则获取URL参数*/
export function queryURLParams(url, name) {
  const pattern = new RegExp('[?&#]+' + name + '=([^?&#]+)');
  const res = pattern.exec(url);
  if (!res) return;
  if (!res[1]) return;
  return res[1];
}

export function languageCode() {
  let lang =
    navigator.languages && navigator.languages.length > 0
      ? navigator.languages[0]
      : navigator.language || navigator.userLanguage /* IE */ || 'en';
  lang = lang.toLowerCase();
  lang = lang.replace(/-/, '_'); // some browsers report language as en-US instead of en_US
  if (lang.length > 3) {
    lang = lang.substring(0, 3) + lang.substring(3).toUpperCase();
  }
  // console.log('------lang--------------',lang);
  return lang;
}

export function checkJavascriptFileType(fileType) {
  const fileTypeArr = ['application/x-javascript', 'text/javascript'];
  if (!fileType) {
    return false;
  }
  if (fileTypeArr.includes('fileType')) {
    return true;
  }
  return false;
}

export function matchRule(str, rule) {
  let reg = new RegExp('([.*+?^=!:${}()|[]/\\])','g');
  let escapeRegex = (str) => str.replace(reg, '\\$1');
  return new RegExp('^' + rule.split('*').map(escapeRegex).join('.*') + '$').test(str);
}

export function getHostname(url) {
  if(!url){
    return ''
  }
  try {
    return new URL(url).hostname.toLowerCase();
  } catch (error) {
    return url.split('/')[0].toLowerCase();
  }
}

export function getFilenameByUrl(url){
  if(!url){
    return '';
  }
  return url.split('/').pop();
}

export function getFiletypeByUrl(url){
  if(!url){
    return '';
  }
  return url.split('.').pop();
}

export function getDomain(url){
  let l2domain = getLevel2domain(url);
  if(!l2domain){
    return '';
  }
  let reg = new RegExp('.(com.cn|com|net.cn|net|org.cn|org|gov.cn|gov|cn|mobi|me|info|name|biz|cc|tv|asia|hk|网络|公司|中国)','g');
  return l2domain.replace(reg, '');
}

export function getLevel2domain(url) {
  try {
    let subdomain = ''
    const domain = url ? url.split('/') : ''
    const domainList = domain[2].split('.')
    const urlItems = []
    urlItems.unshift(domainList.pop())
    while (urlItems.length < 2) {
      urlItems.unshift(domainList.pop())
      subdomain = urlItems.join('.')
    }
    return subdomain
  } catch (e) {
    return ''
  }
}

export function isMobile(){
  const userAgentInfo = navigator.userAgent;
  let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPod'];
  let getArr = Agents.filter(i => userAgentInfo.includes(i));
  return getArr.length ? true : false;
}

export function isMobileOrIpad(){
  const userAgentInfo = navigator.userAgent;
  let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPad', 'iPod'];
  let getArr = Agents.filter(i => userAgentInfo.includes(i));
  let isIphoneOrIpad = getArr.length ? true : false;
  if(isIphoneOrIpad){
    return isIphoneOrIpad
  }else{
    if (userAgentInfo.match(/Macintosh/) && navigator.maxTouchPoints > 1) {
      return true;
    } 
  }
  return isIphoneOrIpad;
}

export function unhtml(str) {
  return str ? str.replace(/[<">']/g, (a) => {
    return {
      '<': '&lt;',
      '"': '&quot;',
      '>': '&gt;',
      '\'': '&#39;'
    }[a]
  }) : '';
}

export function hexMD5 (str) { 
  /*
  * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
  * Digest Algorithm, as defined in RFC 1321.
  * Version 1.1 Copyright (C) Paul Johnston 1999 - 2002.
  * Code also contributed by Greg Holt
  * See http://pajhome.org.uk/site/legal.html for details.
  */

  /*
  * Add integers, wrapping at 2^32. This uses 16-bit operations internally
  * to work around bugs in some JS interpreters.
  */
  function safe_add(x, y)
  {
    let lsw = (x & 0xFFFF) + (y & 0xFFFF)
    let msw = (x >> 16) + (y >> 16) + (lsw >> 16)
    return (msw << 16) | (lsw & 0xFFFF)
  }

  /*
  * Bitwise rotate a 32-bit number to the left.
  */
  function rol(num, cnt)
  {
    return (num << cnt) | (num >>> (32 - cnt))
  }

  /*
  * These functions implement the four basic operations the algorithm uses.
  */
  function cmn(q, a, b, x, s, t)
  {
    return safe_add(rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b)
  }
  function ff(a, b, c, d, x, s, t)
  {
    return cmn((b & c) | ((~b) & d), a, b, x, s, t)
  }
  function gg(a, b, c, d, x, s, t)
  {
    return cmn((b & d) | (c & (~d)), a, b, x, s, t)
  }
  function hh(a, b, c, d, x, s, t)
  {
    return cmn(b ^ c ^ d, a, b, x, s, t)
  }
  function ii(a, b, c, d, x, s, t)
  {
    return cmn(c ^ (b | (~d)), a, b, x, s, t)
  }

  /*
  * Calculate the MD5 of an array of little-endian words, producing an array
  * of little-endian words.
  */
  function coreMD5(x)
  {
    let a = 1732584193
    let b = -271733879
    let c = -1732584194
    let d = 271733878

    for(let i = 0; i < x.length; i += 16)
    {
      let olda = a
      let oldb = b
      let oldc = c
      let oldd = d

      a = ff(a, b, c, d, x[i+ 0], 7 , -680876936)
      d = ff(d, a, b, c, x[i+ 1], 12, -389564586)
      c = ff(c, d, a, b, x[i+ 2], 17, 606105819)
      b = ff(b, c, d, a, x[i+ 3], 22, -1044525330)
      a = ff(a, b, c, d, x[i+ 4], 7 , -176418897)
      d = ff(d, a, b, c, x[i+ 5], 12, 1200080426)
      c = ff(c, d, a, b, x[i+ 6], 17, -1473231341)
      b = ff(b, c, d, a, x[i+ 7], 22, -45705983)
      a = ff(a, b, c, d, x[i+ 8], 7 , 1770035416)
      d = ff(d, a, b, c, x[i+ 9], 12, -1958414417)
      c = ff(c, d, a, b, x[i+10], 17, -42063)
      b = ff(b, c, d, a, x[i+11], 22, -1990404162)
      a = ff(a, b, c, d, x[i+12], 7 , 1804603682)
      d = ff(d, a, b, c, x[i+13], 12, -40341101)
      c = ff(c, d, a, b, x[i+14], 17, -1502002290)
      b = ff(b, c, d, a, x[i+15], 22, 1236535329)

      a = gg(a, b, c, d, x[i+ 1], 5 , -165796510)
      d = gg(d, a, b, c, x[i+ 6], 9 , -1069501632)
      c = gg(c, d, a, b, x[i+11], 14, 643717713)
      b = gg(b, c, d, a, x[i+ 0], 20, -373897302)
      a = gg(a, b, c, d, x[i+ 5], 5 , -701558691)
      d = gg(d, a, b, c, x[i+10], 9 , 38016083)
      c = gg(c, d, a, b, x[i+15], 14, -660478335)
      b = gg(b, c, d, a, x[i+ 4], 20, -405537848)
      a = gg(a, b, c, d, x[i+ 9], 5 , 568446438)
      d = gg(d, a, b, c, x[i+14], 9 , -1019803690)
      c = gg(c, d, a, b, x[i+ 3], 14, -187363961)
      b = gg(b, c, d, a, x[i+ 8], 20, 1163531501)
      a = gg(a, b, c, d, x[i+13], 5 , -1444681467)
      d = gg(d, a, b, c, x[i+ 2], 9 , -51403784)
      c = gg(c, d, a, b, x[i+ 7], 14, 1735328473)
      b = gg(b, c, d, a, x[i+12], 20, -1926607734)

      a = hh(a, b, c, d, x[i+ 5], 4 , -378558)
      d = hh(d, a, b, c, x[i+ 8], 11, -2022574463)
      c = hh(c, d, a, b, x[i+11], 16, 1839030562)
      b = hh(b, c, d, a, x[i+14], 23, -35309556)
      a = hh(a, b, c, d, x[i+ 1], 4 , -1530992060)
      d = hh(d, a, b, c, x[i+ 4], 11, 1272893353)
      c = hh(c, d, a, b, x[i+ 7], 16, -155497632)
      b = hh(b, c, d, a, x[i+10], 23, -1094730640)
      a = hh(a, b, c, d, x[i+13], 4 , 681279174)
      d = hh(d, a, b, c, x[i+ 0], 11, -358537222)
      c = hh(c, d, a, b, x[i+ 3], 16, -722521979)
      b = hh(b, c, d, a, x[i+ 6], 23, 76029189)
      a = hh(a, b, c, d, x[i+ 9], 4 , -640364487)
      d = hh(d, a, b, c, x[i+12], 11, -421815835)
      c = hh(c, d, a, b, x[i+15], 16, 530742520)
      b = hh(b, c, d, a, x[i+ 2], 23, -995338651)

      a = ii(a, b, c, d, x[i+ 0], 6 , -198630844)
      d = ii(d, a, b, c, x[i+ 7], 10, 1126891415)
      c = ii(c, d, a, b, x[i+14], 15, -1416354905)
      b = ii(b, c, d, a, x[i+ 5], 21, -57434055)
      a = ii(a, b, c, d, x[i+12], 6 , 1700485571)
      d = ii(d, a, b, c, x[i+ 3], 10, -1894986606)
      c = ii(c, d, a, b, x[i+10], 15, -1051523)
      b = ii(b, c, d, a, x[i+ 1], 21, -2054922799)
      a = ii(a, b, c, d, x[i+ 8], 6 , 1873313359)
      d = ii(d, a, b, c, x[i+15], 10, -30611744)
      c = ii(c, d, a, b, x[i+ 6], 15, -1560198380)
      b = ii(b, c, d, a, x[i+13], 21, 1309151649)
      a = ii(a, b, c, d, x[i+ 4], 6 , -145523070)
      d = ii(d, a, b, c, x[i+11], 10, -1120210379)
      c = ii(c, d, a, b, x[i+ 2], 15, 718787259)
      b = ii(b, c, d, a, x[i+ 9], 21, -343485551)

      a = safe_add(a, olda)
      b = safe_add(b, oldb)
      c = safe_add(c, oldc)
      d = safe_add(d, oldd)
    }
    return [a, b, c, d]
  }
  /*
  * Convert an 8-bit character string to a sequence of 16-word blocks, stored
  * as an array, and append appropriate padding for MD4/5 calculation.
  * If any of the characters are >255, the high byte is silently ignored.
  */
  function str2binl(str) {
    let bin = [];
    for (let i = 0; i < str.length * 8; i += 8) {
      bin[i >> 5] |= (str.charCodeAt(i / 8) & 0xFF) << (i % 32);
    }
    return bin;
  }
  
  /*
  * Convert an array of little-endian words to a hex string.
  */
  function binl2hex(binarray){
    let hex_tab = '0123456789abcdef'
    let str = ''
    for(let i = 0; i < binarray.length * 4; i++)
    {
      str += hex_tab.charAt((binarray[i>>2] >> ((i%4)*8+4)) & 0xF) +
              hex_tab.charAt((binarray[i>>2] >> ((i%4)*8)) & 0xF)
    }
    return str
  }
  return binl2hex(coreMD5(str2binl(str))) 
}

