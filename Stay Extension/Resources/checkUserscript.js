


console.log("test checkUserscript")
let userscriptText = document.body.textContent;

let meta = extractMeta(userscriptText).match(/.+/g);

if(meta){
    console.log("fint UserScript");
    let url = window.location.href;
    // var iframepush = document.createElement('iframe');
    // iframepush.id = "iframePop";
    // iframepush.name = "iframePop"
    // iframepush.style.position = 'fixed';
    // iframepush.src = browser.runtime.getURL("pop_toast.html");
    // iframepush.style.right = '0px';
    // iframepush.allow = "fullscreen 'src'";
    // iframepush.style.top = '0px';
    // iframepush.style.background = '#fff';
    // iframepush.style.width = '270px';
    // iframepush.style.height = '70px';
    // iframepush.sandbox = "allow-same-origin allow-scripts allow-modals allow-forms allow-popups";
    // document.body.appendChild(iframepush);
    // '<div id="closePop" onclick="javascript:console.log(\'你好啊\')" style="font-size: 13px;color: #979797;line-height:57px;text-align: center;width:40px;">&#215;</div>',
    let stayImg = browser.runtime.getURL("images/icon-256.png");
    let popToastTemp = [
        '<div id="popToast" style="width: 270px;height: 57px;transform: translateX(-50%);border-radius: 16px;background: #fff;position: fixed; bottom: 10;left: 50%;box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;">',
        '<a id="popImg" href="stay://" style="text-decoration: none;width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src=' + stayImg +' style="width: 46px;height: 46px;"></img></a>',
        '<a id="popInstall" href="stay://" style="font-family:Helvetica Neue;text-decoration: none;display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:center;line-height:23px;">',
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
