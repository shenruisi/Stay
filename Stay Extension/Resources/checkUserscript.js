


console.log("test checkUserscript")
let userscriptText = document.body.textContent;

let meta = extractMeta(userscriptText).match(/.+/g);

if(meta){
    let url = encodeURIComponent(window.location.href);
    console.log('"stay://x-callback-url/install?scriptURL='+url+'"');
    let stayImg = browser.runtime.getURL("images/icon-256.png");
    let popToastTemp = [
        '<div id="popToast" style="width: 270px;height: 57px;transform: translateX(-50%);border-radius: 16px;background: #fff;position: fixed; bottom: 10;left: 50%;box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;">',
        '<a id="popImg" href="stay://" style="text-decoration: none;width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src=' + stayImg +' style="width: 46px;height: 46px;"></img></a>',
        '<a id="popInstall" href="stay://x-callback-url/install?scriptURL='+url+'" style="font-family:Helvetica Neue;text-decoration: none;display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:center;line-height:23px;">',
        '<div style="font-size: 17px; color: #B620E0;font-weight:700;">Tap to install</div>',
        '<div style="font-size: 13px;color: #000000;">Stay 2 - Local scrip manager</div>',
        '</a>',
        '</div>'
    ];
    let temp = popToastTemp.join("");
    let tempDom = document.createElement("div");
    tempDom.innerHTML = temp;
    document.body.appendChild(tempDom);
}
