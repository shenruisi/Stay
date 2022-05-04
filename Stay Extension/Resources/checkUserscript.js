


console.log("test checkUserscript")
let userscriptText = document.body.textContent;

let meta = extractMeta(userscriptText).match(/.+/g);

if(meta){
    console.log("fint UserScript");
    let popToastTemp = [
        '<div id="popToast" style="width: 270px;height: 57px;transform: translateX(-50%);border-radius: 16px;background: #fff;position: fixed; bottom: 10;left: 50%;box-shadow: 0 12px 32px rgba(0, 0, 0, .1), 0 2px 6px rgba(0, 0, 0, .08);display: flex;flex-direction: row;">',
        '<div id="popImg" style="width: 75px;display: flex;flex-direction: row;align-items:center;justify-content: center;justify-items: center;"><img src="./images/icon-128.png" style="width: 46px;height: 46px;"></img></div>',
        '<div id="popInstall" style="display: flex;flex-direction: column;justify-content: center;justify-items: center;align-items:center;line-height:23px;">',
        '<div style="font-size: 17px; color: #B620E0;font-weight:700;">Tap to install</div>',
        '<div style="font-size: 13px;color: #000000;">Stay 2 - Local scrip manager</div>',
        '</div>',
        '<div id="closePop" style="font-size: 13px;color: #979797;line-height:57px;text-align: center;width:40px;">&#215;</div>',
        '</div>'
    ];
    let temp = popToastTemp.join("");
    let tempDom = document.createElement("div");
    tempDom.innerHTML = temp;
    document.body.appendChild(tempDom);
    
    function closePop() {
        document.getElementById("popToast").style.display = none;
    }
    function tapToInstall() {
        console.log("dfsdfsdfsdfsdfsdfs")
        window.open("stay://");
    }

    // document.getElementById("closePop").addEventListener("click", () => { 
    //     console.log("closePop--------")
    //     closePop();
    // });
    // document.getElementById("popInstall").addEventListener("click", () => { 
    //     console.log("popInstall--------")
    //     tapToInstall()
    // });
    // document.getElementById("popImg").addEventListener("click", () => {
    //     console.log("popImg--------")
    //     tapToInstall()
    // });

    let code = `${closePop}\n`;
    code = code + `${tapToInstall}\n`;
    code = code + 'document.getElementById("popImg").addEventListener("click", ()=>{tapToInstall();});\n';
    code = code + 'document.getElementById("popInstall").addEventListener("click", ()=>{tapToInstall();});\n';
    code = code + 'document.getElementById("closePop").addEventListener("click", ()=>{closePop();});\n';
    // code = `(function() {\n${code}\n})();`
    let tag = document.createElement("script");
    tag.type = "text/javascript";
    tag.textContent = code;
    document.body.appendChild(tag);

}
