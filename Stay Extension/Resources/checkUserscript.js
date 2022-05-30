


console.log("test checkUserscript")
let userscriptText = document.body.textContent;

let meta = extractMeta(userscriptText).match(/.+/g);
const is_dark = () => {
    return window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
}
if(meta){
    let url = encodeURIComponent(window.location.href);
    let stayImg = browser.runtime.getURL("images/icon-256.png");
    let bg = "background: #fff;";
    let fontColor = "color: #000000;"
    if (is_dark()) {
        bg = "background: #000;";
        fontColor = "color: #F3F3F3;"
    }
    let schemeUrl = "stay://x-callback-url/install?scriptURL="+url;
    let popToastTemp = [
        '<div id="popToast" style="width: 270px;height: 57px;transform: translateX(-50%);border-radius: 16px; ' + bg + ' position: fixed; bottom: 10;left: 50%;box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;">',
        '<a id="popImg" href="' + schemeUrl +'" style="text-decoration: none;width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src=' + stayImg +' style="width: 46px;height: 46px;"></img></a>',
        '<a id="popInstall" href="' + schemeUrl +'" style="font-family:Helvetica Neue;text-decoration: none;display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:center;line-height:23px;">',
        '<div style="font-size: 17px; color: #B620E0;font-weight:700;">Tap to install</div>',
        '<div style="font-size: 13px; ' + fontColor +' ">Stay 2 - Local scrip manager</div>',
        '</a>',
        '</div>'
    ];
    let temp = popToastTemp.join("");
    let tempDom = document.createElement("div");
    tempDom.innerHTML = temp;
    document.body.appendChild(tempDom);
}
