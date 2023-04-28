
(function(){
  let userscriptText = document.body.textContent;
  function languageCode() {
    let lang = (navigator.languages && navigator.languages.length > 0) ? navigator.languages[0]
      : (navigator.language || navigator.userLanguage /* IE */ || 'en');
    lang = lang.toLowerCase();
    lang = lang.replace(/-/, '_'); // some browsers report language as en-US instead of en_US
    if (lang.length > 3) {
      lang = lang.substring(0, 3) + lang.substring(3).toUpperCase();
    }
    if (lang == 'zh_TW' || lang == 'zh_MO'){
      lang = 'zh_HK'
    }
    return lang;
  }
  let browserLangurage = languageCode()
  // eslint-disable-next-line no-undef
  let meta = extractMeta(userscriptText).match(/.+/g);
  const is_dark = () => {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  }
  if(meta){
    console.log('extractMeta-----extractMeta------extractMeta-------extractMeta');
    let url = encodeURIComponent(window.location.href);
    let stayImg = 'https://res.stayfork.app/scripts/C9E820983D1A897E7B324750858277A0/icon.png';
    let bg = 'background: #fff;';
    let fontColor = 'color: #000000;'
    if (is_dark()) {
      bg = 'background: #000;';
      fontColor = 'color: #F3F3F3;'
    }
    console.log('extractMeta-----extractMeta------extractMeta-------extractMeta-----22222------');
    let schemeUrl = 'stay://x-callback-url/install?scriptURL='+url;
    // eslint-disable-next-line no-undef
    i18nProp = langMessage[browserLangurage] || langMessage['en_US'];
    console.log('extractMeta-----extractMeta------extractMeta-------extractMeta-----33333333333------');
    let popToastTemp = [
      '<div id="popToast" style="width: 270px;height: 57px;transform: translateX(-50%);border-radius: 16px; ' + bg + ' position: fixed; bottom: 10px;left: 50%;box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;">',
      '<a id="popImg" href="' + schemeUrl +'" style="text-decoration: none;width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src=' + stayImg +' style="width: 32px;height: 32px;"></img></a>',
      '<a id="popInstall" href="' + schemeUrl +'" style="font-family:Helvetica Neue;text-decoration: none;display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:center;line-height:23px;">',
      '<div style="font-size: 17px; color: #B620E0;font-weight:700;">Tap to install</div>',
      // eslint-disable-next-line no-undef
      '<div style="font-size: 13px; ' + fontColor +' ">Stay - ' + i18nProp['download_text'] + '</div>',
      '</a>',
      '</div>'
    ];
    let temp = popToastTemp.join('');
    let tempDom = document.createElement('div');
    tempDom.innerHTML = temp;
    document.body.appendChild(tempDom);
    console.log('extractMeta-----extractMeta------extractMeta-------extractMeta--------88888888--------');
  }else{
    console.log('extractMeta---------false');
  }
})()
  
  
  