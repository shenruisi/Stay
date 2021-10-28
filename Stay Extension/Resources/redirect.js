let url;
if (R_E_D_I_R_E_C_T_TEST.test(location.href)) {
    url = decodeURIComponent($getQueryVariable("url")).replace("http:","https:");
}
window.onload = function(){
    if (url){
        let html = document.querySelector('html');
        html.innerHTML = '\
        <body style="margin:0px;padding:0px;overflow:hidden">\
            <iframe \
        src='+url+' frameborder="0" style="overflow:hidden;height:100vh;width:100%" height="100vh" width="100%"></iframe>\
        </body>';
    }
}
