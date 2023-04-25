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
  let Agents = ['Android', 'iPhone', 'SymbianOS', 'Windows Phone', 'iPod', 'iPad'];
  let getArr = Agents.filter(i => userAgentInfo.includes(i));
  return getArr.length ? true : false;
}

